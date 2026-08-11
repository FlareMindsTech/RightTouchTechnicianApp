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
import 'package:sms_autofill/sms_autofill.dart';

final NetworkService networkService = NetworkService();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class GlobalScaffold {
  static void showSnackBar(String message, {bool isError = false}) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log App Signature Hash for OTP Auto-fill (Early as possible)
  if (kDebugMode) {
    try {
      final String appSignature = await SmsAutoFill().getAppSignature;
      debugPrint('\n${'*' * 40}');
      debugPrint('📱 APP SIGNATURE HASH: $appSignature');
      debugPrint('*' * 40 + '\n');
    } catch (e) {
      debugPrint('⚠️ Error getting App Signature: $e');
    }
  }

  // Run initializations in parallel
  await Future.wait([
    dotenv.load(fileName: ".env"),
    _initJailbreakDetection(),
    _initServices(),
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(const ProviderScope(child: RightTouchApp()));
}

Future<void> _initJailbreakDetection() async {
  try {
    bool isSecure = await SecurityService.isDeviceSecure();
    if (!isSecure && kDebugMode) {
      debugPrint('⚠️ WARNING: Security Alert - Device appears compromised');
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
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
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
