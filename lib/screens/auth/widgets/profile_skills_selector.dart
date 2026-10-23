import 'package:flutter/material.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import 'package:right_touch/utils/app_theme.dart';

class ProfileSkillsSelector extends StatelessWidget {
  final bool isFetching;
  final bool isSubmitted;
  final List<Map<String, dynamic>> selectedServices;
  final VoidCallback onTap;
  final Function(Map<String, dynamic> service) onRemove;

  const ProfileSkillsSelector({
    super.key,
    required this.isFetching,
    required this.isSubmitted,
    required this.selectedServices,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Skill / Service",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        if (isFetching)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: RtLoader(size: 28),
            ),
          )
        else
          InkWell(
            onTap: onTap,
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: const Icon(Icons.add_circle_outline),
                errorText: isSubmitted && selectedServices.isEmpty
                    ? 'Please select at least one skill'
                    : null,
              ),
              child: selectedServices.isEmpty
                  ? Text(
                      'Select your skills',
                      style: TextStyle(color: AppTheme.grey[600]),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: selectedServices.map((s) {
                        final name = s['serviceName']?.toString() ??
                            s['name']?.toString() ??
                            '';
                        return Chip(
                          label: Text(
                            name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () => onRemove(s),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
            ),
          ),
      ],
    );
  }
}
