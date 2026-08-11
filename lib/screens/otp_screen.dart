import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';

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
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
    if (otp.length < 4) {
      ErrorHandler.showError(context, 'Please enter the 4-digit code');
      return;
    }

    if (widget.isLogin) {
      if (mounted) setState(() => _isLoading = true);
      ref.read(authProvider.notifier).verifyOtpAndLogin(identifier, otp);
    } else {
      if (mounted) setState(() => _isLoading = true);
      try {
        final result =
            await ref.read(authRepositoryProvider).verifyOtp(identifier, otp);
        if (mounted) setState(() => _isLoading = false);

        if (result['success']) {
          if (mounted) context.push('/profile-setup');
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
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
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
    final isGlobalLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final isLoading = _isLoading || isGlobalLoading;
    final identifier = widget.identifier ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: AppTheme.textPrimary),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Verify Your Number",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Enter 4-digit code sent to",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                identifier,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 64,
                    height: 64,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      onChanged: (value) => _onChanged(value, index),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _handleVerify(identifier),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Verify now",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  Text(
                    "Didn't receive code?",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: isLoading || !_canResend
                            ? null
                            : () => _resendCode(identifier),
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: _canResend
                                ? AppTheme.primaryColor
                                : AppTheme.textTertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (!_canResend)
                        Text(
                          _formatTimer(_secondsRemaining),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
