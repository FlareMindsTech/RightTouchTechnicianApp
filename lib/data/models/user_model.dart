import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    @JsonKey(name: '_id') String? id,
    String? userId,
    String? technicianId,
    String? customerId,
    @JsonKey(name: 'fname') String? firstName,
    @JsonKey(name: 'lname') String? lastName,
    String? fullName,
    String? email,
    String? mobileNumber,
    String? gender,
    String? profileImage,
    String? role,
    String? status,
    String? defaultAddressId,

    // Technician fields
    List<String>? skills,
    int? experienceYears,
    String? specialization,
    String? workStatus,
    Map<String, dynamic>? availability,
    bool? trainingCompleted,
    String? kycStatus,
    bool? kycVerified,
    bool? bankVerified,
    @JsonKey(name: 'rating') double? rating,
    int? totalJobsCompleted,

    // Address & Location
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? locality,
    double? latitude,
    double? longitude,

    // Metadata
    DateTime? createdAt,
    DateTime? updatedAt,

    // Legacy / Compatibility fields
    @JsonKey(name: 'technicianProfileId') String? technicianProfileId,
    bool? isVerified,
    bool? profileComplete,
    Map<String, dynamic>? profile,
    String? verificationStatus,
    @JsonKey(name: 'averageRating') double? averageRating,
    @JsonKey(name: 'technician') Map<String, dynamic>? kycDetails,
    Map<String, dynamic>? rawData,
    Map<String, dynamic>? bankDetails,
    String? bankVerificationStatus,
  }) = _UserModel;

  const UserModel._();

  bool get isProfileComplete {
    if (profileComplete == true) return true;

    // Check rawData for explicit profileComplete flag from nested structures
    final rawProfileComplete = rawData?['profileComplete'];
    if (rawProfileComplete == true) return true;

    // Fallback: Check if essential profile fields are populated
    final fname = firstName?.isNotEmpty == true
        ? firstName
        : rawData?['fname']?.toString();
    final hasNames = fname != null && fname.isNotEmpty;
    final hasAddress = address != null && address!.isNotEmpty;
    final hasLocality = locality != null && locality!.isNotEmpty;
    final hasCity = city != null && city!.isNotEmpty;
    final hasSpecialization =
        specialization != null && specialization!.isNotEmpty;

    // Also consider profile complete if skills are present with valid service data
    final rawSkills = rawData?['skills'];
    final hasSkills = rawSkills is List &&
        rawSkills.isNotEmpty &&
        rawSkills.first is Map &&
        rawSkills.first['serviceId'] != null;

    return hasNames &&
        hasAddress &&
        hasLocality &&
        hasCity &&
        (hasSpecialization || hasSkills);
  }

  bool get areKycDocumentsSubmitted {
    final statusValue = kycStatus ??
        verificationStatus ??
        kycDetails?['status'] ??
        kycDetails?['verificationStatus'] ??
        kycDetails?['kycStatus'];

    if (statusValue == null) return false;

    final s = statusValue.toString().toLowerCase();
    if (s == 'none' || s == 'incomplete' || s == '' || s == 'null') {
      return false;
    }

    // If status is 'pending', ensure we actually have details
    if (s == 'pending' || s == 'submitted') {
      final kyc = kycDetails;
      final hasAadhar = kyc?['aadhaarNumber']?.toString().isNotEmpty ?? false;
      final hasPan = kyc?['panNumber']?.toString().isNotEmpty ?? false;
      if (!hasAadhar && !hasPan) return false;
    }

    return (s == 'submitted' ||
        s == 'pending' ||
        s == 'approved' ||
        s == 'verified');
  }

  bool get hasBankDetails {
    // Helper to check if an account number value is valid
    bool validAcctNumber(dynamic v) =>
        v != null &&
        v.toString().trim().isNotEmpty &&
        v.toString().toLowerCase() != 'null';

    // 1. Check the parsed bankDetails map in the model
    final bank = bankDetails;
    if (bank != null) {
      if (validAcctNumber(bank['accountNumber']) ||
          validAcctNumber(bank['bankAccountNumber']) ||
          validAcctNumber(bank['accountNo'])) {
        return true;
      }
    }

    // 2. Check rawData for bankDetails object (root and nested in technician)
    final rawBank =
        rawData?['bankDetails'] ?? rawData?['technician']?['bankDetails'];
    if (rawBank is Map) {
      if (validAcctNumber(rawBank['accountNumber']) ||
          validAcctNumber(rawBank['bankAccountNumber']) ||
          validAcctNumber(rawBank['accountNo'])) {
        return true;
      }
    }

    // 3. Check if bankVerified flag is set
    if (bankVerified == true) return true;
    if (rawData?['bankVerified'] == true) return true;
    if (rawData?['technician']?['bankVerified'] == true) return true;

    // 4. Check bank verification status strings
    final bvStatus = bankVerificationStatus ??
        rawData?['bankVerificationStatus']?.toString() ??
        rawData?['technician']?['bankVerificationStatus']?.toString();

    if (bvStatus != null) {
      final s = bvStatus.toLowerCase();
      if (s == 'verified' || s == 'approved') {
        return true;
      }
      // Note: We don't return true for 'submitted' or 'pending' here
      // because if they were truly submitted, steps 1 or 2 would have
      // already found the account number and returned true.
      // This prevents skipping the screen if the status is 'pending' (e.g. for KYC)
      // but bank details are actually empty.
    }

    return false;
  }

  bool get isKycSubmitted => areKycDocumentsSubmitted && hasBankDetails;

  bool get isVerifiedStatus {
    final s = kycStatus ??
        verificationStatus ??
        workStatus ??
        kycDetails?['status'] ??
        kycDetails?['verificationStatus'] ??
        kycDetails?['kycStatus'];

    return s == 'approved' || s == 'verified';
  }

  String get fullDisplayName {
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName!;
    if (firstName != null && lastName != null) {
      if (firstName!.isEmpty) return lastName!;
      if (lastName!.isEmpty) return firstName!;
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? "Technician";
  }

  double get avgRating {
    final r = rawData?['rating'] ?? rawData?['averageRating'];
    if (r is num) return r.toDouble();
    if (r is Map) return (r['avg'] as num?)?.toDouble() ?? 0.0;
    return 0.0;
  }

  int get ratingCount {
    final r = rawData?['rating'] ?? rawData?['averageRating'];
    if (r is Map) return (r['count'] as num?)?.toInt() ?? 0;
    return 0;
  }

  bool get isOnline {
    return availability?['isOnline'] ?? true;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
