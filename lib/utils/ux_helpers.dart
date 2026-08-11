// UX Enhancement Utilities
// Lightweight helpers for improved user experience
// No external dependencies - uses Flutter's built-in capabilities

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.grey.shade800 : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Try Again',
                textColor: Colors.blueAccent.shade100,
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
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
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
                    const CircularProgressIndicator(),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}

/// Confirmation Dialog with Haptic
class UXDialog {
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    HapticHelper.medium();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              HapticHelper.light();
              Navigator.pop(context, false);
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              if (isDangerous) {
                HapticHelper.heavy();
              } else {
                HapticHelper.medium();
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? Colors.red : null,
            ),
            child: Text(
              confirmText,
              style: TextStyle(color: isDangerous ? Colors.white : null),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Global Error Dialog pop-up (For critical failures)
  static void showError({
    required BuildContext context,
    required String message,
    String title = 'Important',
  }) {
    HapticHelper.error();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Global Notice Dialog pop-up (For non-critical informational boundaries)
  static void showNotice({
    required BuildContext context,
    required String message,
    String title = 'Notice',
  }) {
    HapticHelper.light();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom styled Action Dialog (Auth transitions, etc.)
  static void showActionDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String primaryActionText,
    required VoidCallback onPrimaryAction,
    String? cancelText = 'Cancel',
  }) {
    HapticHelper.medium();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Buttons
              Row(
                children: [
                  if (cancelText != null)
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (cancelText != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticHelper.medium();
                        Navigator.pop(context);
                        onPrimaryAction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32), // Green
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        primaryActionText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
              color: Colors.blue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.archive, color: Colors.white),
            )
          : null,
      secondaryBackground: onDelete != null
          ? Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            )
          : null,
      child: child,
    );
  }
}
