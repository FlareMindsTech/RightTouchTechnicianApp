import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/features/map/models/map_theme.dart';
import 'package:right_touch/features/map/models/route_model.dart';
import 'package:right_touch/features/map/services/routing_service.dart';
import 'package:right_touch/features/map/services/geocoding_service.dart';
import 'package:right_touch/features/map/widgets/map_controls_overlay.dart';
import 'package:right_touch/features/map/widgets/route_info_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Map Themes Tests', () {
    test('Verifies themes are configured with compliant attributions', () {
      final themes = AppMapTheme.availableThemes;
      expect(themes.length, 2);

      final streetTheme = AppMapTheme.getTheme(MapThemeType.streets);
      expect(streetTheme.urlTemplate.isNotEmpty, true);
      expect(streetTheme.attribution.contains('OpenStreetMap'), true);

      final satelliteTheme = AppMapTheme.getTheme(MapThemeType.satellite);
      expect(satelliteTheme.urlTemplate.contains('satellite') || satelliteTheme.urlTemplate.contains('arcgisonline'), true);
    });
  });

  group('Route Models and Calculation Tests', () {
    test('RouteData formatting formats distance and duration correctly', () {
      const route1 = RouteData(
        points: [LatLng(13.0, 80.0), LatLng(13.1, 80.1)],
        distanceMeters: 4500,
        durationSeconds: 720,
        travelMode: TravelMode.driving,
      );

      expect(route1.distanceFormatted, '4.5 km');
      expect(route1.durationFormatted, '12 min');

      const route2 = RouteData(
        points: [LatLng(13.0, 80.0), LatLng(13.001, 80.001)],
        distanceMeters: 350,
        durationSeconds: 3900,
        travelMode: TravelMode.walking,
      );

      expect(route2.distanceFormatted, '350 m');
      expect(route2.durationFormatted, '1h 5m');
    });

    test('RoutingService off-route detection detects diverged coordinates', () {
      final route = [
        const LatLng(13.0000, 80.0000),
        const LatLng(13.0100, 80.0000),
        const LatLng(13.0200, 80.0000),
      ];

      // Point directly on the route line
      const onRoutePoint = LatLng(13.0050, 80.0000);
      expect(
        RoutingService.isOffRoute(
          currentLocation: onRoutePoint,
          routePoints: route,
          thresholdMeters: 50.0,
        ),
        false,
      );

      // Point significantly deviated (~2 km away)
      const offRoutePoint = LatLng(13.0050, 80.0200);
      expect(
        RoutingService.isOffRoute(
          currentLocation: offRoutePoint,
          routePoints: route,
          thresholdMeters: 60.0,
        ),
        true,
      );
    });

    test('RouteStep parses maneuver and creates human-readable instructions', () {
      final json = {
        'name': 'Mount Road',
        'distance': 500.0,
        'duration': 60.0,
        'maneuver': {
          'type': 'turn',
          'modifier': 'right',
          'location': [80.2707, 13.0827]
        }
      };

      final step = RouteStep.fromJson(json);
      expect(step.streetName, 'Mount Road');
      expect(step.instruction, 'Turn right onto Mount Road');
      expect(step.location.latitude, 13.0827);
      expect(step.location.longitude, 80.2707);
    });
  });

  group('Geocoding Parsing Tests', () {
    test('PlaceSearchResult parses displayName and title cleanly', () {
      final json = {
        'display_name': 'T. Nagar, Chennai, Tamil Nadu, 600017, India',
        'lat': '13.0418',
        'lon': '80.2341',
        'class': 'place',
        'type': 'suburb',
      };

      final result = PlaceSearchResult.fromJson(json);
      expect(result.title, 'T. Nagar');
      expect(result.location.latitude, 13.0418);
      expect(result.location.longitude, 80.2341);
    });
  });

  group('Map Widgets Tests', () {
    testWidgets('RouteInfoBottomSheet renders metrics and trigger buttons', (tester) async {
      bool navStarted = false;
      bool recalculated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteInfoBottomSheet(
              routeData: const RouteData(
                points: [LatLng(13.0, 80.0), LatLng(13.1, 80.1)],
                distanceMeters: 2500,
                durationSeconds: 600,
                travelMode: TravelMode.driving,
              ),
              isNavigating: false,
              isLoadingRoute: false,
              isOffRoute: false,
              destinationTitle: 'AC Repair Service',
              destinationAddress: '12 Main Street, Chennai',
              customerPhone: '9876543210',
              onStartNavigation: () => navStarted = true,
              onStopNavigation: () {},
              onRecalculateRoute: () => recalculated = true,
            ),
          ),
        ),
      );

      expect(find.text('AC Repair Service'), findsOneWidget);
      expect(find.text('12 Main Street, Chennai'), findsOneWidget);
      expect(find.text('2.5 km'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);
      expect(find.text('Start Navigation'), findsOneWidget);

      await tester.tap(find.text('Start Navigation'));
      await tester.pump();
      expect(navStarted, true);

      await tester.tap(find.byTooltip('Recalculate route'));
      await tester.pump();
      expect(recalculated, true);
    });

    testWidgets('MapControlsOverlay renders zoom, recenter, and theme buttons', (tester) async {
      bool zoomInTapped = false;
      bool recenterTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MapControlsOverlay(
                onZoomIn: () => zoomInTapped = true,
                onZoomOut: () {},
                onRecenter: () => recenterTapped = true,
                onResetCompass: () {},
                currentRotation: 0.0,
                isTrackingUser: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byIcon(Icons.layers_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(zoomInTapped, true);

      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump();
      expect(recenterTapped, true);
    });
  });
}
