import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceSearchResult {
  final String displayName;
  final String title;
  final LatLng location;
  final String? category;
  final String? type;

  const PlaceSearchResult({
    required this.displayName,
    required this.title,
    required this.location,
    this.category,
    this.type,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '') ?? 0.0;
    final displayName = json['display_name']?.toString() ?? 'Unknown Location';
    final parts = displayName.split(',');
    final title = parts.isNotEmpty ? parts.first.trim() : displayName;

    return PlaceSearchResult(
      displayName: displayName,
      title: title,
      location: LatLng(lat, lon),
      category: json['class']?.toString(),
      type: json['type']?.toString(),
    );
  }

  factory PlaceSearchResult.fromMapTilerJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final coords = geometry?['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    final lon = (coords[0] as num).toDouble();
    final lat = (coords[1] as num).toDouble();
    final text = json['text']?.toString() ?? 'Unknown Place';
    final placeName = json['place_name']?.toString() ?? text;

    return PlaceSearchResult(
      displayName: placeName,
      title: text,
      location: LatLng(lat, lon),
      category: json['place_type'] is List ? (json['place_type'] as List).firstOrNull?.toString() : null,
      type: 'poi',
    );
  }

  Map<String, dynamic> toJson() => {
        'display_name': displayName,
        'title': title,
        'lat': location.latitude,
        'lon': location.longitude,
        'category': category,
        'type': type,
      };
}

class GeocodingService {
  final Dio _dio;
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const String _recentSearchesKey = 'map_recent_searches_list';

  // In-memory LRU cache for reverse-geocoded coordinates (rounded to ~11m precision)
  static final Map<String, PlaceSearchResult> _reverseCache = {};

  GeocodingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                headers: {
                  'User-Agent': 'RightTouchTechnicianApp/2.0 (partner-support@righttouch.com)',
                  'Accept-Language': 'en',
                },
              ),
            );

  /// Searches for places matching [query] with optional coordinate string parsing.
  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Check if query is raw coordinates like "13.0827, 80.2707"
    final coordRegex = RegExp(r'^([-+]?\d{1,2}(?:\.\d+)?)[,\s]+([-+]?\d{1,3}(?:\.\d+)?)$');
    final match = coordRegex.firstMatch(trimmed);
    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
        final reverse = await reverseGeocode(LatLng(lat, lng));
        if (reverse != null) return [reverse];
        return [
          PlaceSearchResult(
            displayName: '$lat, $lng',
            title: 'Custom Coordinate Pin',
            location: LatLng(lat, lng),
            type: 'coordinates',
          ),
        ];
      }
    }

    // 1. Try MapTiler Geocoding if API key is present
    final mapTilerKey = ApiConfig.mapTilerKey;
    if (mapTilerKey.isNotEmpty) {
      try {
        final response = await _dio.get(
          'https://api.maptiler.com/geocoding/${Uri.encodeComponent(trimmed)}.json',
          queryParameters: {
            'key': mapTilerKey,
            'limit': '5',
          },
        );

        if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final features = response.data['features'] as List<dynamic>? ?? [];
          if (features.isNotEmpty) {
            return features
                .map((f) => PlaceSearchResult.fromMapTilerJson(f as Map<String, dynamic>))
                .where((res) => res.location.latitude != 0.0 || res.location.longitude != 0.0)
                .toList();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ MapTiler geocoding search failed: $e');
        }
      }
    }

    // 2. Fallback to Nominatim
    try {
      final response = await _dio.get(
        '$_nominatimUrl/search',
        queryParameters: {
          'q': trimmed,
          'format': 'json',
          'addressdetails': '1',
          'limit': '5',
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List;
        return list
            .map((item) => PlaceSearchResult.fromJson(item as Map<String, dynamic>))
            .where((res) => res.location.latitude != 0.0 || res.location.longitude != 0.0)
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Geocoding search error: $e');
      }
    }
    return [];
  }

  /// Reverse geocodes a [location] into an address description.
  Future<PlaceSearchResult?> reverseGeocode(LatLng location) async {
    // Check in-memory cache (~10-meter rounding)
    final cacheKey =
        '${location.latitude.toStringAsFixed(4)},${location.longitude.toStringAsFixed(4)}';
    if (_reverseCache.containsKey(cacheKey)) {
      return _reverseCache[cacheKey];
    }

    // 1. Try MapTiler Reverse Geocoding
    final mapTilerKey = ApiConfig.mapTilerKey;
    if (mapTilerKey.isNotEmpty) {
      try {
        final response = await _dio.get(
          'https://api.maptiler.com/geocoding/${location.longitude},${location.latitude}.json',
          queryParameters: {
            'key': mapTilerKey,
            'limit': '1',
          },
        );

        if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final features = response.data['features'] as List<dynamic>? ?? [];
          if (features.isNotEmpty) {
            final result = PlaceSearchResult.fromMapTilerJson(features.first as Map<String, dynamic>);
            _reverseCache[cacheKey] = result;
            return result;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ MapTiler reverse geocode error: $e');
        }
      }
    }

    // 2. Fallback to Nominatim
    try {
      final response = await _dio.get(
        '$_nominatimUrl/reverse',
        queryParameters: {
          'lat': location.latitude.toString(),
          'lon': location.longitude.toString(),
          'format': 'json',
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final result = PlaceSearchResult.fromJson(response.data as Map<String, dynamic>);
        _reverseCache[cacheKey] = result;
        return result;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Reverse geocode error: $e');
      }
    }
    return null;
  }

  /// Retrieves cached recent searches.
  Future<List<PlaceSearchResult>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_recentSearchesKey) ?? [];
      return list
          .map((item) => PlaceSearchResult.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves a [place] to recent searches.
  Future<void> saveRecentSearch(PlaceSearchResult place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_recentSearchesKey) ?? [];
      final encoded = jsonEncode(place.toJson());

      list.removeWhere((item) {
        try {
          final map = jsonDecode(item) as Map<String, dynamic>;
          return map['display_name'] == place.displayName;
        } catch (_) {
          return false;
        }
      });

      list.insert(0, encoded);
      if (list.length > 5) {
        list.removeRange(5, list.length);
      }

      await prefs.setStringList(_recentSearchesKey, list);
    } catch (_) {}
  }
}
