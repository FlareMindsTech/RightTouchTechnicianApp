import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/services/socket_service.dart';

void main() {
  group('SocketService Tests', () {
    late SocketService socketService;

    setUp(() {
      socketService = SocketService();
    });

    tearDown(() {
      socketService.dispose();
    });

    test('initializes with disconnected state', () {
      expect(socketService.connectionState.value, equals(SocketConnectionState.disconnected));
      expect(socketService.isConnected, isFalse);
    });

    test('disconnect and methods handle null socket safely without throwing', () {
      expect(() => socketService.disconnect(), returnsNormally);
      expect(() => socketService.updateLocation(12.9716, 77.5946), returnsNormally);
      expect(() => socketService.requestJobs(), returnsNormally);
    });

    test('invokes all business callbacks safely when registered', () {
      Map<String, dynamic>? newJobData;
      Map<String, dynamic>? expiredJobData;
      bool jobsChangedCalled = false;
      Map<String, dynamic>? travelReminderData;
      Map<String, dynamic>? cancelledData;
      Map<String, dynamic>? paymentData;
      Map<String, dynamic>? payoutData;
      Map<String, dynamic>? withdrawalFailedData;
      Map<String, dynamic>? permData;
      Map<String, dynamic>? complaintData;
      Map<String, dynamic>? clawbackData;

      socketService.onJobNew = (data) => newJobData = data;
      socketService.onJobExpired = (data) => expiredJobData = data;
      socketService.onJobsChanged = () => jobsChangedCalled = true;
      socketService.onTravelReminder = (data) => travelReminderData = data;
      socketService.onJobCancelled = (data) => cancelledData = data;
      socketService.onPaymentReceived = (data) => paymentData = data;
      socketService.onPayoutPaid = (data) => payoutData = data;
      socketService.onWithdrawalFailed = (data) => withdrawalFailedData = data;
      socketService.onPermissionChanged = (data) => permData = data;
      socketService.onComplaintFiled = (data) => complaintData = data;
      socketService.onClawbackApplied = (data) => clawbackData = data;

      socketService.onJobNew?.call({'bookingId': 'B001'});
      socketService.onJobExpired?.call({'bookingId': 'B002'});
      socketService.onJobsChanged?.call();
      socketService.onTravelReminder?.call({'bookingCode': 'RT-100'});
      socketService.onJobCancelled?.call({'bookingCode': 'RT-101'});
      socketService.onPaymentReceived?.call({'amount': 500});
      socketService.onPayoutPaid?.call({'payoutRupees': 1200, 'utr': 'UTR123'});
      socketService.onWithdrawalFailed?.call({'reason': 'Bank error'});
      socketService.onPermissionChanged?.call({'status': 'approved'});
      socketService.onComplaintFiled?.call({'bookingCode': 'RT-102'});
      socketService.onClawbackApplied?.call({'holdAmountRupees': 200});

      expect(newJobData?['bookingId'], equals('B001'));
      expect(expiredJobData?['bookingId'], equals('B002'));
      expect(jobsChangedCalled, isTrue);
      expect(travelReminderData?['bookingCode'], equals('RT-100'));
      expect(cancelledData?['bookingCode'], equals('RT-101'));
      expect(paymentData?['amount'], equals(500));
      expect(payoutData?['utr'], equals('UTR123'));
      expect(withdrawalFailedData?['reason'], equals('Bank error'));
      expect(permData?['status'], equals('approved'));
      expect(complaintData?['bookingCode'], equals('RT-102'));
      expect(clawbackData?['holdAmountRupees'], equals(200));
    });
  });
}
