import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:right_touch/config/api_config.dart';

/// Connection state for the socket.
enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class SocketService {
  io.Socket? _socket;
  bool _listenersRegistered = false;

  /// Observable connection state for providers to watch.
  final ValueNotifier<SocketConnectionState> connectionState =
      ValueNotifier(SocketConnectionState.disconnected);

  // ─── Event Callbacks ───────────────────────────────────────────────
  Function(Map<String, dynamic>)? onNewJob;
  Function(String)? onJobTaken;
  Function(List<dynamic>)? onJobsListReceived;
  Function(Map<String, dynamic>)? onStatusUpdate;
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;

  bool get isConnected => _socket?.connected ?? false;

  // ─── Connect ──────────────────────────────────────────────────────
  void connect(String token) {
    // Already connected — nothing to do
    if (_socket != null && _socket!.connected) return;

    // If a stale socket exists, clean it up first
    if (_socket != null) {
      _removeAllListeners();
      _socket!.disconnect();
      _socket = null;
      _listenersRegistered = false;
    }

    final socketUrl = ApiConfig.baseUrl;
    _log('🔌 Connecting to Socket.IO at $socketUrl');

    connectionState.value = SocketConnectionState.connecting;

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setAuth({'token': token, 'Authorization': 'Bearer $token'})
          .build(),
    );

    _registerListeners();
    _socket!.connect();
  }

  // ─── Register Listeners (once per socket instance) ────────────────
  void _registerListeners() {
    if (_listenersRegistered || _socket == null) return;
    _listenersRegistered = true;

    // --- Connection lifecycle events ---

    _socket!.onConnect((_) {
      _log('✅ Connected to Socket.IO Server');
      connectionState.value = SocketConnectionState.connected;
      try {
        onConnected?.call();
      } catch (e) {
        _log('❌ Error in onConnected callback: $e');
      }
    });

    _socket!.onDisconnect((_) {
      _log('❌ Disconnected from Socket.IO Server');
      connectionState.value = SocketConnectionState.disconnected;
      try {
        onDisconnected?.call();
      } catch (e) {
        _log('❌ Error in onDisconnected callback: $e');
      }
    });

    _socket!.on('reconnecting', (_) {
      _log('🔄 Reconnecting to Socket.IO...');
      connectionState.value = SocketConnectionState.reconnecting;
    });

    _socket!.on('reconnect', (_) {
      _log('✅ Reconnected to Socket.IO Server');
      connectionState.value = SocketConnectionState.connected;
      try {
        onConnected?.call();
      } catch (e) {
        _log('❌ Error in onConnected (reconnect) callback: $e');
      }
    });

    _socket!.on('reconnect_error', (err) {
      _log('⚠️ Socket Reconnection Error: $err');
    });

    _socket!.on('reconnect_failed', (_) {
      _log('🚫 Socket Reconnection Failed after max attempts');
      connectionState.value = SocketConnectionState.disconnected;
    });

    _socket!.onConnectError((err) {
      _log('⚠️ Socket Connection Error: $err');
    });

    _socket!.onError((err) {
      _log('❌ Socket Error: $err');
    });

    // --- Business events ---

    // A. New Job broadcast
    _socket!.on('job:new', (data) {
      _log('🔔 New Job Alert: ${data is Map ? data['serviceName'] : data}');
      try {
        if (onNewJob != null && data != null) {
          onNewJob!(Map<String, dynamic>.from(data));
        }
      } catch (e) {
        _log('❌ Error handling job:new: $e');
      }
    });

    // B. Job taken by another technician
    _socket!.on('job:taken', (data) {
      try {
        final bookingId =
            data is Map ? data['bookingId']?.toString() : data?.toString();
        _log('🚫 Job taken by another tech: $bookingId');
        if (bookingId != null && onJobTaken != null) {
          onJobTaken!(bookingId);
        }
      } catch (e) {
        _log('❌ Error handling job:taken: $e');
      }
    });

    // C. Jobs list received
    _socket!.on('technician:jobs_list', (data) {
      _log('📦 Received jobs list: ${data is List ? data.length : 'N/A'}');
      try {
        if (onJobsListReceived != null && data != null) {
          onJobsListReceived!(List<dynamic>.from(data));
        }
      } catch (e) {
        _log('❌ Error handling technician:jobs_list: $e');
      }
    });

    // D. Status updates (admin acceptance, payments, etc.)
    _socket!.on('technician:status_update', (data) {
      _log('🆕 Technician Status Update: $data');
      try {
        if (onStatusUpdate != null && data != null) {
          onStatusUpdate!(Map<String, dynamic>.from(data));
        }
      } catch (e) {
        _log('❌ Error handling technician:status_update: $e');
      }
    });
  }

  // ─── Remove All Listeners ─────────────────────────────────────────
  void _removeAllListeners() {
    if (_socket == null) return;
    _socket!.off('job:new');
    _socket!.off('job:taken');
    _socket!.off('technician:jobs_list');
    _socket!.off('technician:status_update');
    _socket!.clearListeners();
    _listenersRegistered = false;
  }

  // ─── Disconnect ───────────────────────────────────────────────────
  void disconnect() {
    _removeAllListeners();
    _socket?.disconnect();
    _socket = null;
    _listenersRegistered = false;
    connectionState.value = SocketConnectionState.disconnected;
    _log('🔌 Socket disconnected and cleaned up');
  }

  // ─── Emit: Location Update ────────────────────────────────────────
  void updateLocation(double lat, double lng) {
    if (_socket?.connected ?? false) {
      _socket!.emit('technician:location_update', {
        'latitude': lat,
        'longitude': lng,
      });
      _log('📍 Emitted location update: $lat, $lng');
    }
  }

  // ─── Emit: Request Jobs Feed ──────────────────────────────────────
  void requestJobs() {
    if (_socket?.connected ?? false) {
      _socket!.emit('technician:get_jobs');
      _log('🔄 Requested live jobs feed');
    }
  }

  // ─── Full Dispose (called by Riverpod onDispose) ──────────────────
  void dispose() {
    disconnect();
    connectionState.dispose();
  }

  // ─── Debug Logger ─────────────────────────────────────────────────
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[SocketService] $message');
    }
  }
}
