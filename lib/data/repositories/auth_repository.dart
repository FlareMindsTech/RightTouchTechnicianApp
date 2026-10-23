import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:right_touch/config/api_config.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/core/network/network_provider.dart';
import 'package:right_touch/core/storage/secure_storage_provider.dart';
import 'package:right_touch/data/models/user_model.dart';
import 'package:right_touch/data/repositories/helpers/kyc_repo_helper.dart';
import 'package:right_touch/data/repositories/helpers/profile_sync_helper.dart';
import 'package:right_touch/data/repositories/helpers/repo_error_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  AuthRepository(this._client, {FlutterSecureStorage? storage})
      : _storage = storage ?? appSecureStorage;

  Future<UserModel?> getCachedProfile() async {
    try {
      final cachedProfile = await _storage.read(key: 'cached_profile');
      if (cachedProfile != null && cachedProfile.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(cachedProfile);
        return UserModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error reading cached profile: $e');
    }
    return null;
  }

  // --- SharedPreferences Logic ---

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  Future<void> markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  Future<void> saveAvailabilityStatus(bool isOnline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_online', isOnline);
  }

  Future<bool> loadAvailabilityStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_online') ?? true;
  }

  Future<UserModel> getProfile() async {
    return ProfileSyncHelper.getProfile(_client, _storage);
  }

  Future<UserModel> completeProfile(Map<String, dynamic> profileData) async {
    try {
      await _client.post(ApiConfig.technicianDataEndpoint, data: profileData);

      try {
        await _client.post(
          ApiConfig.completeProfileEndpoint,
          data: {'profileComplete': true},
        );
      } catch (e) {
        debugPrint('completeProfile endpoint failed (non-fatal): $e');
      }

      return await getProfile();
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to complete profile'),
      );
    }
  }

  Future<Map<String, dynamic>> submitKYC({
    required String aadhaarNumber,
    required String panNumber,
    required String drivingLicenseNumber,
    Map<String, dynamic>? bankDetails,
  }) {
    return KycRepoHelper.submitKYC(
      _client,
      aadhaarNumber: aadhaarNumber,
      panNumber: panNumber,
      drivingLicenseNumber: drivingLicenseNumber,
      bankDetails: bankDetails,
    );
  }

  Future<Map<String, dynamic>> uploadKYCDocuments({
    required List<String> aadhaarPaths,
    required String panPath,
    required String dlPath,
  }) {
    return KycRepoHelper.uploadKYCDocuments(
      _client,
      aadhaarPaths: aadhaarPaths,
      panPath: panPath,
      dlPath: dlPath,
    );
  }

  Future<Map<String, dynamic>> submitBankOnly({
    required Map<String, dynamic> bankDetails,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.bankDetailsEndpoint,
        data: bankDetails,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Bank verification failed'),
      );
    }
  }

  Future<Map<String, dynamic>> getKYC() async {
    try {
      final response = await _client.get('/api/technician/technician/kyc/me');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to fetch KYC details'),
      );
    }
  }

  Future<Map<String, dynamic>> signup(
    String identifier, {
    bool termsAndServices = true,
    bool privacyPolicy = true,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.signupEndpoint,
        data: {
          'identifier': identifier,
          'role': 'Technician',
          'termsAndServices': termsAndServices,
          'privacyPolicy': privacyPolicy,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Signup failed'),
      );
    }
  }

  Future<Map<String, dynamic>> loginRequest(
    String identifier, {
    bool termsAndServices = true,
    bool privacyPolicy = true,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.loginEndpoint,
        data: {
          'identifier': identifier,
          'termsAndServices': termsAndServices,
          'privacyPolicy': privacyPolicy,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Login failed'),
      );
    }
  }

  Future<Map<String, dynamic>> resendOtp(String identifier) async {
    try {
      final response = await _client.post(
        '/api/user/resend-otp',
        data: {'identifier': identifier},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to resend OTP'),
      );
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String identifier, String otp) async {
    try {
      final response = await _client.post(
        ApiConfig.verifyOtpEndpoint,
        data: {'identifier': identifier, 'role': 'Technician', 'otp': otp},
      );
      final data = response.data;
      final result = data['result'] ?? data;
      final token = result['token'] ??
          result['accessToken'] ??
          data['token'] ??
          data['accessToken'];

      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
      }
      return data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'OTP verification failed'),
      );
    }
  }

  Future<Map<String, dynamic>> updateTechnicianProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.put(
        ApiConfig.updateTechnicianEndpoint,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(
          e,
          'Failed to update technician profile',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> addSkill(
    String serviceId,
    int experienceYears,
  ) async {
    try {
      final response = await _client.put(
        '/api/technician/technician/skills/add',
        data: {
          'serviceIds': [serviceId],
          'experienceYears': experienceYears,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to add skill'),
      );
    }
  }

  Future<Map<String, dynamic>> uploadProfileImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imagePath,
          contentType: KycRepoHelper.getMediaType(imagePath),
        ),
      });
      final response = await _client.post(
        '/api/technician/technician/profile-image',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to upload profile image'),
      );
    }
  }

  Future<Map<String, dynamic>> resendRegistrationOtp(
    String mobileNumber,
  ) async {
    try {
      final response = await _client.post(
        '/api/user/resend-otp',
        data: {'mobileNumber': mobileNumber, 'role': 'Technician'},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to resend OTP'),
      );
    }
  }

  Future<Map<String, dynamic>> getTechnicianData() async {
    try {
      final response = await _client.get('/api/technician/technicianData');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to fetch technician data'),
      );
    }
  }

  Future<Map<String, dynamic>> updateTechnicianData(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiConfig.technicianDataEndpoint,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to update technician data'),
      );
    }
  }

  Future<dynamic> getAllServices() async {
    try {
      final response = await _client.get('/api/user/getAllServices');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to fetch services'),
      );
    }
  }

  Future<Map<String, dynamic>> deleteMyAccount() async {
    try {
      final response = await _client.delete('/api/user/delete-my-account');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'Failed to delete account'),
      );
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(client, storage: storage);
});
