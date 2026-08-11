import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/data/repositories/job_repository.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final DioClient _sharedDioClient = DioClient();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal()
      : _repository = AuthRepository(_sharedDioClient),
        _jobRepository = JobRepository(_sharedDioClient),
        _dashboardRepository = DashboardRepository(_sharedDioClient);

  final AuthRepository _repository;
  final JobRepository _jobRepository;
  final DashboardRepository _dashboardRepository;

  // Secure storage for sensitive data
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _authToken;
  String? _technicianId;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _kycData;

  String? get authToken => _authToken;
  String? get technicianId => _technicianId;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get kycData => _kycData;
  bool get isLoggedIn => _authToken != null;

  /// Fetch user profile and update local state
  Future<bool> fetchUserProfile() async {
    try {
      final user = await _repository.getProfile();
      _userData = user.rawData != null
          ? Map<String, dynamic>.from(user.rawData!)
          : null;
      // Note: _kycData might need to be extracted from rawData if needed specifically
      _kycData = _userData != null ? _userData!['kycDetails'] : null;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getKYC() async {
    try {
      return await _repository.getKYC();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user profile is complete (names, address, etc.)
  bool get isProfileComplete {
    final complete = _userData?['profileComplete'] ??
        _userData?['isProfileComplete'] ??
        _userData?['technician']?['profileComplete'] ??
        _userData?['profile']?['profileComplete'];
    return complete == true;
  }

  /// Check if KYC documents (Identity doc photos) are submitted
  bool get areKycDocumentsSubmitted {
    final status = _userData?['kycStatus'] ??
        _userData?['verificationStatus'] ??
        _userData?['technician']?['kycStatus'] ??
        _userData?['profile']?['kycStatus'] ??
        _userData?['workStatus'] ??
        _kycData?['status'] ??
        _kycData?['verificationStatus'] ??
        _kycData?['kycStatus'];

    return (status == 'submitted' ||
        status == 'pending' ||
        status == 'approved' ||
        status == 'verified' ||
        status == 'Submitted');
  }

  /// Check if bank details are provided
  bool get hasBankDetails {
    final bankObj = _userData?['bankDetails'] ??
        _userData?['technician']?['bankDetails'] ??
        _userData?['profile']?['bankDetails'] ??
        _userData?['kyc']?['bankDetails'];

    return bankObj != null &&
        (bankObj['accountNumber'] != null &&
            bankObj['accountNumber'].toString().isNotEmpty);
  }

  /// Check if both KYC documents and bank details are submitted
  bool get isKycSubmitted => areKycDocumentsSubmitted && hasBankDetails;

  /// Check if user is fully verified and approved by admin
  bool get isVerified {
    final status = _userData?['kycStatus'] ??
        _userData?['verificationStatus'] ??
        _userData?['technician']?['kycStatus'] ??
        _userData?['profile']?['kycStatus'] ??
        _userData?['workStatus'] ??
        _kycData?['status'] ??
        _kycData?['verificationStatus'] ??
        _kycData?['kycStatus'];

    return status == 'approved' || status == 'verified';
  }

  /// Load token from secure storage (encrypted)
  Future<void> loadToken() async {
    _authToken = await _secureStorage.read(key: 'auth_token');
    _technicianId = await _secureStorage.read(key: 'technician_id');
  }

  /// Logout user
  Future<void> logout() async {
    _authToken = null;
    _technicianId = null;
    _userData = null;
    _kycData = null;

    // Clear secure storage
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'technician_id');

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_online');
  }

  /// Get jobs for the logged-in technician
  Future<Map<String, dynamic>> getMyJobs() async {
    try {
      final jobs = await _jobRepository.getBroadcastJobs();
      return {'success': true, 'jobs': jobs};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get nearby jobs based on location
  Future<Map<String, dynamic>> getNearbyJobs({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final jobs = await _jobRepository.getNearbyJobs(latitude, longitude);
      return {'success': true, 'jobs': jobs};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Complete Technician Profile
  Future<Map<String, dynamic>> completeProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final user = await _repository.completeProfile(profileData);
      _userData = user.rawData != null
          ? Map<String, dynamic>.from(user.rawData!)
          : null;
      return {'success': true, 'user': _userData};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get current (accepted) jobs for the logged-in technician
  Future<Map<String, dynamic>> getCurrentJobs() async {
    try {
      final jobs = await _jobRepository.getCurrentJobs();
      return {'success': true, 'jobs': jobs};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Submit KYC details
  Future<Map<String, dynamic>> submitKYC({
    required String aadhaarNumber,
    required String panNumber,
    required String drivingLicenseNumber,
    Map<String, dynamic>? bankDetails,
  }) async {
    try {
      final result = await _repository.submitKYC(
        aadhaarNumber: aadhaarNumber,
        panNumber: panNumber,
        drivingLicenseNumber: drivingLicenseNumber,
        bankDetails: bankDetails,
      );
      await fetchUserProfile();
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Upload KYC documents
  Future<Map<String, dynamic>> uploadKYCDocuments({
    required List<String> aadhaarPaths,
    required String panPath,
    required String dlPath,
  }) async {
    try {
      final result = await _repository.uploadKYCDocuments(
        aadhaarPaths: aadhaarPaths,
        panPath: panPath,
        dlPath: dlPath,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Respond to job
  Future<Map<String, dynamic>> respondToJob(String jobId, String status) async {
    try {
      final result = await _jobRepository.respondToJob(jobId, status);
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Upload Profile Image
  Future<Map<String, dynamic>> uploadProfileImage(String imagePath) async {
    try {
      final result = await _repository.uploadProfileImage(imagePath);
      await fetchUserProfile();
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Signup for technician (sends OTP)
  Future<Map<String, dynamic>> signup(String mobileNumber) async {
    try {
      return await _repository.signup(mobileNumber);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Resend OTP for technician signup
  Future<Map<String, dynamic>> resendRegistrationOtp(
    String mobileNumber,
  ) async {
    try {
      return await _repository.resendRegistrationOtp(mobileNumber);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Verify OTP for technician signup
  Future<Map<String, dynamic>> verifyRegistrationOtp(
    String mobileNumber,
    String otp,
  ) async {
    try {
      return await _repository.verifyOtp(mobileNumber, otp);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Update Profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final result = await _repository.updateTechnicianProfile(data);

      // If updating availability status, persist it locally
      if (result['success'] == true && data.containsKey('availability')) {
        final isOnline = data['availability']?['isOnline'];
        if (isOnline != null) {
          await _saveAvailabilityStatus(isOnline);
          // Update local userData
          if (_userData != null) {
            _userData!['availability'] = {
              ...(_userData!['availability'] ?? {}),
              'isOnline': isOnline,
            };
          }
        }
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Save availability status to SharedPreferences
  Future<void> _saveAvailabilityStatus(bool isOnline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_online', isOnline);
  }

  /// Load availability status from SharedPreferences
  Future<bool> loadAvailabilityStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_online') ?? true; // Default to online
  }

  /// Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  /// Mark onboarding as seen
  Future<void> markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  /// Get current online status (from local data or default to true)
  bool get isOnline {
    return _userData?['availability']?['isOnline'] ?? true;
  }

  /// Get Job History
  Future<Map<String, dynamic>> getJobHistory() async {
    try {
      final jobs = await _jobRepository.getJobHistory();
      return {'success': true, 'jobs': jobs};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Update Job Status
  Future<Map<String, dynamic>> updateJobStatus(
    String jobId,
    String status, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      return await _jobRepository.updateJobStatus(
        jobId,
        status,
        additionalData: additionalData,
      );
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get Wallet History
  Future<Map<String, dynamic>> getWalletHistory() async {
    try {
      final history = await _dashboardRepository.getWalletHistory();
      return {'success': true, 'history': history};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get Technician Data (for skills etc)
  Future<Map<String, dynamic>> getTechnicianData() async {
    try {
      return await _repository.getTechnicianData();
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get All Services
  Future<dynamic> getAllServices() async {
    try {
      return await _repository.getAllServices();
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Update Technician Data (Skills)
  Future<Map<String, dynamic>> updateTechnicianData(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _repository.updateTechnicianData(data);
      await fetchUserProfile();
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get Wallet Balance
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      return await _dashboardRepository.getWalletBalance();
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get Wallet Transactions
  Future<Map<String, dynamic>> getWalletTransactions() async {
    try {
      return await _dashboardRepository.getWalletTransactions();
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get Withdrawal History
  Future<List<dynamic>> getWithdrawalHistory() async {
    try {
      return await _dashboardRepository.getWalletHistory();
    } catch (e) {
      return [];
    }
  }

  /// Request Withdrawal
  Future<Map<String, dynamic>> requestWithdrawal(double amount) async {
    try {
      return await _dashboardRepository.requestWithdrawal(amount);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Delete My Account
  Future<Map<String, dynamic>> deleteMyAccount() async {
    try {
      return await _repository.deleteMyAccount();
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Upload Work Images
  Future<Map<String, dynamic>> uploadWorkImages({
    required String jobId,
    required String beforeImagePath,
    required String afterImagePath,
  }) async {
    try {
      return await _jobRepository.uploadWorkImages(
        jobId: jobId,
        beforeImagePath: beforeImagePath,
        afterImagePath: afterImagePath,
      );
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
