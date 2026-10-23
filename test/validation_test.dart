import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/utils/money.dart';
import 'package:right_touch/utils/validators.dart';
import 'package:right_touch/utils/verhoeff.dart';

void main() {
  group('Verhoeff Checksum Algorithm Tests', () {
    test('generateCheckDigit and validate work correctly', () {
      final numbers = [
        '236',
        '12345',
        '987654321',
        '20485938291',
        '36759834601',
        '99999999999',
      ];
      for (final num in numbers) {
        final check = Verhoeff.generateCheckDigit(num);
        final full = '$num$check';
        expect(Verhoeff.validate(full), isTrue, reason: 'Failed for $full');
      }
    });

    test('invalid inputs fail Verhoeff check', () {
      expect(Verhoeff.validate(''), isFalse);
      expect(Verhoeff.validate('123456'), isFalse);
      expect(Verhoeff.validate('2364'), isFalse); // valid was 2363
      expect(Verhoeff.validate('23631'), isFalse);
      expect(Verhoeff.validate('abcdef'), isFalse);
      expect(Verhoeff.validate('9876543210'), isFalse);
    });
  });

  group('Mobile Number Validation (India) Tests', () {
    test('valid mobile numbers (>= 6 cases)', () {
      expect(Validators.validateIndianMobile('9876543210'), isNull);
      expect(Validators.validateIndianMobile('8123456789'), isNull);
      expect(Validators.validateIndianMobile('7001122334'), isNull);
      expect(Validators.validateIndianMobile('6398765432'), isNull);
      expect(Validators.validateIndianMobile('+91 9876543210'), isNull);
      expect(Validators.validateIndianMobile('09876543210'), isNull);
      expect(Validators.validateIndianMobile(' 919876543210 '), isNull);
    });

    test('invalid mobile numbers (>= 6 cases)', () {
      expect(Validators.validateIndianMobile(null), isNotNull);
      expect(Validators.validateIndianMobile(''), isNotNull);
      expect(Validators.validateIndianMobile('1234567890'), isNotNull); // starts with 1
      expect(Validators.validateIndianMobile('5987654321'), isNotNull); // starts with 5
      expect(Validators.validateIndianMobile('987654321'), isNotNull); // 9 digits
      expect(Validators.validateIndianMobile('98765432100'), isNotNull); // 11 digits
      expect(Validators.validateIndianMobile('987654abcd'), isNotNull); // non-digits
    });
  });

  group('OTP Validation Tests', () {
    test('valid OTPs (>= 6 cases)', () {
      expect(Validators.validateOtp('123456'), isNull);
      expect(Validators.validateOtp('000000'), isNull);
      expect(Validators.validateOtp('999999'), isNull);
      expect(Validators.validateOtp(' 456789 '), isNull);
      expect(Validators.validateOtp('1234', length: 4), isNull);
      expect(Validators.validateOtp('98765432', length: 8), isNull);
    });

    test('invalid OTPs (>= 6 cases)', () {
      expect(Validators.validateOtp(null), isNotNull);
      expect(Validators.validateOtp(''), isNotNull);
      expect(Validators.validateOtp('12345'), isNotNull); // 5 digits
      expect(Validators.validateOtp('1234567'), isNotNull); // 7 digits
      expect(Validators.validateOtp('12a456'), isNotNull); // character
      expect(Validators.validateOtp('12-456'), isNotNull); // special char
      expect(Validators.validateOtp('12345', length: 4), isNotNull);
    });
  });

  group('Email Validation Tests', () {
    test('valid emails (>= 6 cases)', () {
      expect(Validators.validateEmail('partner@righttouch.com'), isNull);
      expect(Validators.validateEmail('user.name+tag@example.co.in'), isNull);
      expect(Validators.validateEmail('support@tech.solutions'), isNull);
      expect(Validators.validateEmail(' john.doe@domain.org '), isNull);
      expect(Validators.validateEmail('a.b-c@sub.domain.io'), isNull);
      expect(Validators.validateEmail('test_123@my-app.info'), isNull);
    });

    test('invalid emails (>= 6 cases)', () {
      expect(Validators.validateEmail(null), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('plainaddress'), isNotNull);
      expect(Validators.validateEmail('@missingusername.com'), isNotNull);
      expect(Validators.validateEmail('user@.com'), isNotNull);
      expect(Validators.validateEmail('user@domain.c'), isNotNull); // TLD < 2 chars
      expect(Validators.validateEmail('user@domain'), isNotNull); // missing TLD
    });
  });

  group('Name Validation Tests', () {
    test('valid names (>= 6 cases)', () {
      expect(Validators.validateName("O'Brien"), isNull);
      expect(Validators.validateName('R. Kumar'), isNull);
      expect(Validators.validateName('Jean-Luc Picard'), isNull);
      expect(Validators.validateName('Aarav Sharma'), isNull);
      expect(Validators.validateName('Dr. Mary Jane-Watson'), isNull);
      expect(Validators.validateName(' François Dupont '), isNull);
    });

    test('invalid names (>= 6 cases)', () {
      expect(Validators.validateName(null), isNotNull);
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('A'), isNotNull); // too short (< 2)
      expect(Validators.validateName('John123'), isNotNull); // numbers
      expect(Validators.validateName('User@Home'), isNotNull); // symbol @
      expect(Validators.validateName('A' * 51), isNotNull); // too long (> 50)
      expect(Validators.validateName('   '), isNotNull);
    });
  });

  group('Aadhaar Validation (with Verhoeff Checksum) Tests', () {
    // Generate valid 12-digit Aadhaar vectors with Verhoeff
    final validAadhaars = [
      '20485938291',
      '36759834601',
      '54321987654',
      '68923415789',
      '81927364510',
      '99887766554',
    ].map((prefix) => '$prefix${Verhoeff.generateCheckDigit(prefix)}').toList();

    test('valid Aadhaar vectors (>= 6 cases)', () {
      for (final aadhaar in validAadhaars) {
        expect(Validators.validateAadhaar(aadhaar), isNull, reason: 'Failed for $aadhaar');
      }
      // With spaces
      final spaced = '${validAadhaars[0].substring(0, 4)} ${validAadhaars[0].substring(4, 8)} ${validAadhaars[0].substring(8)}';
      expect(Validators.validateAadhaar(spaced), isNull);
    });

    test('invalid Aadhaar numbers (>= 6 cases)', () {
      expect(Validators.validateAadhaar(null), isNotNull);
      expect(Validators.validateAadhaar(''), isNotNull);
      expect(Validators.validateAadhaar('012345678901'), isNotNull); // starts with 0
      expect(Validators.validateAadhaar('123456789012'), isNotNull); // starts with 1
      expect(Validators.validateAadhaar('20485938291'), isNotNull); // 11 digits
      expect(Validators.validateAadhaar('2048593829119'), isNotNull); // 13 digits
      expect(Validators.validateAadhaar('20485938291A'), isNotNull); // non-digits
      // Wrong check digit
      final wrongChecksum = '${validAadhaars[0].substring(0, 11)}${(int.parse(validAadhaars[0].substring(11)) + 1) % 10}';
      expect(Validators.validateAadhaar(wrongChecksum), isNotNull);
    });
  });

  group('PAN Validation Tests', () {
    test('valid PAN numbers (>= 6 cases)', () {
      expect(Validators.validatePan('ABCPK1234F'), isNull); // P = Individual
      expect(Validators.validatePan('XYZCA9876G'), isNull); // C = Company
      expect(Validators.validatePan('AAAFR5555M'), isNull); // F = Firm
      expect(Validators.validatePan('BBBHB1111Q'), isNull); // H = HUF
      expect(Validators.validatePan('CCCCA2222Z'), isNull); // A = AOP
      expect(Validators.validatePan('DDDTG3333X'), isNull); // T = Trust
      expect(Validators.validatePan(' abcpa1234f '), isNull); // normalized lowercase
    });

    test('invalid PAN numbers (>= 6 cases)', () {
      expect(Validators.validatePan(null), isNotNull);
      expect(Validators.validatePan(''), isNotNull);
      expect(Validators.validatePan('ABCDE1234F'), isNotNull); // 4th char 'D' is invalid holder type
      expect(Validators.validatePan('ABCP12345F'), isNotNull); // 5 digits instead of 4
      expect(Validators.validatePan('ABCP1234F'), isNotNull); // 9 chars
      expect(Validators.validatePan('ABCP123456F'), isNotNull); // 11 chars
      expect(Validators.validatePan('12345ABCDE'), isNotNull); // numbers first
      expect(Validators.validatePan('ABCP12345'), isNotNull); // missing last letter
    });
  });

  group('Driving Licence Validation Tests', () {
    test('valid driving licences (>= 6 cases)', () {
      expect(Validators.validateDrivingLicense('DL0120150012345'), isNull); // Delhi
      expect(Validators.validateDrivingLicense('MH1220180056789'), isNull); // Maharashtra
      expect(Validators.validateDrivingLicense('KA0520201234567'), isNull); // Karnataka
      expect(Validators.validateDrivingLicense('TN0920100098765'), isNull); // Tamil Nadu
      expect(Validators.validateDrivingLicense('UP32-2016-0034567'), isNull); // With hyphens
      expect(Validators.validateDrivingLicense('GJ01 2019 0045678'), isNull); // With spaces
    });

    test('invalid driving licences (>= 6 cases)', () {
      expect(Validators.validateDrivingLicense(null), isNotNull);
      expect(Validators.validateDrivingLicense(''), isNotNull);
      expect(Validators.validateDrivingLicense('ZZ0120150012345'), isNotNull); // Invalid state code ZZ
      expect(Validators.validateDrivingLicense('DLAA20150012345'), isNotNull); // Invalid RTO code AA
      expect(Validators.validateDrivingLicense('DL0119300012345'), isNotNull); // Year < 1950
      expect(Validators.validateDrivingLicense('DL0120990012345'), isNotNull); // Future year > current
      expect(Validators.validateDrivingLicense('DL0120150012'), isNotNull); // Too short
      expect(Validators.validateDrivingLicense('DL0120150012345678'), isNotNull); // Too long
    });
  });

  group('Bank Account Validation Tests', () {
    test('valid bank accounts (>= 6 cases)', () {
      expect(Validators.validateBankAccount('123456789'), isNull); // 9 digits
      expect(Validators.validateBankAccount('1234567890'), isNull); // 10 digits
      expect(Validators.validateBankAccount('123456789012'), isNull); // 12 digits
      expect(Validators.validateBankAccount('00123456789012'), isNull); // 14 digits
      expect(Validators.validateBankAccount('1234567890123456'), isNull); // 16 digits
      expect(Validators.validateBankAccount('123456789012345678'), isNull); // 18 digits
    });

    test('invalid bank accounts (>= 6 cases)', () {
      expect(Validators.validateBankAccount(null), isNotNull);
      expect(Validators.validateBankAccount(''), isNotNull);
      expect(Validators.validateBankAccount('12345678'), isNotNull); // 8 digits (too short)
      expect(Validators.validateBankAccount('1234567890123456789'), isNotNull); // 19 digits (too long)
      expect(Validators.validateBankAccount('12345678A'), isNotNull); // alphanumeric
      expect(Validators.validateBankAccount('1234-5678-90'), isNotNull); // hyphens
    });
  });

  group('IFSC Code Validation Tests', () {
    test('valid IFSC codes (>= 6 cases)', () {
      expect(Validators.validateIfsc('SBIN0001234'), isNull);
      expect(Validators.validateIfsc('HDFC0000123'), isNull);
      expect(Validators.validateIfsc('ICIC0006789'), isNull);
      expect(Validators.validateIfsc('BARB0COLABA'), isNull);
      expect(Validators.validateIfsc('PUNB0123456'), isNull);
      expect(Validators.validateIfsc(' sbin0001234 '), isNull); // normalized
    });

    test('invalid IFSC codes (>= 6 cases)', () {
      expect(Validators.validateIfsc(null), isNotNull);
      expect(Validators.validateIfsc(''), isNotNull);
      expect(Validators.validateIfsc('SBI00001234'), isNotNull); // 3 letters prefix
      expect(Validators.validateIfsc('SBIN1001234'), isNotNull); // 5th char not '0'
      expect(Validators.validateIfsc('SBIN000123'), isNotNull); // 10 chars
      expect(Validators.validateIfsc('SBIN00012345'), isNotNull); // 12 chars
      expect(Validators.validateIfsc('12340001234'), isNotNull); // Starts with numbers
    });
  });

  group('UPI ID Validation Tests', () {
    test('valid UPI IDs (>= 6 cases)', () {
      expect(Validators.validateUpiId('partner@okhdfcbank'), isNull);
      expect(Validators.validateUpiId('john.doe@okicici'), isNull);
      expect(Validators.validateUpiId('user_123@paytm'), isNull);
      expect(Validators.validateUpiId('shop-name@upi'), isNull);
      expect(Validators.validateUpiId('9876543210@ybl'), isNull);
      expect(Validators.validateUpiId('test.user@axl'), isNull);
      expect(Validators.validateUpiId(null, required: false), isNull);
      expect(Validators.validateUpiId('', required: false), isNull);
    });

    test('invalid UPI IDs (>= 6 cases)', () {
      expect(Validators.validateUpiId(null, required: true), isNotNull);
      expect(Validators.validateUpiId('', required: true), isNotNull);
      expect(Validators.validateUpiId('plainupi'), isNotNull); // no @
      expect(Validators.validateUpiId('@bank'), isNotNull); // no username
      expect(Validators.validateUpiId('user@'), isNotNull); // no handle
      expect(Validators.validateUpiId('user@b'), isNotNull); // handle < 2 chars
      expect(Validators.validateUpiId('u@bank'), isNotNull); // username < 2 chars
    });
  });

  group('Withdrawal Amount Validation Tests', () {
    final balance = Money.fromRupees(5000);
    final minAmount = Money.fromRupees(100);
    final maxAmount = Money.fromRupees(10000);

    test('valid withdrawal amounts (>= 6 cases)', () {
      expect(Validators.validateWithdrawalAmount('100', balance: balance, minAmount: minAmount, maxAmount: maxAmount), isNull);
      expect(Validators.validateWithdrawalAmount('500', balance: balance, minAmount: minAmount, maxAmount: maxAmount), isNull);
      expect(Validators.validateWithdrawalAmount('1250.50', balance: balance, minAmount: minAmount, maxAmount: maxAmount), isNull);
      expect(Validators.validateWithdrawalAmount('4999.99', balance: balance, minAmount: minAmount, maxAmount: maxAmount), isNull);
      expect(Validators.validateWithdrawalAmount('5000', balance: balance, minAmount: minAmount, maxAmount: maxAmount), isNull);
      expect(Validators.validateWithdrawalAmount(' 100.00 ', balance: balance, minAmount: minAmount, maxAmount: maxAmount), isNull);
    });

    test('invalid withdrawal amounts (>= 6 cases)', () {
      expect(Validators.validateWithdrawalAmount(null, balance: balance, minAmount: minAmount), isNotNull);
      expect(Validators.validateWithdrawalAmount('', balance: balance, minAmount: minAmount), isNotNull);
      expect(Validators.validateWithdrawalAmount('0', balance: balance, minAmount: minAmount), isNotNull); // <= 0
      expect(Validators.validateWithdrawalAmount('-50', balance: balance, minAmount: minAmount), isNotNull); // negative
      expect(Validators.validateWithdrawalAmount('50', balance: balance, minAmount: minAmount), isNotNull); // < minimum 100
      expect(Validators.validateWithdrawalAmount('5000.001', balance: balance, minAmount: minAmount), isNotNull); // > 2 decimals
      expect(Validators.validateWithdrawalAmount('5001', balance: balance, minAmount: minAmount), isNotNull); // exceeds balance 5000
      expect(Validators.validateWithdrawalAmount('15000', balance: Money.fromRupees(20000), minAmount: minAmount, maxAmount: maxAmount), isNotNull); // exceeds max
      expect(Validators.validateWithdrawalAmount('abc', balance: balance, minAmount: minAmount), isNotNull); // non-numeric
    });
  });

  group('Pincode Validation Tests', () {
    test('valid pincodes (>= 6 cases)', () {
      expect(Validators.validatePincode('600001'), isNull);
      expect(Validators.validatePincode('110001'), isNull);
      expect(Validators.validatePincode('560001'), isNull);
      expect(Validators.validatePincode('400001'), isNull);
      expect(Validators.validatePincode('700001'), isNull);
      expect(Validators.validatePincode(' 500001 '), isNull);
    });

    test('invalid pincodes (>= 6 cases)', () {
      expect(Validators.validatePincode(null), isNotNull);
      expect(Validators.validatePincode(''), isNotNull);
      expect(Validators.validatePincode('012345'), isNotNull); // starts with 0
      expect(Validators.validatePincode('60000'), isNotNull); // 5 digits
      expect(Validators.validatePincode('6000001'), isNotNull); // 7 digits
      expect(Validators.validatePincode('60000A'), isNotNull); // non-digits
      expect(Validators.validatePincode('600 01'), isNotNull); // spaces inside
    });
  });

  group('Required and Masking Utility Tests', () {
    test('validateRequired works correctly', () {
      expect(Validators.validateRequired('Main Branch', 'Branch'), isNull);
      expect(Validators.validateRequired('John Doe', 'Account Holder'), isNull);
      expect(Validators.validateRequired(null, 'Branch'), isNotNull);
      expect(Validators.validateRequired('', 'Branch'), isNotNull);
      expect(Validators.validateRequired(' ', 'Branch'), isNotNull);
      expect(Validators.validateRequired('A', 'Branch', minLength: 2), isNotNull);
    });

    test('maskAadhaar formats correctly', () {
      expect(Validators.maskAadhaar('204859382919'), equals('XXXX XXXX 2919'));
      expect(Validators.maskAadhaar('2048 5938 2919'), equals('XXXX XXXX 2919'));
      expect(Validators.maskAadhaar('123'), equals('123')); // non-12 unchanged
    });
  });
}
