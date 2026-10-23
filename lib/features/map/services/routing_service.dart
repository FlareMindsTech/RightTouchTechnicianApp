import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/features/map/models/route_model.dart';

class RoutingService {
  final Dio _dio;
  static const String _osrmBaseUrl = 'https://router.project-osrm.org';

  RoutingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'User-Agent': 'RightTouchTechnicianApp/2.0 (contact@righttouch.com)'
                },
              ),
            );

  Future<RouteData?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    try {
      final profile = mode == TravelMode.driving
          ? 'driving'
          : (mode == TravelMode.cycling ? 'bike' : 'foot');

      final url =
          '$_osrmBaseUrl/route/v1/$profile/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

      final response = await _dio.get(
        url,
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'true',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final primaryRoute = routes.first as Map<String, dynamic>;
          final geometry = primaryRoute['geometry'] as Map<String, dynamic>?;
          final coordinates = geometry?['coordinates'] as List<dynamic>? ?? [];

          final points = coordinates.map((coord) {
            final pair = coord as List<dynamic>;
            return LatLng(
              (pair[1] as num).toDouble(),
              (pair[0] as num).toDouble(),
            );
          }).toList();

          final distance = (primaryRoute['distance'] as num?)?.toDouble() ?? 0.0;
          final duration = (primaryRoute['duration'] as num?)?.toDouble() ?? 0.0;

          // Parse steps from legs
          final List<RouteStep> steps = [];
          final legs = primaryRoute['legs'] as List<dynamic>?;
          if (legs != null && legs.isNotEmpty) {
            for (final leg in legs) {
              final rawSteps = (leg as Map<String, dynamic>)['steps'] as List<dynamic>?;
              if (rawSteps != null) {
                for (final step in rawSteps) {
                  steps.add(RouteStep.fromJson(step as Map<String, dynamic>));
                }
              }
            }
          }

          return RouteData(
            points: points,
            distanceMeters: distance,
            durationSeconds: duration,
            travelMode: mode,
            steps: steps,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Routing error: $e');
      }
    }
    return null;
  }

  /// Calculates the shortest distance in meters from a [point] to a polyline segment [p1]-[p2].
  static double distanceToSegment(LatLng point, LatLng p1, LatLng p2) {
    const distanceCalc = Distance();
    final d13 = distanceCalc.as(LengthUnit.Meter, p1, point);
    final d23 = distanceCalc.as(LengthUnit.Meter, p2, point);
    final d12 = distanceCalc.as(LengthUnit.Meter, p1, p2);

    if (d12 <= 1.0) return d13;

    // Projection calculation
    final dot = ((point.latitude - p1.latitude) * (p2.latitude - p1.latitude) +
            (point.longitude - p1.longitude) * (p2.longitude - p1.longitude)) /
        (pow(p2.latitude - p1.latitude, 2) + pow(p2.longitude - p1.longitude, 2));

    if (dot <= 0.0) return d13;
    if (dot >= 1.0) return d23;

    final projLat = p1.latitude + dot * (p2.latitude - p1.latitude);
    final projLng = p1.longitude + dot * (p2.longitude - p1.longitude);
    return distanceCalc.as(LengthUnit.Meter, point, LatLng(projLat, projLng));
  }

  /// Checks if [currentLocation] has deviated farther than [thresholdMeters] (default 50m)
  /// from any segment along [routePoints].
  static bool isOffRoute({
    required LatLng currentLocation,
    required List<LatLng> routePoints,
    double thresholdMeters = 60.0,
  }) {
    if (routePoints.length < 2) return false;

    double minDistance = double.infinity;
    for (int i = 0; i < routePoints.length - 1; i++) {
      final dist = distanceToSegment(currentLocation, routePoints[i], routePoints[i + 1]);
      if (dist < minDistance) {
        minDistance = dist;
      }
      if (minDistance <= thresholdMeters) {
        return false;
      }
    }

    return minDistance > thresholdMeters;
  }
}
