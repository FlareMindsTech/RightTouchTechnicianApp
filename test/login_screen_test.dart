import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/screens/login_screen.dart';
import 'package:right_touch/utils/app_theme.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState.unauthenticated();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.hasSeenOnboarding()).thenAnswer((_) async => true);
    when(() => mockAuthRepo.getCachedProfile()).thenAnswer((_) async => null);
  });

  testWidgets('Get OTP button dynamically turns darker when 10 digits are typed', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          authProvider.overrideWith(() => FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pump();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'Get OTP');
    expect(buttonFinder, findsOneWidget);

    // Initial state: 0 digits typed -> light green Color(0xFF8CD8AE)
    ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
    Color? bgColor = button.style?.backgroundColor?.resolve({});
    expect(bgColor, equals(const Color(0xFF8CD8AE)));

    // Type 9 digits (< 10 digits) -> still light green Color(0xFF8CD8AE)
    final textFormFieldFinder = find.byType(TextFormField);
    await tester.enterText(textFormFieldFinder, '989416971');
    await tester.pump();

    button = tester.widget<ElevatedButton>(buttonFinder);
    bgColor = button.style?.backgroundColor?.resolve({});
    expect(bgColor, equals(const Color(0xFF8CD8AE)));

    // Type 10th digit -> becomes darker (AppTheme.primaryColor)
    await tester.enterText(textFormFieldFinder, '9894169716');
    await tester.pump();

    button = tester.widget<ElevatedButton>(buttonFinder);
    bgColor = button.style?.backgroundColor?.resolve({});
    expect(bgColor, equals(AppTheme.primaryColor));

    // Delete a digit back to 9 digits -> reverts to light green Color(0xFF8CD8AE)
    await tester.enterText(textFormFieldFinder, '989416971');
    await tester.pump();

    button = tester.widget<ElevatedButton>(buttonFinder);
    bgColor = button.style?.backgroundColor?.resolve({});
    expect(bgColor, equals(const Color(0xFF8CD8AE)));
  });
}
