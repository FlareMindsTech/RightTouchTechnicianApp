import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/config/api_config.dart';
import 'package:http_parser/http_parser.dart';
import 'package:right_touch/core/network/network_provider.dart';

class JobRepository {
  final DioClient _client;

  // Instance memory cache: Map<Key, List<dynamic>> with LRU eviction
  final Map<String, List<dynamic>> _cache = {};
  final Map<String, DateTime> _cacheTime = {};
  static const _cacheDuration = Duration(minutes: 5);
  static const int _maxCacheEntries = 20;

  JobRepository(this._client);

  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final timestamp = _cacheTime[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  void _putCache(String key, List<dynamic> data) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
      _cacheTime.remove(key);
    } else if (_cache.length >= _maxCacheEntries) {
      final oldestKey = _cacheTime.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _cache.remove(oldestKey);
      _cacheTime.remove(oldestKey);
    }
    _cache[key] = data;
    _cacheTime[key] = DateTime.now();
  }

  Future<List<dynamic>> getNearbyJobs(
    double lat,
    double lng, {
    bool forceRefresh = false,
  }) async {
    // Quantize GPS coordinates to ~2 decimal places (~1.1km grid) to prevent jitter cache explosion
    final quantizedLat = lat.toStringAsFixed(2);
    final quantizedLng = lng.toStringAsFixed(2);
    final cacheKey = 'nearby_${quantizedLat}_$quantizedLng';

    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _client.get(
        ApiConfig.nearbyJobsEndpoint,
        queryParameters: {'latitude': lat, 'longitude': lng},
      );
      final raw = response.data;
      final data = (raw is Map)
          ? (raw['result'] ?? raw['jobs'] ?? raw['data'] ?? [])
          : (raw is List ? raw : []);

      final listData = data is List ? data : [];
      _putCache(cacheKey, listData);
      return listData;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch nearby jobs'));
    }
  }

  Future<List<dynamic>> getBroadcastJobs({bool forceRefresh = false}) async {
    const cacheKey = 'broadcast_jobs';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _client.get(ApiConfig.myBroadcastJobsEndpoint);
      final raw = response.data;
      final data = (raw is Map)
          ? (raw['result'] ?? raw['jobs'] ?? raw['data'] ?? [])
          : (raw is List ? raw : []);

      final listData = data is List ? data : [];
      _putCache(cacheKey, listData);
      return listData;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch jobs'));
    }
  }

  Future<List<dynamic>> getCurrentJobs({bool forceRefresh = false}) async {
    const cacheKey = 'current_jobs';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _client.get(ApiConfig.currentJobsEndpoint);
      final data = response.data;
      List<dynamic> jobs = [];
      if (data != null) {
        if (data is List) {
          jobs = data;
        } else if (data is Map) {
          jobs = data['result'] ?? data['jobs'] ?? data['data'] ?? [];
        }
      }

      _cache[cacheKey] = jobs;
      _cacheTime[cacheKey] = DateTime.now();
      return jobs;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch current jobs'));
    }
  }

  Future<Map<String, dynamic>> respondToJob(String jobId, String status) async {
    try {
      final response = await _client.put(
        ApiConfig.respondJobBroadcastEndpoint(jobId),
        data: {'status': status},
      );
      // Invalidate relevant caches
      _cache.remove('broadcast_jobs');
      _cache.remove('current_jobs');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to respond to job'));
    }
  }

  Future<Map<String, dynamic>> updateJobStatus(
    String jobId,
    String status, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await _client.put(
        '/api/technician/status/$jobId',
        data: {'status': status, ...?additionalData},
      );
      // Invalidate caches
      _cache.remove('current_jobs');
      _cache.remove('job_history');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to update job status'));
    }
  }

  Future<List<dynamic>> getJobHistory({bool forceRefresh = false}) async {
    const cacheKey = 'job_history';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _client.get(ApiConfig.jobHistoryEndpoint);
      final data = response.data;
      List<dynamic> jobs = [];
      if (data != null) {
        if (data is List) {
          jobs = data;
        } else if (data is Map) {
          jobs = data['result'] ?? data['jobs'] ?? data['data'] ?? [];
        }
      }

      _cache[cacheKey] = jobs;
      _cacheTime[cacheKey] = DateTime.now();
      return jobs;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch job history'));
    }
  }

  Future<Map<String, dynamic>> uploadWorkImages({
    required String jobId,
    required String beforeImagePath,
    required String afterImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'beforeImage': await MultipartFile.fromFile(
          beforeImagePath,
          contentType: _getMediaType(beforeImagePath),
        ),
        'afterImage': await MultipartFile.fromFile(
          afterImagePath,
          contentType: _getMediaType(afterImagePath),
        ),
      });

      final response = await _client.post(
        ApiConfig.workImagesEndpoint(jobId),
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to upload work images'));
    }
  }

  MediaType? _getMediaType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) return MediaType('image', 'png');
    if (lowerPath.endsWith('.pdf')) return MediaType('application', 'pdf');
    return MediaType('image', 'jpeg');
  }

  void invalidateCache() {
    _cache.clear();
    _cacheTime.clear();
  }

  String _getErrorMessage(DioException e, String fallback) {
    if (e.type != DioExceptionType.badResponse) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet.';
      }
      return 'Unable to connect. Please check your network.';
    }

    final statusCode = e.response?.statusCode ?? 500;
    final responseData = e.response?.data;

    if (statusCode >= 500) {
      return 'Something went wrong on our end. Please try again later.';
    }

    if (responseData is Map) {
      final message = responseData['message']?.toString() ??
          responseData['error']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }

    return fallback;
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return JobRepository(client);
});
