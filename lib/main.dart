import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:right_touch/services/security_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:right_touch/services/notification_service.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/services/network_service.dart';
import 'package:right_touch/core/routing/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:right_touch/core/notifications/notification_channels.dart';
import 'package:sms_autofill/sms_autofill.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Background message handler Firebase init error: $e');
  }
}

final NetworkService networkService = NetworkService();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class GlobalScaffold {
  static void showSnackBar(String message, {bool isError = false}) {
    messengerKey.currentState?.hideCurrentSnackBar();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.red : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showJobOfferBanner({
    required String title,
    required String subtitle,
    required VoidCallback onView,
  }) {
    messengerKey.currentState?.hideCurrentMaterialBanner();
    messengerKey.currentState?.showMaterialBanner(
      MaterialBanner(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppTheme.white70),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        leading: const Icon(Icons.work_outline, color: AppTheme.white, size: 28),
        actions: [
          TextButton(
            onPressed: () {
              messengerKey.currentState?.hideCurrentMaterialBanner();
            },
            child: const Text('Dismiss', style: TextStyle(color: AppTheme.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              messengerKey.currentState?.hideCurrentMaterialBanner();
              onView();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.white,
              foregroundColor: AppTheme.primaryColor,
              elevation: 0,
            ),
            child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase & background messaging
  try {
    await Firebase.initializeApp();
    await initNotificationChannel();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Log App Signature Hash for OTP Auto-fill (Early as possible)
  if (kDebugMode) {
    try {
      final String appSignature = await SmsAutoFill().getAppSignature.timeout(
            const Duration(seconds: 2),
            onTimeout: () => 'unknown',
          );
      debugPrint('\n${'*' * 40}');
      debugPrint('📱 APP SIGNATURE HASH: $appSignature');
      debugPrint('*' * 40 + '\n');
    } catch (e) {
      debugPrint('⚠️ Error getting App Signature: $e');
    }
  }

  // Run initializations in parallel
  await Future.wait([
    () async {
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        debugPrint('Note: .env file not loaded (using environment definitions): $e');
      }
    }(),
    _initJailbreakDetection(),
    _initServices(),
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(const ProviderScope(child: RightTouchApp()));
}

Future<void> _initJailbreakDetection() async {
  try {
    final isSecure = await SecurityService.isDeviceSecure();
    final isDev = await SecurityService.isDevMode();

    if (!isSecure) {
      // Option A2: Telemetry warning without blocking technician access
      debugPrint('⚠️ SECURITY ALERT: Compromised/Rooted device detected. Logging event.');
    } else if (isDev && kDebugMode) {
      debugPrint('ℹ️ Security Notice: Developer mode enabled on device');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Security check error: $e');
    }
  }
}


Future<void> _initServices() async {
  try {
    // Initialize Network Service
    await NetworkService().initialize();

    // Initialize Notification Service
    await NotificationService().initialize();

    if (kDebugMode) {
      debugPrint('✅ Services initialized');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Service initialization failed: $e');
    }
  }
}

class RightTouchApp extends ConsumerWidget {
  const RightTouchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'RIGHT TOUCH',
        theme: AppTheme.lightTheme,
        scaffoldMessengerKey: messengerKey,
        routerConfig: router,
      ),
    );
  }
}
