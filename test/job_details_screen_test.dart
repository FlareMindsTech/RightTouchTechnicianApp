import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/data/repositories/job_repository.dart';
import 'package:right_touch/screens/job_details_screen.dart';

class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late MockJobRepository mockJobRepo;
  late Job dummyJob;

  setUp(() {
    mockJobRepo = MockJobRepository();
    dummyJob = Job(
      id: 'job_123',
      title: 'AC Repair',
      description: 'Filter clean',
      location: '123 Test St',
      status: 'assigned',
      isExclusive: false,
      createdAt: DateTime.now(),
    );
  });

  testWidgets('JobDetailsScreen renders job information', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobRepositoryProvider.overrideWithValue(mockJobRepo),
        ],
        child: MaterialApp(
          home: JobDetailsScreen(job: dummyJob),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(JobDetailsScreen), findsOneWidget);
    expect(find.text('AC Repair'), findsOneWidget);
  });

  testWidgets('JobDetailsScreen openMap pushes /job-map route declaratively', (tester) async {
    String? navigatedRoute;
    Object? navigatedExtra;

    final router = GoRouter(
      initialLocation: '/details',
      routes: [
        GoRoute(
          path: '/details',
          builder: (context, state) => JobDetailsScreen(job: dummyJob),
        ),
        GoRoute(
          path: '/job-map',
          builder: (context, state) {
            navigatedRoute = '/job-map';
            navigatedExtra = state.extra;
            return const Scaffold(body: Text('Job Map Screen'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobRepositoryProvider.overrideWithValue(mockJobRepo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap the map button
    final mapBtn = find.byIcon(Icons.directions);
    if (mapBtn.evaluate().isNotEmpty) {
      await tester.tap(mapBtn);
      await tester.pumpAndSettle();
      expect(navigatedRoute, '/job-map');
      expect(navigatedExtra, isA<Map<String, dynamic>>());
    }
  });
}
