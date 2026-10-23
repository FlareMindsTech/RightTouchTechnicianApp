import 'package:flutter/material.dart';
import 'package:right_touch/screens/auth/widgets/profile_setup_text_field.dart';
import 'package:right_touch/utils/validators.dart';

class ProfilePersonalFields extends StatelessWidget {
  final TextEditingController fnameController;
  final TextEditingController lnameController;
  final TextEditingController emailController;
  final String gender;
  final ValueChanged<String> onGenderChanged;

  const ProfilePersonalFields({
    super.key,
    required this.fnameController,
    required this.lnameController,
    required this.emailController,
    required this.gender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileSetupTextField(
                controller: fnameController,
                label: "First Name",
                hint: "Enter first name",
                autofillHints: const [AutofillHints.givenName],
                inputFormatters: [Validators.nameInputFormatter],
                validator: (v) => Validators.validateName(
                  v,
                  fieldName: 'First Name',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfileSetupTextField(
                controller: lnameController,
                label: "Last Name",
                hint: "Enter last name",
                autofillHints: const [AutofillHints.familyName],
                inputFormatters: [Validators.nameInputFormatter],
                validator: (v) => Validators.validateName(
                  v,
                  fieldName: 'Last Name',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProfileSetupTextField(
          controller: emailController,
          label: "Email",
          hint: "Enter your email address",
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 16),
        const Text(
          "Gender",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'Male',
                label: FittedBox(child: Text('Male')),
              ),
              ButtonSegment(
                value: 'Female',
                label: FittedBox(child: Text('Female')),
              ),
              ButtonSegment(
                value: 'Other',
                label: FittedBox(child: Text('Other')),
              ),
            ],
            selected: {gender},
            onSelectionChanged: (Set<String> newSelection) {
              onGenderChanged(newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}
