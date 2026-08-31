import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:right_touch/services/auth_service.dart';
import 'package:right_touch/services/socket_service.dart';
import 'package:right_touch/widgets/location_permission_dialog.dart';
import 'package:right_touch/core/routing/app_router.dart';
import 'package:right_touch/providers/socket_provider.dart';

final locationServiceProvider = Provider<LocationTrackingService>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  final service = LocationTrackingService(socketService: socketService);
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class LocationTrackingService with WidgetsBindingObserver {
  Timer? _timer;
  final AuthService _authService = AuthService();
  final SocketService _socketService;
  bool _isTracking = false;

  LocationTrackingService({required SocketService socketService})
      : _socketService = socketService {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Stop timer when app goes to background
      _stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      // Restart timer if we were supposed to be tracking
      if (_isTracking) {
        _startTimer();
      }
    }
  }

  Future<void> startTracking() async {
    if (_isTracking) return;

    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        debugPrint('Location services are disabled.');
      }
      // Attempt to open settings to enable location services
      await Geolocator.openLocationSettings();
      // Re-check after returning from settings (best effort)
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }
    }

    ph.PermissionStatus status = await ph.Permission.location.status;

    if (status.isDenied) {
      status = await ph.Permission.location.request();
      if (status.isDenied) {
        if (kDebugMode) {
          debugPrint('Location permissions are denied');
        }
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      if (kDebugMode) {
        debugPrint('Location permissions are permanently denied');
      }
      _showPermissionDialog();
      return;
    }

    if (!status.isGranted && !status.isLimited) {
      return;
    }

    _isTracking = true;

    // Ensure auth token is loaded from storage so that API calls can succeed
    await _authService.loadToken();

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel existing if any
    // Use a conservative 10-minute interval for REST persistence.
    // Real-time tracking is handled via Socket.IO emit.
    _timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      await _updateLocation();
    });
    // Immediately update once when starting
    _updateLocation();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Update profile with location coordinates via REST
      await _authService.updateProfile({
        'location': {
          'coordinates': [position.longitude, position.latitude],
          'type': 'Point',
        },
        'lastLocationUpdate': DateTime.now().toIso8601String(),
      });

      // Emit via Socket.IO for real-time updates (uses Riverpod-managed service)
      _socketService.updateLocation(
        position.latitude,
        position.longitude,
      );

      if (kDebugMode) {
        debugPrint(
          '✅ Location updated: ${position.latitude}, ${position.longitude}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending location: $e');
      }
    }
  }

  void _showPermissionDialog() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => const LocationPermissionDialog(),
      );
    }
  }

  void stopTracking() {
    _stopTimer();
    _isTracking = false;
  }
}
