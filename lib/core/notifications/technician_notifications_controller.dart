import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/core/notifications/fcm_service.dart';
import 'package:right_touch/core/socket/socket_provider.dart';
import 'package:right_touch/main.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/data/models/job.dart';

import 'package:right_touch/core/routing/app_router.dart';

final technicianNotificationsProvider =
    Provider.family<void, String>((ref, jwt) {
  final socketService = ref.read(socketServiceProvider);
  final fcmService = ref.read(fcmServiceProvider);

  debugPrint('[TechnicianNotifications] Initializing FCM & Socket for JWT: ${jwt.isNotEmpty}');

  // Register FCM token and attach token refresh listener
  fcmService.registerToken(jwt);
  fcmService.listenTokenRefresh(() => jwt);

  // Connect Socket.IO with all backend business event callbacks
  socketService.connect(
    jwt,
    onJobNew: (job) {
      debugPrint('[TechnicianNotifications] onJobNew received: $job');
      Job? jobModel;
      try {
        jobModel = Job.fromJson(job);
      } catch (e) {
        debugPrint('[TechnicianNotifications] Error parsing Job in onJobNew: $e');
        try {
          jobModel = Job(
            id: job['bookingId']?.toString() ?? job['_id']?.toString() ?? '',
            createdAt: DateTime.now(),
          );
        } catch (e) {
          debugPrint('[TechnicianNotifications] Fallback job creation error: $e');
        }
      }

      final serviceName = job['serviceName'] ?? job['service'] ?? 'New Job Offer';
      final bookingCode = job['bookingCode'] ?? job['bookingId'] ?? '';
      final subtitle = bookingCode.toString().isNotEmpty
          ? 'Booking #$bookingCode • Tap View to inspect'
          : 'Tap View to inspect';

      GlobalScaffold.showJobOfferBanner(
        title: '🔔 $serviceName',
        subtitle: subtitle,
        onView: () {
          if (jobModel != null) {
            ref.read(goRouterProvider).push('/job-details', extra: jobModel);
          }
        },
      );

      ref.invalidate(broadcastJobsProvider);
    },
    onJobExpired: (data) {
      debugPrint('[TechnicianNotifications] onJobExpired: $data');
      ref.read(goRouterProvider).go('/dashboard', extra: {'expiredJobId': data['bookingId']});
      ref.invalidate(broadcastJobsProvider);
    },
    onJobsChanged: () {
      debugPrint('[TechnicianNotifications] onJobsChanged');
      ref.invalidate(currentJobsProvider);
      ref.invalidate(historyJobsProvider);
      ref.invalidate(broadcastJobsProvider);
    },
    onTravelReminder: (data) {
      debugPrint('[TechnicianNotifications] onTravelReminder: $data');
      final code = data['bookingCode'] ?? data['bookingId'] ?? '';
      GlobalScaffold.showSnackBar('🚗 Travel Reminder: Please start travel for booking $code');
    },
    onJobCancelled: (data) {
      debugPrint('[TechnicianNotifications] onJobCancelled: $data');
      final code = data['bookingCode'] ?? data['bookingId'] ?? '';
      GlobalScaffold.showSnackBar('❌ Booking $code was cancelled by customer', isError: true);
      ref.invalidate(currentJobsProvider);
      ref.invalidate(broadcastJobsProvider);
    },
    onPaymentReceived: (data) {
      debugPrint('[TechnicianNotifications] onPaymentReceived: $data');
      final amount = data['amount'] ?? data['payoutRupees'] ?? '';
      GlobalScaffold.showSnackBar('💰 Payment received: ₹$amount');
      ref.invalidate(dashboardDataProvider);
    },
    onPayoutPaid: (data) {
      debugPrint('[TechnicianNotifications] onPayoutPaid: $data');
      final rupees = data['payoutRupees'] ?? data['amount'] ?? '';
      final utr = data['utr'] ?? data['reference'] ?? 'N/A';
      GlobalScaffold.showSnackBar('💸 Payout processed: ₹$rupees (UTR: $utr)');
      ref.invalidate(dashboardDataProvider);
    },
    onWithdrawalFailed: (data) {
      debugPrint('[TechnicianNotifications] onWithdrawalFailed: $data');
      final reason = data['reason'] ?? data['message'] ?? 'Withdrawal failed';
      GlobalScaffold.showSnackBar('⚠️ $reason', isError: true);
      ref.invalidate(dashboardDataProvider);
    },
    onPermissionChanged: (data) {
      debugPrint('[TechnicianNotifications] onPermissionChanged: $data');
      ref.read(authProvider.notifier).refreshKYC();
    },
    onComplaintFiled: (data) {
      debugPrint('[TechnicianNotifications] onComplaintFiled: $data');
      final code = data['bookingCode'] ?? data['bookingId'] ?? '';
      GlobalScaffold.showSnackBar('⚠️ A complaint was filed for booking $code', isError: true);
    },
    onClawbackApplied: (data) {
      debugPrint('[TechnicianNotifications] onClawbackApplied: $data');
      final amount = data['holdAmountRupees'] ?? data['amount'] ?? '';
      GlobalScaffold.showSnackBar('📉 Clawback applied: ₹$amount', isError: true);
      ref.invalidate(dashboardDataProvider);
    },
  );

  ref.onDispose(() {
    debugPrint('[TechnicianNotifications] Disposing socket');
    socketService.disconnect();
  });
});
