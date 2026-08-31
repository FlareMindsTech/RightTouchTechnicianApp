import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    // Wait a bit for the splash screen to be visible
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    await ref.read(authProvider.notifier).checkAuth();

    // Fallback: If still on splash screen after checkAuth completes, force navigate to login/onboarding
    if (mounted) {
      final authState = ref.read(authProvider);
      authState.maybeWhen(
        authenticated: (_) {}, // Handled by GoRouter redirect
        orElse: () {
          ref.read(authProvider.notifier).hasSeenOnboarding().then((seen) {
            if (!mounted) return;
            context.go(seen ? '/login' : '/onboarding');
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/righttouch.png',
                width: 200,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.flash_on,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
