import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/screens/otp_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.hasSeenOnboarding()).thenAnswer((_) async => true);
    when(() => mockAuthRepo.getCachedProfile()).thenAnswer((_) async => null);
    when(() => mockAuthRepo.verifyOtp(any(), any())).thenAnswer(
      (_) async => {'success': true, 'message': 'Verified', 'token': 'mock_token'},
    );
    when(() => mockAuthRepo.resendOtp(any())).thenAnswer(
      (_) async => {'success': true, 'message': 'Resent'},
    );
  });

  testWidgets('OtpScreen renders verification elements, edit link, and inputs digits', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
        child: const MaterialApp(
          home: OtpScreen(
            identifier: '+91 9876543210',
            isLogin: false,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Enter Verification Code'), findsOneWidget);
    expect(find.text('+91 9876543210'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Verify & Proceed'), findsOneWidget);

    // Verify 4 input boxes
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(4));

    // Type digits
    await tester.enterText(textFields.at(0), '1');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(textFields.at(1), '2');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(textFields.at(2), '3');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(textFields.at(3), '4');
    await tester.pump(const Duration(milliseconds: 50));
  });
}
