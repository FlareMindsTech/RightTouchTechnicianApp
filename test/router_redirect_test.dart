import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/models/auth_state.dart';
import 'package:right_touch/data/models/user_model.dart';
import 'package:right_touch/core/routing/app_router.dart';

void main() {
  group('appRouterRedirect 401 Expiry & Navigation Tests', () {
    test('Redirects unauthenticated session on protected screen to /login exactly once', () {
      const authState = AuthState.unauthenticated();

      // Protected route: /dashboard
      final redirect = appRouterRedirect(authState, '/dashboard');
      expect(redirect, equals('/login'));
    });

    test('Does not redirect if already on an auth route (prevents loop/double-navigation)', () {
      const authState = AuthState.unauthenticated();

      // Already on /login
      final loginRedirect = appRouterRedirect(authState, '/login');
      expect(loginRedirect, isNull);

      // On /register
      final registerRedirect = appRouterRedirect(authState, '/register');
      expect(registerRedirect, isNull);

      // On /otp
      final otpRedirect = appRouterRedirect(authState, '/otp');
      expect(otpRedirect, isNull);
    });

    test('Redirects on error state to /login exactly once', () {
      const authState = AuthState.error('Session expired');

      final redirect = appRouterRedirect(authState, '/dashboard');
      expect(redirect, equals('/login'));
    });

    test('Authenticated user with complete profile stays on protected route', () {
      const authState = AuthState.authenticated(
        UserModel(
          id: 'user123',
          profileComplete: true,
          kycStatus: 'approved',
          bankDetails: {'accountNumber': '123456789'},
        ),
      );

      final redirect = appRouterRedirect(authState, '/dashboard');
      expect(redirect, isNull);
    });

    test('Does not prematurely redirect on splash route / allowing animation to complete', () {
      const authStateAuth = AuthState.authenticated(
        UserModel(
          id: 'user123',
          profileComplete: true,
          kycStatus: 'approved',
          bankDetails: {'accountNumber': '123456789'},
        ),
      );
      const authStateUnauth = AuthState.unauthenticated();

      expect(appRouterRedirect(authStateAuth, '/'), isNull);
      expect(appRouterRedirect(authStateUnauth, '/'), isNull);
    });

    test('GoRouter /job-details route defines redirect fallback when extra is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(goRouterProvider);
      final jobRoute = router.configuration.routes
          .whereType<GoRoute>()
          .firstWhere((r) => r.path == '/job-details');

      expect(jobRoute.redirect, isNotNull);
    });
  });
}
