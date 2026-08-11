import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/auth_state.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:right_touch/services/location_tracking_service.dart';

import 'package:right_touch/data/models/user_model.dart';
import 'package:right_touch/providers/registration_form_provider.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  final _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    // Initial check and setup
    Future.microtask(() {
      checkAuth();
    });

    return const AuthState.initial();
  }

  String _error(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      return msg.replaceFirst('Exception: ', '');
    }
    return msg;
  }

  bool get isLoggedIn =>
      state.maybeWhen(authenticated: (_) => true, orElse: () => false);

  Future<void> refreshProfile() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final user = await _repository.getProfile();
        state = AuthState.authenticated(user);
      } catch (e) {
        // Keep current state if refresh fails rather than logging out
        debugPrint('Profile refresh failed: $e');
      }
    }
  }

  bool _isDeactivatedOrUnauthorized(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) return true;
    }
    final msg = _error(e).toLowerCase();
    return msg.contains('account_deleted') ||
        msg.contains('deactivated') ||
        msg.contains('unauthenticated');
  }

  Future<void> checkAuth({bool silent = false}) async {
    if (!silent) {
      state = const AuthState.loading();
    }
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        final user = await _repository.getProfile();
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      debugPrint('AuthNotifier: checkAuth failed: $e');

      // Immediate redirect for deleted/deactivated/forbidden accounts
      if (_isDeactivatedOrUnauthorized(e)) {
        await logout();
        return;
      }

      state = const AuthState.unauthenticated();
    }
  }

  Future<void> completeProfile(Map<String, dynamic> profileData) async {
    final previousUser = state.maybeWhen(
      authenticated: (u) => u,
      orElse: () => null,
    );
    state = const AuthState.loading();
    try {
      await _repository.completeProfile(profileData);

      var user = previousUser ?? const UserModel();
      try {
        user = await _repository.getProfile();
      } catch (e) {
        debugPrint('Post-complete getProfile failed: $e');
      }

      // If the subsequent fetch is incomplete or failed, trust the submitted data
      if (!user.isProfileComplete) {
        final userData =
            profileData['user'] as Map<String, dynamic>? ?? profileData;
        final mobile = userData['mobileNumber']?.toString() ?? "";
        final email = userData['email']?.toString() ?? "";

        user = user.copyWith(
          firstName: userData['fname']?.toString() ??
              userData['firstName']?.toString() ??
              user.firstName ??
              previousUser?.firstName,
          lastName: userData['lname']?.toString() ??
              userData['lastName']?.toString() ??
              user.lastName ??
              previousUser?.lastName,
          mobileNumber: (mobile.isNotEmpty)
              ? mobile
              : (user.mobileNumber ?? previousUser?.mobileNumber),
          email:
              (email.isNotEmpty) ? email : (user.email ?? previousUser?.email),
          gender: userData['gender']?.toString() ??
              user.gender ??
              previousUser?.gender,
          locality: profileData['locality']?.toString() ??
              user.locality ??
              previousUser?.locality,
          address: profileData['address']?.toString() ??
              user.address ??
              previousUser?.address,
          city: profileData['city']?.toString() ??
              user.city ??
              previousUser?.city,
          state: profileData['state']?.toString() ??
              user.state ??
              previousUser?.state,
          specialization: profileData['specialization']?.toString() ??
              user.specialization ??
              previousUser?.specialization,
          profileComplete: true, // Force true since API call was successful
        );
      }

      state = AuthState.authenticated(user);
    } catch (e) {
      if (_error(e).toLowerCase().contains('deleted')) {
        await logout();
        return;
      }
      state = AuthState.error(_error(e));
      await checkAuth(silent: true);
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'technician_id');
      await _storage.delete(key: 'cached_profile');
      await _repository.saveAvailabilityStatus(false);

      // Stop location tracking
      ref.read(locationServiceProvider).stopTracking();

      // Clear registration draft cache
      ref.read(registrationFormProvider.notifier).clearCache();

      state = const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> hasSeenOnboarding() => _repository.hasSeenOnboarding();

  Future<void> markOnboardingAsSeen() => _repository.markOnboardingAsSeen();

  Future<void> submitFullKYC({
    required String aadhaarNumber,
    required String panNumber,
    required String drivingLicenseNumber,
    required String aadhaarPath,
    required String aadhaarBackPath,
    required String panPath,
    required String dlPath,
  }) async {
    state = const AuthState.loading();
    try {
      await _repository.submitKYC(
        aadhaarNumber: aadhaarNumber,
        panNumber: panNumber,
        drivingLicenseNumber: drivingLicenseNumber,
      );
      await _repository.uploadKYCDocuments(
        aadhaarPaths: [aadhaarPath, aadhaarBackPath],
        panPath: panPath,
        dlPath: dlPath,
      );
      final user = await _repository.getProfile();
      state = AuthState.authenticated(user);
    } catch (e) {
      if (_isDeactivatedOrUnauthorized(e)) {
        await logout();
        return;
      }
      state = AuthState.error(_error(e));
      await checkAuth(silent: true);
    }
  }

  Future<void> refreshKYC() async {
    try {
      final user = await _repository.getProfile();
      state = AuthState.authenticated(user);
    } catch (e) {
      debugPrint('KYC Refresh failed: $e');
      if (e.toString().toLowerCase().contains('deleted')) {
        await logout();
      }
    }
  }

  Future<void> submitBankDetails({
    required Map<String, dynamic> bankDetails,
  }) async {
    state = const AuthState.loading();
    try {
      await _repository.submitBankOnly(
        bankDetails: bankDetails,
      );
      final updatedUser = await _repository.getProfile();
      state = AuthState.authenticated(updatedUser);
    } catch (e) {
      if (_isDeactivatedOrUnauthorized(e)) {
        await logout();
        return;
      }
      state = AuthState.error(_error(e));
      await checkAuth(silent: true);
    }
  }

  // Job-related raw methods moved to specialized providers

  Future<void> updateTechnicianData(Map<String, dynamic> data) async {
    state = const AuthState.loading();
    try {
      await _repository.updateTechnicianData(data);
      final user = await _repository.getProfile();
      state = AuthState.authenticated(user);
    } catch (e) {
      if (_isDeactivatedOrUnauthorized(e)) {
        await logout();
        return;
      }
      state = AuthState.error(_error(e));
      await checkAuth(silent: true);
      rethrow;
    }
  }

  Future<void> updateTechnicianProfile(Map<String, dynamic> data) async {
    // Don't set loading state — it causes DashboardScreen to show
    // a full-screen spinner and unmount all tabs, breaking navigation.
    try {
      await _repository.updateTechnicianProfile(data);
      final user = await _repository.getProfile();
      state = AuthState.authenticated(user);
    } catch (e) {
      if (_isDeactivatedOrUnauthorized(e)) {
        await logout();
        return;
      }
      state = AuthState.error(_error(e));
      await checkAuth(silent: true);
      rethrow;
    }
  }

  Future<void> verifyOtpAndLogin(String identifier, String otp) async {
    state = const AuthState.loading();
    try {
      final result = await _repository.verifyOtp(identifier, otp);
      if (result['success'] == true) {
        final resData = result['result'] ?? result['data'] ?? result;
        final userData = resData['user'] ?? resData;

        var user = await _repository.getProfile();

        // If profile is missing basic info, preserve data from the login response
        if (user.firstName == null || user.firstName!.isEmpty) {
          final fname = userData['fname']?.toString() ??
              userData['firstName']?.toString();
          if (fname != null && fname.isNotEmpty) {
            user = user.copyWith(firstName: fname);
          }
        }
        if (user.lastName == null || user.lastName!.isEmpty) {
          final lname =
              userData['lname']?.toString() ?? userData['lastName']?.toString();
          if (lname != null && lname.isNotEmpty) {
            user = user.copyWith(lastName: lname);
          }
        }

        debugPrint(
          'AuthNotifier: Profile fetched. mobile=${user.mobileNumber}, email=${user.email}',
        );

        // Ensure we don't lose the mobile number used to login
        if (user.mobileNumber == null || user.mobileNumber!.isEmpty) {
          debugPrint(
            'AuthNotifier: Preserving login mobile number $identifier',
          );
          user = user.copyWith(mobileNumber: identifier);
        }
        state = AuthState.authenticated(user);
      } else {
        final message =
            (result['message'] ?? 'OTP verification failed').toString();
        // Handle account deleted in the response message
        if (message.toLowerCase().contains('deleted')) {
          await logout();
          return;
        }
        state = AuthState.error(message);
      }
    } catch (e) {
      final errorMsg = _error(e);
      if (errorMsg.toLowerCase().contains('deleted')) {
        await logout();
        return;
      }
      state = AuthState.error(errorMsg);
    }
  }

  Future<void> markSuccessSeen() async {
    await _storage.write(key: 'has_seen_verification_success', value: 'true');
  }

  Future<bool> hasSeenSuccess() async {
    final seen = await _storage.read(key: 'has_seen_verification_success');
    return seen == 'true';
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    state = const AuthState.loading();
    try {
      final result = await _repository.deleteMyAccount();
      if (result['success'] == true) {
        await logout();
      } else {
        await checkAuth(silent: true);
      }
      return result;
    } catch (e) {
      if (_error(e).toLowerCase().contains('deleted')) {
        await logout();
        return {'success': false, 'message': _error(e)};
      }
      state = AuthState.error(_error(e));
      await checkAuth(silent: true);
      return {'success': false, 'message': _error(e)};
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
