import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/core/notifications/technician_notifications_controller.dart';
import 'package:right_touch/core/notifications/fcm_service.dart';
import 'package:right_touch/core/routing/app_router.dart';
import 'package:right_touch/core/socket/socket_provider.dart';
import 'package:right_touch/services/socket_service.dart';
import 'package:right_touch/main.dart';

class MockSocketService extends Mock implements SocketService {}
class MockFcmService extends Mock implements FcmService {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSocketService mockSocketService;
  late MockFcmService mockFcmService;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockSocketService = MockSocketService();
    mockFcmService = MockFcmService();
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.push(any(), extra: any(named: 'extra'))).thenAnswer((_) async => null);
  });

  testWidgets('technicianNotificationsProvider displays dismissible MaterialBanner on new job and does not auto-push route', (tester) async {
    void Function(Map<String, dynamic>)? capturedOnJobNew;

    when(() => mockFcmService.registerToken(any())).thenAnswer((_) async {});
    when(() => mockFcmService.listenTokenRefresh(any())).thenReturn(null);
    when(() => mockSocketService.connect(
          any(),
          onJobNew: any(named: 'onJobNew'),
          onJobExpired: any(named: 'onJobExpired'),
          onJobsChanged: any(named: 'onJobsChanged'),
          onTravelReminder: any(named: 'onTravelReminder'),
          onJobCancelled: any(named: 'onJobCancelled'),
          onPaymentReceived: any(named: 'onPaymentReceived'),
          onPayoutPaid: any(named: 'onPayoutPaid'),
          onWithdrawalFailed: any(named: 'onWithdrawalFailed'),
          onPermissionChanged: any(named: 'onPermissionChanged'),
          onComplaintFiled: any(named: 'onComplaintFiled'),
          onClawbackApplied: any(named: 'onClawbackApplied'),
        )).thenAnswer((invocation) {
      capturedOnJobNew = invocation.namedArguments[#onJobNew] as void Function(Map<String, dynamic>)?;
    });

    final container = ProviderContainer(
      overrides: [
        socketServiceProvider.overrideWithValue(mockSocketService),
        fcmServiceProvider.overrideWithValue(mockFcmService),
        goRouterProvider.overrideWithValue(mockGoRouter),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          scaffoldMessengerKey: messengerKey,
          home: const Scaffold(
            body: Center(child: Text('Active Form Screen')),
          ),
        ),
      ),
    );

    // Initialize provider
    container.read(technicianNotificationsProvider('mock_jwt'));

    expect(capturedOnJobNew, isNotNull);

    // Trigger onJobNew with sample job payload
    capturedOnJobNew!({
      '_id': 'job_123',
      'serviceName': 'AC Deep Clean',
      'bookingCode': 'BK9900',
    });

    await tester.pumpAndSettle();

    // Verify auto router push was NOT called
    verifyNever(() => mockGoRouter.push(any(), extra: any(named: 'extra')));

    // Verify MaterialBanner is rendered on screen non-blockingly
    expect(find.text('🔔 AC Deep Clean'), findsOneWidget);
    expect(find.text('Booking #BK9900 • Tap View to inspect'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);

    // Active form screen is still visible underneath
    expect(find.text('Active Form Screen'), findsOneWidget);

    // Tapping View navigates
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    verify(() => mockGoRouter.push('/job-details', extra: any(named: 'extra'))).called(1);
  });
}
