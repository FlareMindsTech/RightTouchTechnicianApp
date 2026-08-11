import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  RegistrationFormState build() {
    return RegistrationFormState();
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
  }

  void clearCache() {
    state = RegistrationFormState();
  }
}

final registrationFormProvider =
    NotifierProvider<RegistrationFormNotifier, RegistrationFormState>(
  () => RegistrationFormNotifier(),
);
