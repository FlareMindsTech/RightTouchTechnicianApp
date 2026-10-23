import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';
import 'package:right_touch/screens/profile/wallet_screen.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockDashboardRepo;

  setUp(() {
    mockDashboardRepo = MockDashboardRepository();
    when(() => mockDashboardRepo.getWalletBalance()).thenAnswer(
      (_) async => {'balance': 2500.0},
    );
    when(() => mockDashboardRepo.getWalletTransactions()).thenAnswer(
      (_) async => {'transactions': [], 'withdrawRequests': []},
    );
  });

  testWidgets('WalletScreen renders balance and tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockDashboardRepo),
        ],
        child: const MaterialApp(
          home: WalletScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    expect(find.byType(WalletScreen), findsOneWidget);
    expect(find.text('My Wallet'), findsOneWidget);
  });
}
