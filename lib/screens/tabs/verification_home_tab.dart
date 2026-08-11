import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/registration_form_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/widgets/dashboard/modern_dashboard.dart';

import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/data/models/user_model.dart';

class VerificationHomeTab extends ConsumerStatefulWidget {
  final VoidCallback? onVerified;
  const VerificationHomeTab({super.key, this.onVerified});

  @override
  ConsumerState<VerificationHomeTab> createState() =>
      _VerificationHomeTabState();
}

class _VerificationHomeTabState extends ConsumerState<VerificationHomeTab> {
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _dlController = TextEditingController();

  String? _aadharPath;
  String? _aadharBackPath;
  String? _panPath;
  String? _dlPath;

  bool _isLoading = false;
  final bool _isRefreshingKYC = false;
  bool _hasSeenSuccess = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _checkSuccessStatus();
        _prefillData();
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

  void _listenToAuthState(WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      if (previous != next) {
        _prefillData();
      }
    });
  }

  Future<void> _checkSuccessStatus() async {
    final seen = await ref.read(authProvider.notifier).hasSeenSuccess();
    if (mounted) setState(() => _hasSeenSuccess = seen);
  }

  void _prefillData() {
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

          // Prefill images from URLs
          setState(() {
            // Helper to get image from multiple possible keys
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

              _aadharBackPath ??= getImg(kyc, [
                'aadhaarBack',
                'aadhaar_back',
                'aadharBack',
                'aadhar_back',
                'aadhaarBackUrl',
                'aadharBackUrl',
              ]);

              if (_aadharBackPath == null) {
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
                'pan_url'
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
      }
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    }
  }

  Future<void> _submitVerification() async {
    if (_aadharController.text.isEmpty ||
        _panController.text.isEmpty ||
        _dlController.text.isEmpty) {
      ErrorHandler.showError(context, 'Please fill all number fields');
      return;
    }

    if (_aadharPath == null ||
        _aadharBackPath == null ||
        _panPath == null ||
        _dlPath == null) {
      ErrorHandler.showError(context, 'Please upload all images');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).submitFullKYC(
            aadhaarNumber: _aadharController.text.trim(),
            panNumber: _panController.text.trim().toUpperCase(),
            drivingLicenseNumber: _dlController.text.trim(),
            aadhaarPath: _aadharPath!,
            aadhaarBackPath: _aadharBackPath!,
            panPath: _panPath!,
            dlPath: _dlPath!,
          );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verification Submitted'),
        content: const Text(
          'Your documents have been submitted successfully. We will review them shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onVerified?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _listenToAuthState(ref);
    final authState = ref.watch(authProvider);

    return authState.maybeWhen(
      authenticated: (user) {
        // 1) Relaxed constraint: Show dashboard immediately if kycVerified is true AND trainingCompleted is true
        // regardless of bank details for faster loading and better UX
        if (user.kycVerified == true && user.trainingCompleted == true) {
          if (_hasSeenSuccess) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(dashboardDataProvider.notifier).refresh(),
              child: const ModernDashboard(showHeader: true),
            );
          } else {
            return _buildVerifiedHome(user);
          }
        }

        // 2) If KYC is submitted but pending, or if training is pending
        if (user.kycVerified == true ||
            (user.kycStatus != null &&
                user.kycStatus != 'none' &&
                user.kycStatus != '')) {
          return _buildPendingHome(user);
        }

        // Otherwise show verification form
        return _buildVerificationForm();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (msg) => ErrorBoundary(
        message: ErrorHandler.parseError(msg),
        onRetry: () => ref.read(authProvider.notifier).checkAuth(),
        showTitle: false,
        isElevated: true,
        onLoginAgain: () => ref.read(authProvider.notifier).logout(),
      ),
      orElse: () => ErrorBoundary(
        message: "Your account is not active.\nPlease contact support.",
        onRetry: () => ref.read(authProvider.notifier).checkAuth(),
        showTitle: false,
        isElevated: true,
        onLoginAgain: () => ref.read(authProvider.notifier).logout(),
      ),
    );
  }

  Widget _buildVerifiedHome(UserModel user) {
    final name = user.fullDisplayName;
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 80,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          "Welcome $name",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "You are verified and ready to work!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).markSuccessSeen();
                if (mounted) setState(() => _hasSeenSuccess = true);
              },
              child: const Text(
                'Go to Dashboard',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Expanded(child: ModernDashboard(showHeader: false)),
      ],
    );
  }

  Widget _buildPendingHome(UserModel user) {
    final bool isTrainingPending = user.kycVerified == true && user.trainingCompleted != true;
    final String statusMessage = isTrainingPending
        ? "Training pending. Please complete your training to proceed!"
        : "Verification pending approval.\nWe'll notify you once complete!";

    return ModernDashboard(
      showHeader: false,
      topSlivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.hourglass_empty_rounded,
                size: 80,
                color: Colors.orange,
              ),
              if (_isRefreshingKYC) ...[
                const SizedBox(height: 12),
                _buildStatusIndicator(),
              ],
              const SizedBox(height: 16),
              Text(
                "Hello ${user.fullDisplayName}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 8),
        Text(
          "Checking status...",
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Partner Verification",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSection(
            "Aadhar Front",
            _aadharController,
            "Enter Aadhar Number",
            _aadharPath,
            () => _pickImage('aadhar'),
            title2: "Aadhar Back",
            path2: _aadharBackPath,
            onUpload2: () => _pickImage('aadhar_back'),
          ),
          const SizedBox(height: 24),
          _buildSection(
            "PAN Card Front",
            _panController,
            "Enter PAN Number",
            _panPath,
            () => _pickImage('pan'),
          ),
          const SizedBox(height: 24),
          _buildSection(
            "Driving License",
            _dlController,
            "Enter License Number",
            _dlPath,
            () => _pickImage('dl'),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitVerification,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Verification'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    TextEditingController controller,
    String hint,
    String? path,
    VoidCallback onUpload, {
    String? title2,
    String? path2,
    VoidCallback? onUpload2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onUpload,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: path != null ? Colors.green : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: path != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: path.startsWith('http')
                                ? Image.network(path, fit: BoxFit.cover)
                                : Image.file(File(path), fit: BoxFit.cover),
                          )
                        : const Icon(
                            Icons.cloud_upload_outlined,
                            color: Colors.grey,
                            size: 40,
                          ),
                  ),
                ),
              ),
            ),
            if (onUpload2 != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onUpload2,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: path2 != null ? Colors.green : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: path2 != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: path2.startsWith('http')
                                  ? Image.network(path2, fit: BoxFit.cover)
                                  : Image.file(File(path2), fit: BoxFit.cover),
                            )
                          : const Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
