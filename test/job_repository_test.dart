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
  });
}
