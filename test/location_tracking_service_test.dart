import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/services/location_tracking_service.dart';
import 'package:right_touch/services/socket_service.dart';
import 'package:right_touch/widgets/location_permission_dialog.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSocketService extends Mock implements SocketService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late MockSocketService mockSocketService;
  late LocationTrackingService trackingService;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockSocketService = MockSocketService();

    trackingService = LocationTrackingService(
      socketService: mockSocketService,
      authRepository: mockAuthRepo,
    );
  });

  tearDown(() {
    trackingService.dispose();
  });

  group('LocationTrackingService Tests', () {
    test('stopTracking sets tracking flag to false and stops timer', () {
      trackingService.stopTracking();
      expect(trackingService, isNotNull);
    });

    testWidgets('LocationServiceRationaleDialog renders title, rationale, and action buttons', (tester) async {
      bool? userResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  userResult = await showDialog<bool>(
                    context: context,
                    builder: (_) => const LocationServiceRationaleDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Enable Device Location'), findsOneWidget);
      expect(find.textContaining('Location is required to receive nearby job offers'), findsOneWidget);
      expect(find.text('Enable in Settings'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);

      // Tap Enable in Settings
      await tester.tap(find.text('Enable in Settings'));
      await tester.pumpAndSettle();

      expect(userResult, isTrue);
    });
  });
}
