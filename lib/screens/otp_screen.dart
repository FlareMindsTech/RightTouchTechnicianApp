import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
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
    with SingleTickerProviderStateMixin, CodeAutoFill {
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
    listenForCode();
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
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

        if (result['success'] == true) {
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

    for (var controller in _controllers) {
      controller.clear();
    }

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
  void codeUpdated() {
    if (code != null && code!.isNotEmpty) {
      _fillOtp(code!);
    }
  }

  void _fillOtp(String rawCode) {
    final digits = Validators.normalizeDigitsOnly(rawCode);
    for (int i = 0; i < 4; i++) {
      if (i < digits.length) {
        _controllers[i].text = digits[i];
      } else {
        _controllers[i].clear();
      }
    }

    if (digits.length >= 4) {
      if (mounted) {
        HapticFeedback.mediumImpact();
        _handleVerify(widget.identifier ?? "");
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    cancel();
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
    HapticFeedback.selectionClick();
    if (value.length == 4) {
      HapticFeedback.mediumImpact();
      _handleVerify(widget.identifier ?? "");
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Verification Code",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                // Top Trust Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "SECURE OTP VERIFICATION",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                OtpHeaderSection(
                  identifier: identifier,
                  onEditPhone: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 36),

                // Sleek PIN Input Card
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppTheme.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      OtpPinInputRow(
                        controllers: _controllers,
                        focusNodes: _focusNodes,
                        onChanged: _onChanged,
                        onOtpPasted: _fillOtp,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Enter the 4-digit verification code sent to your phone",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Primary Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : () => _handleVerify(identifier),
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
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "VERIFY & CONTINUE",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 28),

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
      ),
    );
  }
}
