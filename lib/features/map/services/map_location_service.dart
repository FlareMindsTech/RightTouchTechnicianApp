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

  /// Fetches a one-time high-accuracy position.
  Future<LatLng?> getCurrentPosition() async {
    try {
      final state = await requestPermissions();
      if (state != LocationPermissionState.granted) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      currentLocation.value = latLng;
      currentHeading.value = position.heading;
      currentAccuracy.value = position.accuracy;
      return latLng;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error fetching location: $e');
      }
      return null;
    }
  }

  /// Starts listening to active location updates for navigation or live map tracking.
  void startLocationUpdates({
    required Function(LatLng position, double heading, double accuracy) onUpdate,
    int distanceFilterMeters = 5,
  }) {
    stopLocationUpdates();
    isTrackingActive.value = true;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (pos) {
        final latLng = LatLng(pos.latitude, pos.longitude);
        currentLocation.value = latLng;
        currentHeading.value = pos.heading;
        currentAccuracy.value = pos.accuracy;
        onUpdate(latLng, pos.heading, pos.accuracy);
      },
      onError: (err) {
        if (kDebugMode) {
          debugPrint('⚠️ Position stream error: $err');
        }
      },
    );
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
    isTrackingActive.dispose();
  }
}
