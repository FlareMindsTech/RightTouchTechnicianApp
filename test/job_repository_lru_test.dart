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

  group('JobRepository LRU and Quantization Tests', () {
    test('GPS jitter within ~0.005 hits quantized cache without issuing new network requests', () async {
      when(() => mockClient.get(
            ApiConfig.nearbyJobsEndpoint,
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: {
            'result': [
              {'_id': 'j1', 'serviceName': 'Plumbing'}
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Call 1: 12.97161, 77.59461 (quantizes to 12.97, 77.59)
      final res1 = await repository.getNearbyJobs(12.97161, 77.59461);
      expect(res1, isNotEmpty);
      verify(() => mockClient.get(ApiConfig.nearbyJobsEndpoint, queryParameters: any(named: 'queryParameters'))).called(1);

      // Call 2: Micro-jitter 12.97162, 77.59462 (quantizes to 12.97, 77.59 -> cache hit)
      final res2 = await repository.getNearbyJobs(12.97162, 77.59462);
      expect(res2, isNotEmpty);
      // Verify no extra network call was made
      verifyNever(() => mockClient.get(ApiConfig.nearbyJobsEndpoint, queryParameters: any(named: 'queryParameters')));
    });

    test('Cache size stays capped at 20 entries under heavy coordinate shift (LRU eviction)', () async {
      when(() => mockClient.get(
            ApiConfig.nearbyJobsEndpoint,
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: {'result': []},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Generate 35 distinct coordinates (> 20 cap)
      for (int i = 0; i < 35; i++) {
        await repository.getNearbyJobs(10.0 + i, 70.0 + i);
      }

      // Verify network was called 35 times initially
      verify(() => mockClient.get(ApiConfig.nearbyJobsEndpoint, queryParameters: any(named: 'queryParameters'))).called(35);
    });
  });
}
