import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:right_touch/utils/ux_helpers.dart';
import 'package:right_touch/utils/app_theme.dart';

/// Custom exception classes for better error handling
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String? message])
      : super(
          message ??
              "It looks like you're offline. Please check your connection and let's try again.",
          code: 'NETWORK_ERROR',
        );
}

class AuthException extends AppException {
  AuthException([String? message])
      : super(
          message ??
              'It looks like your session expired. Please log in again to continue.',
          code: 'AUTH_ERROR',
        );
}

class ServerException extends AppException {
  ServerException([String? message])
      : super(
          message ??
              'We’re having a little trouble connecting to our servers right now. Please check back in a moment.',
          code: 'SERVER_ERROR',
        );
}

class ValidationException extends AppException {
  ValidationException([String? message])
      : super(
            message ??
                "Some of these details don't seem quite right. Please check them and try again.",
            code: 'VALIDATION_ERROR');
}

/// Error handler utility class
class ErrorHandler {
  /// Parse API error response and return user-friendly message
  static String parseError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String? apiMessage;
      String? errorCode;

      if (data is Map) {
        apiMessage = data['message']?.toString() ?? data['error']?.toString();
        if (apiMessage == null || apiMessage.isEmpty) {
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            final first = errors.first;
            apiMessage = first is Map ? (first['message'] ?? first['msg'])?.toString() : first?.toString();
          } else if (errors is Map && errors.isNotEmpty) {
            final firstVal = errors.values.first;
            apiMessage = (firstVal is List && firstVal.isNotEmpty)
                ? firstVal.first?.toString()
                : firstVal?.toString();
          }
        }
        errorCode = data['code']?.toString() ?? data['errorCode']?.toString();
      }

      if (errorCode == 'ACCOUNT_DEACTIVATED' || errorCode == 'ACCOUNT_DELETED') {
        return 'Your account has been deactivated.\nPlease contact support.';
      }


      if (statusCode == 404) {
        return 'User is not registered. Please register to continue.';
      }

      if (statusCode != null && statusCode >= 500) {
        return 'We’re having a little trouble connecting to our servers right now. Please check back in a moment.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'This is taking longer than usual. Would you like to try again?';
      }

      if (error.type == DioExceptionType.connectionError) {
        return "It looks like you're offline. Please check your connection and let's try again.";
      }

      if (apiMessage != null && apiMessage.isNotEmpty) {
        return _cleanMessage(apiMessage);
      }
    }

    if (error is AppException) {
      return _cleanMessage(error.message);
    }

    // Handle string/generic exception fallbacks
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('account_deleted') || errorString.contains('deactivated')) {
      return 'Your account has been deactivated.\nPlease contact support.';
    }

    if (error is String) {
      return _cleanMessage(error);
    }

    return _cleanMessage(error.toString());
  }

  /// Removes common technical prefixes like "Exception:", "Error:", etc.
  static String _cleanMessage(String message) {
    if (message.isEmpty) return message;

    String clean = message.trim();

    // Regex to recursively remove technical prefixes
    // Examples: "Error: Exception: message", "Exception: Error: message", "Exception: message"
    final prefixPattern = RegExp(
      r'^(error|exception|failure|msg|message|status|backend error|server error)[:\s]+',
      caseSensitive: false,
    );

    while (prefixPattern.hasMatch(clean)) {
      clean = clean.replaceFirst(prefixPattern, '').trim();
    }

    // Capitalize first letter if needed
    if (clean.isNotEmpty) {
      clean = clean[0].toUpperCase() + clean.substring(1);
    }

    return clean;
  }

  /// Show error dialog (replaced snackbar for better UX)
  static void showError(BuildContext context, dynamic error) {
    final message = parseError(error);
    UXDialog.showError(context: context, message: message);
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1976D2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
