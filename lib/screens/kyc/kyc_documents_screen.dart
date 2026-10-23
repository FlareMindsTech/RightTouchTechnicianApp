import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/registration_form_provider.dart';
import 'package:right_touch/screens/kyc/utils/kyc_prefill_helper.dart';
import 'package:right_touch/screens/kyc/widgets/kyc_document_fields.dart';
import 'package:right_touch/screens/kyc/widgets/kyc_step_indicator.dart';
import 'package:right_touch/services/security_service.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/validators.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import 'package:right_touch/widgets/success_overlay.dart';
import 'package:right_touch/utils/app_theme.dart';

class KycDocumentsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const KycDocumentsScreen({super.key, this.onNext, this.onBack});

  @override
  ConsumerState<KycDocumentsScreen> createState() => _KycDocumentsScreenState();
}

class _KycDocumentsScreenState extends ConsumerState<KycDocumentsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _dlController = TextEditingController();

  String? _aadharPath;
  String? _aadharBackPath;
  String? _panPath;
  String? _dlPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviderState();
      _prefillFields();

      for (final c in [_aadharController, _panController, _dlController]) {
        c.addListener(_autoSave);
      }
    });
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _panController.dispose();
    _dlController.dispose();
    super.dispose();
  }

  void _loadProviderState() {
    final state = ref.read(registrationFormProvider);
    setState(() {
      if (state.aadharNumber.isNotEmpty) {
        _aadharController.text = state.aadharNumber;
      }
      if (state.panNumber.isNotEmpty) _panController.text = state.panNumber;
      if (state.dlNumber.isNotEmpty) _dlController.text = state.dlNumber;

      bool isValid(String? p) =>
          p != null &&
          p.isNotEmpty &&
          (p.startsWith('http') || File(p).existsSync());

      if (isValid(state.aadharPath)) _aadharPath = state.aadharPath;
      if (isValid(state.aadharBackPath)) _aadharBackPath = state.aadharBackPath;
      if (isValid(state.panPath)) _panPath = state.panPath;
      if (isValid(state.dlPath)) _dlPath = state.dlPath;
    });
  }

  void _autoSave() {
    ref.read(registrationFormProvider.notifier).updateKyc(
          aadharNumber: _aadharController.text,
          panNumber: _panController.text,
          dlNumber: _dlController.text,
          aadharPath: _aadharPath,
          aadharBackPath: _aadharBackPath,
          panPath: _panPath,
          dlPath: _dlPath,
        );
  }

  void _prefillFields() {
    final authState = ref.read(authProvider);
    authState.maybeWhen(
      authenticated: (user) {
        final prefill = KycPrefillHelper.extract(user);
        if (_aadharController.text.isEmpty && prefill.aadharNumber != null) {
          _aadharController.text = prefill.aadharNumber!;
        }
        if (_panController.text.isEmpty && prefill.panNumber != null) {
          _panController.text = prefill.panNumber!;
        }
        if (_dlController.text.isEmpty && prefill.dlNumber != null) {
          _dlController.text = prefill.dlNumber!;
        }

        setState(() {
          final notifier = ref.read(registrationFormProvider.notifier);
          if ((_aadharPath?.isEmpty ?? true) && prefill.aadharPath != null) {
            _aadharPath = prefill.aadharPath;
            notifier.updateKyc(aadharPath: _aadharPath);
          }
          if (_aadharBackPath == null && prefill.aadharBackPath != null) {
            _aadharBackPath = prefill.aadharBackPath;
            notifier.updateKyc(aadharBackPath: _aadharBackPath);
          }
          if ((_panPath?.isEmpty ?? true) && prefill.panPath != null) {
            _panPath = prefill.panPath;
            notifier.updateKyc(panPath: _panPath);
          }
          if ((_dlPath?.isEmpty ?? true) && prefill.dlPath != null) {
            _dlPath = prefill.dlPath;
            notifier.updateKyc(dlPath: _dlPath);
          }
        });
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
          final isKycNowSubmitted = (user.kycStatus == 'submitted' ||
              user.kycStatus == 'pending' ||
              user.kycStatus == 'approved' ||
              user.kycStatus == 'verified' ||
              user.kycVerified == true);

          if (wasLoading && isKycNowSubmitted) {
            HapticFeedback.heavyImpact();
            SuccessOverlay.show(
              context,
              message: 'Documents Submitted!',
              subtitle: 'Proceeding to bank details...',
              duration: const Duration(milliseconds: 1600),
              onDone: () {
                if (mounted) {
                  widget.onNext?.call();
                }
              },
            );
          }

          if (wasLoading || previous != next) {
            _prefillFields();
          }
        },
        error: (message) {
          if (wasLoading && mounted) {
            ErrorHandler.showError(
              context,
              message.isNotEmpty
                  ? message
                  : 'KYC submission failed. Please try again.',
            );
          }
        },
        orElse: () {},
      );
    });
  }

  Future<void> _handleSubmit() async {
    final securityError = await SecurityService.checkSensitiveActionSecurity();
    if (securityError != null) {
      if (mounted) {
        ErrorHandler.showError(context, securityError);
      }
      return;
    }

    if (!mounted) return;

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final aadharPath = _aadharPath;
    final aadharBackPath = _aadharBackPath;
    final panPath = _panPath;
    final dlPath = _dlPath;

    if (aadharPath == null ||
        aadharBackPath == null ||
        panPath == null ||
        dlPath == null) {
      ErrorHandler.showError(context, 'Please upload all required documents');
      return;
    }

    final aadharError = Validators.validateAadhaar(_aadharController.text);
    if (aadharError != null) {
      ErrorHandler.showError(context, aadharError);
      return;
    }

    final panError = Validators.validatePan(_panController.text);
    if (panError != null) {
      ErrorHandler.showError(context, panError);
      return;
    }

    final dlError = Validators.validateDrivingLicense(_dlController.text);
    if (dlError != null) {
      ErrorHandler.showError(context, dlError);
      return;
    }

    final aadhar = Validators.normalizeAadhaar(_aadharController.text);
    final pan = Validators.normalizePan(_panController.text);
    final dl = Validators.normalizeDrivingLicense(_dlController.text);

    await ref.read(authProvider.notifier).submitFullKYC(
          aadhaarNumber: aadhar,
          panNumber: pan,
          drivingLicenseNumber: dl,
          aadhaarPath: aadharPath,
          aadhaarBackPath: aadharBackPath,
          panPath: panPath,
          dlPath: dlPath,
        );
  }

  Future<void> _pickImage(String type) async {
    unawaited(showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Select Image Source",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.blue),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(type, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.blue),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(type, ImageSource.camera);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> _processImage(String type, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          if (type == 'aadhar') _aadharPath = image.path;
          if (type == 'aadhar_back') _aadharBackPath = image.path;
          if (type == 'pan') _panPath = image.path;
          if (type == 'dl') _dlPath = image.path;
        });
        _autoSave();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _listenToAuthState(ref);
    final authState = ref.watch(authProvider);

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification"),
        leading: IconButton(
          onPressed: () => widget.onBack?.call(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const KycStepIndicator(activeStep: 1),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "KYC Documents",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We need to verify your identity to ensure a safe experience for everyone.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      KycDocumentFields(
                        aadharController: _aadharController,
                        panController: _panController,
                        dlController: _dlController,
                        aadharPath: _aadharPath,
                        aadharBackPath: _aadharBackPath,
                        panPath: _panPath,
                        dlPath: _dlPath,
                        onPickAadhar: () => _pickImage('aadhar'),
                        onPickAadharBack: () => _pickImage('aadhar_back'),
                        onPickPan: () => _pickImage('pan'),
                        onPickDl: () => _pickImage('dl'),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: isLoading ? null : () => _handleSubmit(),
                        child: isLoading
                            ? const RtLoader.button(color: AppTheme.white)
                            : const Text("Next Step: Bank Details"),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
