import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/core/network/network_provider.dart';

class FcmService {
  final Dio dio;
  FcmService(this.dio);

  Future<String?> _getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var deviceId = prefs.getString('device_id');
      if (deviceId == null || deviceId.isEmpty) {
        final info = DeviceInfoPlugin();
        if (kIsWeb) {
          deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
        } else if (Platform.isAndroid) {
          final android = await info.androidInfo;
          deviceId = android.id;
        } else if (Platform.isIOS) {
          final ios = await info.iosInfo;
          deviceId = ios.identifierForVendor;
        } else {
          deviceId = 'dev_${DateTime.now().millisecondsSinceEpoch}';
        }
        deviceId ??= 'device_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('device_id', deviceId);
      }
      return deviceId;
    } catch (e) {
      debugPrint('[FcmService] Error retrieving deviceId: $e');
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version.isNotEmpty ? packageInfo.version : '1.0.0';
    } catch (e) {
      return '1.0.0';
    }
  }

  Future<void> registerToken(String technicianJwt) async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint('[FcmService] Notification permission not granted');
        return;
      }

      final fcmToken = await FirebaseMessaging.instance.getToken();
      final deviceId = await _getDeviceId();
      final appVersion = await _getAppVersion();
      final platform = Platform.isIOS ? 'ios' : 'android';

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('[FcmService] FCM token is null or empty');
        return;
      }

      debugPrint('[FcmService] Registering FCM token for device: $deviceId');

      await dio.post(
        '/api/technician/device-token',
        data: {
          'deviceId': deviceId,
          'platform': platform,
          'fcmToken': fcmToken,
          'appVersion': appVersion,
        },
        options: Options(headers: {'Authorization': 'Bearer $technicianJwt'}),
      );
      debugPrint('[FcmService] FCM token registered successfully');
    } catch (e) {
      debugPrint('[FcmService] Error registering token: $e');
    }
  }

  Future<void> unregisterToken(String technicianJwt) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final deviceId = await _getDeviceId();

      if (fcmToken == null || deviceId == null) return;

      debugPrint('[FcmService] Unregistering FCM token for device: $deviceId');

      await dio.delete(
        '/api/technician/device-token',
        data: {'deviceId': deviceId, 'fcmToken': fcmToken},
        options: Options(headers: {'Authorization': 'Bearer $technicianJwt'}),
      );
      debugPrint('[FcmService] FCM token unregistered successfully');
    } catch (e) {
      debugPrint('[FcmService] Error unregistering token: $e');
    }
  }

  void listenTokenRefresh(String Function() getJwt) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        final jwt = getJwt();
        if (jwt.isEmpty) return;

        final deviceId = await _getDeviceId();
        final appVersion = await _getAppVersion();
        final platform = Platform.isIOS ? 'ios' : 'android';

        debugPrint('[FcmService] Token refreshed, updating backend');

        await dio.post(
          '/api/technician/device-token',
          data: {
            'deviceId': deviceId,
            'platform': platform,
            'fcmToken': newToken,
            'appVersion': appVersion,
          },
          options: Options(headers: {'Authorization': 'Bearer $jwt'}),
        );
      } catch (e) {
        debugPrint('[FcmService] Error in token refresh handler: $e');
      }
    });
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FcmService(dioClient.dio);
});
