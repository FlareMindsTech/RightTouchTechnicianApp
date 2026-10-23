import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/validators.dart';

class ProfileSetupTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  const ProfileSetupTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
  });

  static String? nameValidator(String? value) {
    return Validators.validateName(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint, counterText: ""),
          validator: validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
        ),
      ],
    );
  }
}
