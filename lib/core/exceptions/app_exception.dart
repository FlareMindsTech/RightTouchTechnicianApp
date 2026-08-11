import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class AuthException extends AppException {
  AuthException(super.message) : super(code: 'AUTH_ERROR');
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.details})
      : super(code: 'VALIDATION_ERROR');
}

extension DioErrorExtension on DioException {
  AppException toAppException() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timed out. Please check your internet.',
        );
      case DioExceptionType.badResponse:
        final status = response?.statusCode;
        final data = response?.data;
        final message = data?['message'] ?? 'Something went wrong';

        if (status == 401 || status == 403) {
          return AuthException(message);
        }
        return AppException(message, code: status?.toString());
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection.');
      default:
        return AppException('An unexpected error occurred.');
    }
  }
}
