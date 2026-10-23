import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel rightTouchChannel = AndroidNotificationChannel(
  'righttouch_alerts',
  'RightTouch Technician Alerts',
  description: 'Job offers, payouts, reminders, and verification updates.',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
  vibrationPattern: null,
);

Future<void> initNotificationChannel({
  void Function(NotificationResponse response)? onNotificationTap,
}) async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwinInit = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: darwinInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: onNotificationTap,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(rightTouchChannel);
}

/// Helper method to display a notification from a Firebase RemoteMessage in the foreground
Future<void> showForegroundNotification(RemoteMessage message) async {
  final notification = message.notification;
  final title = notification?.title ?? message.data['title']?.toString();
  final body = notification?.body ?? message.data['body']?.toString();
  if (title == null && body == null) return;

  await flutterLocalNotificationsPlugin.show(
    id: notification?.hashCode ??
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        rightTouchChannel.id,
        rightTouchChannel.name,
        channelDescription: rightTouchChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}
