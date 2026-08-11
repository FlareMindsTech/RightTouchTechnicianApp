import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/services/socket_service.dart';

/// Riverpod-managed SocketService. This is the ONLY way to obtain a
/// SocketService instance — there is no singleton.
final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();

  // Full cleanup when provider is disposed (app teardown / scope change)
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
