import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import 'package:right_touch/utils/app_theme.dart';

class DeleteAccountDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    unawaited(HapticFeedback.mediumImpact());

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.red, size: 28),
              SizedBox(width: 12),
              Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone. All your data including:',
                style: TextStyle(fontSize: 14, color: AppTheme.grey[600]),
              ),
              const SizedBox(height: 8),
              ...[
                '• Profile information',
                '• Job history',
                '• Earnings records',
                '• Settings and preferences',
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 14, color: AppTheme.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'will be permanently deleted.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(ctx).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(ctx).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Final Confirmation',
            style: TextStyle(color: AppTheme.red),
          ),
          content: const Text(
            'This is your last chance. Are you absolutely sure you want to delete your account?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(ctx).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(ctx).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes, Delete My Account'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _executeDelete(context, ref);
    }
  }

  static Future<void> _executeDelete(
      BuildContext context, WidgetRef ref) async {
    unawaited(HapticFeedback.heavyImpact());

    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          margin: EdgeInsets.all(40),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RtLoader(),
                SizedBox(height: 16),
                Text('Deleting your account...'),
              ],
            ),
          ),
        ),
      ),
    ));

    try {
      final result = await ref.read(authProvider.notifier).deleteAccount();

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (result['success'] == true) {
        if (context.mounted) {
          unawaited(HapticFeedback.heavyImpact());
          GoRouter.of(context).go('/login');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Your account has been deleted successfully'),
                  ),
                ],
              ),
              backgroundColor: AppTheme.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (context.mounted) {
          unawaited(HapticFeedback.vibrate());
          ErrorHandler.showError(
            context,
            result['message'] ?? 'Failed to delete account',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        unawaited(HapticFeedback.vibrate());
        ErrorHandler.showError(context, e);
      }
    }
  }
}
