import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/empty_state.dart';

enum NotificationType { job, payment, system }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'New Service Request Nearby',
      body:
          'AC repair & gas filling service requested within 3.2 km of your location.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      type: NotificationType.job,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Weekly Payout Processed',
      body:
          '₹4,250 has been credited to your verified bank account ending in **4921.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.payment,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Profile Verification Complete',
      body:
          'Congratulations! Your technician KYC and background check have been approved.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.system,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'High Demand Area Alert',
      body:
          'Demand for electrical & AC technicians is surging near your current sector.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.job,
      isRead: true,
    ),
  ];

  NotificationType? _selectedFilter;

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isRead = true;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == null
        ? _notifications
        : _notifications.where((n) => n.type == _selectedFilter).toList();

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
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.black),
              onSelected: (val) {
                if (val == 'read') _markAllAsRead();
                if (val == 'clear') _clearAll();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'read',
                  child: Text('Mark all as read'),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear all'),
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
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Jobs', NotificationType.job),
                const SizedBox(width: 8),
                _buildFilterChip('Payments', NotificationType.payment),
                const SizedBox(width: 8),
                _buildFilterChip('System', NotificationType.system),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: "No Notifications",
                      subtitle: "You're all caught up! New alerts will appear here.",
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationType? type) {
    final isSelected = _selectedFilter == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = type;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : const Color(0xFFF1F5F2),
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

  Widget _buildNotificationCard(NotificationItem item) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (item.type) {
      case NotificationType.job:
        icon = Icons.work_outline_rounded;
        iconColor = AppTheme.primaryColor;
        iconBg = const Color(0xFFE8F5E9);
        break;
      case NotificationType.payment:
        icon = Icons.account_balance_wallet_outlined;
        iconColor = const Color(0xFFEF6C00);
        iconBg = const Color(0xFFFFF3E0);
        break;
      case NotificationType.system:
        icon = Icons.verified_user_outlined;
        iconColor = const Color(0xFF1976D2);
        iconBg = const Color(0xFFE3F2FD);
        break;
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
                  item.body,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grey[700],
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(item.timestamp),
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
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}

