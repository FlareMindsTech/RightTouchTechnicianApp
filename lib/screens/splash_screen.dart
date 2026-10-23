import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/rt_loader.dart';

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
    // Wait for splash screen display
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = ref.read(authProvider);
    authState.maybeWhen(
      authenticated: (_) {}, // Automatically redirected to dashboard by GoRouter
      loading: () {}, // Will be redirected once AuthNotifier finishes checking
      initial: () {},
      orElse: () {
        ref.read(authProvider.notifier).hasSeenOnboarding().then((seen) {
          if (!mounted) return;
          context.go(seen ? '/login' : '/onboarding');
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
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
            const RtLoader(size: 40),
          ],
        ),
      ),
    );
  }
}

