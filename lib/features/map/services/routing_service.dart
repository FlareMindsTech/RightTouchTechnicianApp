import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/config/api_config.dart';
import 'package:right_touch/features/map/models/route_model.dart';

class RoutingService {
  final Dio _dio;
  static const String _primaryOsrmUrl = 'https://router.project-osrm.org';
  static const String _fallbackOsrmUrl = 'https://routing.openstreetmap.de/routed-car';

  RoutingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                headers: {
                  'User-Agent': 'RightTouchTechnicianApp/2.0 (partner-support@righttouch.com)'
                },
              ),
            );

  Future<RouteData?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    final profile = mode == TravelMode.driving
        ? 'driving'
        : (mode == TravelMode.cycling ? 'bike' : 'foot');

    // 1. Try MapTiler Directions (if key available) or Primary OSRM
    RouteData? route = await _fetchFromOsrm(
      baseUrl: _primaryOsrmUrl,
      origin: origin,
      destination: destination,
      profile: profile,
      mode: mode,
    );

    // 2. If primary fails, try fallback OSRM mirror
    if (route == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Primary routing failed. Attempting fallback routing server...');
      }
      route = await _fetchFromOsrm(
        baseUrl: _fallbackOsrmUrl,
        origin: origin,
        destination: destination,
        profile: profile,
        mode: mode,
      );
    }

    // 3. Fallback: Offline Geodesic Route Interpolation
    // If technician has no cell connectivity, provide a direct navigation line
    // with accurate geodesic distance and estimated duration rather than failing.
    route ??= _createOfflineFallbackRoute(
      origin: origin,
      destination: destination,
      mode: mode,
    );

    return route;
  }

  Future<RouteData?> _fetchFromOsrm({
    required String baseUrl,
    required LatLng origin,
    required LatLng destination,
    required String profile,
    required TravelMode mode,
  }) async {
    try {
      final url =
          '$baseUrl/route/v1/$profile/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

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
        debugPrint('⚠️ Routing request failed on $baseUrl: $e');
      }
    }
    return null;
  }

  /// Generates a straight direct trajectory for offline scenarios.
  RouteData _createOfflineFallbackRoute({
    required LatLng origin,
    required LatLng destination,
    required TravelMode mode,
  }) {
    const distanceCalc = Distance();
    final distanceMeters = distanceCalc.as(LengthUnit.Meter, origin, destination);

    // Approximate average city speeds:
    // Driving: 30 km/h (8.33 m/s)
    // Cycling: 15 km/h (4.16 m/s)
    // Walking: 4.5 km/h (1.25 m/s)
    final double speedMps = switch (mode) {
      TravelMode.driving => 8.33,
      TravelMode.cycling => 4.16,
      TravelMode.walking => 1.25,
    };

    final durationSeconds = (distanceMeters / speedMps).clamp(60.0, 86400.0);

    return RouteData(
      points: [origin, destination],
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      travelMode: mode,
      steps: [
        RouteStep(
          instruction: 'Proceed directly toward destination',
          distanceMeters: distanceMeters,
          durationSeconds: durationSeconds,
          streetName: 'Direct Path',
          location: origin,
          type: 'depart',
          modifier: 'straight',
        ),
      ],
    );
  }

  /// Calculates the shortest distance in meters from a [point] to a polyline segment [p1]-[p2].
  static double distanceToSegment(LatLng point, LatLng p1, LatLng p2) {
    const distanceCalc = Distance();
    final d13 = distanceCalc.as(LengthUnit.Meter, p1, point);
    final d23 = distanceCalc.as(LengthUnit.Meter, p2, point);
    final d12 = distanceCalc.as(LengthUnit.Meter, p1, p2);

    if (d12 == 0) return d13;

    // Projection calculation using planar approximation for short segments
    final latDelta = p2.latitude - p1.latitude;
    final lngDelta = p2.longitude - p1.longitude;
    final u = ((point.latitude - p1.latitude) * latDelta +
            (point.longitude - p1.longitude) * lngDelta) /
        (latDelta * latDelta + lngDelta * lngDelta);

    if (u <= 0.0) return d13;
    if (u >= 1.0) return d23;

    final projLat = p1.latitude + u * latDelta;
    final projLng = p1.longitude + u * lngDelta;
    return distanceCalc.as(LengthUnit.Meter, point, LatLng(projLat, projLng));
  }

  /// Checks if [currentLocation] has deviated more than [thresholdMeters] from [routePoints].
  static bool isOffRoute({
    required LatLng currentLocation,
    required List<LatLng> routePoints,
    double thresholdMeters = 60.0,
  }) {
    if (routePoints.isEmpty) return false;
    if (routePoints.length == 1) {
      const dist = Distance();
      return dist.as(LengthUnit.Meter, currentLocation, routePoints.first) > thresholdMeters;
    }

    double minDistance = double.infinity;
    for (int i = 0; i < routePoints.length - 1; i++) {
      final d = distanceToSegment(currentLocation, routePoints[i], routePoints[i + 1]);
      if (d < minDistance) {
        minDistance = d;
      }
      if (minDistance <= thresholdMeters) return false;
    }

    return minDistance > thresholdMeters;
  }
}
