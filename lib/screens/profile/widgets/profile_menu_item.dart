import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class ProfileMenuItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor,
  });

  @override
  State<ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<ProfileMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primaryColor.withValues(alpha: 0.08)
                : AppTheme.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onHover: (value) {
              setState(() {
                _isHovered = value;
              });
            },
            borderRadius: BorderRadius.circular(12),
            splashColor: AppTheme.primaryColor.withValues(alpha: 0.15),
            highlightColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 24,
                    color: widget.textColor ?? AppTheme.black,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.textColor ?? AppTheme.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFFBDBDBD),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
