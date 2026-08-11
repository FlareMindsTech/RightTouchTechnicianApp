import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/registration_form_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/success_overlay.dart';

// --- KYC Regex Patterns ---
// Aadhar: 12 digits
final _aadharRegex = RegExp(r'^\d{12}$');
// PAN: standard ABCDE1234F format
const String _panPattern = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$';
// DL: 2 uppercase letters + 2 digits + 4 digits + 7 digits = 2+2+4+7 = 15 chars per user spec
const String _dlPattern = r'^[A-Z]{2}[0-9]{2}[0-9]{4}[0-9]{7}$';

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

      // Allow network URLs (starting with http) or existing local files
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
        final kyc = user.kycDetails;
        if (kyc != null) {
          if (_aadharController.text.isEmpty) {
            _aadharController.text = kyc['aadhaarNumber']?.toString() ?? '';
          }
          if (_panController.text.isEmpty) {
            _panController.text = kyc['panNumber']?.toString() ?? '';
          }
          if (_dlController.text.isEmpty) {
            _dlController.text = kyc['drivingLicenseNumber']?.toString() ?? '';
          }

          // Prefill images from Cloudinary URLs if they exist
          setState(() {
            // Helper to get image from multiple possible keys and formats
            String? getImg(Map<String, dynamic> map, List<String> keys) {
              // Try root level first
              for (final k in keys) {
                final val = map[k];
                if (val != null) {
                  final res = _parseImgValue(val);
                  if (res != null) return res;
                }
              }
              // Try inside 'documents' if present
              final docs = map['documents'];
              if (docs is Map<String, dynamic>) {
                for (final k in keys) {
                  final val = docs[k];
                  if (val != null) {
                    final res = _parseImgValue(val);
                    if (res != null) return res;
                  }
                }
              }
              return null;
            }

            final notifier = ref.read(registrationFormProvider.notifier);

            if (_aadharPath == null || _aadharPath!.isEmpty) {
              _aadharPath = getImg(kyc, [
                'aadhaarFront',
                'aadhaar_front',
                'aadharFront',
                'aadhar_front',
                'aadhaarImage',
                'aadhaarUrl',
                'aadharImage',
                'aadharUrl'
              ]);

              if (_aadharPath != null) {
                notifier.updateKyc(aadharPath: _aadharPath);
              }

              // Try back side
              _aadharBackPath ??= getImg(kyc, [
                'aadhaarBack',
                'aadhaar_back',
                'aadharBack',
                'aadhar_back',
                'aadhaarBackUrl',
                'aadharBackUrl',
              ]);

              if (_aadharBackPath == null) {
                // Check if it's the second item in a list
                final aadharVal = kyc['aadhaarImage'] ??
                    kyc['aadhaarUrl'] ??
                    kyc['aadharImage'] ??
                    kyc['aadharUrl'] ??
                    (kyc['documents'] is Map
                        ? kyc['documents']['aadhaarUrl']
                        : null) ??
                    (kyc['documents'] is Map
                        ? kyc['documents']['aadhaarImage']
                        : null);

                if (aadharVal is List && aadharVal.length > 1) {
                  _aadharBackPath = _parseImgValue(aadharVal[1]);
                }
              }
              if (_aadharBackPath != null) {
                notifier.updateKyc(aadharBackPath: _aadharBackPath);
              }
            }

            if (_panPath == null || _panPath!.isEmpty) {
              _panPath = getImg(kyc, [
                'panImage',
                'panUrl',
                'panFront',
                'pan_front',
                'pan_image',
                'pan_url',
                'panCardFront'
              ]);
              if (_panPath != null) {
                notifier.updateKyc(panPath: _panPath);
              }
            }

            if (_dlPath == null || _dlPath!.isEmpty) {
              _dlPath = getImg(kyc, [
                'dlImage',
                'dlUrl',
                'dlFront',
                'dl_front',
                'dl_image',
                'dl_url',
                'drivingLicenseUrl',
                'drivingLicenseImage'
              ]);
              if (_dlPath != null) {
                notifier.updateKyc(dlPath: _dlPath);
              }
            }
          });
        }
      },
      orElse: () {},
    );
  }

  String? _parseImgValue(dynamic val) {
    if (val == null) return null;
    if (val is String && val.isNotEmpty) return val;
    if (val is List && val.isNotEmpty) {
      return _parseImgValue(val[0]);
    }
    if (val is Map) {
      return val['url']?.toString() ??
          val['path']?.toString() ??
          val['image']?.toString() ??
          val['secure_url']?.toString();
    }
    return null;
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
                  if (widget.onNext != null) {
                    widget.onNext!();
                  }
                }
              },
            );
          }

          // Trigger prefill if we just transition to authenticated or user changed
          if (wasLoading || previous != next) {
            _prefillFields();
          }
        },
        error: (message) {
          if (wasLoading) {
            if (!mounted) return;
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
    if (!_formKey.currentState!.validate()) return;

    if (_aadharPath == null ||
        _aadharBackPath == null ||
        _panPath == null ||
        _dlPath == null) {
      ErrorHandler.showError(context, 'Please upload all required documents');
      return;
    }

    // Strip spaces from Aadhar (formatted as XXXX XXXX XXXX)
    final aadhar = _aadharController.text.replaceAll(' ', '').trim();
    if (!_aadharRegex.hasMatch(aadhar)) {
      ErrorHandler.showError(
        context,
        'Aadhar number must be exactly 12 digits',
      );
      return;
    }

    final pan = _panController.text.trim().toUpperCase();
    if (!RegExp(_panPattern).hasMatch(pan)) {
      ErrorHandler.showError(
        context,
        'Invalid PAN format (Expected: ABCDE1234F)',
      );
      return;
    }

    final dl = _dlController.text.trim().toUpperCase();
    if (!RegExp(_dlPattern).hasMatch(dl)) {
      ErrorHandler.showError(
        context,
        'Invalid DL format (Expected: TN20245678901)',
      );
      return;
    }

    await ref.read(authProvider.notifier).submitFullKYC(
          aadhaarNumber: aadhar,
          panNumber: pan,
          drivingLicenseNumber: dl,
          aadhaarPath: _aadharPath!,
          aadhaarBackPath: _aadharBackPath!,
          panPath: _panPath!,
          dlPath: _dlPath!,
        );
  }

  Future<void> _pickImage(String type) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
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
                leading: const Icon(
                  Icons.photo_library,
                  color: AppTheme.primaryColor,
                ),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(type, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.primaryColor,
                ),
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
    );
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
    // 2️⃣ REMOVED ROUTING CONFLICT: No more context.go() guards here
    // Navigation is controlled by RegistrationFlowScreen based on successful submissions

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification"),
        leading: IconButton(
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
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
                      _buildKycCard(
                        "Aadhar Card",
                        "Format: 1234 1234 1234",
                        _aadharController,
                        "1234 5678 9012",
                        _aadharPath,
                        () => _pickImage('aadhar'),
                        Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        // 14 = 12 digits + 2 spaces
                        maxLength: 14,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _AadharInputFormatter(),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final digits = v.replaceAll(' ', '');
                          if (!_aadharRegex.hasMatch(digits)) {
                            return 'Must be exactly 12 digits';
                          }
                          return null;
                        },
                        localImageBackPath: _aadharBackPath,
                        onUploadBack: () => _pickImage('aadhar_back'),
                      ),
                      const SizedBox(height: 20),
                      _buildKycCard(
                        "PAN Card",
                        "Format:ABCDE1234F",
                        _panController,
                        "ABCDE1234F",
                        _panPath,
                        () => _pickImage('pan'),
                        Icons.credit_card_outlined,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9]'),
                          ),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (!RegExp(_panPattern).hasMatch(v.toUpperCase())) {
                            return 'Invalid format (e.g. ABCDE1234F)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildKycCard(
                        "Driving License",
                        "Format: TN20245678901",
                        _dlController,
                        "TN20245678901",
                        _dlPath,
                        () => _pickImage('dl'),
                        Icons.drive_eta_outlined,
                        textCapitalization: TextCapitalization.characters,
                        // 2+2+4+7 = 15 total characters
                        maxLength: 15,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9]'),
                          ),
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (!RegExp(_dlPattern).hasMatch(v.toUpperCase())) {
                            return 'Invalid format (e.g. TN20245678901)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: isLoading ? null : () => _handleSubmit(),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
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

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textTertiary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _stepItem("Profile", true, true),
          _stepDivider(true),
          _stepItem("KYC", true, false),
          _stepDivider(false),
          _stepItem("Bank", false, false),
        ],
      ),
    );
  }

  Widget _stepItem(String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.primaryColor
                : isActive
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.white,
            border: Border.all(
              color: isCompleted || isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textTertiary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive ? AppTheme.primaryColor : Colors.transparent,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
            color: isActive || isCompleted
                ? AppTheme.primaryColor
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(bool isCompleted) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Divider(
          color: isCompleted
              ? AppTheme.primaryColor
              : AppTheme.textTertiary.withValues(alpha: 0.3),
          thickness: 2,
        ),
      ),
    );
  }

  Widget _buildKycCard(
    String title,
    String subtitle,
    TextEditingController controller,
    String hint,
    String? localImagePath,
    VoidCallback onUpload,
    IconData icon, {
    String? localImageBackPath,
    VoidCallback? onUploadBack,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller,
              textCapitalization: textCapitalization,
              keyboardType: keyboardType,
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                counterText: "",
                prefixIcon: const Icon(Icons.edit_note, size: 20),
              ),
              onChanged: (val) {
                if (textCapitalization == TextCapitalization.characters) {
                  final upper = val.toUpperCase();
                  if (val != upper) {
                    controller.value = controller.value.copyWith(
                      text: upper,
                      selection: TextSelection.collapsed(offset: upper.length),
                    );
                  }
                }
              },
              validator: validator ??
                  (v) => v == null || v.isEmpty ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Front Side",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildUploadArea(localImagePath, onUpload),
                    ],
                  ),
                ),
                if (onUploadBack != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Back Side",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildUploadArea(localImageBackPath, onUploadBack),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(String? path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 120,
        decoration: BoxDecoration(
          color: path != null ? Colors.grey[50] : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: path != null
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : AppTheme.textTertiary.withValues(alpha: 0.2),
            style: path != null ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: path != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: path.startsWith('http')
                        ? Image.network(
                            path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.error)),
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 14,
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 28,
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Upload",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Auto-formats Aadhar input as XXXX XXXX XXXX
class _AadharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 12) {
      return oldValue; // don't allow more than 12 digits
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 8) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
