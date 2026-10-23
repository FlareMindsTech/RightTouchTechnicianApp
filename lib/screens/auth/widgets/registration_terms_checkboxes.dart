import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationTermsCheckboxes extends StatelessWidget {
  final bool agreedToTerms;
  final bool agreedToPrivacy;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;

  const RegistrationTermsCheckboxes({
    super.key,
    required this.agreedToTerms,
    required this.agreedToPrivacy,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
  });

  Future<void> _launchPolicy(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildCheckboxItem({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            activeColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  TextSpan _linkSpan(String text, String url) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = () => _launchPolicy(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCheckboxItem(
          value: agreedToTerms,
          onChanged: (v) => onTermsChanged(v ?? false),
          child: Text.rich(
            TextSpan(
              text: "I agree to the ",
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              children: [
                _linkSpan(
                  "Terms and Conditions",
                  "https://righttouch.vercel.app/terms/",
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCheckboxItem(
          value: agreedToPrivacy,
          onChanged: (v) => onPrivacyChanged(v ?? false),
          child: Text.rich(
            TextSpan(
              text: "I agree to the ",
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              children: [
                _linkSpan(
                  "Privacy Policy",
                  "https://righttouch.vercel.app/privacy/",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
