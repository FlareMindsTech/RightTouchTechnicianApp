import 'package:flutter/material.dart';
import 'package:right_touch/screens/auth/widgets/profile_setup_text_field.dart';
import 'package:right_touch/screens/auth/widgets/profile_skill_selection_sheet.dart';
import 'package:right_touch/screens/auth/widgets/profile_skills_selector.dart';
import 'package:right_touch/utils/validators.dart';

class ProfileProfessionalFields extends StatelessWidget {
  final TextEditingController specializationController;
  final TextEditingController expController;
  final List<dynamic> services;
  final List<Map<String, dynamic>> selectedServices;
  final bool isFetchingServices;
  final bool isSubmitted;
  final Function(Map<String, dynamic> service, bool isSelected) onToggleSkill;
  final Function(Map<String, dynamic> service) onRemoveSkill;

  const ProfileProfessionalFields({
    super.key,
    required this.specializationController,
    required this.expController,
    required this.services,
    required this.selectedServices,
    required this.isFetchingServices,
    required this.isSubmitted,
    required this.onToggleSkill,
    required this.onRemoveSkill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSetupTextField(
          controller: specializationController,
          label: "Specialization",
          hint: "e.g. AC Repair, Electrician",
          inputFormatters: [Validators.nameInputFormatter],
          validator: (v) => Validators.validateRequired(v, 'Specialization'),
        ),
        const SizedBox(height: 16),
        ProfileSkillsSelector(
          isFetching: isFetchingServices,
          isSubmitted: isSubmitted,
          selectedServices: selectedServices,
          onTap: () => ProfileSkillSelectionSheet.show(
            context,
            services: services,
            selectedServices: selectedServices,
            onToggle: onToggleSkill,
          ),
          onRemove: onRemoveSkill,
        ),
        const SizedBox(height: 16),
        ProfileSetupTextField(
          controller: expController,
          label: "Experience (Years)",
          hint: "Years of experience",
          keyboardType: TextInputType.number,
          maxLength: 2,
          inputFormatters: [Validators.digitsOnlyFormatter],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            final years = int.tryParse(value.trim());
            if (years == null) return 'Please enter a valid number';
            if (years < 0) return 'Experience cannot be negative';
            if (years > 15) return 'Experience cannot exceed 15 years';
            return null;
          },
        ),
      ],
    );
  }
}
