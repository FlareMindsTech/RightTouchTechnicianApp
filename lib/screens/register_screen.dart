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

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _showLoginSuggestion = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.identifier);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormReady =>
      _phoneController.text.trim().replaceAll(RegExp(r'\D'), '').length == 10 &&
      _agreedToTerms &&
      _agreedToPrivacy;

  Future<void> _handleConfirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
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
      } else {
        final message =
            result['message']?.toString() ?? 'Failed to send OTP.';
        if (message.toLowerCase().contains('already registered') ||
            message.toLowerCase().contains('already exists')) {
          setState(() => _showLoginSuggestion = true);
        } else {
          ErrorHandler.showError(context, message);
        }
      }
    } catch (e) {
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),

              // Title Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Join our network of professional technicians",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Label
                      const Text(
                        "Mobile Number",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Phone input
                      TextFormField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        // Disabled during typing so keyboard doesn't close on 1st digit
                        autovalidateMode: AutovalidateMode.disabled,
                        inputFormatters: [Validators.digitsOnlyFormatter],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          letterSpacing: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: "98765 43210",
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.normal,
                          ),
                          counterText: "",
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 14, right: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "🇮🇳",
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "+91",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ],
                            ),
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
                              color: AppTheme.primaryColor,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: Validators.validateIndianMobile,
                        onFieldSubmitted: (_) => _handleConfirm(),
                      ),

                      const SizedBox(height: 20),

                      // Terms and Conditions Checkboxes
                      RegistrationTermsCheckboxes(
                        agreedToTerms: _agreedToTerms,
                        agreedToPrivacy: _agreedToPrivacy,
                        onTermsChanged: (v) =>
                            setState(() => _agreedToTerms = v),
                        onPrivacyChanged: (v) =>
                            setState(() => _agreedToPrivacy = v),
                      ),

                      if (_showLoginSuggestion) ...[
                        const SizedBox(height: 16),
                        AlreadyRegisteredBanner(
                          phone: _phoneController.text,
                          onClose: () => setState(
                            () => _showLoginSuggestion = false,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormReady
                                ? AppTheme.primaryColor
                                : const Color(0xFFA5D6A7),
                            foregroundColor: Colors.white,
                            elevation: _isFormReady ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleConfirm,
                          child: _isLoading
                              ? const RtLoader.button(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "Continue to Verification",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Already have an account CTA
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
