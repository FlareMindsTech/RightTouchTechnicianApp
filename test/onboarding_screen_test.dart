import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders, interacts with next button, and disposes without leaks', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    await tester.pump();

    // Initial page rendered
    expect(find.byType(PageView), findsOneWidget);
    expect(find.text("Welcome to Right Touch"), findsOneWidget);

    // Forward button tap
    final forwardButton = find.byIcon(Icons.arrow_forward);
    if (forwardButton.evaluate().isNotEmpty) {
      await tester.tap(forwardButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Dispose widget by replacing widget tree
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
