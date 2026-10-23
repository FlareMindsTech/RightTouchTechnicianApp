import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/registration_form_provider.dart';
import 'package:right_touch/screens/auth/utils/profile_prefill_helper.dart';
import 'package:right_touch/screens/auth/widgets/profile_address_fields.dart';
import 'package:right_touch/screens/auth/widgets/profile_personal_fields.dart';
import 'package:right_touch/screens/auth/widgets/profile_professional_fields.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import 'package:right_touch/widgets/success_overlay.dart';
import 'package:right_touch/utils/app_theme.dart';

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

  String _gender = 'Male';
  List<dynamic> _services = [];
  final List<Map<String, dynamic>> _selectedServices = [];
  bool _isFetchingServices = false;
  bool _submitted = false;
  bool _isSaving = false;

  static List<dynamic>? _cachedServices;

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

  Future<void> _fetchServices() async {
    final cached = _cachedServices;
    if (cached != null && cached.isNotEmpty) {
      setState(() => _services = cached);
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
        ProfilePrefillHelper.prefillControllers(
          user: user,
          fname: _fnameController,
          lname: _lnameController,
          email: _emailController,
          address: _addressController,
          city: _cityController,
          state: _stateController,
          pincode: _pincodeController,
          locality: _localityController,
          exp: _expController,
          specialization: _specializationController,
          onGender: (g) {
            if (_gender == 'Male') setState(() => _gender = g);
          },
        );

        if (_selectedServices.isEmpty) {
          final resolved = ProfilePrefillHelper.resolveInitialSkills(
            user: user,
            services: _services,
          );
          if (resolved.isNotEmpty) {
            setState(() {
              _selectedServices.clear();
              _selectedServices.addAll(resolved);
            });
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
          if (wasLoading && user.isProfileComplete) {
            HapticFeedback.heavyImpact();
            final VoidCallback? callback = !user.areKycDocumentsSubmitted ||
                    !user.hasBankDetails
                ? widget.onNext
                : widget.onComplete;

            SuccessOverlay.show(
              context,
              message: 'Profile Complete!',
              subtitle: !user.areKycDocumentsSubmitted
                  ? 'Proceeding to verification...'
                  : (!user.hasBankDetails
                      ? 'Proceeding to bank details...'
                      : null),
              duration: const Duration(milliseconds: 1400),
              onDone: () {
                if (mounted) callback?.call();
              },
            );
          }
        },
        error: (message) {
          if (wasLoading && context.mounted) {
            ErrorHandler.showError(context, message);
          }
        },
        orElse: () {},
      );
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return;
    await HapticFeedback.mediumImpact();
    setState(() {
      _submitted = true;
      _isSaving = true;
    });

    try {
      final formState = _formKey.currentState;
      if (formState == null || !formState.validate()) return;

      if (_selectedServices.isEmpty) {
        if (!mounted) return;
        ErrorHandler.showError(context, 'Please select at least one skill');
        return;
      }

      final authState = ref.read(authProvider);
      var user = authState.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      if (user == null) {
        await ref.read(authProvider.notifier).checkAuth(silent: true);
        if (!mounted) return;
        user = ref
            .read(authProvider)
            .maybeWhen(authenticated: (user) => user, orElse: () => null);
      }

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session mismatch. Please wait or log in again.'),
          ),
        );
        return;
      }

      final profileData = ProfilePrefillHelper.buildProfilePayload(
        user: user,
        fname: _fnameController.text,
        lname: _lnameController.text,
        email: _emailController.text,
        gender: _gender,
        locality: _localityController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        exp: _expController.text,
        specialization: _specializationController.text,
        selectedServices: _selectedServices,
      );

      await ref.read(authProvider.notifier).completeProfile(profileData);
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _listenToAuthState(ref);
    final authState = ref.watch(authProvider);

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
                  style: TextStyle(fontSize: 16, color: AppTheme.grey),
                ),
                const SizedBox(height: 24),
                ProfilePersonalFields(
                  fnameController: _fnameController,
                  lnameController: _lnameController,
                  emailController: _emailController,
                  gender: _gender,
                  onGenderChanged: (val) {
                    setState(() => _gender = val);
                    _autoSave();
                  },
                ),
                const SizedBox(height: 16),
                ProfileAddressFields(
                  addressController: _addressController,
                  localityController: _localityController,
                  cityController: _cityController,
                  stateController: _stateController,
                  pincodeController: _pincodeController,
                ),
                const SizedBox(height: 16),
                ProfileProfessionalFields(
                  specializationController: _specializationController,
                  expController: _expController,
                  services: _services,
                  selectedServices: _selectedServices,
                  isFetchingServices: _isFetchingServices,
                  isSubmitted: _submitted,
                  onToggleSkill: (service, isSelected) {
                    final id = service['_id'] ?? service['id'];
                    if (isSelected) {
                      _selectedServices.removeWhere(
                        (s) => (s['_id'] ?? s['id']) == id,
                      );
                    } else {
                      _selectedServices.add(service);
                    }
                    setState(() {});
                    _autoSave();
                  },
                  onRemoveSkill: (service) {
                    setState(() {
                      _selectedServices.remove(service);
                    });
                    _autoSave();
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    child: isLoading
                        ? const RtLoader.button(color: AppTheme.white)
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
}
