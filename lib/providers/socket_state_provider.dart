import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/socket_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:right_touch/services/socket_service.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';

class SocketState {
  final bool isConnected;
  final bool hasNewJob;
  final List<dynamic> liveJobs;
  final SocketConnectionState connectionState;

  SocketState({
    this.isConnected = false,
    this.hasNewJob = false,
    this.liveJobs = const [],
    this.connectionState = SocketConnectionState.disconnected,
  });

  SocketState copyWith({
    bool? isConnected,
    bool? hasNewJob,
    List<dynamic>? liveJobs,
    SocketConnectionState? connectionState,
  }) {
    return SocketState(
      isConnected: isConnected ?? this.isConnected,
      hasNewJob: hasNewJob ?? this.hasNewJob,
      liveJobs: liveJobs ?? this.liveJobs,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}

class SocketNotifier extends Notifier<SocketState> {
  late final SocketService _socketService;
  final _storage = const FlutterSecureStorage();

  /// Listener callback reference for cleanup.
  VoidCallback? _connectionStateListener;

  @override
  SocketState build() {
    _socketService = ref.watch(socketServiceProvider);

    Future.microtask(() {
      _init();
      _loadNotificationStatus();
      if (ref.read(authProvider.notifier).isLoggedIn) {
        connect();
      }
    });

    return SocketState();
  }

  Future<void> _loadNotificationStatus() async {
    try {
      final hasNew = await _storage.read(key: 'has_new_job');
      if (hasNew == 'true') {
        state = state.copyWith(hasNewJob: true);
      }
    } catch (e) {
      debugPrint('[SocketNotifier] Error loading notification status: $e');
    }
  }

  void _init() {
    // ─── Watch socket connection state via ValueNotifier ───────────
    _connectionStateListener?.call; // no-op, just to reference
    _connectionStateListener = () {
      final connState = _socketService.connectionState.value;
      state = state.copyWith(
        connectionState: connState,
        isConnected: connState == SocketConnectionState.connected,
      );
    };
    _socketService.connectionState.addListener(_connectionStateListener!);

    // ─── Socket event callbacks ───────────────────────────────────
    _socketService.onConnected = () {
      state = state.copyWith(
        isConnected: true,
        connectionState: SocketConnectionState.connected,
      );
      _socketService.requestJobs();
    };

    _socketService.onDisconnected = () {
      state = state.copyWith(
        isConnected: false,
        connectionState: SocketConnectionState.disconnected,
      );
    };

    _socketService.onNewJob = (data) async {
      try {
        state = state.copyWith(hasNewJob: true);
        await _storage.write(key: 'has_new_job', value: 'true');
        // Invalidate broadcast jobs to show the new one
        ref.invalidate(broadcastJobsProvider);
      } catch (e) {
        debugPrint('[SocketNotifier] Error handling onNewJob: $e');
      }
    };

    _socketService.onJobsListReceived = (jobs) {
      try {
        state = state.copyWith(liveJobs: jobs);
      } catch (e) {
        debugPrint('[SocketNotifier] Error handling onJobsListReceived: $e');
      }
    };

    // Handle job:taken to update local state
    _socketService.onJobTaken = (bookingId) {
      try {
        final updatedJobs =
            state.liveJobs.where((j) => j['bookingId'] != bookingId).toList();
        state = state.copyWith(liveJobs: updatedJobs);
        // Invalidate broadcast jobs as one is gone
        ref.invalidate(broadcastJobsProvider);
      } catch (e) {
        debugPrint('[SocketNotifier] Error handling onJobTaken: $e');
      }
    };

    _socketService.onStatusUpdate = (data) {
      try {
        final type = data['type']?.toString().toUpperCase();

        // Invalidate job/earnings data on relevant events
        if (type == 'JOB_ACCEPTED' ||
            type == 'JOB_COMPLETED' ||
            type == 'PAYMENT_RECEIVED' ||
            type == 'WALLET_UPDATE') {
          ref.invalidate(currentJobsProvider);
          ref.invalidate(historyJobsProvider);
          ref.invalidate(dashboardDataProvider);
        }

        // Handle verification / profile updates that AuthNotifier needs
        if (type == 'VERIFICATION_UPDATE' || type == 'PROFILE_CHANGE') {
          ref.read(authProvider.notifier).checkAuth(silent: true);
        }
      } catch (e) {
        debugPrint('[SocketNotifier] Error handling onStatusUpdate: $e');
      }
    };

    // ─── Auth lifecycle binding ───────────────────────────────────
    ref.listen(authProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (_) => connect(),
        unauthenticated: () => disconnect(),
        orElse: () {}, // error/loading: leave socket connection alone
      );
    });
  }

  Future<void> connect() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _socketService.connect(token);
      }
    } catch (e) {
      debugPrint('[SocketNotifier] Error connecting: $e');
    }
  }

  void disconnect() {
    _socketService.disconnect();
    state = SocketState();
  }

  void clearNewJobAlert() async {
    state = state.copyWith(hasNewJob: false);
    await _storage.delete(key: 'has_new_job');
  }
}

final socketStateProvider =
    NotifierProvider<SocketNotifier, SocketState>(SocketNotifier.new);
