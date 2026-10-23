import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/core/notifications/technician_notifications_controller.dart';
import 'package:right_touch/core/notifications/fcm_service.dart';
import 'package:right_touch/core/routing/app_router.dart';
import 'package:right_touch/core/socket/socket_provider.dart';
import 'package:right_touch/services/socket_service.dart';

class MockSocketService extends Mock implements SocketService {}
class MockFcmService extends Mock implements FcmService {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSocketService mockSocketService;
  late MockFcmService mockFcmService;

  setUp(() {
    mockSocketService = MockSocketService();
    mockFcmService = MockFcmService();

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
        )).thenAnswer((_) {});
    when(() => mockSocketService.disconnect()).thenAnswer((_) {});
  });

  test('Decoupled technicianNotificationsProvider creates exactly 1 socket instance across multiple screen transitions', () {
    final mockRouter = MockGoRouter();
    final container = ProviderContainer(
      overrides: [
        socketServiceProvider.overrideWithValue(mockSocketService),
        fcmServiceProvider.overrideWithValue(mockFcmService),
        goRouterProvider.overrideWithValue(mockRouter),
      ],
    );
    addTearDown(container.dispose);

    // Screen A mounts / reads
    container.read(technicianNotificationsProvider('user_jwt'));

    // Screen B mounts / reads same session
    container.read(technicianNotificationsProvider('user_jwt'));

    // Screen C rebuilds
    container.read(technicianNotificationsProvider('user_jwt'));

    // Verify connect was called EXACTLY ONCE (no duplication)
    verify(() => mockSocketService.connect('user_jwt',
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
    )).called(1);
  });
}
