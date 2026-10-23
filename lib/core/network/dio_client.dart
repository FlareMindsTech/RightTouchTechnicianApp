import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:right_touch/config/api_config.dart';
import 'package:right_touch/main.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Future<void> Function()? onUnauthorized;
  final Future<bool> Function()? onRefreshToken;
  final void Function(String message)? onForbidden;
  bool _isLoggingOut = false;

  DioClient({
    this.onUnauthorized,
    this.onRefreshToken,
    this.onForbidden,
    FlutterSecureStorage? secureStorage,
    Dio? dio,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                headers: {'Accept': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (options.data is! FormData &&
              !options.headers.containsKey('Content-Type')) {
            options.headers['Content-Type'] = 'application/json';
          }

          if (kDebugMode) {
            debugPrint(
              '🌐 REQUEST[${options.method}] => PATH: ${options.path}',
            );
            debugPrint('📋 HEADERS: ${options.headers}');
            if (options.data is FormData) {
              debugPrint('📦 DATA: Multipart/FormData');
              for (var field in (options.data as FormData).fields) {
                debugPrint('   - ${field.key}: ${field.value}');
              }
              for (var file in (options.data as FormData).files) {
                debugPrint(
                  '   - ${file.key}: File(${file.value.filename}, length: ${file.value.length})',
                );
              }
            } else {
              debugPrint('📦 DATA: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
          }
          return handler.next(response);
        },
        onError: (err, handler) async {
          final statusCode = err.response?.statusCode;
          if (kDebugMode) {
            debugPrint(
              '❌ ERROR[$statusCode] => PATH: ${err.requestOptions.path}',
            );
            debugPrint('   Type: ${err.type}');
            debugPrint('   Message: ${err.message}');
            if (err.error != null) debugPrint('   Error: ${err.error}');
            if (err.response != null) {
              debugPrint('   Response Data: ${err.response?.data}');
            }
          }

          if (statusCode == 401) {
            bool refreshed = false;
            if (onRefreshToken != null) {
              try {
                refreshed = await onRefreshToken!();
              } catch (_) {
                refreshed = false;
              }
            }

            if (!refreshed && !_isLoggingOut) {
              _isLoggingOut = true;
              try {
                await _secureStorage.delete(key: 'auth_token');
                await _secureStorage.delete(key: 'technician_id');
                await _secureStorage.delete(key: 'cached_profile');
                if (onUnauthorized != null) {
                  await onUnauthorized!();
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('Error during 401 forced logout: $e');
                }
              } finally {
                _isLoggingOut = false;
              }
            }
          } else if (statusCode == 403) {
            const forbiddenMessage =
                'No permission: You do not have access to perform this action.';
            if (onForbidden != null) {
              onForbidden!(forbiddenMessage);
            } else {
              GlobalScaffold.showSnackBar(forbiddenMessage, isError: true);
            }
          }

          return handler.next(err);
        },
      ),
    );
  }


  Dio get dio => _dio;

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      url,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
