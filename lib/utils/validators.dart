import 'package:flutter/services.dart';
import 'package:right_touch/utils/money.dart';
import 'package:right_touch/utils/verhoeff.dart';

/// Centralized Validation & Input Formatting Utilities.
/// Single source of truth for form validations across the application.
class Validators {
  Validators._();

  // --- Regular Expressions ---
  static final RegExp _mobilePattern = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _digitsOnlyPattern = RegExp(r'^\d+$');
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );
  static final RegExp _namePattern = RegExp(
    r"^[a-zA-Z\u00C0-\u024F\u1E00-\u1EFF\s'\.\-]+$",
  );
  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static final RegExp _ifscPattern = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  static final RegExp _upiPattern = RegExp(
    r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$',
  );

  static const Set<String> _panValidTypes = {
    'P', // Individual
    'C', // Company
    'H', // Hindu Undivided Family (HUF)
    'F', // Firm
    'A', // Association of Persons (AOP)
    'B', // Body of Individuals (BOI)
    'G', // Government Agency
    'J', // Artificial Juridical Person
    'L', // Local Authority
    'T', // Trust
  };

  static const Set<String> _dlStateCodes = {
    'AN', 'AP', 'AR', 'AS', 'BR', 'CH', 'CG', 'DD', 'DL', 'DN',
    'GA', 'GJ', 'HP', 'HR', 'JH', 'JK', 'KA', 'KL', 'LA', 'LD',
    'MH', 'ML', 'MN', 'MP', 'MZ', 'NL', 'OD', 'OR', 'PB', 'PY',
    'RJ', 'SK', 'TN', 'TR', 'TS', 'UA', 'UK', 'UP', 'WB',
  };

  // --- Formatters ---
  static final TextInputFormatter digitsOnlyFormatter =
      FilteringTextInputFormatter.digitsOnly;

  static final TextInputFormatter nameInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'\.\-]"));

  static final TextInputFormatter panInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));

  static final TextInputFormatter ifscInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));

  static final TextInputFormatter aadhaarInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]'));

  static final TextInputFormatter dlInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-]'));

  static final TextInputFormatter amountInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

  // --- Normalizers ---

  /// Strips whitespace, leading +91, 91, or 0 from Indian mobile numbers.
  static String normalizeMobile(String input) {
    String clean = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (clean.startsWith('+91')) {
      clean = clean.substring(3);
    } else if (clean.startsWith('91') && clean.length > 10) {
      clean = clean.substring(2);
    } else if (clean.startsWith('0') && clean.length > 10) {
      clean = clean.substring(1);
    }
    return clean.trim();
  }

  /// Trims, collapses multiple spaces, and normalizes name.
  static String normalizeName(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Trims and converts email to lowercase.
  static String normalizeEmail(String input) {
    return input.trim().toLowerCase();
  }

  /// Removes whitespace/hyphens and converts to uppercase.
  static String normalizePan(String input) {
    return input.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
  }

  /// Removes whitespace/hyphens and converts to uppercase.
  static String normalizeIfsc(String input) {
    return input.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
  }

  /// Removes whitespace and hyphens from Aadhaar input.
  static String normalizeAadhaar(String input) {
    return input.replaceAll(RegExp(r'[\s\-]'), '');
  }

  /// Removes spaces and hyphens from DL and converts to uppercase.
  static String normalizeDrivingLicense(String input) {
    return input.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
  }

  /// Strips all non-digit characters from string.
  static String normalizeDigitsOnly(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  /// Masks 12-digit Aadhaar for safe display (e.g. `XXXX XXXX 1234`).
  static String maskAadhaar(String input) {
    final clean = normalizeAadhaar(input);
    if (clean.length != 12) return input;
    return 'XXXX XXXX ${clean.substring(8)}';
  }

  // --- Validators ---

  /// Validates Indian 6-digit postal pincode.
  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    final clean = value.trim();
    if (!_digitsOnlyPattern.hasMatch(clean)) {
      return 'Pincode must contain only digits';
    }
    if (clean.length != 6) {
      return 'Pincode must be exactly 6 digits';
    }
    if (clean.startsWith('0')) {
      return 'Pincode cannot start with 0';
    }
    return null;
  }

  /// Validates Indian 10-digit mobile number starting with 6, 7, 8, or 9.
  static String? validateIndianMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final normalized = normalizeMobile(value);
    if (normalized.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    if (!_mobilePattern.hasMatch(normalized)) {
      return 'Enter a valid 10-digit mobile number starting with 6-9';
    }
    return null;
  }

  /// Validates OTP code of expected length.
  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    final trimmed = value.trim();
    if (!_digitsOnlyPattern.hasMatch(trimmed)) {
      return 'OTP must contain only digits';
    }
    if (trimmed.length != length) {
      return 'OTP must be $length digits';
    }
    return null;
  }

  /// Validates RFC-safe email with TLD length >= 2.
  static String? validateEmail(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Email is required' : null;
    }
    final normalized = normalizeEmail(value);
    if (!_emailPattern.hasMatch(normalized)) {
      return 'Enter a valid email address';
    }
    final parts = normalized.split('@');
    if (parts.length != 2) return 'Enter a valid email address';
    final domain = parts[1];
    final dotIndex = domain.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == domain.length - 1) {
      return 'Enter a valid email address';
    }
    final tld = domain.substring(dotIndex + 1);
    if (tld.length < 2) {
      return 'Enter a valid email domain';
    }
    return null;
  }

  /// Validates personal / organization name (Unicode letters, spaces, ', ., -; 2-50 chars).
  static String? validateName(String? value, {String fieldName = 'Name', int minLength = 2, int maxLength = 50}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final collapsed = normalizeName(value);
    if (collapsed.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    if (collapsed.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    if (!_namePattern.hasMatch(collapsed)) {
      return '$fieldName contains invalid characters';
    }
    return null;
  }

  /// Validates 12-digit Aadhaar number with Verhoeff checksum. First digit must be 2-9.
  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar number is required';
    }
    final clean = normalizeAadhaar(value);
    if (!_digitsOnlyPattern.hasMatch(clean)) {
      return 'Aadhaar must contain only digits';
    }
    if (clean.length != 12) {
      return 'Aadhaar must be 12 digits';
    }
    final firstChar = clean[0];
    if (firstChar == '0' || firstChar == '1') {
      return 'Aadhaar cannot start with 0 or 1';
    }
    if (!Verhoeff.validate(clean)) {
      return 'Invalid Aadhaar number checksum';
    }
    return null;
  }

  /// Validates 10-character PAN number with valid 4th character entity type.
  static String? validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required';
    }
    final clean = normalizePan(value);
    if (clean.length != 10) {
      return 'PAN must be 10 characters';
    }
    if (!_panPattern.hasMatch(clean)) {
      return 'Invalid PAN format (e.g. ABCDE1234F)';
    }
    final entityType = clean[3];
    if (!_panValidTypes.contains(entityType)) {
      return 'Invalid PAN holder type in 4th character';
    }
    return null;
  }

  /// Validates Indian Driving Licence.
  /// Format: 2-letter state code + 2-digit RTO + 4-digit year (1950-current) + 7-digit serial (total 15-16 chars).
  static String? validateDrivingLicense(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Driving licence number is required';
    }
    final clean = normalizeDrivingLicense(value);
    if (clean.length < 15 || clean.length > 16) {
      return 'Driving licence must be 15 or 16 alphanumeric characters';
    }
    final stateCode = clean.substring(0, 2);
    if (!_dlStateCodes.contains(stateCode)) {
      return 'Invalid state code in driving licence';
    }

    final rtoCode = clean.substring(2, 4);
    if (!_digitsOnlyPattern.hasMatch(rtoCode)) {
      return 'Invalid RTO code in driving licence';
    }

    final yearStr = clean.substring(4, 8);
    final year = int.tryParse(yearStr);
    final currentYear = DateTime.now().year;
    if (year == null || year < 1950 || year > currentYear) {
      return 'Invalid issue year in driving licence (1950-$currentYear)';
    }

    final serial = clean.substring(8);
    if (!_digitsOnlyPattern.hasMatch(serial)) {
      return 'Invalid driving licence serial number';
    }

    return null;
  }

  /// Validates Indian bank account number (digits only, 9-18 chars).
  static String? validateBankAccount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bank account number is required';
    }
    final clean = value.trim();
    if (!_digitsOnlyPattern.hasMatch(clean)) {
      return 'Account number must contain digits only';
    }
    if (clean.length < 9 || clean.length > 18) {
      return 'Account number must be between 9 and 18 digits';
    }
    return null;
  }

  /// Validates IFSC code (`^[A-Z]{4}0[A-Z0-9]{6}$`).
  static String? validateIfsc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    final clean = normalizeIfsc(value);
    if (clean.length != 11) {
      return 'IFSC must be 11 characters';
    }
    if (!_ifscPattern.hasMatch(clean)) {
      return 'Invalid IFSC code (e.g. SBIN0001234)';
    }
    return null;
  }

  /// Validates UPI ID format if provided.
  static String? validateUpiId(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'UPI ID is required' : null;
    }
    final clean = value.trim();
    if (!_upiPattern.hasMatch(clean)) {
      return 'Enter a valid UPI ID (e.g. name@okhdfcbank)';
    }
    return null;
  }

  /// Validates generic required trimmed field.
  static String? validateRequired(String? value, String fieldName, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates withdrawal amount: > 0, >= minAmount, <= balance, <= maxAmount, max 2 decimal places.
  static String? validateWithdrawalAmount(
    String? value, {
    required Money balance,
    Money? minAmount,
    Money? maxAmount,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter withdrawal amount';
    }
    final clean = value.trim();
    final parsed = double.tryParse(clean);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid amount greater than 0';
    }

    if (clean.contains('.')) {
      final decimals = clean.split('.')[1];
      if (decimals.length > 2) {
        return 'Amount can have at most 2 decimal places';
      }
    }

    final requested = Money.fromRupees(parsed);
    final min = minAmount ?? Money.fromRupees(100);
    if (requested < min) {
      return 'Minimum withdrawal amount is ${min.formatted}';
    }

    if (maxAmount != null && requested > maxAmount) {
      return 'Maximum withdrawal amount is ${maxAmount.formatted}';
    }

    if (requested > balance) {
      return 'Requested amount exceeds available balance (${balance.formatted})';
    }

    return null;
  }
}
