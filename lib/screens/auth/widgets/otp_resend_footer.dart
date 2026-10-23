import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class OtpResendFooter extends StatelessWidget {
  final bool isLoading;
  final bool canResend;
  final int secondsRemaining;
  final VoidCallback onResend;

  const OtpResendFooter({
    super.key,
    required this.isLoading,
    required this.canResend,
    required this.secondsRemaining,
    required this.onResend,
  });

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Didn't receive code?",
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: isLoading || !canResend ? null : onResend,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              canResend
                  ? "Resend"
                  : "Resend in ${_formatTimer(secondsRemaining)}",
              style: TextStyle(
                color: canResend
                    ? AppTheme.primaryColor
                    : AppTheme.textTertiary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
