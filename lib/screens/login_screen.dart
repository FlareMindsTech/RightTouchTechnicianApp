import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/ux_helpers.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/validators.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? identifier;
  const LoginScreen({super.key, this.identifier});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isPhoneComplete = false;
  bool _localLoading = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(text: widget.identifier);
    _isPhoneComplete = _checkPhoneComplete(_identifierController.text);
    _identifierController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final complete = _checkPhoneComplete(_identifierController.text);
    if (complete != _isPhoneComplete) {
      setState(() {
        _isPhoneComplete = complete;
      });
    }
  }

  bool _checkPhoneComplete(String text) {
    return text.trim().replaceAll(RegExp(r'\D'), '').length == 10;
  }

  @override
  void dispose() {
    _identifierController.removeListener(_onPhoneChanged);
    _identifierController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _listenToAuthState() {
    ref.listen<AuthState>(authProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (user) {
          setState(() => _localLoading = false);

          if (user.isProfileComplete &&
              user.areKycDocumentsSubmitted &&
              user.hasBankDetails) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful! Welcome back.'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          }

          if (!user.isProfileComplete) {
            context.go('/profile-setup');
          } else if (!user.areKycDocumentsSubmitted) {
            context.go('/kyc-documents');
          } else if (!user.hasBankDetails) {
            context.go('/bank-details');
          } else {
            context.go('/dashboard');
          }
        },
        error: (message) {
          if (!mounted) return;
          setState(() => _localLoading = false);
          final cleanMsg = ErrorHandler.parseError(message);
          if (cleanMsg.toLowerCase().contains('register to continue') ||
              cleanMsg.toLowerCase().contains('not found') ||
              cleanMsg.toLowerCase().contains('deleted')) {
            UXDialog.showActionDialog(
              context: context,
              title: "Welcome New User!",
              message:
                  "It seems you're a new user! Please register to continue.",
              primaryActionText: "Register",
              onPrimaryAction: () {
                context.pushReplacement(
                  '/register',
                  extra: {'identifier': _identifierController.text.trim()},
                );
              },
            );
          } else {
            ErrorHandler.showError(context, message);
          }
        },
        orElse: () {},
      );
    });
  }

  Future<void> _handleGetOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final identifier = Validators.normalizeMobile(_identifierController.text);
    setState(() => _localLoading = true);

    try {
      final result = await ref.read(authRepositoryProvider).loginRequest(
            identifier,
            termsAndServices: true,
            privacyPolicy: true,
          );

      if (!mounted) return;

      if (result['success'] == true ||
          result['statusCode'] == 200 ||
          result['statusCode'] == 201) {
        setState(() => _localLoading = false);
        unawaited(context.push(
          '/otp',
          extra: {
            'identifier': identifier,
            'isLogin': true,
          },
        ));
      } else {
        setState(() => _localLoading = false);
        final message =
            result['message']?.toString() ?? 'Failed to send OTP';
        if (message.toLowerCase().contains('not found') ||
            message.toLowerCase().contains('please register') ||
            message.toLowerCase().contains('deleted')) {
          UXDialog.showActionDialog(
            context: context,
            title: "Welcome New User!",
            message:
                "It seems you're a new user! Please register to continue.",
            primaryActionText: "Register",
            onPrimaryAction: () {
              context.pushReplacement(
                '/register',
                extra: {'identifier': identifier},
              );
            },
          );
        } else {
          ErrorHandler.showError(context, message);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _localLoading = false);
      final cleanMsg = ErrorHandler.parseError(e);
      if (cleanMsg.toLowerCase().contains('not found') ||
          cleanMsg.toLowerCase().contains('please register') ||
          cleanMsg.toLowerCase().contains('deleted')) {
        UXDialog.showActionDialog(
          context: context,
          title: "Welcome New User!",
          message:
              "It seems you're a new user! Please register to continue.",
          primaryActionText: "Register",
          onPrimaryAction: () {
            context.pushReplacement(
              '/register',
              extra: {'identifier': _identifierController.text.trim()},
            );
          },
        );
      } else {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenToAuthState();

    final authState = ref.watch(authProvider);
    final isGlobalLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    final isLoading = _localLoading || isGlobalLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0B3B24),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Premium Branded Hero Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF09311E),
                    Color(0xFF0F5132),
                    Color(0xFF146C43),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 44),
                  child: Column(
                    children: [
                      // Brand Crest Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                            ),
                            child: const Icon(
                              Icons.handyman_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Brand Name
                      const Text(
                        "RIGHT TOUCH",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Partner Pill Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          "P A R T N E R   P O R T A L",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD1FAE5),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Premium Floating Card Container
            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0.0, -18.0, 0.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFBFDFB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 34, 28, 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Enter your mobile number to sign in",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Input Label
                      Row(
                        children: const [
                          Icon(
                            Icons.phone_android_rounded,
                            size: 16,
                            color: Color(0xFF059669),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Mobile Number",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Premium Phone Input Box
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _identifierController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          autovalidateMode: AutovalidateMode.disabled,
                          inputFormatters: [Validators.digitsOnlyFormatter],
                          maxLength: 10,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: '98765 43210',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade400,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.normal,
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 14, right: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "🇮🇳",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "+91",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    height: 26,
                                    width: 1.2,
                                    color: const Color(0xFFD1D5DB),
                                  ),
                                ],
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1.2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFF10B981),
                                width: 2.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: Validators.validateIndianMobile,
                          onFieldSubmitted: (_) => _handleGetOtp(),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // High-Gloss Emerald CTA Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: _isPhoneComplete
                                ? const [Color(0xFF10B981), Color(0xFF047857)]
                                : const [Color(0xFFA7F3D0), Color(0xFF6EE7B7)],
                          ),
                          boxShadow: _isPhoneComplete
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.38),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: isLoading ? null : _handleGetOtp,
                          child: isLoading
                              ? const RtLoader.button(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "Get Verification Code",
                                      style: TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 19,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Security / Trust Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 15,
                                color: Color(0xFF059669),
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Official Partner Access • Verified via SMS",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register CTA
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => context.push('/register'),
                                  child: const Text(
                                    "Register Now",
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
