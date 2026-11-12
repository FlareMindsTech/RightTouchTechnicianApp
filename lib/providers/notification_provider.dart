import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/app_notification.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(() {
  return NotificationsNotifier();
});

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  FutureOr<List<AppNotification>> build() async {
    ref.keepAlive();
    return _fetch();
  }

  Future<List<AppNotification>> _fetch() async {
    final repo = ref.read(dashboardRepositoryProvider);
    final rawList = await repo.getNotifications();
    return rawList
        .whereType<Map>()
        .map((m) => AppNotification.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAsRead(String id) async {
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
    final repo = ref.read(dashboardRepositoryProvider);
    await repo.markNotificationRead(id);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllAsRead() async {
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.map((n) => n.copyWith(isRead: true)).toList(),
    );
    final repo = ref.read(dashboardRepositoryProvider);
    for (final item in currentList.where((n) => !n.isRead)) {
      unawaited(repo.markNotificationRead(item.id));
    }
    ref.invalidate(unreadNotificationCountProvider);
  }
}

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getNotificationUnreadCount();
});

