import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/screens/auth/widgets/already_registered_banner.dart';
import 'package:right_touch/screens/auth/widgets/registration_terms_checkboxes.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/validators.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? identifier;
  const RegisterScreen({super.key, this.identifier});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _showLoginSuggestion = false; // shown when number is already registered

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.identifier);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms || !_agreedToPrivacy) {
      ErrorHandler.showError(
        context,
        'Please agree to the terms and privacy policy',
      );
      return;
    }

    setState(() => _isLoading = true);
    final identifier = Validators.normalizeMobile(_phoneController.text);

    try {
      final result = await ref.read(authRepositoryProvider).signup(
            identifier,
            termsAndServices: _agreedToTerms,
            privacyPolicy: _agreedToPrivacy,
          );
      setState(() => _isLoading = false);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          unawaited(context.push(
            '/otp',
            extra: {'identifier': identifier, 'isLogin': false},
          ));
        }
      } else {
        if (mounted) {
          final message =
              result['message']?.toString() ?? 'Failed to send OTP.';
          if (message.toLowerCase().contains('already registered') ||
              message.toLowerCase().contains('already exists')) {
            // Show suggestion banner inline instead of error dialog
            setState(() => _showLoginSuggestion = true);
          } else {
            ErrorHandler.showError(context, message);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final msg = ErrorHandler.parseError(e);
        if (msg.toLowerCase().contains('already registered') ||
            msg.toLowerCase().contains('already exists') ||
            msg.toLowerCase().contains('already register')) {
          setState(() => _showLoginSuggestion = true);
        } else {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppTheme.textPrimary,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Join our professional network",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              enabled: !_isLoading,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.telephoneNumber],
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              inputFormatters: [Validators.digitsOnlyFormatter],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              decoration: InputDecoration(
                                hintText: "Mobile Number",
                                counterText: "",
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
                            RegistrationTermsCheckboxes(
                              agreedToTerms: _agreedToTerms,
                              agreedToPrivacy: _agreedToPrivacy,
                              onTermsChanged: (v) =>
                                  setState(() => _agreedToTerms = v),
                              onPrivacyChanged: (v) =>
                                  setState(() => _agreedToPrivacy = v),
                            ),
                            const SizedBox(height: 48),
                            if (_showLoginSuggestion)
                              AlreadyRegisteredBanner(
                                phone: _phoneController.text,
                                onClose: () => setState(
                                  () => _showLoginSuggestion = false,
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8CD8AE),
                                  foregroundColor: AppTheme.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _handleConfirm,
                                child: _isLoading
                                    ? const RtLoader.button(color: AppTheme.white)
                                    : const Text(
                                        "Continue",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: const Text.rich(
                                  TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Login",
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}
