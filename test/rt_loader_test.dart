import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/widgets/rt_loader.dart';

void main() {
  group('RtLoader Widget Tests', () {
    testWidgets('renders inline RtLoader with default sizing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: RtLoader(size: 48, label: 'Custom Loading'),
            ),
          ),
        ),
      );

      expect(find.byType(RtLoader), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(RepaintBoundary), findsWidgets);

      final semantics = tester.getSemantics(find.byType(RtLoader));
      expect(semantics.label, contains('Custom Loading'));
    });

    testWidgets('renders RtLoader.button variant with 20px default size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: null,
              child: RtLoader.button(),
            ),
          ),
        ),
      );

      expect(find.byType(RtLoader), findsOneWidget);
      final size = tester.getSize(find.byType(RtLoader));
      expect(size.width, equals(20.0));
      expect(size.height, equals(20.0));
    });

    testWidgets('honors reduced motion when disableAnimations is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: RtLoader(size: 40),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(RtLoader), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('overlay shows with message and hides properly', (tester) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              testContext = ctx;
              return const Scaffold(body: Text('Base Screen'));
            },
          ),
        ),
      );

      // Show overlay
      RtLoader.showOverlay(testContext, message: 'Processing Payment...');
      await tester.pump();

      expect(find.text('Processing Payment...'), findsOneWidget);
      expect(find.byType(PopScope), findsOneWidget);
      expect(find.byType(RtLoader), findsOneWidget);

      // Hide overlay
      await RtLoader.hideOverlay(enforceMinDisplay: false);
      await tester.pumpAndSettle();

      expect(find.text('Processing Payment...'), findsNothing);
    });

    testWidgets('delayed loader avoids initial flash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RtLoader(size: 32, delay: true),
          ),
        ),
      );

      final loaderPaintFinder = find.descendant(
        of: find.byType(RtLoader),
        matching: find.byType(CustomPaint),
      );

      // Immediately after build, painter should not yet be visible
      expect(loaderPaintFinder, findsNothing);

      // Advance clock past 250ms delay
      await tester.pump(const Duration(milliseconds: 300));
      expect(loaderPaintFinder, findsWidgets);
    });
  });
}
