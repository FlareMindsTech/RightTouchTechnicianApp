import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/widgets/right_touch_splash.dart';

void main() {
  testWidgets('RightTouchSplash renders and executes onInit and onComplete', (tester) async {
    bool initCalled = false;
    bool completeCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RightTouchSplash(
          onInit: () async {
            initCalled = true;
          },
          onComplete: () {
            completeCalled = true;
          },
        ),
      ),
    );

    // Initial render
    expect(find.byType(RightTouchSplash), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
    expect(find.text('T'), findsWidgets);

    // Pump past the intro animation duration (3200ms)
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1000));

    expect(initCalled, isTrue);
    expect(completeCalled, isTrue);
  });
}
