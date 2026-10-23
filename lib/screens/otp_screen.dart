import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/screens/auth/widgets/otp_header_section.dart';
import 'package:right_touch/screens/auth/widgets/otp_pin_input_row.dart';
import 'package:right_touch/screens/auth/widgets/otp_resend_footer.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/validators.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String? identifier;
  final bool isLogin;
  const OtpScreen({super.key, this.identifier, this.isLogin = false});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isLoading = false;

  Timer? _timer;
  int _secondsRemaining = 120;
  bool _canResend = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();

    // Auto focus first box after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 120;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  void _listenToAuthState(WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (user) {
          if (mounted) {
            if (!user.isProfileComplete) {
              context.go('/profile-setup');
            } else if (!user.areKycDocumentsSubmitted) {
              context.go('/kyc-documents');
            } else if (!user.hasBankDetails) {
              context.go('/bank-details');
            } else {
              context.go('/dashboard');
            }
          }
        },
        error: (message) {
          if (mounted) {
            setState(() => _isLoading = false);
            ErrorHandler.showError(context, message);
          }
        },
        unauthenticated: () {
          if (mounted) {
            context.go('/login');
          }
        },
        orElse: () {},
      );
    });
  }

  Future<void> _handleVerify(String identifier) async {
    final otp = _controllers.map((c) => c.text).join();
    final otpError = Validators.validateOtp(otp, length: 4);
    if (otpError != null) {
      ErrorHandler.showError(context, otpError);
      return;
    }

    if (widget.isLogin) {
      if (mounted) setState(() => _isLoading = true);
      unawaited(ref.read(authProvider.notifier).verifyOtpAndLogin(identifier, otp));
    } else {
      if (mounted) setState(() => _isLoading = true);
      try {
        final result =
            await ref.read(authRepositoryProvider).verifyOtp(identifier, otp);
        if (mounted) setState(() => _isLoading = false);

        if (result['success']) {
          if (mounted) unawaited(context.push('/profile-setup'));
        } else {
          if (mounted) {
            ErrorHandler.showError(context, result['message'] ?? 'Invalid OTP');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  Future<void> _resendCode(String identifier) async {
    if (!_canResend) return;

    // Clear existing boxes
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    if (mounted) setState(() => _isLoading = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.resendOtp(identifier);
      if (mounted) setState(() => _isLoading = false);

      if (mounted) {
        if (result['success'] || result['statusCode'] == 200) {
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP resent successfully'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ErrorHandler.showError(
            context,
            result['message'] ?? 'Failed to resend OTP',
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

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Handle multi-character paste
    if (value.length > 1) {
      final digits = Validators.normalizeDigitsOnly(value);
      for (int i = 0; i < 4 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 4) {
        _focusNodes[3].unfocus();
        HapticFeedback.mediumImpact();
        _handleVerify(widget.identifier ?? "");
      } else if (digits.isNotEmpty) {
        final nextIndex = digits.length < 4 ? digits.length : 3;
        _focusNodes[nextIndex].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      HapticFeedback.selectionClick();
      if (index < 3) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
        // Auto submit if all 4 are filled
        final fullCode = _controllers.map((c) => c.text).join();
        if (fullCode.length == 4) {
          HapticFeedback.mediumImpact();
          _handleVerify(widget.identifier ?? "");
        }
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLogin) {
      _listenToAuthState(ref);
    }
    final authState = ref.watch(authProvider);
    final isGlobalLoading = widget.isLogin &&
        authState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
    final isLoading = _isLoading || isGlobalLoading;
    final identifier = widget.identifier ?? "";

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: const BackButton(color: AppTheme.textPrimary),
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          "Verification",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OtpHeaderSection(
                identifier: identifier,
                onEditPhone: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 40),
              OtpPinInputRow(
                controllers: _controllers,
                focusNodes: _focusNodes,
                onChanged: _onChanged,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _handleVerify(identifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const RtLoader.button(color: AppTheme.white)
                      : const Text(
                          "Verify & Proceed",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              OtpResendFooter(
                isLoading: isLoading,
                canResend: _canResend,
                secondsRemaining: _secondsRemaining,
                onResend: () => _resendCode(identifier),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

