import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';

class LogoutDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Logout Confirmation"),
          content: const Text(
            "Are you sure you want to log out? Please stay professional.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.red,
              ),
              child: const Text("Log Out"),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        router.go('/login');
      }
    }
  }
}
