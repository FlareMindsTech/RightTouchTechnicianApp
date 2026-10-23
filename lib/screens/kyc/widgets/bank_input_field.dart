import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';

class BankInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool required;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const BankInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.required = true,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.words,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            counterText: "",
            prefixIcon: Icon(icon, size: 20),
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
              (required
                  ? (v) => v == null || v.isEmpty ? 'Required' : null
                  : null),
        ),
      ],
    );
  }
}
