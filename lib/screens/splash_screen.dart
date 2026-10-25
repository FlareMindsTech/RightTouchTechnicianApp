import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/widgets/right_touch_splash.dart';

export 'package:right_touch/widgets/right_touch_splash.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Future<void> _handleInit() async {
    final currentState = ref.read(authProvider);
    final isPending = currentState.maybeWhen(
      initial: () => true,
      loading: () => true,
      orElse: () => false,
    );
    if (!isPending) return;

    final completer = Completer<void>();
    ProviderSubscription? sub;
    sub = ref.listenManual(authProvider, (_, next) {
      final stillPending = next.maybeWhen(
        initial: () => true,
        loading: () => true,
        orElse: () => false,
      );
      if (!stillPending && !completer.isCompleted) {
        completer.complete();
        sub?.close();
      }
    });

    await completer.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        sub?.close();
      },
    );
  }

  Future<void> _handleComplete() async {
    if (!mounted) return;
    final authState = ref.read(authProvider);

    await authState.when(
      authenticated: (user) async {
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
      unauthenticated: () async {
        final seen = await ref.read(authProvider.notifier).hasSeenOnboarding();
        if (!mounted) return;
        context.go(seen ? '/login' : '/onboarding');
      },
      error: (_) async {
        final seen = await ref.read(authProvider.notifier).hasSeenOnboarding();
        if (!mounted) return;
        context.go(seen ? '/login' : '/onboarding');
      },
      initial: () async {
        final seen = await ref.read(authProvider.notifier).hasSeenOnboarding();
        if (!mounted) return;
        context.go(seen ? '/login' : '/onboarding');
      },
      loading: () async {
        final seen = await ref.read(authProvider.notifier).hasSeenOnboarding();
        if (!mounted) return;
        context.go(seen ? '/login' : '/onboarding');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RightTouchSplash(
      onInit: _handleInit,
      onComplete: _handleComplete,
    );
  }
}
