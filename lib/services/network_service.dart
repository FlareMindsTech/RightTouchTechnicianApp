import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity status
class NetworkService {
  // Singleton pattern
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Network status notifier
  final ValueNotifier<bool> isConnected = ValueNotifier(true);
  final ValueNotifier<ConnectivityResult> connectionType = ValueNotifier(
    ConnectivityResult.wifi,
  );

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      isConnected.value = false;
      connectionType.value = ConnectivityResult.none;
      return;
    }

    final result = results.first;
    connectionType.value = result;

    // Consider connected if not none
    isConnected.value = result != ConnectivityResult.none;

    if (kDebugMode) {
      debugPrint(
        '🌐 Network Status: ${isConnected.value ? "Connected" : "Disconnected"} ($result)',
      );
    }
  }

  /// Check if device has internet connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result.isNotEmpty && result.first != ConnectivityResult.none;
  }

  /// Get connection type as string
  String get connectionTypeString {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      default:
        return 'No Connection';
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    isConnected.dispose();
    connectionType.dispose();
  }
}
