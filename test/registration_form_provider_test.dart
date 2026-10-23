import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:right_touch/providers/registration_form_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RegistrationFormState and Notifier Persistence Tests', () {
    test('State serializes to and deserializes from JSON correctly', () {
      final initial = RegistrationFormState(
        fname: 'John',
        lname: 'Doe',
        email: 'john@example.com',
        aadharNumber: '123456789012',
        aadharPath: '/storage/aadhar.jpg',
        accountHolder: 'John Doe',
        accountNumber: '9876543210',
        selectedServices: [
          {'id': 's1', 'name': 'AC Repair'}
        ],
      );

      final json = initial.toJson();
      final restored = RegistrationFormState.fromJson(json);

      expect(restored.fname, 'John');
      expect(restored.lname, 'Doe');
      expect(restored.email, 'john@example.com');
      expect(restored.aadharNumber, '123456789012');
      expect(restored.aadharPath, '/storage/aadhar.jpg');
      expect(restored.accountHolder, 'John Doe');
      expect(restored.accountNumber, '9876543210');
      expect(restored.selectedServices.length, 1);
      expect(restored.selectedServices.first['name'], 'AC Repair');
    });

    test('Notifier updates profile and persists draft to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(registrationFormProvider.notifier);
      notifier.updateProfile(
        fname: 'Jane',
        lname: 'Smith',
        email: 'jane@example.com',
        city: 'Bengaluru',
      );

      notifier.updateKyc(
        aadharNumber: '999988887777',
        panPath: '/local/cache/pan.png',
      );

      notifier.updateBank(
        bankName: 'HDFC Bank',
        ifsc: 'HDFC0001234',
      );

      // Wait a tick for async disk persist
      await Future.delayed(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      final savedDraft = prefs.getString('registration_form_draft');
      expect(savedDraft, isNotNull);
      expect(savedDraft, contains('Jane'));
      expect(savedDraft, contains('999988887777'));
      expect(savedDraft, contains('/local/cache/pan.png'));
      expect(savedDraft, contains('HDFC0001234'));
    });

    test('clearCache clears in-memory state and removes SharedPreferences draft', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(registrationFormProvider.notifier);
      notifier.updateProfile(fname: 'Alice');

      await Future.delayed(const Duration(milliseconds: 50));
      notifier.clearCache();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(registrationFormProvider);
      expect(state.fname, isEmpty);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('registration_form_draft'), isNull);
    });
  });
}
