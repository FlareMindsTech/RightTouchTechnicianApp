import 'package:dio/dio.dart';

class RepoErrorHelper {
  static String getErrorMessage(DioException e, String fallback) {
    if (e.type != DioExceptionType.badResponse) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet.';
      }
      return 'Unable to connect. Please check your network.';
    }

    final statusCode = e.response?.statusCode ?? 500;
    final responseData = e.response?.data;

    if (statusCode >= 500) {
      return 'Something went wrong on our end. Please try again later.';
    }

    if (responseData == null) return fallback;

    if (responseData is Map) {
      final message = responseData['message']?.toString() ??
          responseData['error']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    if (responseData is List && responseData.isNotEmpty) {
      final first = responseData.first;
      if (first is Map) {
        final message =
            first['message']?.toString() ?? first['error']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
    }

    return fallback;
  }
}
