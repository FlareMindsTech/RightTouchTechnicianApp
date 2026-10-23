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
  void Function(Map<String, dynamic>)? onJobNew;
  void Function(Map<String, dynamic>)? onJobExpired;
  VoidCallback? onJobsChanged;
  void Function(Map<String, dynamic>)? onTravelReminder;
  void Function(Map<String, dynamic>)? onJobCancelled;
  void Function(Map<String, dynamic>)? onPaymentReceived;
  void Function(Map<String, dynamic>)? onPayoutPaid;
  void Function(Map<String, dynamic>)? onWithdrawalFailed;
  void Function(Map<String, dynamic>)? onPermissionChanged;
  void Function(Map<String, dynamic>)? onComplaintFiled;
  void Function(Map<String, dynamic>)? onClawbackApplied;

  // Legacy/Compatibility callbacks
  void Function(Map<String, dynamic>)? get onNewJob => onJobNew;
  set onNewJob(void Function(Map<String, dynamic>)? fn) => onJobNew = fn;
  void Function(String)? onJobTaken;
  void Function(List<dynamic>)? onJobsListReceived;
  void Function(Map<String, dynamic>)? onStatusUpdate;
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;

  bool get isConnected => _socket?.connected ?? false;

  // ─── Connect ──────────────────────────────────────────────────────
  void connect(
    String token, {
    void Function(Map<String, dynamic>)? onJobNew,
    void Function(Map<String, dynamic>)? onJobExpired,
    VoidCallback? onJobsChanged,
    void Function(Map<String, dynamic>)? onTravelReminder,
    void Function(Map<String, dynamic>)? onJobCancelled,
    void Function(Map<String, dynamic>)? onPaymentReceived,
    void Function(Map<String, dynamic>)? onPayoutPaid,
    void Function(Map<String, dynamic>)? onWithdrawalFailed,
    void Function(Map<String, dynamic>)? onPermissionChanged,
    void Function(Map<String, dynamic>)? onComplaintFiled,
    void Function(Map<String, dynamic>)? onClawbackApplied,
    void Function(String)? onJobTaken,
    void Function(List<dynamic>)? onJobsListReceived,
    void Function(Map<String, dynamic>)? onStatusUpdate,
    VoidCallback? onConnected,
    VoidCallback? onDisconnected,
  }) {
    if (onJobNew != null) this.onJobNew = onJobNew;
    if (onJobExpired != null) this.onJobExpired = onJobExpired;
    if (onJobsChanged != null) this.onJobsChanged = onJobsChanged;
    if (onTravelReminder != null) this.onTravelReminder = onTravelReminder;
    if (onJobCancelled != null) this.onJobCancelled = onJobCancelled;
    if (onPaymentReceived != null) this.onPaymentReceived = onPaymentReceived;
    if (onPayoutPaid != null) this.onPayoutPaid = onPayoutPaid;
    if (onWithdrawalFailed != null) this.onWithdrawalFailed = onWithdrawalFailed;
    if (onPermissionChanged != null) this.onPermissionChanged = onPermissionChanged;
    if (onComplaintFiled != null) this.onComplaintFiled = onComplaintFiled;
    if (onClawbackApplied != null) this.onClawbackApplied = onClawbackApplied;
    if (onJobTaken != null) this.onJobTaken = onJobTaken;
    if (onJobsListReceived != null) this.onJobsListReceived = onJobsListReceived;
    if (onStatusUpdate != null) this.onStatusUpdate = onStatusUpdate;
    if (onConnected != null) this.onConnected = onConnected;
    if (onDisconnected != null) this.onDisconnected = onDisconnected;

    final existingSocket = _socket;
    // Already connected — nothing to do
    if (existingSocket != null && existingSocket.connected) return;

    // If a stale socket exists, clean it up first
    if (existingSocket != null) {
      _removeAllListeners();
      existingSocket.disconnect();
      _socket = null;
      _listenersRegistered = false;
    }

    final socketUrl = ApiConfig.baseUrl;
    _log('🔌 Connecting to Socket.IO at $socketUrl');

    connectionState.value = SocketConnectionState.connecting;

    final newSocket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setAuth({'token': token, 'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket = newSocket;
    _registerListeners();
    newSocket.connect();
  }

  // ─── Register Listeners (once per socket instance) ────────────────
  void _registerListeners() {
    final socket = _socket;
    if (_listenersRegistered || socket == null) return;
    _listenersRegistered = true;

    // --- Connection lifecycle events ---

    socket.onConnect((_) {
      _log('🟢 Socket connected');
      connectionState.value = SocketConnectionState.connected;
      try {
        onConnected?.call();
      } catch (e) {
        _log('❌ Error in onConnected callback: $e');
      }
    });

    socket.onDisconnect((reason) {
      _log('🔴 Socket disconnected: $reason');
      connectionState.value = SocketConnectionState.disconnected;
      try {
        onDisconnected?.call();
      } catch (e) {
        _log('❌ Error in onDisconnected callback: $e');
      }
    });

    socket.on('reconnecting', (_) {
      _log('🔄 Reconnecting to Socket.IO...');
      connectionState.value = SocketConnectionState.reconnecting;
    });

    socket.on('reconnect', (_) {
      _log('✅ Reconnected to Socket.IO Server');
      connectionState.value = SocketConnectionState.connected;
      try {
        onConnected?.call();
      } catch (e) {
        _log('❌ Error in onConnected (reconnect) callback: $e');
      }
    });

    socket.on('reconnect_error', (err) {
      _log('⚠️ Socket Reconnection Error: $err');
    });

    socket.on('reconnect_failed', (_) {
      _log('🚫 Socket Reconnection Failed after max attempts');
      connectionState.value = SocketConnectionState.disconnected;
    });

    socket.onConnectError((err) {
      _log('⚠️ Socket Connection Error: $err');
    });

    socket.onError((err) {
      _log('❌ Socket Error: $err');
    });

    // --- Business events ---

    // A. New Job & Broadcast
    socket.on('job:new', (data) {
      _log('🔔 New Job Alert (job:new): $data');
      _safeMapCallback(onJobNew, data);
    });

    socket.on('job:broadcast', (data) {
      _log('🔔 New Job Broadcast (job:broadcast): $data');
      _safeMapCallback(onJobNew, data);
    });

    // B. Job Expired
    socket.on('job:expired', (data) {
      _log('⌛ Job Expired (job:expired): $data');
      _safeMapCallback(onJobExpired, data);
    });

    // C. Jobs Changed
    socket.on('technician:jobs_changed', (_) {
      _log('🔄 Technician jobs changed');
      try {
        onJobsChanged?.call();
      } catch (e) {
        _log('❌ Error in onJobsChanged: $e');
      }
    });

    // D. Travel Reminder
    socket.on('booking:travel_reminder', (data) {
      _log('🚗 Travel Reminder: $data');
      _safeMapCallback(onTravelReminder, data);
    });

    // E. Job Cancelled
    socket.on('job_cancelled_by_customer', (data) {
      _log('❌ Job Cancelled by Customer: $data');
      _safeMapCallback(onJobCancelled, data);
    });

    // F. Payment Received
    socket.on('payment_received', (data) {
      _log('💰 Payment Received: $data');
      _safeMapCallback(onPaymentReceived, data);
    });

    // G. Payout Paid
    socket.on('auto_payout_paid', (data) {
      _log('💸 Auto Payout Paid: $data');
      _safeMapCallback(onPayoutPaid, data);
    });

    // H. Withdrawal Failed
    socket.on('withdrawal_failed', (data) {
      _log('⚠️ Withdrawal Failed: $data');
      _safeMapCallback(onWithdrawalFailed, data);
    });

    // I. Permission Status Changed
    socket.on('permission_status_changed', (data) {
      _log('🛡️ Permission Status Changed: $data');
      _safeMapCallback(onPermissionChanged, data);
    });

    // J. Complaint Filed
    socket.on('complaint:filed_against_you', (data) {
      _log('⚠️ Complaint Filed: $data');
      _safeMapCallback(onComplaintFiled, data);
    });

    // K. Clawback Applied
    socket.on('clawback:applied', (data) {
      _log('📉 Clawback Applied: $data');
      _safeMapCallback(onClawbackApplied, data);
    });

    // L. Job taken by another technician
    socket.on('job:taken', (data) {
      try {
        final bookingId =
            data is Map ? data['bookingId']?.toString() : data?.toString();
        _log('🚫 Job taken by another tech: $bookingId');
        if (bookingId != null && onJobTaken != null) {
          onJobTaken?.call(bookingId);
        }
      } catch (e) {
        _log('❌ Error handling job:taken: $e');
      }
    });

    // M. Jobs list received
    socket.on('technician:jobs_list', (data) {
      _log('📦 Received jobs list: ${data is List ? data.length : 'N/A'}');
      try {
        if (onJobsListReceived != null && data != null && data is Iterable) {
          onJobsListReceived?.call(List<dynamic>.from(data));
        }
      } catch (e) {
        _log('❌ Error handling technician:jobs_list: $e');
      }
    });

    // N. Status updates (admin acceptance, payments, etc.)
    socket.on('technician:status_update', (data) {
      _log('🆕 Technician Status Update: $data');
      _safeMapCallback(onStatusUpdate, data);
    });
  }

  void _safeMapCallback(void Function(Map<String, dynamic>)? callback, dynamic data) {
    if (callback == null) return;
    try {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      } else if (data != null) {
        callback({'raw': data});
      }
    } catch (e) {
      _log('❌ Error executing socket event callback: $e');
    }
  }

  // ─── Remove All Listeners ─────────────────────────────────────────
  void _removeAllListeners() {
    final socket = _socket;
    if (socket == null) return;
    socket.off('job:new');
    socket.off('job:broadcast');
    socket.off('job:expired');
    socket.off('technician:jobs_changed');
    socket.off('booking:travel_reminder');
    socket.off('job_cancelled_by_customer');
    socket.off('payment_received');
    socket.off('auto_payout_paid');
    socket.off('withdrawal_failed');
    socket.off('permission_status_changed');
    socket.off('complaint:filed_against_you');
    socket.off('clawback:applied');
    socket.off('job:taken');
    socket.off('technician:jobs_list');
    socket.off('technician:status_update');
    socket.clearListeners();
    _listenersRegistered = false;
  }

  // ─── Disconnect ───────────────────────────────────────────────────
  void disconnect() {
    _removeAllListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _listenersRegistered = false;
    connectionState.value = SocketConnectionState.disconnected;
    _log('🔌 Socket disconnected and cleaned up');
  }

  // ─── Emit: Location Update ────────────────────────────────────────
  void updateLocation(double lat, double lng) {
    final socket = _socket;
    if (socket != null && socket.connected) {
      socket.emit('technician:location_update', {
        'latitude': lat,
        'longitude': lng,
      });
      _log('📍 Emitted location update: $lat, $lng');
    }
  }

  // ─── Emit: Request Jobs Feed ──────────────────────────────────────
  void requestJobs() {
    final socket = _socket;
    if (socket != null && socket.connected) {
      socket.emit('technician:get_jobs');
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
