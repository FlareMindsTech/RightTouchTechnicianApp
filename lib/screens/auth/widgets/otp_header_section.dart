import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class OtpHeaderSection extends StatelessWidget {
  final String identifier;
  final VoidCallback onEditPhone;

  const OtpHeaderSection({
    super.key,
    required this.identifier,
    required this.onEditPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppTheme.primaryColor,
            size: 42,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Enter Verification Code",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "We sent a 4-digit code to",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              identifier.isNotEmpty ? identifier : "your mobile number",
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onEditPhone,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
