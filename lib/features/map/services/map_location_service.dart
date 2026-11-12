import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum LocationPermissionState {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

class MapLocationService {
  StreamSubscription<Position>? _positionSubscription;
  final ValueNotifier<LatLng?> currentLocation = ValueNotifier<LatLng?>(null);
  final ValueNotifier<double?> currentHeading = ValueNotifier<double?>(null);
  final ValueNotifier<double?> currentAccuracy = ValueNotifier<double?>(null);
  final ValueNotifier<double?> currentSpeedKmh = ValueNotifier<double?>(null);
  final ValueNotifier<bool> isTrackingActive = ValueNotifier<bool>(false);

  /// Checks the current location permission state.
  Future<LocationPermissionState> checkPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionState.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return LocationPermissionState.denied;
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionState.permanentlyDenied;
    }
    return LocationPermissionState.granted;
  }

  /// Requests location permissions.
  Future<LocationPermissionState> requestPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionState.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return LocationPermissionState.denied;
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionState.permanentlyDenied;
    }
    return LocationPermissionState.granted;
  }

  /// Opens system app settings for permanently denied permission.
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  /// Opens system location settings if services are disabled.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Fetches an initial high-accuracy position with instant last-known fallback.
  Future<LatLng?> getCurrentPosition() async {
    try {
      final state = await requestPermissions();
      if (state != LocationPermissionState.granted) return null;

      // 1. Try last known position for instant responsiveness
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        currentLocation.value = latLng;
        currentHeading.value = lastKnown.heading;
        currentAccuracy.value = lastKnown.accuracy;
      }

      // 2. Query fresh GPS position with best navigation accuracy
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _buildLocationSettings(distanceFilterMeters: 0),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      currentLocation.value = latLng;
      currentHeading.value = position.heading;
      currentAccuracy.value = position.accuracy;
      return latLng;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error fetching high-accuracy location: $e');
      }
      return currentLocation.value;
    }
  }

  /// Starts listening to active location updates for navigation or live map tracking.
  void startLocationUpdates({
    required Function(LatLng position, double heading, double accuracy, double speedKmh) onUpdate,
    int distanceFilterMeters = 2,
  }) {
    stopLocationUpdates();
    isTrackingActive.value = true;

    final locationSettings =
        _buildLocationSettings(distanceFilterMeters: distanceFilterMeters);

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (pos) {
        final latLng = LatLng(pos.latitude, pos.longitude);
        final speedKmh = pos.speed > 0 ? (pos.speed * 3.6) : 0.0;
        currentLocation.value = latLng;
        currentHeading.value = pos.heading;
        currentAccuracy.value = pos.accuracy;
        currentSpeedKmh.value = speedKmh;
        onUpdate(latLng, pos.heading, pos.accuracy, speedKmh);
      },
      onError: (err) {
        if (kDebugMode) {
          debugPrint('⚠️ Position stream error: $err');
        }
      },
    );
  }

  /// Builds platform-optimized high accuracy location settings.
  LocationSettings _buildLocationSettings({required int distanceFilterMeters}) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilterMeters,
        intervalDuration: const Duration(milliseconds: 1000),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: distanceFilterMeters,
        pauseLocationUpdatesAutomatically: false,
      );
    } else {
      return LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilterMeters,
      );
    }
  }

  /// Stops active GPS stream to conserve battery.
  void stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    isTrackingActive.value = false;
  }

  void dispose() {
    stopLocationUpdates();
    currentLocation.dispose();
    currentHeading.dispose();
    currentAccuracy.dispose();
    currentSpeedKmh.dispose();
    isTrackingActive.dispose();
  }
}
