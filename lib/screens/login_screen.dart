import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/ux_helpers.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/data/models/auth_state.dart';
import 'package:right_touch/utils/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? identifier;
  const LoginScreen({super.key, this.identifier});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(text: widget.identifier);
  }

  @override
  void dispose() {
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
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 180,
                        errorBuilder: (context, error, stackTrace) => Column(
                          children: [
                            Text(
                              "RIGHT TOUCH",
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                                letterSpacing: 1.2,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "PARTNER",
                              style: TextStyle(
                                color:
                                    AppTheme.textPrimary.withValues(alpha: 0.8),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 6.0,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppTheme.borderRadiusXLarge),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
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
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Login to your technician account",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 48),
                          TextFormField(
                            controller: _identifierController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: 'Enter mobile number',
                              labelText: 'Mobile Number',
                              counterText: '',
                              prefixIcon: Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.phone_android_rounded,
                                  color: AppTheme.textSecondary,
                                  size: 22,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (value.length != 10) {
                                return 'Mobile number must be 10 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        final identifier =
                                            _identifierController.text.trim();
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
                                            context.push(
                                              '/otp',
                                              extra: {
                                                'identifier': identifier,
                                                'isLogin': true,
                                              },
                                            );
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
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
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
                                style: TextStyle(color: AppTheme.textSecondary),
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
