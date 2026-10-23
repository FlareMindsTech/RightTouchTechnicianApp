import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/ux_helpers.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/validators.dart';
import 'package:right_touch/widgets/auth/auth_brand_header.dart';
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
  bool _isPhoneComplete = false;

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
    super.dispose();
  }

  bool _localLoading = false;

  void _listenToAuthState() {
    ref.listen<AuthState>(authProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (user) {
          setState(() => _localLoading = false);

          // Only show "Login successful" if the user is fully set up.
          // For users in the middle of registration/setup flow, we skip the toast
          // to avoid confusion as requested by the user.
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppTheme.lightGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Expanded(
                flex: 2,
                child: AuthBrandHeader(),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Login to your technician account",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 36),
                          TextFormField(
                            controller: _identifierController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.telephoneNumber],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            inputFormatters: [Validators.digitsOnlyFormatter],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: 'Mobile Number',
                              counterText: '',
                              filled: true,
                              fillColor: AppTheme.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8CD8AE),
                                  width: 1.5,
                                ),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Icon(
                                  Icons.phone_android_rounded,
                                  color: Color(0xFF6B7280),
                                  size: 22,
                                ),
                              ),
                            ),
                            validator: Validators.validateIndianMobile,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPhoneComplete
                                    ? AppTheme.primaryColor
                                    : const Color(0xFF8CD8AE),
                                foregroundColor: AppTheme.white,
                                elevation: _isPhoneComplete ? 2 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        final identifier =
                                            Validators.normalizeMobile(_identifierController.text);
                                        setState(() => _localLoading = true);
                                        try {
                                          final result = await ref
                                              .read(authRepositoryProvider)
                                              .loginRequest(
                                                identifier,
                                                termsAndServices: true,
                                                privacyPolicy: true,
                                              );
                                          if (!context.mounted) return;
                                          if (result['success'] == true ||
                                              result['statusCode'] == 200 ||
                                              result['statusCode'] == 201) {
                                            if (!context.mounted) return;
                                            setState(
                                              () => _localLoading = false,
                                            );
                                            unawaited(context.push(
                                              '/otp',
                                              extra: {
                                                'identifier': identifier,
                                                'isLogin': true,
                                              },
                                            ));
                                          } else {
                                            if (!context.mounted) return;
                                            setState(
                                              () => _localLoading = false,
                                            );
                                            final message =
                                                result['message']?.toString() ??
                                                    'Failed to send OTP';
                                            if (message
                                                    .toLowerCase()
                                                    .contains('not found') ||
                                                message.toLowerCase().contains(
                                                      'please register',
                                                    ) ||
                                                message.toLowerCase().contains(
                                                      'deleted',
                                                    )) {
                                              UXDialog.showActionDialog(
                                                context: context,
                                                title: "Welcome New User!",
                                                message:
                                                    "It seems you're a new user! Please register to continue.",
                                                primaryActionText: "Register",
                                                onPrimaryAction: () {
                                                  context.pushReplacement(
                                                    '/register',
                                                    extra: {
                                                      'identifier': identifier,
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              ErrorHandler.showError(
                                                context,
                                                message,
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          setState(() => _localLoading = false);
                                          final cleanMsg =
                                              ErrorHandler.parseError(e);
                                          if (cleanMsg
                                                  .toLowerCase()
                                                  .contains('not found') ||
                                              cleanMsg.toLowerCase().contains(
                                                    'please register',
                                                  ) ||
                                              cleanMsg.toLowerCase().contains(
                                                    'deleted',
                                                  )) {
                                            UXDialog.showActionDialog(
                                              context: context,
                                              title: "Welcome New User!",
                                              message:
                                                  "It seems you're a new user! Please register to continue.",
                                              primaryActionText: "Register",
                                              onPrimaryAction: () {
                                                context.pushReplacement(
                                                  '/register',
                                                  extra: {
                                                    'identifier':
                                                        _identifierController
                                                            .text
                                                            .trim(),
                                                  },
                                                );
                                              },
                                            );
                                          } else {
                                            ErrorHandler.showError(context, e);
                                          }
                                        }
                                      }
                                    },
                              child: isLoading
                                  ? const RtLoader.button(color: AppTheme.white)
                                  : const Text(
                                      "Get OTP",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: const TextStyle(color: AppTheme.textSecondary),
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => context.push('/register'),
                                      child: const Text(
                                        "Register Now",
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
