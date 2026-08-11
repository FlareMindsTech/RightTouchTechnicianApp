import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _localityController;
  late TextEditingController _expController;
  late TextEditingController _specController;

  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref
        .read(authProvider)
        .maybeWhen(authenticated: (user) => user, orElse: () => null);

    final profileMap = (user?.profile is Map)
        ? Map<String, dynamic>.from(user!.profile as Map)
        : <String, dynamic>{};
    final rawMap = user?.rawData ?? {};

    // Pull fname/lname from all possible locations in the API response
    final fname = user?.firstName?.isNotEmpty == true
        ? user!.firstName
        : (profileMap['fname']?.toString().isNotEmpty == true
            ? profileMap['fname']?.toString()
            : rawMap['fname']?.toString());
    final lname = user?.lastName?.isNotEmpty == true
        ? user!.lastName
        : (profileMap['lname']?.toString().isNotEmpty == true
            ? profileMap['lname']?.toString()
            : rawMap['lname']?.toString());

    _fnameController = TextEditingController(text: fname ?? '');
    _lnameController = TextEditingController(text: lname ?? '');
    _emailController = TextEditingController(
      text: user?.email ?? rawMap['email']?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: user?.address ?? rawMap['address']?.toString() ?? '',
    );
    _cityController = TextEditingController(
      text: user?.city ?? rawMap['city']?.toString() ?? '',
    );
    _stateController = TextEditingController(
      text: user?.state ?? rawMap['state']?.toString() ?? '',
    );
    _pincodeController = TextEditingController(
      text: user?.pincode ?? rawMap['pincode']?.toString() ?? '',
    );
    _localityController = TextEditingController(
      text: user?.locality ?? rawMap['locality']?.toString() ?? '',
    );
    _expController = TextEditingController(
      text: (user?.experienceYears ?? rawMap['experienceYears'])?.toString() ??
          '',
    );
    _specController = TextEditingController(
      text: user?.specialization ?? rawMap['specialization']?.toString() ?? '',
    );
    _selectedGender = user?.gender ?? rawMap['gender']?.toString();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _localityController.dispose();
    _expController.dispose();
    _specController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updateData = {
      'user': {
        'fname': _fnameController.text.trim(),
        'lname': _lnameController.text.trim(),
        'gender': _selectedGender,
      },
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'locality': _localityController.text.trim(),
      'experienceYears': int.tryParse(_expController.text.trim()) ?? 0,
      'specialization': _specController.text.trim(),
    };

    try {
      await ref.read(authProvider.notifier).updateTechnicianProfile(updateData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _fnameController,
                            label: 'First Name',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]'))
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) {
                                return 'Only letters and spaces allowed';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _lnameController,
                            label: 'Last Name',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]'))
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) {
                                return 'Only letters and spaces allowed';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(v)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildGenderDropdown(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Work Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _specController,
                      label: 'Specialization (e.g. AC Repair)',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) {
                          return 'Only letters and spaces allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _expController,
                      label: 'Years of Experience',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final years = int.tryParse(v);
                        if (years == null) return 'Invalid number';
                        if (years < 0) return 'Experience cannot be negative';
                        if (years > 50) return 'Experience cannot exceed 50 years';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Address Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Street Address',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _localityController,
                            label: 'Locality',
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _stateController,
                            label: 'State',
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _pincodeController,
                            label: 'Pincode',
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: [
        'Male',
        'Female',
        'Other',
      ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }
}
