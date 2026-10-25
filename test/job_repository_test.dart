import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/data/repositories/job_repository.dart';
import 'package:right_touch/config/api_config.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient mockClient;
  late JobRepository repository;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockClient = MockDioClient();
    repository = JobRepository(mockClient);
  });

  group('JobRepository Job Action Tests', () {
    test('respondToJob successfully puts acceptance status', () async {
      when(
        () => mockClient.put(
          ApiConfig.respondJobBroadcastEndpoint('job123'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'message': 'Job accepted'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.respondToJob('job123', 'accepted');
      expect(result['success'], isTrue);
      verify(
        () => mockClient.put(
          ApiConfig.respondJobBroadcastEndpoint('job123'),
          data: {'status': 'accepted'},
        ),
      ).called(1);
    });

    test('updateJobStatus successfully puts status and extra data', () async {
      when(
        () => mockClient.put(
          '/api/technician/status/job123',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'message': 'Job updated'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.updateJobStatus(
        'job123',
        'completed',
        additionalData: {'customerId': 'cust1'},
      );

      expect(result['success'], isTrue);
      verify(
        () => mockClient.put(
          '/api/technician/status/job123',
          data: {'status': 'completed', 'customerId': 'cust1'},
        ),
      ).called(1);
    });

    test('sendCompletionOtp successfully calls endpoint', () async {
      when(
        () => mockClient.post(
          ApiConfig.sendCompletionOtpEndpoint('job123'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'message': 'OTP sent'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.sendCompletionOtp('job123');
      expect(result['success'], isTrue);
      expect(result['message'], 'OTP sent');
      verify(
        () => mockClient.post(
          ApiConfig.sendCompletionOtpEndpoint('job123'),
        ),
      ).called(1);
    });

    test('resendCompletionOtp successfully calls resend endpoint', () async {
      when(
        () => mockClient.post(
          ApiConfig.resendCompletionOtpEndpoint('job123'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'message': 'OTP resent'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.resendCompletionOtp('job123');
      expect(result['success'], isTrue);
      expect(result['message'], 'OTP resent');
      verify(
        () => mockClient.post(
          ApiConfig.resendCompletionOtpEndpoint('job123'),
        ),
      ).called(1);
    });

    test('verifyCompletionOtp successfully calls verify endpoint with OTP and data', () async {
      when(
        () => mockClient.post(
          ApiConfig.verifyCompletionOtpEndpoint('job123'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'message': 'Job completed'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.verifyCompletionOtp(
        'job123',
        '1234',
        additionalData: {'locationType': 'Home'},
      );
      expect(result['success'], isTrue);
      verify(
        () => mockClient.post(
          ApiConfig.verifyCompletionOtpEndpoint('job123'),
          data: {'otp': '1234', 'locationType': 'Home'},
        ),
      ).called(1);
    });

    test('invalidateCache clears internal job memory cache', () async {
      when(
        () => mockClient.get(
          ApiConfig.currentJobsEndpoint,
        ),
      ).thenAnswer(
        (_) async => Response(
          data: [
            {'_id': 'job_1', 'status': 'assigned'}
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final first = await repository.getCurrentJobs();
      expect(first, isNotEmpty);

      // Invalidate cache
      repository.invalidateCache();

      // Next call queries client again instead of serving from cache
      await repository.getCurrentJobs();
      verify(() => mockClient.get(ApiConfig.currentJobsEndpoint)).called(2);
    });
  });
}
