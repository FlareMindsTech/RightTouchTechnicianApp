// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {
  @JsonKey(name: '_id')
  String? get id;
  String? get userId;
  String? get technicianId;
  String? get customerId;
  @JsonKey(name: 'fname')
  String? get firstName;
  @JsonKey(name: 'lname')
  String? get lastName;
  String? get fullName;
  String? get email;
  String? get mobileNumber;
  String? get gender;
  String? get profileImage;
  String? get role;
  String? get status;
  String? get defaultAddressId; // Technician fields
  List<String>? get skills;
  int? get experienceYears;
  String? get specialization;
  String? get workStatus;
  Map<String, dynamic>? get availability;
  bool? get trainingCompleted;
  String? get kycStatus;
  bool? get kycVerified;
  bool? get bankVerified;
  @JsonKey(name: 'rating')
  double? get rating;
  int? get totalJobsCompleted; // Address & Location
  String? get address;
  String? get city;
  String? get state;
  String? get pincode;
  String? get locality;
  double? get latitude;
  double? get longitude; // Metadata
  DateTime? get createdAt;
  DateTime? get updatedAt; // Legacy / Compatibility fields
  @JsonKey(name: 'technicianProfileId')
  String? get technicianProfileId;
  bool? get isVerified;
  bool? get profileComplete;
  Map<String, dynamic>? get profile;
  String? get verificationStatus;
  @JsonKey(name: 'averageRating')
  double? get averageRating;
  @JsonKey(name: 'technician')
  Map<String, dynamic>? get kycDetails;
  Map<String, dynamic>? get rawData;
  Map<String, dynamic>? get bankDetails;
  String? get bankVerificationStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<UserModel> get copyWith =>
      _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.technicianId, technicianId) ||
                other.technicianId == technicianId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.defaultAddressId, defaultAddressId) ||
                other.defaultAddressId == defaultAddressId) &&
            const DeepCollectionEquality().equals(other.skills, skills) &&
            (identical(other.experienceYears, experienceYears) ||
                other.experienceYears == experienceYears) &&
            (identical(other.specialization, specialization) ||
                other.specialization == specialization) &&
            (identical(other.workStatus, workStatus) ||
                other.workStatus == workStatus) &&
            const DeepCollectionEquality()
                .equals(other.availability, availability) &&
            (identical(other.trainingCompleted, trainingCompleted) ||
                other.trainingCompleted == trainingCompleted) &&
            (identical(other.kycStatus, kycStatus) ||
                other.kycStatus == kycStatus) &&
            (identical(other.kycVerified, kycVerified) ||
                other.kycVerified == kycVerified) &&
            (identical(other.bankVerified, bankVerified) ||
                other.bankVerified == bankVerified) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalJobsCompleted, totalJobsCompleted) ||
                other.totalJobsCompleted == totalJobsCompleted) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            (identical(other.locality, locality) ||
                other.locality == locality) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.technicianProfileId, technicianProfileId) ||
                other.technicianProfileId == technicianProfileId) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.profileComplete, profileComplete) ||
                other.profileComplete == profileComplete) &&
            const DeepCollectionEquality().equals(other.profile, profile) &&
            (identical(other.verificationStatus, verificationStatus) ||
                other.verificationStatus == verificationStatus) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            const DeepCollectionEquality()
                .equals(other.kycDetails, kycDetails) &&
            const DeepCollectionEquality().equals(other.rawData, rawData) &&
            const DeepCollectionEquality()
                .equals(other.bankDetails, bankDetails) &&
            (identical(other.bankVerificationStatus, bankVerificationStatus) ||
                other.bankVerificationStatus == bankVerificationStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        technicianId,
        customerId,
        firstName,
        lastName,
        fullName,
        email,
        mobileNumber,
        gender,
        profileImage,
        role,
        status,
        defaultAddressId,
        const DeepCollectionEquality().hash(skills),
        experienceYears,
        specialization,
        workStatus,
        const DeepCollectionEquality().hash(availability),
        trainingCompleted,
        kycStatus,
        kycVerified,
        bankVerified,
        rating,
        totalJobsCompleted,
        address,
        city,
        state,
        pincode,
        locality,
        latitude,
        longitude,
        createdAt,
        updatedAt,
        technicianProfileId,
        isVerified,
        profileComplete,
        const DeepCollectionEquality().hash(profile),
        verificationStatus,
        averageRating,
        const DeepCollectionEquality().hash(kycDetails),
        const DeepCollectionEquality().hash(rawData),
        const DeepCollectionEquality().hash(bankDetails),
        bankVerificationStatus
      ]);

  @override
  String toString() {
    return 'UserModel(id: $id, userId: $userId, technicianId: $technicianId, customerId: $customerId, firstName: $firstName, lastName: $lastName, fullName: $fullName, email: $email, mobileNumber: $mobileNumber, gender: $gender, profileImage: $profileImage, role: $role, status: $status, defaultAddressId: $defaultAddressId, skills: $skills, experienceYears: $experienceYears, specialization: $specialization, workStatus: $workStatus, availability: $availability, trainingCompleted: $trainingCompleted, kycStatus: $kycStatus, kycVerified: $kycVerified, bankVerified: $bankVerified, rating: $rating, totalJobsCompleted: $totalJobsCompleted, address: $address, city: $city, state: $state, pincode: $pincode, locality: $locality, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt, technicianProfileId: $technicianProfileId, isVerified: $isVerified, profileComplete: $profileComplete, profile: $profile, verificationStatus: $verificationStatus, averageRating: $averageRating, kycDetails: $kycDetails, rawData: $rawData, bankDetails: $bankDetails, bankVerificationStatus: $bankVerificationStatus)';
  }
}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) =
      _$UserModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
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
      String? address,
      String? city,
      String? state,
      String? pincode,
      String? locality,
      double? latitude,
      double? longitude,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(name: 'technicianProfileId') String? technicianProfileId,
      bool? isVerified,
      bool? profileComplete,
      Map<String, dynamic>? profile,
      String? verificationStatus,
      @JsonKey(name: 'averageRating') double? averageRating,
      @JsonKey(name: 'technician') Map<String, dynamic>? kycDetails,
      Map<String, dynamic>? rawData,
      Map<String, dynamic>? bankDetails,
      String? bankVerificationStatus});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res> implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? technicianId = freezed,
    Object? customerId = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? fullName = freezed,
    Object? email = freezed,
    Object? mobileNumber = freezed,
    Object? gender = freezed,
    Object? profileImage = freezed,
    Object? role = freezed,
    Object? status = freezed,
    Object? defaultAddressId = freezed,
    Object? skills = freezed,
    Object? experienceYears = freezed,
    Object? specialization = freezed,
    Object? workStatus = freezed,
    Object? availability = freezed,
    Object? trainingCompleted = freezed,
    Object? kycStatus = freezed,
    Object? kycVerified = freezed,
    Object? bankVerified = freezed,
    Object? rating = freezed,
    Object? totalJobsCompleted = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pincode = freezed,
    Object? locality = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? technicianProfileId = freezed,
    Object? isVerified = freezed,
    Object? profileComplete = freezed,
    Object? profile = freezed,
    Object? verificationStatus = freezed,
    Object? averageRating = freezed,
    Object? kycDetails = freezed,
    Object? rawData = freezed,
    Object? bankDetails = freezed,
    Object? bankVerificationStatus = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      technicianId: freezed == technicianId
          ? _self.technicianId
          : technicianId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      mobileNumber: freezed == mobileNumber
          ? _self.mobileNumber
          : mobileNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImage: freezed == profileImage
          ? _self.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultAddressId: freezed == defaultAddressId
          ? _self.defaultAddressId
          : defaultAddressId // ignore: cast_nullable_to_non_nullable
              as String?,
      skills: freezed == skills
          ? _self.skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      experienceYears: freezed == experienceYears
          ? _self.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int?,
      specialization: freezed == specialization
          ? _self.specialization
          : specialization // ignore: cast_nullable_to_non_nullable
              as String?,
      workStatus: freezed == workStatus
          ? _self.workStatus
          : workStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      availability: freezed == availability
          ? _self.availability
          : availability // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      trainingCompleted: freezed == trainingCompleted
          ? _self.trainingCompleted
          : trainingCompleted // ignore: cast_nullable_to_non_nullable
              as bool?,
      kycStatus: freezed == kycStatus
          ? _self.kycStatus
          : kycStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      kycVerified: freezed == kycVerified
          ? _self.kycVerified
          : kycVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      bankVerified: freezed == bankVerified
          ? _self.bankVerified
          : bankVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      rating: freezed == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalJobsCompleted: freezed == totalJobsCompleted
          ? _self.totalJobsCompleted
          : totalJobsCompleted // ignore: cast_nullable_to_non_nullable
              as int?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      pincode: freezed == pincode
          ? _self.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String?,
      locality: freezed == locality
          ? _self.locality
          : locality // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      technicianProfileId: freezed == technicianProfileId
          ? _self.technicianProfileId
          : technicianProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      profileComplete: freezed == profileComplete
          ? _self.profileComplete
          : profileComplete // ignore: cast_nullable_to_non_nullable
              as bool?,
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      verificationStatus: freezed == verificationStatus
          ? _self.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      averageRating: freezed == averageRating
          ? _self.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double?,
      kycDetails: freezed == kycDetails
          ? _self.kycDetails
          : kycDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      rawData: freezed == rawData
          ? _self.rawData
          : rawData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      bankDetails: freezed == bankDetails
          ? _self.bankDetails
          : bankDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      bankVerificationStatus: freezed == bankVerificationStatus
          ? _self.bankVerificationStatus
          : bankVerificationStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_UserModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_UserModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_UserModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
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
            String? address,
            String? city,
            String? state,
            String? pincode,
            String? locality,
            double? latitude,
            double? longitude,
            DateTime? createdAt,
            DateTime? updatedAt,
            @JsonKey(name: 'technicianProfileId') String? technicianProfileId,
            bool? isVerified,
            bool? profileComplete,
            Map<String, dynamic>? profile,
            String? verificationStatus,
            @JsonKey(name: 'averageRating') double? averageRating,
            @JsonKey(name: 'technician') Map<String, dynamic>? kycDetails,
            Map<String, dynamic>? rawData,
            Map<String, dynamic>? bankDetails,
            String? bankVerificationStatus)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.technicianId,
            _that.customerId,
            _that.firstName,
            _that.lastName,
            _that.fullName,
            _that.email,
            _that.mobileNumber,
            _that.gender,
            _that.profileImage,
            _that.role,
            _that.status,
            _that.defaultAddressId,
            _that.skills,
            _that.experienceYears,
            _that.specialization,
            _that.workStatus,
            _that.availability,
            _that.trainingCompleted,
            _that.kycStatus,
            _that.kycVerified,
            _that.bankVerified,
            _that.rating,
            _that.totalJobsCompleted,
            _that.address,
            _that.city,
            _that.state,
            _that.pincode,
            _that.locality,
            _that.latitude,
            _that.longitude,
            _that.createdAt,
            _that.updatedAt,
            _that.technicianProfileId,
            _that.isVerified,
            _that.profileComplete,
            _that.profile,
            _that.verificationStatus,
            _that.averageRating,
            _that.kycDetails,
            _that.rawData,
            _that.bankDetails,
            _that.bankVerificationStatus);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
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
            String? address,
            String? city,
            String? state,
            String? pincode,
            String? locality,
            double? latitude,
            double? longitude,
            DateTime? createdAt,
            DateTime? updatedAt,
            @JsonKey(name: 'technicianProfileId') String? technicianProfileId,
            bool? isVerified,
            bool? profileComplete,
            Map<String, dynamic>? profile,
            String? verificationStatus,
            @JsonKey(name: 'averageRating') double? averageRating,
            @JsonKey(name: 'technician') Map<String, dynamic>? kycDetails,
            Map<String, dynamic>? rawData,
            Map<String, dynamic>? bankDetails,
            String? bankVerificationStatus)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel():
        return $default(
            _that.id,
            _that.userId,
            _that.technicianId,
            _that.customerId,
            _that.firstName,
            _that.lastName,
            _that.fullName,
            _that.email,
            _that.mobileNumber,
            _that.gender,
            _that.profileImage,
            _that.role,
            _that.status,
            _that.defaultAddressId,
            _that.skills,
            _that.experienceYears,
            _that.specialization,
            _that.workStatus,
            _that.availability,
            _that.trainingCompleted,
            _that.kycStatus,
            _that.kycVerified,
            _that.bankVerified,
            _that.rating,
            _that.totalJobsCompleted,
            _that.address,
            _that.city,
            _that.state,
            _that.pincode,
            _that.locality,
            _that.latitude,
            _that.longitude,
            _that.createdAt,
            _that.updatedAt,
            _that.technicianProfileId,
            _that.isVerified,
            _that.profileComplete,
            _that.profile,
            _that.verificationStatus,
            _that.averageRating,
            _that.kycDetails,
            _that.rawData,
            _that.bankDetails,
            _that.bankVerificationStatus);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
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
            String? address,
            String? city,
            String? state,
            String? pincode,
            String? locality,
            double? latitude,
            double? longitude,
            DateTime? createdAt,
            DateTime? updatedAt,
            @JsonKey(name: 'technicianProfileId') String? technicianProfileId,
            bool? isVerified,
            bool? profileComplete,
            Map<String, dynamic>? profile,
            String? verificationStatus,
            @JsonKey(name: 'averageRating') double? averageRating,
            @JsonKey(name: 'technician') Map<String, dynamic>? kycDetails,
            Map<String, dynamic>? rawData,
            Map<String, dynamic>? bankDetails,
            String? bankVerificationStatus)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.technicianId,
            _that.customerId,
            _that.firstName,
            _that.lastName,
            _that.fullName,
            _that.email,
            _that.mobileNumber,
            _that.gender,
            _that.profileImage,
            _that.role,
            _that.status,
            _that.defaultAddressId,
            _that.skills,
            _that.experienceYears,
            _that.specialization,
            _that.workStatus,
            _that.availability,
            _that.trainingCompleted,
            _that.kycStatus,
            _that.kycVerified,
            _that.bankVerified,
            _that.rating,
            _that.totalJobsCompleted,
            _that.address,
            _that.city,
            _that.state,
            _that.pincode,
            _that.locality,
            _that.latitude,
            _that.longitude,
            _that.createdAt,
            _that.updatedAt,
            _that.technicianProfileId,
            _that.isVerified,
            _that.profileComplete,
            _that.profile,
            _that.verificationStatus,
            _that.averageRating,
            _that.kycDetails,
            _that.rawData,
            _that.bankDetails,
            _that.bankVerificationStatus);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserModel extends UserModel {
  const _UserModel(
      {@JsonKey(name: '_id') this.id,
      this.userId,
      this.technicianId,
      this.customerId,
      @JsonKey(name: 'fname') this.firstName,
      @JsonKey(name: 'lname') this.lastName,
      this.fullName,
      this.email,
      this.mobileNumber,
      this.gender,
      this.profileImage,
      this.role,
      this.status,
      this.defaultAddressId,
      final List<String>? skills,
      this.experienceYears,
      this.specialization,
      this.workStatus,
      final Map<String, dynamic>? availability,
      this.trainingCompleted,
      this.kycStatus,
      this.kycVerified,
      this.bankVerified,
      @JsonKey(name: 'rating') this.rating,
      this.totalJobsCompleted,
      this.address,
      this.city,
      this.state,
      this.pincode,
      this.locality,
      this.latitude,
      this.longitude,
      this.createdAt,
      this.updatedAt,
      @JsonKey(name: 'technicianProfileId') this.technicianProfileId,
      this.isVerified,
      this.profileComplete,
      final Map<String, dynamic>? profile,
      this.verificationStatus,
      @JsonKey(name: 'averageRating') this.averageRating,
      @JsonKey(name: 'technician') final Map<String, dynamic>? kycDetails,
      final Map<String, dynamic>? rawData,
      final Map<String, dynamic>? bankDetails,
      this.bankVerificationStatus})
      : _skills = skills,
        _availability = availability,
        _profile = profile,
        _kycDetails = kycDetails,
        _rawData = rawData,
        _bankDetails = bankDetails,
        super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? userId;
  @override
  final String? technicianId;
  @override
  final String? customerId;
  @override
  @JsonKey(name: 'fname')
  final String? firstName;
  @override
  @JsonKey(name: 'lname')
  final String? lastName;
  @override
  final String? fullName;
  @override
  final String? email;
  @override
  final String? mobileNumber;
  @override
  final String? gender;
  @override
  final String? profileImage;
  @override
  final String? role;
  @override
  final String? status;
  @override
  final String? defaultAddressId;
// Technician fields
  final List<String>? _skills;
// Technician fields
  @override
  List<String>? get skills {
    final value = _skills;
    if (value == null) return null;
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? experienceYears;
  @override
  final String? specialization;
  @override
  final String? workStatus;
  final Map<String, dynamic>? _availability;
  @override
  Map<String, dynamic>? get availability {
    final value = _availability;
    if (value == null) return null;
    if (_availability is EqualUnmodifiableMapView) return _availability;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? trainingCompleted;
  @override
  final String? kycStatus;
  @override
  final bool? kycVerified;
  @override
  final bool? bankVerified;
  @override
  @JsonKey(name: 'rating')
  final double? rating;
  @override
  final int? totalJobsCompleted;
// Address & Location
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? pincode;
  @override
  final String? locality;
  @override
  final double? latitude;
  @override
  final double? longitude;
// Metadata
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// Legacy / Compatibility fields
  @override
  @JsonKey(name: 'technicianProfileId')
  final String? technicianProfileId;
  @override
  final bool? isVerified;
  @override
  final bool? profileComplete;
  final Map<String, dynamic>? _profile;
  @override
  Map<String, dynamic>? get profile {
    final value = _profile;
    if (value == null) return null;
    if (_profile is EqualUnmodifiableMapView) return _profile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? verificationStatus;
  @override
  @JsonKey(name: 'averageRating')
  final double? averageRating;
  final Map<String, dynamic>? _kycDetails;
  @override
  @JsonKey(name: 'technician')
  Map<String, dynamic>? get kycDetails {
    final value = _kycDetails;
    if (value == null) return null;
    if (_kycDetails is EqualUnmodifiableMapView) return _kycDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _rawData;
  @override
  Map<String, dynamic>? get rawData {
    final value = _rawData;
    if (value == null) return null;
    if (_rawData is EqualUnmodifiableMapView) return _rawData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _bankDetails;
  @override
  Map<String, dynamic>? get bankDetails {
    final value = _bankDetails;
    if (value == null) return null;
    if (_bankDetails is EqualUnmodifiableMapView) return _bankDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? bankVerificationStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserModelCopyWith<_UserModel> get copyWith =>
      __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.technicianId, technicianId) ||
                other.technicianId == technicianId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.defaultAddressId, defaultAddressId) ||
                other.defaultAddressId == defaultAddressId) &&
            const DeepCollectionEquality().equals(other._skills, _skills) &&
            (identical(other.experienceYears, experienceYears) ||
                other.experienceYears == experienceYears) &&
            (identical(other.specialization, specialization) ||
                other.specialization == specialization) &&
            (identical(other.workStatus, workStatus) ||
                other.workStatus == workStatus) &&
            const DeepCollectionEquality()
                .equals(other._availability, _availability) &&
            (identical(other.trainingCompleted, trainingCompleted) ||
                other.trainingCompleted == trainingCompleted) &&
            (identical(other.kycStatus, kycStatus) ||
                other.kycStatus == kycStatus) &&
            (identical(other.kycVerified, kycVerified) ||
                other.kycVerified == kycVerified) &&
            (identical(other.bankVerified, bankVerified) ||
                other.bankVerified == bankVerified) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalJobsCompleted, totalJobsCompleted) ||
                other.totalJobsCompleted == totalJobsCompleted) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            (identical(other.locality, locality) ||
                other.locality == locality) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.technicianProfileId, technicianProfileId) ||
                other.technicianProfileId == technicianProfileId) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.profileComplete, profileComplete) ||
                other.profileComplete == profileComplete) &&
            const DeepCollectionEquality().equals(other._profile, _profile) &&
            (identical(other.verificationStatus, verificationStatus) ||
                other.verificationStatus == verificationStatus) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            const DeepCollectionEquality()
                .equals(other._kycDetails, _kycDetails) &&
            const DeepCollectionEquality().equals(other._rawData, _rawData) &&
            const DeepCollectionEquality()
                .equals(other._bankDetails, _bankDetails) &&
            (identical(other.bankVerificationStatus, bankVerificationStatus) ||
                other.bankVerificationStatus == bankVerificationStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        technicianId,
        customerId,
        firstName,
        lastName,
        fullName,
        email,
        mobileNumber,
        gender,
        profileImage,
        role,
        status,
        defaultAddressId,
        const DeepCollectionEquality().hash(_skills),
        experienceYears,
        specialization,
        workStatus,
        const DeepCollectionEquality().hash(_availability),
        trainingCompleted,
        kycStatus,
        kycVerified,
        bankVerified,
        rating,
        totalJobsCompleted,
        address,
        city,
        state,
        pincode,
        locality,
        latitude,
        longitude,
        createdAt,
        updatedAt,
        technicianProfileId,
        isVerified,
        profileComplete,
        const DeepCollectionEquality().hash(_profile),
        verificationStatus,
        averageRating,
        const DeepCollectionEquality().hash(_kycDetails),
        const DeepCollectionEquality().hash(_rawData),
        const DeepCollectionEquality().hash(_bankDetails),
        bankVerificationStatus
      ]);

  @override
  String toString() {
    return 'UserModel(id: $id, userId: $userId, technicianId: $technicianId, customerId: $customerId, firstName: $firstName, lastName: $lastName, fullName: $fullName, email: $email, mobileNumber: $mobileNumber, gender: $gender, profileImage: $profileImage, role: $role, status: $status, defaultAddressId: $defaultAddressId, skills: $skills, experienceYears: $experienceYears, specialization: $specialization, workStatus: $workStatus, availability: $availability, trainingCompleted: $trainingCompleted, kycStatus: $kycStatus, kycVerified: $kycVerified, bankVerified: $bankVerified, rating: $rating, totalJobsCompleted: $totalJobsCompleted, address: $address, city: $city, state: $state, pincode: $pincode, locality: $locality, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt, technicianProfileId: $technicianProfileId, isVerified: $isVerified, profileComplete: $profileComplete, profile: $profile, verificationStatus: $verificationStatus, averageRating: $averageRating, kycDetails: $kycDetails, rawData: $rawData, bankDetails: $bankDetails, bankVerificationStatus: $bankVerificationStatus)';
  }
}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(
          _UserModel value, $Res Function(_UserModel) _then) =
      __$UserModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
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
      String? address,
      String? city,
      String? state,
      String? pincode,
      String? locality,
      double? latitude,
      double? longitude,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(name: 'technicianProfileId') String? technicianProfileId,
      bool? isVerified,
      bool? profileComplete,
      Map<String, dynamic>? profile,
      String? verificationStatus,
      @JsonKey(name: 'averageRating') double? averageRating,
      @JsonKey(name: 'technician') Map<String, dynamic>? kycDetails,
      Map<String, dynamic>? rawData,
      Map<String, dynamic>? bankDetails,
      String? bankVerificationStatus});
}

/// @nodoc
class __$UserModelCopyWithImpl<$Res> implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? technicianId = freezed,
    Object? customerId = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? fullName = freezed,
    Object? email = freezed,
    Object? mobileNumber = freezed,
    Object? gender = freezed,
    Object? profileImage = freezed,
    Object? role = freezed,
    Object? status = freezed,
    Object? defaultAddressId = freezed,
    Object? skills = freezed,
    Object? experienceYears = freezed,
    Object? specialization = freezed,
    Object? workStatus = freezed,
    Object? availability = freezed,
    Object? trainingCompleted = freezed,
    Object? kycStatus = freezed,
    Object? kycVerified = freezed,
    Object? bankVerified = freezed,
    Object? rating = freezed,
    Object? totalJobsCompleted = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pincode = freezed,
    Object? locality = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? technicianProfileId = freezed,
    Object? isVerified = freezed,
    Object? profileComplete = freezed,
    Object? profile = freezed,
    Object? verificationStatus = freezed,
    Object? averageRating = freezed,
    Object? kycDetails = freezed,
    Object? rawData = freezed,
    Object? bankDetails = freezed,
    Object? bankVerificationStatus = freezed,
  }) {
    return _then(_UserModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      technicianId: freezed == technicianId
          ? _self.technicianId
          : technicianId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      mobileNumber: freezed == mobileNumber
          ? _self.mobileNumber
          : mobileNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImage: freezed == profileImage
          ? _self.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultAddressId: freezed == defaultAddressId
          ? _self.defaultAddressId
          : defaultAddressId // ignore: cast_nullable_to_non_nullable
              as String?,
      skills: freezed == skills
          ? _self._skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      experienceYears: freezed == experienceYears
          ? _self.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int?,
      specialization: freezed == specialization
          ? _self.specialization
          : specialization // ignore: cast_nullable_to_non_nullable
              as String?,
      workStatus: freezed == workStatus
          ? _self.workStatus
          : workStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      availability: freezed == availability
          ? _self._availability
          : availability // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      trainingCompleted: freezed == trainingCompleted
          ? _self.trainingCompleted
          : trainingCompleted // ignore: cast_nullable_to_non_nullable
              as bool?,
      kycStatus: freezed == kycStatus
          ? _self.kycStatus
          : kycStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      kycVerified: freezed == kycVerified
          ? _self.kycVerified
          : kycVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      bankVerified: freezed == bankVerified
          ? _self.bankVerified
          : bankVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      rating: freezed == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalJobsCompleted: freezed == totalJobsCompleted
          ? _self.totalJobsCompleted
          : totalJobsCompleted // ignore: cast_nullable_to_non_nullable
              as int?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      pincode: freezed == pincode
          ? _self.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String?,
      locality: freezed == locality
          ? _self.locality
          : locality // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      technicianProfileId: freezed == technicianProfileId
          ? _self.technicianProfileId
          : technicianProfileId // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      profileComplete: freezed == profileComplete
          ? _self.profileComplete
          : profileComplete // ignore: cast_nullable_to_non_nullable
              as bool?,
      profile: freezed == profile
          ? _self._profile
          : profile // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      verificationStatus: freezed == verificationStatus
          ? _self.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      averageRating: freezed == averageRating
          ? _self.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double?,
      kycDetails: freezed == kycDetails
          ? _self._kycDetails
          : kycDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      rawData: freezed == rawData
          ? _self._rawData
          : rawData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      bankDetails: freezed == bankDetails
          ? _self._bankDetails
          : bankDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      bankVerificationStatus: freezed == bankVerificationStatus
          ? _self.bankVerificationStatus
          : bankVerificationStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
