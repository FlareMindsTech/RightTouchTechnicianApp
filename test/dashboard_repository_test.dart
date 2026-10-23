import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';
import 'package:right_touch/config/api_config.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient mockClient;
  late DashboardRepository repository;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockClient = MockDioClient();
    repository = DashboardRepository(mockClient);
  });

  group('DashboardRepository Wallet Tests', () {
    test('getWalletBalance returns balance map on success', () async {
      when(() => mockClient.get('/api/technician/wallet')).thenAnswer(
        (_) async => Response(
          data: {'balance': 1500.0, 'currency': 'INR'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getWalletBalance();
      expect(result['balance'], 1500.0);
      verify(() => mockClient.get('/api/technician/wallet')).called(1);
    });

    test('getWalletTransactions returns transactions map on success', () async {
      when(() => mockClient.get('/api/technician/wallet/transactions')).thenAnswer(
        (_) async => Response(
          data: {
            'transactions': [
              {'id': 'tx1', 'amount': 500}
            ],
            'withdrawRequests': []
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getWalletTransactions();
      expect(result['transactions'], isNotEmpty);
      verify(() => mockClient.get('/api/technician/wallet/transactions')).called(1);
    });

    test('requestWithdrawal sends amount and returns response', () async {
      when(
        () => mockClient.post(
          ApiConfig.withdrawFundEndpoint,
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'message': 'Withdrawal request created'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.requestWithdrawal(200.0);
      expect(result['success'], isTrue);
      verify(
        () => mockClient.post(
          ApiConfig.withdrawFundEndpoint,
          data: {'amount': 200.0},
        ),
      ).called(1);
    });

    test('getWalletTransactions gracefully handles non-JSON 502/504 HTML string response', () async {
      when(() => mockClient.get('/api/technician/wallet/transactions')).thenAnswer(
        (_) async => Response(
          data: '<html><body>502 Bad Gateway: Cloud Run timeout</body></html>',
          statusCode: 502,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getWalletTransactions();
      expect(result['success'], isFalse);
      expect(result['transactions'], isEmpty);
      expect(result['withdrawRequests'], isEmpty);
    });

    test('getWalletBalance gracefully handles non-Map 502/504 response', () async {
      when(() => mockClient.get('/api/technician/wallet')).thenAnswer(
        (_) async => Response(
          data: '<html><body>504 Gateway Timeout</body></html>',
          statusCode: 504,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getWalletBalance();
      expect(result['balance'], 0);
      expect(result['pending'], 0);
    });
  });
}
