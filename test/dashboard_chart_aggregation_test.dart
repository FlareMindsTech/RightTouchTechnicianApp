import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:right_touch/data/repositories/job_repository.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';
import 'package:right_touch/providers/dashboard_provider.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}
class MockJobRepository extends Mock implements JobRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDashboardRepository mockRepo;
  late MockJobRepository mockJobRepo;

  setUp(() {
    mockRepo = MockDashboardRepository();
    mockJobRepo = MockJobRepository();
  });

  group('Dashboard Trend Chart Aggregation Tests', () {
    test('Year filter generates exactly 12 monthly FlSpot points regardless of number of daily transactions', () async {
      final currentYear = DateTime.now().year;

      // Mock 100 transactions scattered across months
      final List<Map<String, dynamic>> mockTxs = [];
      for (int m = 1; m <= 12; m++) {
        for (int d = 1; d <= 5; d++) {
          mockTxs.add({
            'createdAt': '$currentYear-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}T10:00:00Z',
            'amount': 250.0,
            'type': 'credit',
          });
        }
      }

      when(() => mockRepo.getWalletBalance(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => {'balance': 15000.0});
      when(() => mockRepo.getWalletTransactions(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => {
            'transactions': mockTxs,
            'withdrawRequests': [],
          });
      when(() => mockJobRepo.getCurrentJobs(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => []);
      when(() => mockJobRepo.getJobHistory(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepo),
          jobRepositoryProvider.overrideWithValue(mockJobRepo),
        ],
      );
      addTearDown(container.dispose);

      // Set filter to Year
      container.read(dashboardFilterProvider.notifier).state = 'Year';

      // Read async dashboard data
      final data = await container.read(dashboardDataProvider.future);

      expect(data.earningTrend.length, 12, reason: 'Year filter must bucket into exactly 12 monthly FlSpots');
      // Each month has 5 * 250 = 1250
      expect(data.earningTrend[0].y, 1250.0);
    });
  });
}
