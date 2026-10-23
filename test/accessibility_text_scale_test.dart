import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/custom_bottom_nav_bar.dart';
import 'package:right_touch/widgets/empty_state.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/widgets/job_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildScaledTestWidget({
    required Widget child,
    required double textScale,
    Size screenSize = const Size(320, 640),
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('Accessibility & Text Scaling (0.8 - 2.0) Tests', () {
    testWidgets('EmptyState renders cleanly at 2.0x text scale without overflow on 320dp',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildScaledTestWidget(
          child: const EmptyState(
            title: 'No Active Bookings',
            subtitle: 'When new bookings arrive, they will appear right here.',
            icon: Icons.inbox,
          ),
          textScale: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Active Bookings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ErrorBoundary renders cleanly at 2.0x text scale without overflow on 320dp',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildScaledTestWidget(
          child: ErrorBoundary(
            message: 'Unable to connect to service. Please check network.',
            onRetry: () {},
          ),
          textScale: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('JobCard renders cleanly at 2.0x text scale on narrow 320dp screen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testJob = Job(
        id: 'job_456',
        bookingId: 'BK-8899',
        customerName: 'Aarav Patel',
        customerPhone: '9876543210',
        serviceName: 'AC Deep Service & Gas Refill',
        title: 'AC Deep Service & Gas Refill',
        status: 'pending',
        location: 'Flat 402, Green Valley Apartments, Mumbai',
        totalAmount: 1499.0,
        createdAt: DateTime.now(),
        latitude: 19.0760,
        longitude: 72.8777,
      );

      await tester.pumpWidget(
        buildScaledTestWidget(
          child: SingleChildScrollView(
            child: JobCard(
              job: testJob,
              onTap: () {},
            ),
          ),
          textScale: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AC Deep Service & Gas Refill'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CustomBottomNavBar includes Semantics and works at text scale 2.0',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildScaledTestWidget(
            child: CustomBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
            ),
            textScale: 2.0,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        // Semantics check
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Home tab',
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Profile tab',
          ),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('AppTheme defines minTouchTarget >= 48.0', (tester) async {
      expect(AppTheme.minTouchTarget, greaterThanOrEqualTo(48.0));
      expect(AppTheme.lightTheme.iconButtonTheme.style?.minimumSize?.resolve({}),
          const Size(48.0, 48.0));
    });
  });
}
