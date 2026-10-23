import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:right_touch/core/notifications/notification_channels.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Channels Tests', () {
    test('rightTouchChannel is properly configured', () {
      expect(rightTouchChannel.id, equals('righttouch_alerts'));
      expect(rightTouchChannel.name, equals('RightTouch Technician Alerts'));
      expect(rightTouchChannel.description, equals('Job offers, payouts, reminders, and verification updates.'));
      expect(rightTouchChannel.importance, equals(Importance.high));
      expect(rightTouchChannel.playSound, isTrue);
      expect(rightTouchChannel.enableVibration, isTrue);
    });

    test('flutterLocalNotificationsPlugin instance is available', () {
      expect(flutterLocalNotificationsPlugin, isNotNull);
    });
  });
}
