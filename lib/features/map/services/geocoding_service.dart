import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
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

  GeocodingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
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
        return PlaceSearchResult.fromJson(response.data as Map<String, dynamic>);
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
      final jsonList = prefs.getStringList(_recentSearchesKey) ?? [];
      return jsonList
          .map((item) => PlaceSearchResult.fromJson(json.decode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves a search result to the recent searches cache (max 6 items).
  Future<void> saveRecentSearch(PlaceSearchResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var list = await getRecentSearches();
      list.removeWhere((item) =>
          item.displayName == result.displayName ||
          (item.location.latitude == result.location.latitude &&
              item.location.longitude == result.location.longitude));
      list.insert(0, result);
      if (list.length > 6) {
        list = list.sublist(0, 6);
      }
      final jsonList = list.map((item) => json.encode(item.toJson())).toList();
      await prefs.setStringList(_recentSearchesKey, jsonList);
    } catch (_) {}
  }
}
