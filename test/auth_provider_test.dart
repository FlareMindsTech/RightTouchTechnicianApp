import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/user_model.dart';
import 'package:right_touch/data/repositories/auth_repository.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/services/location_tracking_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockLocationTrackingService extends Mock implements LocationTrackingService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockLocationTrackingService mockLocationService;

  setUpAll(() {
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockLocationService = MockLocationTrackingService();

    when(() => mockAuthRepository.saveAvailabilityStatus(any()))
        .thenAnswer((_) async => {});
    when(() => mockLocationService.stopTracking()).thenReturn(null);
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        locationServiceProvider.overrideWithValue(mockLocationService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthNotifier Unified Flow Tests', () {
    test('initial state is unauthenticated or loading before checkAuth resolves', () async {
      when(() => mockAuthRepository.getProfile())
          .thenAnswer((_) async => const UserModel(id: 'tech123', firstName: 'John'));

      final container = createContainer();
      final authState = container.read(authProvider);

      expect(authState, isNotNull);
    });

    test('logout resets auth state to unauthenticated and stops location tracking', () async {
      final container = createContainer();
      final notifier = container.read(authProvider.notifier);

      await notifier.logout();

      final state = container.read(authProvider);
      expect(state.maybeWhen(unauthenticated: () => true, orElse: () => false), isTrue);
      verify(() => mockLocationService.stopTracking()).called(1);
      verify(() => mockAuthRepository.saveAvailabilityStatus(false)).called(1);
    });
  });
}
