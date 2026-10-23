import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:right_touch/core/network/dio_client.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}
class MockDioAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late MockSecureStorage mockStorage;
  late int onUnauthorizedCallCount;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockStorage = MockSecureStorage();
    onUnauthorizedCallCount = 0;

    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => 'mock_token');
    when(() => mockStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async => {});
  });

  group('DioClient 401/403 Centralized Interceptor Tests', () {
    test('401 response automatically clears secure storage and triggers onUnauthorized exactly once', () async {
      final dio = Dio();
      final adapter = MockDioAdapter();
      dio.httpClientAdapter = adapter;

      when(() => adapter.fetch(any(), any(), any())).thenAnswer(
        (_) async => ResponseBody.fromString(
          '{"message": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );

      final client = DioClient(
        dio: dio,
        secureStorage: mockStorage,
        onUnauthorized: () async {
          onUnauthorizedCallCount++;
        },
      );

      // Attempt GET request that returns 401
      try {
        await client.get('/api/test-protected');
      } catch (e) {
        // Expected DioException
      }

      // Verify token invalidated
      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
      verify(() => mockStorage.delete(key: 'technician_id')).called(1);
      verify(() => mockStorage.delete(key: 'cached_profile')).called(1);

      // Verify onUnauthorized called exactly once
      expect(onUnauthorizedCallCount, equals(1));
    });

    test('403 response shows no permission error and does NOT invalidate token or trigger onUnauthorized', () async {
      final dio = Dio();
      final adapter = MockDioAdapter();
      dio.httpClientAdapter = adapter;
      String? forbiddenMessage;

      when(() => adapter.fetch(any(), any(), any())).thenAnswer(
        (_) async => ResponseBody.fromString(
          '{"message": "Forbidden"}',
          403,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );

      final client = DioClient(
        dio: dio,
        secureStorage: mockStorage,
        onUnauthorized: () async {
          onUnauthorizedCallCount++;
        },
        onForbidden: (msg) {
          forbiddenMessage = msg;
        },
      );

      try {
        await client.get('/api/test-forbidden');
      } catch (e) {
        // Expected DioException
      }

      verifyNever(() => mockStorage.delete(key: 'auth_token'));
      verifyNever(() => mockStorage.delete(key: 'technician_id'));
      verifyNever(() => mockStorage.delete(key: 'cached_profile'));
      expect(onUnauthorizedCallCount, equals(0));
      expect(forbiddenMessage, contains('No permission'));
    });

    test('200 success response does not clear storage or call onUnauthorized', () async {
      final dio = Dio();
      final adapter = MockDioAdapter();
      dio.httpClientAdapter = adapter;

      when(() => adapter.fetch(any(), any(), any())).thenAnswer(
        (_) async => ResponseBody.fromString(
          '{"success": true}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );

      final client = DioClient(
        dio: dio,
        secureStorage: mockStorage,
        onUnauthorized: () async {
          onUnauthorizedCallCount++;
        },
      );

      final response = await client.get('/api/test-success');
      expect(response.statusCode, equals(200));

      verifyNever(() => mockStorage.delete(key: 'auth_token'));
      expect(onUnauthorizedCallCount, equals(0));
    });
  });
}
