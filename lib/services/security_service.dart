import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class SecurityService {
  /// Evaluates device security posture.
  /// If [isSensitiveAction] is true (e.g. withdrawal, KYC submission),
  /// any platform error or compromised state will NOT silently pass and returns false.
  /// For non-sensitive operations (telemetry), it falls back to true on platform exceptions.
  static Future<bool> isDeviceSecure({bool isSensitiveAction = false}) async {
    try {
      if (kIsWeb) return true;

      final isJailbroken = await FlutterJailbreakDetection.jailbroken;
      if (isJailbroken) {
        debugPrint('⚠️ SecurityService: Device is rooted or jailbroken');
        return false;
      }

      return true;
    } on PlatformException catch (e) {
      debugPrint('SecurityService: PlatformException during security check: ${e.message}');
      if (isSensitiveAction) return false;
      return true;
    } catch (e) {
      debugPrint('SecurityService: Unexpected error during security check: $e');
      if (isSensitiveAction) return false;
      return true;
    }
  }

  /// Verifies device security before executing sensitive actions (e.g. withdrawal, KYC/bank).
  /// Returns null if secure, or a clear user-facing error message if blocked.
  static Future<String?> checkSensitiveActionSecurity() async {
    final secure = await isDeviceSecure(isSensitiveAction: true);
    if (!secure) {
      return 'Security Policy: This action is blocked on rooted, jailbroken, or untrusted devices for your account security.';
    }
    return null;
  }

  /// Checks developer mode status (for logging and diagnostic telemetry).
  static Future<bool> isDevMode() async {
    try {
      if (kIsWeb) return false;
      return await FlutterJailbreakDetection.developerMode;
    } catch (_) {
      return false;
    }
  }
}
