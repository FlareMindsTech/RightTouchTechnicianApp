import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';

class MockDioClient extends Mock implements DioClient {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthRepository repository;
  late MockDioClient mockClient;
  late MockSecureStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockClient = MockDioClient();
    mockStorage = MockSecureStorage();
    repository = AuthRepository(mockClient, storage: mockStorage);

    // Default mock for storage
    when(
      () => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async => {});
  });

  group('AuthRepository Passwordless Flow', () {
    const String testIdentifier = '7305107148';
    const String testOtp = '1234';

    test(
      'signup (Request OTP) successfully calls the endpoint with mobileNumber',
      () async {
        // Arrange
        when(() => mockClient.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {'success': true, 'message': 'OTP sent'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await repository.signup(testIdentifier);

        // Assert
        expect(result['success'], true);
        verify(
          () => mockClient.post(
            '/api/user/signup',
            data: {'mobileNumber': testIdentifier, 'role': 'Technician'},
          ),
        ).called(1);
      },
    );

    test(
      'verifyOtp (OTP Validation) successfully calls the endpoint, returns token, and saves it',
      () async {
        // Arrange
        when(() => mockClient.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'result': {'token': 'test_token'},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await repository.verifyOtp(testIdentifier, testOtp);

        // Assert
        expect(result['success'], true);
        expect(result['result']['token'], 'test_token');
        verify(
          () => mockClient.post(
            '/api/technician/login/technician/verify-otp',
            data: {
              'identifier': testIdentifier,
              'role': 'Technician',
              'otp': testOtp,
            },
          ),
        ).called(1);

        verify(
          () => mockStorage.write(key: 'auth_token', value: 'test_token'),
        ).called(1);
      },
    );

    test('verifyOtp handles error responses properly', () async {
      // Arrange
      when(() => mockClient.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Invalid OTP'},
            statusCode: 400,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act & Assert
      expect(
        () => repository.verifyOtp(testIdentifier, testOtp),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid OTP'),
          ),
        ),
      );
    });
  });
}
