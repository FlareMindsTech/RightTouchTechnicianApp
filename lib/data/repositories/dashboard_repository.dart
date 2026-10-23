import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/config/api_config.dart';
import 'package:right_touch/core/network/network_provider.dart';

class DashboardRepository {
  final DioClient _client;

  // Simple memory cache
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTime = {};
  static const _cacheDuration = Duration(minutes: 5);

  DashboardRepository(this._client);

  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final timestamp = _cacheTime[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  Future<Map<String, dynamic>> getWalletBalance({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'wallet_balance';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _client.get('/api/technician/wallet');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return {'balance': 0, 'pending': 0};
      }
      _cache[cacheKey] = data;
      _cacheTime[cacheKey] = DateTime.now();
      return data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch wallet data'));
    }
  }

  Future<Map<String, dynamic>> getWalletTransactions({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'wallet_transactions';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _client.get('/api/technician/wallet/transactions');
      final data = response.data;
      if (data is! Map) {
        return {'success': false, 'transactions': [], 'withdrawRequests': []};
      }
      final result = {
        'success': true,
        'transactions': (data['result'] is List)
            ? data['result']
            : (data['result'] is Map
                ? (data['result']['transactions'] ?? [])
                : (data['transactions'] ?? [])),
        'withdrawRequests': (data['result'] is Map)
            ? (data['result']['withdrawRequests'] ?? [])
            : (data['withdrawRequests'] ?? []),
      };

      _cache[cacheKey] = result;
      _cacheTime[cacheKey] = DateTime.now();
      return result;
    } on DioException catch (e) {
      throw Exception(
        _getErrorMessage(e, 'Failed to fetch wallet transactions'),
      );
    }
  }

  Future<List<dynamic>> getWalletHistory({bool forceRefresh = false}) async {
    const cacheKey = 'wallet_history';
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _client.get(ApiConfig.walletHistoryEndpoint);
      final data = response.data;
      if (data is! Map) {
        return [];
      }
      final history = data['result'] ?? data['history'] ?? [];
      final listResult = history is List ? history : [];

      _cache[cacheKey] = listResult;
      _cacheTime[cacheKey] = DateTime.now();
      return listResult;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch wallet history'));
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal(double amount) async {
    try {
      final response = await _client.post(
        ApiConfig.withdrawFundEndpoint,
        data: {'amount': amount},
      );
      // Invalidate wallet caches
      invalidateCache();
      if (response.data is! Map<String, dynamic>) {
        return {'success': false};
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to request withdrawal'));
    }
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

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return DashboardRepository(client);
});
