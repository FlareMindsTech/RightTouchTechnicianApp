// UX Enhancement Utilities
// Lightweight helpers for improved user experience
// No external dependencies - uses Flutter's built-in capabilities

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/rt_loader.dart';
import 'ux_dialog.dart';
import 'package:right_touch/utils/app_theme.dart';

export 'ux_dialog.dart';

/// Haptic Feedback Helper
class HapticHelper {
  /// Light impact for selection changes, toggles
  static void light() {
    HapticFeedback.selectionClick();
  }

  /// Medium impact for button taps, confirmations
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for important actions, completions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Vibrate for errors, warnings
  static void error() {
    HapticFeedback.vibrate();
  }
}

/// Enhanced SnackBar with better UX
class UXSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticHelper.medium();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppTheme.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.grey.shade800 : AppTheme.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Try Again',
                textColor: AppTheme.blueAccent.shade100,
                onPressed: () {
                  HapticHelper.light();
                  onRetry();
                },
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, isError: false);
  }

  static void error(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    HapticFeedback.vibrate();
    UXDialog.showNotice(context: context, message: message, title: 'Notice');
  }
}

/// Smooth Page Transitions
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SmoothPageRoute({required this.page, this.direction = SlideDirection.right})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.up:
                begin = const Offset(0, 1);
                break;
              case SlideDirection.down:
                begin = const Offset(0, -1);
                break;
              case SlideDirection.left:
                begin = const Offset(-1, 0);
                break;
              case SlideDirection.right:
                begin = const Offset(1, 0);
                break;
            }

            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

enum SlideDirection { up, down, left, right }

/// Enhanced Button with Haptic Feedback
class HapticButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isLoading;

  const HapticButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null || isLoading
          ? null
          : () {
              HapticHelper.medium();
              onPressed!();
            },
      style: style,
      child: isLoading
          ? const RtLoader.button(color: AppTheme.white)
          : child,
    );
  }
}

/// Loading Overlay (instead of full-screen blocking)
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isLoading,
          child: Opacity(opacity: isLoading ? 0.5 : 1.0, child: child),
        ),
        if (isLoading)
          Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const RtLoader(),
                    if (loadingMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loadingMessage!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Smooth Bottom Sheet Helper
class UXBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    HapticHelper.medium();
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: AppTheme.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}

/// Swipeable List Item for Delete/Actions
class SwipeableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final String itemKey;

  const SwipeableCard({
    super.key,
    required this.child,
    required this.itemKey,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    if (onDelete == null && onArchive == null) {
      return child;
    }

    return Dismissible(
      key: Key(itemKey),
      direction: onDelete != null && onArchive != null
          ? DismissDirection.horizontal
          : onDelete != null
              ? DismissDirection.endToStart
              : DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        HapticHelper.medium();

        if (direction == DismissDirection.endToStart && onDelete != null) {
          return await UXDialog.confirm(
            context: context,
            title: 'Delete',
            message: 'Are you sure you want to delete this item?',
            confirmText: 'Delete',
            isDangerous: true,
          );
        }
        return true;
      },
      onDismissed: (direction) {
        HapticHelper.heavy();
        if (direction == DismissDirection.endToStart && onDelete != null) {
          onDelete!();
        } else if (direction == DismissDirection.startToEnd &&
            onArchive != null) {
          onArchive!();
        }
      },
      background: onArchive != null
          ? Container(
              color: AppTheme.blue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.archive, color: AppTheme.white),
            )
          : null,
      secondaryBackground: onDelete != null
          ? Container(
              color: AppTheme.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: AppTheme.white),
            )
          : null,
      child: child,
    );
  }
}
