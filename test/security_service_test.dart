import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/services/security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_jailbreak_detection');

  group('SecurityService Tests', () {
    test('isDeviceSecure returns true when device is not jailbroken', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'jailbroken') {
          return false;
        }
        return null;
      });

      final secure = await SecurityService.isDeviceSecure();
      expect(secure, isTrue);
    });

    test('isDeviceSecure returns false when device is jailbroken', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'jailbroken') {
          return true;
        }
        return null;
      });

      final secure = await SecurityService.isDeviceSecure();
      expect(secure, isFalse);
    });

    test('isDeviceSecure falls back to true on PlatformException without crashing', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(code: 'UNAVAILABLE', message: 'Not supported on this platform');
      });

      final secure = await SecurityService.isDeviceSecure();
      expect(secure, isTrue);
    });

    test('isDevMode returns developer mode status', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'developerMode') {
          return true;
        }
        return false;
      });

      final devMode = await SecurityService.isDevMode();
      expect(devMode, isTrue);
    });

    test('isDeviceSecure with isSensitiveAction does NOT silently pass on PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(code: 'UNAVAILABLE', message: 'Not supported on this platform');
      });

      final secure = await SecurityService.isDeviceSecure(isSensitiveAction: true);
      expect(secure, isFalse);
    });

    test('checkSensitiveActionSecurity blocks rooted device with clear error message', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'jailbroken') {
          return true;
        }
        return false;
      });

      final errorMsg = await SecurityService.checkSensitiveActionSecurity();
      expect(errorMsg, isNotNull);
      expect(errorMsg, contains('blocked on rooted, jailbroken'));
    });

    test('checkSensitiveActionSecurity returns null for secure device', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'jailbroken') {
          return false;
        }
        return false;
      });

      final errorMsg = await SecurityService.checkSensitiveActionSecurity();
      expect(errorMsg, isNull);
    });
  });
}
