import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';

class ProfileSkillSelectionSheet {
  static void show(
    BuildContext context, {
    required List<dynamic> services,
    required List<Map<String, dynamic>> selectedServices,
    required Function(Map<String, dynamic> service, bool isSelected) onToggle,
  }) {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final searchText = searchController.text.toLowerCase();
            final filteredServices = services.where((service) {
              final name = (service['serviceName']?.toString() ??
                      service['name']?.toString() ??
                      '')
                  .toLowerCase();
              return name.contains(searchText);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      height: 4,
                      width: 36,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        'Select Your Skill',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search skills...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppTheme.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (val) => setSheetState(() {}),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredServices.isEmpty
                          ? const Center(child: Text("No skills found"))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredServices.length,
                              itemBuilder: (context, index) {
                                final service = filteredServices[index];
                                final name =
                                    service['serviceName']?.toString() ??
                                        service['name']?.toString() ??
                                        'N/A';
                                final id = service['_id']?.toString() ??
                                    service['id']?.toString();
                                final isSelected = selectedServices.any(
                                  (s) =>
                                      (s['_id'] ?? s['id'])?.toString() == id,
                                );

                                return Material(
                                  color: isSelected
                                      ? AppTheme.green.withValues(alpha: 0.08)
                                      : AppTheme.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setSheetState(() {
                                        onToggle(
                                          Map<String, dynamic>.from(service),
                                          isSelected,
                                        );
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                fontSize: 15,
                                                color: isSelected
                                                    ? AppTheme.green.shade700
                                                    : AppTheme.black87,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: AppTheme.green.shade600,
                                              size: 22,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.0,
                        16.0,
                        16.0,
                        16.0 + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Done"),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
