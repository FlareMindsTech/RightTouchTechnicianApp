import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class SkillSelectionSheet extends StatefulWidget {
  final List<dynamic> allServices;
  final Map<String, dynamic>? selectedService;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const SkillSelectionSheet({
    super.key,
    required this.allServices,
    required this.selectedService,
    required this.onSelect,
  });

  @override
  State<SkillSelectionSheet> createState() => _SkillSelectionSheetState();
}

class _SkillSelectionSheetState extends State<SkillSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchText = _searchController.text.toLowerCase();
    final filteredServices = widget.allServices.where((service) {
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
              height: 5,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search skills...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.grey[100],
                ),
                onChanged: (_) => setState(() {}),
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
                        final name = service['serviceName']?.toString() ??
                            service['name']?.toString() ??
                            'N/A';
                        final id = service['_id']?.toString() ??
                            service['id']?.toString();
                        final isSelected = widget.selectedService != null &&
                            (widget.selectedService!['_id'] == id ||
                                widget.selectedService!['id'] == id);

                        return ListTile(
                          title: Text(
                            name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.black,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: AppTheme.primaryColor,
                                )
                              : null,
                          onTap: () {
                            widget.onSelect(Map<String, dynamic>.from(service));
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
