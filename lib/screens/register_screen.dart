import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchPolicy(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
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
    final identifier = _phoneController.text.trim();

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
          context.push(
            '/otp',
            extra: {'identifier': identifier, 'isLogin': false},
          );
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                      const SizedBox(height: 8),
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
                    padding: const EdgeInsets.all(24.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppTheme.borderRadiusLarge),
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
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: "Mobile Number",
                                hintText: "Enter your 10 digit number",
                                counterText: "",
                                prefixIcon: Icon(
                                  Icons.phone_android_rounded,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your mobile number';
                                }
                                if (value.length != 10) {
                                  return 'Mobile number must be 10 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            _buildCheckboxItem(
                              value: _agreedToTerms,
                              onChanged: (v) =>
                                  setState(() => _agreedToTerms = v!),
                              child: Text.rich(
                                TextSpan(
                                  text: "I agree to the ",
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    _linkSpan(
                                      "Terms and Conditions",
                                      "https://righttouch.vercel.app/terms/",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCheckboxItem(
                              value: _agreedToPrivacy,
                              onChanged: (v) =>
                                  setState(() => _agreedToPrivacy = v!),
                              child: Text.rich(
                                TextSpan(
                                  text: "I agree to the ",
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    _linkSpan(
                                      "Privacy Policy",
                                      "https://righttouch.vercel.app/privacy/",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Friendly suggestion when number is already registered
                            if (_showLoginSuggestion)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Already have an account?',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'This number is already registered.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () {
                                              final identifier =
                                                  _phoneController.text.trim();
                                              context.pushReplacement(
                                                '/login',
                                                extra: {
                                                  'identifier': identifier,
                                                },
                                              );
                                            },
                                            child: const Text(
                                              'Go to Login →',
                                              style: TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _showLoginSuggestion = false,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleConfirm,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
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
                                child: Text.rich(
                                  TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                    children: const [
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

  Widget _buildCheckboxItem({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            activeColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  TextSpan _linkSpan(String text, String url, {bool isBold = false}) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = () => _launchPolicy(url),
    );
  }
}
