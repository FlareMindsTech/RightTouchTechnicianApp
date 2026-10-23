import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/repositories/auth_repository.dart'
    as auth_repo;
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/screens/profile/widgets/skill_selection_sheet.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class EditSkillsScreen extends ConsumerStatefulWidget {
  const EditSkillsScreen({super.key});

  @override
  ConsumerState<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends ConsumerState<EditSkillsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expController = TextEditingController();

  List<dynamic> _allServices = [];
  Map<String, dynamic>? _selectedService;
  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _expController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isFetching = true);
    try {
      // Use aliased provider to fix undefined name error
      final repository = ref.read(auth_repo.authRepositoryProvider);
      final response = await repository.getAllServices();
      setState(() {
        if (response is List) {
          _allServices = response;
        } else if (response is Map) {
          // Robust extraction: Check 'result', then 'data', then 'services'
          dynamic data =
              response['result'] ?? response['data'] ?? response['services'];

          // If the extracted data is still a Map, try one level deeper (common in some API wrappers)
          if (data is Map) {
            data = data['result'] ?? data['data'] ?? data['services'] ?? data;
          }

          if (data is List) {
            _allServices = data;
          } else {
            // If still not a list, maybe it's the response itself failing to be parsed properly
            _allServices = [];
          }
        }
        _isFetching = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isFetching = false);
        ErrorHandler.showError(context, 'Error fetching services: $e');
      }
    }
  }

  String _getSkillName(String skillId) {
    if (_allServices.isEmpty) return skillId;
    try {
      String targetId = skillId;
      String? nameFromFile;

      // Check if skillId itself is a stringified Map (common if backend returns object instead of ID)
      if (skillId.trim().startsWith('{')) {
        // Extract serviceName using simple string splitting to avoid regex/json issues with unquoted keys
        if (skillId.contains('serviceName:')) {
          final parts = skillId.split('serviceName:');
          if (parts.length > 1) {
            nameFromFile = parts[1].split(',').first.split('}').first.trim();
            // Clean up quotes
            nameFromFile = nameFromFile.replaceAll('"', '').replaceAll("'", "");
          }
        }

        // Also extract the actual ID for lookup
        if (skillId.contains('_id:')) {
          final parts = skillId.split('_id:');
          if (parts.length > 1) {
            targetId = parts[1].split(',').first.split('}').first.trim();
            targetId = targetId.replaceAll('"', '').replaceAll("'", "");
          }
        }
      }

      if (nameFromFile != null &&
          nameFromFile.isNotEmpty &&
          nameFromFile != 'null') {
        return nameFromFile;
      }

      // Fallback: Look up in _allServices list
      final service = _allServices.firstWhere((s) {
        if (s is! Map) return false;
        final id = s['_id']?.toString() ?? s['id']?.toString();
        return id == targetId;
      }, orElse: () => null);

      if (service != null && service is Map) {
        final name = service['serviceName']?.toString() ??
            service['name']?.toString() ??
            (service['service'] is Map
                ? (service['service']['serviceName']?.toString() ??
                    service['service']['name']?.toString())
                : null);

        if (name != null) return name;
      }
    } catch (e) {
      debugPrint('[EditSkillsScreen] Error resolving skill name: $e');
    }
    return skillId;
  }

  Future<void> _addSkill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null) {
      ErrorHandler.showError(context, 'Please select a skill');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Use aliased provider
      final repository = ref.read(auth_repo.authRepositoryProvider);
      final serviceId = _selectedService!['_id']?.toString() ??
          _selectedService!['id']?.toString();

      if (serviceId == null) {
        throw Exception('Selected service has no ID');
      }

      final result = await repository.addSkill(
        serviceId,
        int.parse(_expController.text.trim()),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Skill added successfully')),
          );
          _expController.clear();
          setState(() => _selectedService = null);
          // Refresh auth state to show new skills
          unawaited(ref.read(authProvider.notifier).refreshProfile());
        } else {
          ErrorHandler.showError(
            context,
            result['message'] ?? 'Failed to add skill',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _showSkillSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SkillSelectionSheet(
        allServices: _allServices,
        selectedService: _selectedService,
        onSelect: (service) => setState(() => _selectedService = service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref
        .watch(authProvider)
        .maybeWhen(authenticated: (user) => user, orElse: () => null);

    // Skills are currently List<String> in UserModel, which might be flattened map strings
    final skills = user?.skills ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Skills'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: _isFetching
          ? const Center(child: RtLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Skills",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (skills.isEmpty)
                    const Text(
                      "No skills added yet",
                      style: TextStyle(color: AppTheme.grey),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) {
                        return Chip(
                          label: Text(_getSkillName(skill)),
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          labelStyle: const TextStyle(
                            color: AppTheme.primaryColor,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                  const Divider(height: 40),
                  const Text(
                    "Add New Skill",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _showSkillSelectionSheet,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Select Skill',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                            ),
                            child: Text(
                              _selectedService != null
                                  ? (_selectedService!['serviceName']
                                          ?.toString() ??
                                      _selectedService!['name']?.toString() ??
                                      'Select Skill')
                                  : 'Select Skill',
                              style: TextStyle(
                                color: _selectedService != null
                                    ? AppTheme.black
                                    : AppTheme.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _expController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Years of Experience',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Required';
                            }
                            final yrs = int.tryParse(val.trim());
                            if (yrs == null) {
                              return 'Invalid number';
                            }
                            if (yrs < 0) return 'Experience cannot be negative';
                            if (yrs > 15) return 'Experience cannot exceed 15 years';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addSkill,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const RtLoader.button(
                                    color: AppTheme.white,
                                  )
                                : const Text(
                                    'Add Skill',
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
