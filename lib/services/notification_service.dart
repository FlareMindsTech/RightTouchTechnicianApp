import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:right_touch/core/notifications/notification_channels.dart';
import 'package:right_touch/core/routing/app_router.dart';
import 'package:right_touch/data/models/job.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Callback for when new job notification arrives
  VoidCallback? onNewJobReceived;

  Future<void> initialize() async {
    try {
      // 1. Initialize notification channel and local notifications plugin
      await initNotificationChannel(
        onNotificationTap: (NotificationResponse response) {
          if (response.payload != null) {
            try {
              final dynamic decoded = jsonDecode(response.payload!);
              if (decoded is Map) {
                _handleNotificationTap(Map<String, dynamic>.from(decoded));
              }
            } catch (e) {
              debugPrint('Error parsing notification payload: $e');
            }
          }
        },
      );

      // 2. Request Notification Permission (with timeout so app doesn't hang)
      try {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        ).timeout(const Duration(seconds: 5));
        debugPrint('[NotificationService] Permission status: ${settings.authorizationStatus}');
      } catch (e) {
        debugPrint('[NotificationService] Permission request timed out or failed: $e');
      }

      // 3. Listen to token refresh (triggers whenever network connects / token updates)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          debugPrint('[NotificationService] FCM token refreshed: $newToken');
        }
      });

      // Attempt to get token (fire-and-forget, does NOT block startup)
      unawaited(_retrieveAndPrintToken());

      // 4. Subscribe to topic (with timeout)
      try {
        await FirebaseMessaging.instance
            .subscribeToTopic('technicians')
            .timeout(const Duration(seconds: 5));
        debugPrint('[NotificationService] Subscribed to topic: technicians');
      } catch (e) {
        debugPrint('[NotificationService] Topic subscription notice: $e');
      }

      // 5. Foreground Push Listener (FCM)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint('[NotificationService] Foreground push received: ${message.messageId}');
        await showForegroundNotification(message);
      });

      // 6. Notification tap when app opened from background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[NotificationService] App opened from push: ${message.data}');
        _handleNotificationTap(message.data);
      });

      // 7. Check if app was opened from terminated state via push notification
      try {
        final initialMessage = await FirebaseMessaging.instance
            .getInitialMessage()
            .timeout(const Duration(seconds: 5));
        if (initialMessage != null) {
          debugPrint('[NotificationService] App opened from terminated state via push: ${initialMessage.data}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleNotificationTap(initialMessage.data);
          });
        }
      } catch (e) {
        debugPrint('[NotificationService] getInitialMessage timed out: $e');
      }
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    if (data['jobId'] != null || data['bookingId'] != null) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        try {
          final job = Job.fromJson(data);
          GoRouter.of(context).push('/job-details', extra: job);
        } catch (e) {
          GoRouter.of(context).go('/dashboard');
        }
      }
    } else {
      rootNavigatorKey.currentContext?.go('/dashboard');
    }
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id: id,
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
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  Future<void> _retrieveAndPrintToken() async {
    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        final token = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 10));
        if (token != null && token.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('[NotificationService] FCM DEVICE TOKEN: $token');
            // Show the token as a LOCAL NOTIFICATION on the phone in debug mode only
            await showLocalNotification(
              id: 99999,
              title: '📋 Your FCM Token (tap to copy)',
              body: token,
            );
          }
          return;
        }
      } catch (e) {
        debugPrint('[NotificationService] Attempt $attempt: Error getting token ($e). Retrying in 5s...');
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    debugPrint('[NotificationService] Failed to get FCM token after 5 attempts');
  }

  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('[NotificationService] Error getting token: $e');
      return null;
    }
  }
}
