import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';

/// Shows a full-screen success animation overlay, then calls [onDone].
/// Usage: SuccessOverlay.show(context, message: 'Profile Complete!', onDone: () => ...);
class SuccessOverlay {
  static void show(
    BuildContext context, {
    String message = 'Success!',
    String? subtitle,
    VoidCallback? onDone,
    Duration duration = const Duration(milliseconds: 1800),
  }) {
    HapticFeedback.heavyImpact();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SuccessOverlayWidget(
        message: message,
        subtitle: subtitle,
        onDone: () {
          entry.remove();
          onDone?.call();
        },
        duration: duration,
      ),
    );
    overlay.insert(entry);
  }
}

class _SuccessOverlayWidget extends StatefulWidget {
  final String message;
  final String? subtitle;
  final VoidCallback onDone;
  final Duration duration;

  const _SuccessOverlayWidget({
    required this.message,
    required this.onDone,
    required this.duration,
    this.subtitle,
  });

  @override
  State<_SuccessOverlayWidget> createState() => _SuccessOverlayWidgetState();
}

class _SuccessOverlayWidgetState extends State<_SuccessOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.4)),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Material(
            color: AppTheme.black.withValues(alpha: 0.6),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.green.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.green,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black87,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
