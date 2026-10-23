import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';

class KycDocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final String hint;
  final String? localImagePath;
  final VoidCallback onUpload;
  final IconData icon;
  final String? localImageBackPath;
  final VoidCallback? onUploadBack;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const KycDocumentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.hint,
    required this.localImagePath,
    required this.onUpload,
    required this.icon,
    this.localImageBackPath,
    this.onUploadBack,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller,
              textCapitalization: textCapitalization,
              keyboardType: keyboardType,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                counterText: "",
                prefixIcon: const Icon(Icons.edit_note, size: 20),
              ),
              onChanged: (val) {
                if (textCapitalization == TextCapitalization.characters) {
                  final upper = val.toUpperCase();
                  if (val != upper) {
                    controller.value = controller.value.copyWith(
                      text: upper,
                      selection: TextSelection.collapsed(offset: upper.length),
                    );
                  }
                }
              },
              validator: validator ??
                  (v) => v == null || v.isEmpty ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Front Side",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildUploadArea(localImagePath, onUpload),
                    ],
                  ),
                ),
                if (onUploadBack != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Back Side",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildUploadArea(localImageBackPath, onUploadBack!),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(String? path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 120,
        decoration: BoxDecoration(
          color: path != null ? AppTheme.grey[50] : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: path != null
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : AppTheme.textTertiary.withValues(alpha: 0.2),
            style: path != null ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: path != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: path.startsWith('http')
                        ? Image.network(
                            path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.error)),
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.transparent,
                          AppTheme.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: AppTheme.white,
                      radius: 14,
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 28,
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Upload",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Auto-formats Aadhar input as XXXX XXXX XXXX
class AadharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 12) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 8) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
