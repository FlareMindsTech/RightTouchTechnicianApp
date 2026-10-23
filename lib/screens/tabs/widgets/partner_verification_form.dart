import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/registration_form_provider.dart';
import 'package:right_touch/screens/tabs/widgets/document_upload_field.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class PartnerVerificationForm extends ConsumerStatefulWidget {
  final VoidCallback? onVerified;
  const PartnerVerificationForm({super.key, this.onVerified});

  @override
  ConsumerState<PartnerVerificationForm> createState() =>
      _PartnerVerificationFormState();
}

class _PartnerVerificationFormState
    extends ConsumerState<PartnerVerificationForm> {
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _dlController = TextEditingController();

  String? _aadharPath;
  String? _aadharBackPath;
  String? _panPath;
  String? _dlPath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) _prefillData();
    });
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _panController.dispose();
    _dlController.dispose();
    super.dispose();
  }

  void _prefillData() {
    final authState = ref.read(authProvider);
    authState.maybeWhen(
      authenticated: (user) {
        final kyc = user.kycDetails;
        if (kyc == null) return;

        if (_aadharController.text.isEmpty) {
          _aadharController.text = kyc['aadhaarNumber']?.toString() ?? '';
        }
        if (_panController.text.isEmpty) {
          _panController.text = kyc['panNumber']?.toString() ?? '';
        }
        if (_dlController.text.isEmpty) {
          _dlController.text = kyc['drivingLicenseNumber']?.toString() ?? '';
        }

        setState(() {
          String? getImg(Map<String, dynamic> map, List<String> keys) {
            for (final k in keys) {
              final val = map[k];
              if (val != null) {
                final res = _parseImgValue(val);
                if (res != null) return res;
              }
            }
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
      },
      orElse: () {},
    );
  }

  String? _parseImgValue(dynamic val) {
    if (val == null) return null;
    if (val is String && val.isNotEmpty) return val;
    if (val is List && val.isNotEmpty) return _parseImgValue(val[0]);
    if (val is Map) {
      return val['url']?.toString() ??
          val['path']?.toString() ??
          val['image']?.toString() ??
          val['secure_url']?.toString();
    }
    return null;
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
          DocumentUploadField(
            title: "Aadhar Front",
            controller: _aadharController,
            hint: "Enter Aadhar Number",
            path: _aadharPath,
            onUpload: () => _pickImage('aadhar'),
            title2: "Aadhar Back",
            path2: _aadharBackPath,
            onUpload2: () => _pickImage('aadhar_back'),
          ),
          const SizedBox(height: 24),
          DocumentUploadField(
            title: "PAN Card Front",
            controller: _panController,
            hint: "Enter PAN Number",
            path: _panPath,
            onUpload: () => _pickImage('pan'),
          ),
          const SizedBox(height: 24),
          DocumentUploadField(
            title: "Driving License",
            controller: _dlController,
            hint: "Enter License Number",
            path: _dlPath,
            onUpload: () => _pickImage('dl'),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitVerification,
              child: _isLoading
                  ? const RtLoader.button(color: AppTheme.white)
                  : const Text('Submit Verification'),
            ),
          ),
        ],
      ),
    );
  }
}
