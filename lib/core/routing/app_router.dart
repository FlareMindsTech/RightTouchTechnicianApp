import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';


import 'package:right_touch/screens/splash_screen.dart';
import 'package:right_touch/screens/onboarding_screen.dart';
import 'package:right_touch/screens/login_screen.dart';
import 'package:right_touch/screens/register_screen.dart';
import 'package:right_touch/screens/otp_screen.dart';
import 'package:right_touch/screens/welcome_screen.dart';
import 'package:right_touch/screens/dashboard_screen.dart';
import 'package:right_touch/screens/auth/registration_flow_screen.dart';
import 'package:right_touch/screens/job_details_screen.dart';
import 'package:right_touch/screens/job_map_screen.dart';
import 'package:right_touch/data/models/job.dart';

import 'package:right_touch/screens/profile/delete_account_screen.dart';
import 'package:right_touch/screens/fcm_token_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Builds a slide-up + fade page transition for GoRouter.
CustomTransitionPage<T> _buildPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

String? appRouterRedirect(AuthState authState, String location) {
  final isSplash = location == '/';
  final isOnboarding = location == '/onboarding';
  final isLogin = location == '/login';
  final isRegister = location == '/register';
  final isOtp = location == '/otp';

  final isAuthRoute = isSplash || isOnboarding || isLogin || isRegister || isOtp;

  return authState.maybeWhen(
    authenticated: (user) {
      if (!user.isProfileComplete) {
        return location == '/profile-setup' ? null : '/profile-setup';
      } else if (!user.areKycDocumentsSubmitted) {
        return location == '/kyc-documents' ? null : '/kyc-documents';
      } else if (!user.hasBankDetails) {
        return location == '/bank-details' ? null : '/bank-details';
      } else {
        if (isAuthRoute ||
            location == '/profile-setup' ||
            location == '/kyc-documents' ||
            location == '/bank-details') {
          return '/dashboard';
        }
        return null;
      }
    },
    unauthenticated: () {
      if (isAuthRoute) return null;
      return '/login';
    },
    error: (_) {
      if (isAuthRoute) return null;
      return '/login';
    },
    initial: () => null,
    loading: () => null,
    orElse: () {
      if (isAuthRoute) return null;
      return '/login';
    },
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      return appRouterRedirect(ref.read(authProvider), state.uri.toString());
    },

    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final identifier = extra['identifier'] as String?;
          return _buildPage(
            context: context,
            state: state,
            child: LoginScreen(identifier: identifier),
          );
        },
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final identifier = extra['identifier'] as String?;
          return _buildPage(
            context: context,
            state: state,
            child: RegisterScreen(identifier: identifier),
          );
        },
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final identifier = extra['identifier'] as String?;
          final isLogin = extra['isLogin'] as bool? ?? false;
          return _buildPage(
            context: context,
            state: state,
            child: OtpScreen(identifier: identifier, isLogin: isLogin),
          );
        },
      ),
      GoRoute(
        path: '/kyc-documents',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const RegistrationFlowScreen(initialPage: 1),
        ),
      ),
      GoRoute(
        path: '/bank-details',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const RegistrationFlowScreen(initialPage: 2),
        ),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/profile-setup',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const RegistrationFlowScreen(initialPage: 0),
        ),
      ),
      GoRoute(
        path: '/job-details',
        pageBuilder: (context, state) {
          final job = state.extra as Job;
          return _buildPage(
            context: context,
            state: state,
            child: JobDetailsScreen(job: job),
          );
        },
      ),
      GoRoute(
        path: '/delete-account',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const DeleteAccountScreen(),
        ),
      ),
      GoRoute(
        path: '/fcm-token',
        pageBuilder: (context, state) => _buildPage(
          context: context,
          state: state,
          child: const FcmTokenScreen(),
        ),
      ),
      GoRoute(
        path: '/job-map',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final latitude = (extra['latitude'] as num?)?.toDouble() ?? 13.0827;
          final longitude = (extra['longitude'] as num?)?.toDouble() ?? 80.2707;
          final title = extra['title'] as String? ?? 'Job Location';
          final job = extra['job'] as Job?;
          return _buildPage(
            context: context,
            state: state,
            child: JobMapScreen(
              latitude: latitude,
              longitude: longitude,
              title: title,
              job: job,
            ),
          );
        },
      ),
    ],
  );
});
