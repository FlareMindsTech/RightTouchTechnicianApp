import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/registration_form_provider.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/success_overlay.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onComplete;
  const ProfileSetupScreen({super.key, this.onNext, this.onComplete});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _skillSearchController = TextEditingController();

  String _gender = 'Male';

  List<dynamic> _services = [];
  final List<Map<String, dynamic>> _selectedServices = [];
  bool _isFetchingServices = false;
  // Only show skill validation error after user has attempted submit
  bool _submitted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviderState();
      _prefillFields();

      for (final c in [
        _fnameController,
        _lnameController,
        _emailController,
        _addressController,
        _cityController,
        _stateController,
        _pincodeController,
        _localityController,
        _expController,
        _specializationController,
      ]) {
        c.addListener(_autoSave);
      }
    });
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
    _specializationController.dispose();
    _skillSearchController.dispose();
    super.dispose();
  }

  void _loadProviderState() {
    final state = ref.read(registrationFormProvider);
    if (state.fname.isNotEmpty) _fnameController.text = state.fname;
    if (state.lname.isNotEmpty) _lnameController.text = state.lname;
    if (state.email.isNotEmpty) _emailController.text = state.email;
    if (state.address.isNotEmpty) _addressController.text = state.address;
    if (state.city.isNotEmpty) _cityController.text = state.city;
    if (state.state.isNotEmpty) _stateController.text = state.state;
    if (state.pincode.isNotEmpty) _pincodeController.text = state.pincode;
    if (state.locality.isNotEmpty) _localityController.text = state.locality;
    if (state.exp.isNotEmpty) _expController.text = state.exp;
    if (state.specialization.isNotEmpty) {
      _specializationController.text = state.specialization;
    }
    setState(() {
      if (state.gender.isNotEmpty) _gender = state.gender;
      // Restore skills from provider — this is the source of truth after saving
      if (state.selectedServices.isNotEmpty && _selectedServices.isEmpty) {
        _selectedServices.clear();
        _selectedServices.addAll(state.selectedServices);
      }
    });
  }

  void _autoSave() {
    ref.read(registrationFormProvider.notifier).updateProfile(
          fname: _fnameController.text,
          lname: _lnameController.text,
          email: _emailController.text,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          pincode: _pincodeController.text,
          locality: _localityController.text,
          exp: _expController.text,
          specialization: _specializationController.text,
          gender: _gender,
          selectedServices: _selectedServices,
        );
  }

  // In-memory cache for services list (#9 API Caching)
  static List<dynamic>? _cachedServices;

  Future<void> _fetchServices() async {
    // Return cached data immediately
    if (_cachedServices != null && _cachedServices!.isNotEmpty) {
      setState(() => _services = _cachedServices!);
      // Re-run prefill so skills stored as IDs can now be resolved with the fetched list
      _prefillFields();
      return;
    }
    setState(() => _isFetchingServices = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.getAllServices();
      List<dynamic> result = [];
      if (response is List) {
        result = response;
      } else if (response is Map) {
        dynamic data =
            response['result'] ?? response['data'] ?? response['services'];
        if (data is Map) {
          data = data['result'] ?? data['data'] ?? data['services'] ?? data;
        }
        result = data is List ? data : [];
      }
      _cachedServices = result;
      setState(() {
        _services = result;
        _isFetchingServices = false;
      });
      // Re-run prefill so skill IDs can be resolved now
      _prefillFields();
    } catch (e) {
      setState(() => _isFetchingServices = false);
      debugPrint('Error fetching services: $e');
    }
  }

  void _prefillFields() {
    final authState = ref.read(authProvider);
    authState.maybeWhen(
      authenticated: (user) {
        final raw = user.rawData ?? {};
        if (_fnameController.text.isEmpty) {
          _fnameController.text = user.firstName?.isNotEmpty == true
              ? user.firstName!
              : raw['fname']?.toString() ?? '';
        }
        if (_lnameController.text.isEmpty) {
          _lnameController.text = user.lastName?.isNotEmpty == true
              ? user.lastName!
              : raw['lname']?.toString() ?? '';
        }
        if (_emailController.text.isEmpty) {
          _emailController.text = user.email?.isNotEmpty == true
              ? user.email!
              : raw['email']?.toString() ?? '';
        }
        if (_addressController.text.isEmpty) {
          _addressController.text =
              user.address ?? raw['address']?.toString() ?? '';
        }
        if (_cityController.text.isEmpty) {
          _cityController.text = user.city ?? raw['city']?.toString() ?? '';
        }
        if (_stateController.text.isEmpty) {
          _stateController.text = user.state ?? raw['state']?.toString() ?? '';
        }
        if (_pincodeController.text.isEmpty) {
          _pincodeController.text =
              user.pincode ?? raw['pincode']?.toString() ?? '';
        }
        if (_localityController.text.isEmpty) {
          _localityController.text =
              user.locality ?? raw['locality']?.toString() ?? '';
        }
        if (_expController.text.isEmpty) {
          _expController.text =
              (user.experienceYears ?? raw['experienceYears'])?.toString() ??
                  '';
        }
        if (_specializationController.text.isEmpty) {
          _specializationController.text =
              user.specialization ?? raw['specialization']?.toString() ?? '';
        }
        final genderVal = user.gender?.isNotEmpty == true
            ? user.gender
            : raw['gender']?.toString();
        if (genderVal != null && genderVal.isNotEmpty && _gender == 'Male') {
          setState(() {
            _gender = genderVal;
          });
        }
        // Pre-fill skills: use skillObjects (full name+id) from getProfile() as priority,
        // then fall back to plain ID matching against loaded services list.
        if (_selectedServices.isEmpty) {
          final skillObjects = user.rawData?['skillObjects'];
          if (skillObjects is List && skillObjects.isNotEmpty) {
            // Best case: full skill objects preserved by auth_repository
            final resolved = <Map<String, dynamic>>[];
            for (var s in skillObjects) {
              if (s is Map && s['_id']?.toString().isNotEmpty == true) {
                resolved.add({
                  '_id': s['_id'].toString(),
                  'serviceName': s['serviceName']?.toString() ?? '',
                });
              }
            }
            if (resolved.isNotEmpty) {
              setState(() {
                _selectedServices.clear();
                _selectedServices.addAll(resolved);
              });
            }
          } else {
            // Fallback: match plain skill IDs against loaded services list
            final rawSkills = user.rawData?['skills'];
            if (rawSkills is List &&
                rawSkills.isNotEmpty &&
                _services.isNotEmpty) {
              final resolved = <Map<String, dynamic>>[];
              for (var skill in rawSkills) {
                final id = skill is String
                    ? skill
                    : (skill is Map ? skill['_id']?.toString() : null);
                if (id == null || id.isEmpty) continue;
                final match = _services.firstWhere(
                  (s) => (s['_id'] ?? s['id'])?.toString() == id,
                  orElse: () => <String, dynamic>{},
                );
                if (match.isNotEmpty) {
                  resolved.add(Map<String, dynamic>.from(match));
                }
              }
              if (resolved.isNotEmpty) {
                setState(() {
                  _selectedServices.clear();
                  _selectedServices.addAll(resolved);
                });
              }
            }
          }
        }
      },
      orElse: () {},
    );
  }

  void _listenToAuthState(WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      final wasLoading =
          previous?.maybeWhen(loading: () => true, orElse: () => false) ??
              false;

      next.maybeWhen(
        authenticated: (user) {
          debugPrint(
            'ProfileSetup: authenticated. wasLoading: $wasLoading, isProfileComplete: ${user.isProfileComplete}',
          );
          if (wasLoading && user.isProfileComplete) {
            HapticFeedback.heavyImpact();
            if (!user.areKycDocumentsSubmitted) {
              SuccessOverlay.show(
                context,
                message: 'Profile Complete!',
                subtitle: 'Proceeding to verification...',
                duration: const Duration(milliseconds: 1400),
                onDone: () {
                  if (mounted && widget.onNext != null) widget.onNext!();
                },
              );
            } else if (!user.hasBankDetails) {
              SuccessOverlay.show(
                context,
                message: 'Profile Complete!',
                subtitle: 'Proceeding to bank details...',
                duration: const Duration(milliseconds: 1400),
                onDone: () {
                  if (mounted && widget.onNext != null) widget.onNext!();
                },
              );
            } else {
              SuccessOverlay.show(
                context,
                message: 'Profile Complete!',
                duration: const Duration(milliseconds: 1400),
                onDone: () {
                  if (mounted && widget.onComplete != null) {
                    widget.onComplete!();
                  }
                },
              );
            }
          }
        },
        error: (message) {
          if (wasLoading) {
            if (!context.mounted) return;
            ErrorHandler.showError(context, message);
          }
        },
        orElse: () {},
      );
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return;
    debugPrint('ProfileSetup: _handleSubmit called');
    HapticFeedback.mediumImpact();

    setState(() {
      _submitted = true;
      _isSaving = true;
    });

    try {
      if (!_formKey.currentState!.validate()) {
        debugPrint('ProfileSetup: Form validation failed');
        return;
      }
      if (_selectedServices.isEmpty) {
        debugPrint('ProfileSetup: Skill selection missing');
        ErrorHandler.showError(context, 'Please select at least one skill');
        return;
      }

      debugPrint('ProfileSetup: Validation passed. constructing profileData');
      final authState = ref.read(authProvider);
      var user = authState.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      // Critical fallback: if state is loading, we might still have user info in
      // storage. If it's truly empty, we show the error.
      if (user == null) {
        debugPrint('ProfileSetup: User is null, attempting quick re-fetch');
        await ref.read(authProvider.notifier).checkAuth(silent: true);
        if (!mounted) return;
        user = ref
            .read(authProvider)
            .maybeWhen(authenticated: (user) => user, orElse: () => null);
      }

      if (user == null) {
        debugPrint(
          'ProfileSetup: User is STILL null, cannot proceed. Current state: ${ref.read(authProvider)}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session mismatch. Please wait or log in again.'),
          ),
        );
        return;
      }

      debugPrint(
        'ProfileSetup: Construction details: fname=${_fnameController.text}, skillsCount=${_selectedServices.length}',
      );

      final skills = _selectedServices.map((s) {
        final id = s['_id']?.toString() ?? s['id']?.toString();
        return {
          "serviceId": id,
          "experienceYears": int.tryParse(_expController.text.trim()) ?? 0,
        };
      }).toList();

      final profileData = {
        "fname": _fnameController.text.trim(),
        "lname": _lnameController.text.trim(),
        "email": _emailController.text.trim(),
        "mobileNumber": user.mobileNumber ?? "",
        "gender": _gender,
        "locality": _localityController.text.trim(),
        "address": _addressController.text.trim(),
        "city": _cityController.text.trim(),
        "state": _stateController.text.trim(),
        "pincode": _pincodeController.text.trim(),
        "experienceYears": int.tryParse(_expController.text) ?? 0,
        "specialization": _specializationController.text.trim(),
        "skills": skills,
        "profileComplete": true,
      };

      debugPrint('ProfileSetup: Calling completeProfile with data');
      await ref.read(authProvider.notifier).completeProfile(profileData);
    } catch (e) {
      debugPrint('ProfileSetup: Error in _handleSubmit: $e');
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSkillSelectionSheet() {
    _skillSearchController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final searchText = _skillSearchController.text.toLowerCase();
            final filteredServices = _services.where((service) {
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
                    // Polished drag handle
                    Container(
                      height: 4,
                      width: 36,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
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
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _skillSearchController,
                          decoration: InputDecoration(
                            hintText: 'Search skills...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
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
                                final isSelected = _selectedServices.any(
                                  (s) =>
                                      (s['_id'] ?? s['id'])?.toString() == id,
                                );

                                return Material(
                                  color: isSelected
                                      ? Colors.green.withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setSheetState(() {
                                        if (isSelected) {
                                          _selectedServices.removeWhere(
                                            (s) =>
                                                (s['_id'] ?? s['id'])
                                                    ?.toString() ==
                                                id,
                                          );
                                        } else {
                                          _selectedServices.add(
                                            Map<String, dynamic>.from(service),
                                          );
                                        }
                                      });
                                      setState(() {}); // Update main screen
                                      _autoSave();
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
                                                    ? Colors.green.shade700
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.green.shade600,
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    _listenToAuthState(ref);
    final authState = ref.watch(authProvider);

    // Removal of aggressive forward guard to allow manual back-navigation
    // The SplashScreen and SuccessOverlay handle the primary forward transitions.

    final isAuthLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final isLoading = isAuthLoading || _isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tell us more about yourself",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _fnameController,
                        label: "First Name",
                        hint: "Enter first name",
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'))
                        ],
                        validator: _nameValidator,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lnameController,
                        label: "Last Name",
                        hint: "Enter last name",
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'))
                        ],
                        validator: _nameValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Enter your email address",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Required';
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Gender",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
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
                    selected: {_gender},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _gender = newSelection.first;
                      });
                      _autoSave();
                    },
                    style: SegmentedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: "Address",
                  hint: "Flat / Street / Area",
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _localityController,
                        label: "Locality",
                        hint: "e.g. T Nagar",
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'))
                        ],
                        validator: _nameValidator,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: "City",
                        hint: "e.g. Chennai",
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'))
                        ],
                        validator: _nameValidator,
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
                        label: "State",
                        hint: "e.g. TN",
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'))
                        ],
                        validator: _nameValidator,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _pincodeController,
                        label: "Pincode",
                        hint: "6 digits",
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (value.trim().length != 6) {
                            return 'Pincode must be exactly 6 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _specializationController,
                  label: "Specialization",
                  hint: "e.g. AC Repair, Electrician",
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                  ],
                  validator: _nameValidator,
                ),
                const SizedBox(height: 16),
                // Searchable Skill Selector
                const Text(
                  "Skill / Service",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _isFetchingServices
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : InkWell(
                        onTap: _showSkillSelectionSheet,
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
                            errorText: _submitted && _selectedServices.isEmpty
                                ? 'Please select at least one skill'
                                : null,
                          ),
                          child: _selectedServices.isEmpty
                              ? Text(
                                  'Select your skills',
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _selectedServices.map((s) {
                                    final name = s['serviceName']?.toString() ??
                                        s['name']?.toString() ??
                                        '';
                                    return Chip(
                                      label: Text(
                                        name,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedServices.remove(s);
                                        });
                                        _autoSave();
                                      },
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    );
                                  }).toList(),
                                ),
                        ),
                      ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _expController,
                  label: "Experience (Years)",
                  hint: "Years of experience",
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final years = int.tryParse(value.trim());
                    if (years == null) return 'Please enter a valid number';
                    if (years < 0) return 'Experience cannot be negative';
                    if (years > 50) return 'Experience cannot exceed 50 years';
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Next: KYC Documents"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Only letters and spaces allowed';
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
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
