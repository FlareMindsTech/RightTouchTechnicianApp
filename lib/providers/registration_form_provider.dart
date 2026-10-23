import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationFormState {
  // Profile Data
  final String fname;
  final String lname;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String locality;
  final String exp;
  final String specialization;
  final String gender;
  final List<Map<String, dynamic>> selectedServices;

  // KYC Data
  final String aadharNumber;
  final String panNumber;
  final String dlNumber;
  final String? aadharPath;
  final String? aadharBackPath;
  final String? panPath;
  final String? dlPath;

  // Bank Data
  final String accountHolder;
  final String bankName;
  final String accountNumber;
  final String ifsc;
  final String branch;
  final String upi;

  RegistrationFormState({
    this.fname = '',
    this.lname = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.locality = '',
    this.exp = '',
    this.specialization = '',
    this.gender = 'Male',
    this.selectedServices = const [],
    this.aadharNumber = '',
    this.panNumber = '',
    this.dlNumber = '',
    this.aadharPath,
    this.aadharBackPath,
    this.panPath,
    this.dlPath,
    this.accountHolder = '',
    this.bankName = '',
    this.accountNumber = '',
    this.ifsc = '',
    this.branch = '',
    this.upi = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'fname': fname,
      'lname': lname,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'locality': locality,
      'exp': exp,
      'specialization': specialization,
      'gender': gender,
      'selectedServices': selectedServices,
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'dlNumber': dlNumber,
      'aadharPath': aadharPath,
      'aadharBackPath': aadharBackPath,
      'panPath': panPath,
      'dlPath': dlPath,
      'accountHolder': accountHolder,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifsc': ifsc,
      'branch': branch,
      'upi': upi,
    };
  }

  factory RegistrationFormState.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parseServices(dynamic list) {
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return RegistrationFormState(
      fname: json['fname']?.toString() ?? '',
      lname: json['lname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      locality: json['locality']?.toString() ?? '',
      exp: json['exp']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Male',
      selectedServices: parseServices(json['selectedServices']),
      aadharNumber: json['aadharNumber']?.toString() ?? '',
      panNumber: json['panNumber']?.toString() ?? '',
      dlNumber: json['dlNumber']?.toString() ?? '',
      aadharPath: json['aadharPath']?.toString(),
      aadharBackPath: json['aadharBackPath']?.toString(),
      panPath: json['panPath']?.toString(),
      dlPath: json['dlPath']?.toString(),
      accountHolder: json['accountHolder']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifsc: json['ifsc']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      upi: json['upi']?.toString() ?? '',
    );
  }

  RegistrationFormState copyWith({
    String? fname,
    String? lname,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? locality,
    String? exp,
    String? specialization,
    String? gender,
    List<Map<String, dynamic>>? selectedServices,
    String? aadharNumber,
    String? panNumber,
    String? dlNumber,
    String? aadharPath,
    String? aadharBackPath,
    String? panPath,
    String? dlPath,
    String? accountHolder,
    String? bankName,
    String? accountNumber,
    String? ifsc,
    String? branch,
    String? upi,
  }) {
    return RegistrationFormState(
      fname: fname ?? this.fname,
      lname: lname ?? this.lname,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      locality: locality ?? this.locality,
      exp: exp ?? this.exp,
      specialization: specialization ?? this.specialization,
      gender: gender ?? this.gender,
      selectedServices: selectedServices ?? this.selectedServices,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      dlNumber: dlNumber ?? this.dlNumber,
      aadharPath: aadharPath ?? this.aadharPath,
      aadharBackPath: aadharBackPath ?? this.aadharBackPath,
      panPath: panPath ?? this.panPath,
      dlPath: dlPath ?? this.dlPath,
      accountHolder: accountHolder ?? this.accountHolder,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifsc: ifsc ?? this.ifsc,
      branch: branch ?? this.branch,
      upi: upi ?? this.upi,
    );
  }
}

class RegistrationFormNotifier extends Notifier<RegistrationFormState> {
  static const String _storageKey = 'registration_form_draft';

  @override
  RegistrationFormState build() {
    _restoreFromStorage();
    return RegistrationFormState();
  }

  Future<void> _restoreFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null && saved.isNotEmpty) {
        final decoded = jsonDecode(saved);
        if (decoded is Map<String, dynamic>) {
          state = RegistrationFormState.fromJson(decoded);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error restoring registration form draft: $e');
      }
    }
  }

  Future<void> _persistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving registration form draft: $e');
      }
    }
  }

  void updateProfile({
    String? fname,
    String? lname,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? locality,
    String? exp,
    String? specialization,
    String? gender,
    List<Map<String, dynamic>>? selectedServices,
  }) {
    this.state = this.state.copyWith(
      fname: fname,
      lname: lname,
      email: email,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      locality: locality,
      exp: exp,
      specialization: specialization,
      gender: gender,
      selectedServices: selectedServices,
    );
    _persistToStorage();
  }

  void updateKyc({
    String? aadharNumber,
    String? panNumber,
    String? dlNumber,
    String? aadharPath,
    String? aadharBackPath,
    String? panPath,
    String? dlPath,
  }) {
    state = state.copyWith(
      aadharNumber: aadharNumber,
      panNumber: panNumber,
      dlNumber: dlNumber,
      aadharPath: aadharPath,
      aadharBackPath: aadharBackPath,
      panPath: panPath,
      dlPath: dlPath,
    );
    _persistToStorage();
  }

  void updateBank({
    String? accountHolder,
    String? bankName,
    String? accountNumber,
    String? ifsc,
    String? branch,
    String? upi,
  }) {
    state = state.copyWith(
      accountHolder: accountHolder,
      bankName: bankName,
      accountNumber: accountNumber,
      ifsc: ifsc,
      branch: branch,
      upi: upi,
    );
    _persistToStorage();
  }

  void clearCache() {
    state = RegistrationFormState();
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_storageKey);
    }).catchError((e) {
      if (kDebugMode) {
        debugPrint('Error clearing registration draft from prefs: $e');
      }
    });
  }
}

final registrationFormProvider =
    NotifierProvider<RegistrationFormNotifier, RegistrationFormState>(
  () => RegistrationFormNotifier(),
);
