import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';

class ErrorBoundary extends ConsumerWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onLoginAgain;
  final bool showTitle;
  final bool isOverlay;
  final bool isElevated; // Added to provide card-like elevation

  const ErrorBoundary({
    super.key,
    required this.message,
    required this.onRetry,
    this.onLoginAgain,
    this.showTitle = true,
    this.isOverlay = false,
    this.isElevated = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          const SizedBox(height: 12),
          Text(
            "Oops! Something went wrong",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(
              "Try Again",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (onLoginAgain != null ||
            message.toLowerCase().contains('deactivated') ||
            message.toLowerCase().contains('support') ||
            message.toLowerCase().contains('deleted')) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onLoginAgain ??
                  () {
                    ref.read(authProvider.notifier).logout();
                  },
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text(
                "Login Again",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (isElevated) {
      content = Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: content,
      );
    }

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: content,
        ),
      ),
    );
  }
}
