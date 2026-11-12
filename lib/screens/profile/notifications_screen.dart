import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/app_notification.dart';
import 'package:right_touch/providers/notification_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/empty_state.dart';
import 'package:right_touch/widgets/list_shimmer.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String? _selectedFilter; // null = 'all', 'job', 'payment', 'system'

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.black),
            onSelected: (val) {
              if (val == 'read') {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              }
              if (val == 'refresh') {
                ref.read(notificationsProvider.notifier).refresh();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Jobs', 'job'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Payouts', 'payment'),
                  const SizedBox(width: 8),
                  _buildFilterChip('System', 'system'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          Expanded(
            child: notificationsAsync.when(
              loading: () => const ListShimmer(),
              error: (err, _) => Center(
                child: EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: "Unable to load notifications",
                  subtitle: "Check your connection and try again.",
                  onRetry: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                ),
              ),
              data: (items) {
                final filtered = _selectedFilter == null
                    ? items
                    : items.where((n) {
                        if (_selectedFilter == 'payment') {
                          return n.type.contains('pay') ||
                              n.type.contains('withdraw');
                        }
                        return n.type.contains(_selectedFilter!);
                      }).toList();

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                    child: ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: EmptyState(
                            icon: Icons.notifications_off_outlined,
                            title: "No Notifications",
                            subtitle:
                                "You're all caught up! New alerts will appear here.",
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return InkWell(
                        onTap: () {
                          if (!item.isRead) {
                            ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(item.id);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: _buildNotificationCard(item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type) {
    final isSelected = _selectedFilter == type;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : const Color(0xFFF1F5F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.white : AppTheme.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification item) {
    IconData icon = Icons.notifications_outlined;
    Color iconColor = AppTheme.primaryColor;
    Color iconBg = const Color(0xFFE8F5E9);

    if (item.type.contains('pay') || item.type.contains('withdraw')) {
      icon = Icons.account_balance_wallet_outlined;
      iconColor = const Color(0xFFEF6C00);
      iconBg = const Color(0xFFFFF3E0);
    } else if (item.type.contains('job') || item.type.contains('booking')) {
      icon = Icons.work_outline_rounded;
      iconColor = AppTheme.primaryColor;
      iconBg = const Color(0xFFE8F5E9);
    } else {
      icon = Icons.verified_user_outlined;
      iconColor = const Color(0xFF1976D2);
      iconBg = const Color(0xFFE3F2FD);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isRead ? AppTheme.white : const Color(0xFFF3FAF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead
              ? const Color(0xFFE0E0E0).withValues(alpha: 0.6)
              : AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: item.isRead
                              ? FontWeight.w600
                              : FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grey[700],
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(item.createdAt),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes < 1 ? 1 : diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
