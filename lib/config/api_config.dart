import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  /// Base URL for the backend API and Socket.IO connection.
  /// Priority:
  /// 1. `.env` file (if loaded in development)
  /// 2. Build-time dart define: `--dart-define=BASE_URL=https://...`
  /// 3. Default production fallback
  static String get baseUrl {
    if (dotenv.isInitialized && dotenv.env.containsKey('BASE_URL')) {
      final envUrl = dotenv.env['BASE_URL'];
      if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    }
    const fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://backend-pa6p.onrender.com';
  }

  // API Endpoints
  static const String loginEndpoint = '/api/technician/login/technician';
  static const String signupEndpoint = '/api/user/signup';
  static const String verifyOtpEndpoint =
      '/api/technician/login/technician/verify-otp';
  static const String nearbyJobsEndpoint =
      '/api/technician/job-broadcast/nearby-jobs';
  static const String myBroadcastJobsEndpoint =
      '/api/technician/job-broadcast/my-jobs';
  static const String currentJobsEndpoint = '/api/technician/jobs/current';
  static const String jobHistoryEndpoint = '/api/technician/jobs/history';
  static const String walletHistoryEndpoint =
      '/api/technician/wallet/withdrawalhistory';
  static const String withdrawFundEndpoint =
      '/api/technician/wallet/withdrawal';
  static const String updateTechnicianEndpoint =
      '/api/technician/updateTechnician';
  static const String completeProfileEndpoint = '/api/user/complete-profile';
  static const String technicianDataEndpoint = '/api/technician/technicianData';
  static const String bankDetailsEndpoint = '/api/technician/technician/banks';

  static String workImagesEndpoint(String bookingId) =>
      '/api/technician/jobs/$bookingId/work-images';

  static String respondJobBroadcastEndpoint(String bookingId) =>
      '/api/technician/job-broadcast/respond/$bookingId';

  // API Keys
  static String get mapTilerKey {
    if (dotenv.isInitialized && dotenv.env.containsKey('MAP_TILER_KEY')) {
      final key = dotenv.env['MAP_TILER_KEY'];
      if (key != null && key.isNotEmpty) return key;
    }
    return const String.fromEnvironment('MAP_TILER_KEY');
  }

  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get signupUrl => '$baseUrl$signupEndpoint';
  static String get verifyOtpUrl => '$baseUrl$verifyOtpEndpoint';
  static String get nearbyJobsUrl => '$baseUrl$nearbyJobsEndpoint';
  static String get broadcastJobsUrl => '$baseUrl$myBroadcastJobsEndpoint';
  static String get currentJobsUrl => '$baseUrl$currentJobsEndpoint';
  static String get jobHistoryUrl => '$baseUrl$jobHistoryEndpoint';
  static String get walletHistoryUrl => '$baseUrl$walletHistoryEndpoint';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> headersWithToken(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
