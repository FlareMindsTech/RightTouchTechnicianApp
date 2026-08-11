// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get technicianId => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get mobileNumber => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get profileImage => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get defaultAddressId =>
      throw _privateConstructorUsedError; // Technician fields
  List<String>? get skills => throw _privateConstructorUsedError;
  int? get experienceYears => throw _privateConstructorUsedError;
  String? get specialization => throw _privateConstructorUsedError;
  String? get workStatus => throw _privateConstructorUsedError;
  Map<String, dynamic>? get availability => throw _privateConstructorUsedError;
  bool? get trainingCompleted => throw _privateConstructorUsedError;
  String? get kycStatus => throw _privateConstructorUsedError;
  bool? get kycVerified => throw _privateConstructorUsedError;
  bool? get bankVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating')
  double? get rating => throw _privateConstructorUsedError;
  int? get totalJobsCompleted =>
      throw _privateConstructorUsedError; // Address & Location
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get pincode => throw _privateConstructorUsedError;
  String? get locality => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError; // Metadata
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Legacy / Compatibility fields
  @JsonKey(name: 'technicianProfileId')
  String? get technicianProfileId => throw _privateConstructorUsedError;
  bool? get isVerified => throw _privateConstructorUsedError;
  bool? get profileComplete => throw _privateConstructorUsedError;
  Map<String, dynamic>? get profile => throw _privateConstructorUsedError;
  String? get verificationStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'averageRating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'technician')
  Map<String, dynamic>? get kycDetails => throw _privateConstructorUsedError;
  Map<String, dynamic>? get rawData => throw _privateConstructorUsedError;
  Map<String, dynamic>? get bankDetails => throw _privateConstructorUsedError;
  String? get bankVerificationStatus => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String? userId,
    String? technicianId,
    String? customerId,
    String? firstName,
    String? lastName,
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
    String? bankVerificationStatus,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(
      _value.copyWith(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                as String?,
        technicianId: freezed == technicianId
            ? _value.technicianId
            : technicianId // ignore: cast_nullable_to_non_nullable
                as String?,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                as String?,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                as String?,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                as String?,
        mobileNumber: freezed == mobileNumber
            ? _value.mobileNumber
            : mobileNumber // ignore: cast_nullable_to_non_nullable
                as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                as String?,
        profileImage: freezed == profileImage
            ? _value.profileImage
            : profileImage // ignore: cast_nullable_to_non_nullable
                as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                as String?,
        defaultAddressId: freezed == defaultAddressId
            ? _value.defaultAddressId
            : defaultAddressId // ignore: cast_nullable_to_non_nullable
                as String?,
        skills: freezed == skills
            ? _value.skills
            : skills // ignore: cast_nullable_to_non_nullable
                as List<String>?,
        experienceYears: freezed == experienceYears
            ? _value.experienceYears
            : experienceYears // ignore: cast_nullable_to_non_nullable
                as int?,
        specialization: freezed == specialization
            ? _value.specialization
            : specialization // ignore: cast_nullable_to_non_nullable
                as String?,
        workStatus: freezed == workStatus
            ? _value.workStatus
            : workStatus // ignore: cast_nullable_to_non_nullable
                as String?,
        availability: freezed == availability
            ? _value.availability
            : availability // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        trainingCompleted: freezed == trainingCompleted
            ? _value.trainingCompleted
            : trainingCompleted // ignore: cast_nullable_to_non_nullable
                as bool?,
        kycStatus: freezed == kycStatus
            ? _value.kycStatus
            : kycStatus // ignore: cast_nullable_to_non_nullable
                as String?,
        kycVerified: freezed == kycVerified
            ? _value.kycVerified
            : kycVerified // ignore: cast_nullable_to_non_nullable
                as bool?,
        bankVerified: freezed == bankVerified
            ? _value.bankVerified
            : bankVerified // ignore: cast_nullable_to_non_nullable
                as bool?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                as double?,
        totalJobsCompleted: freezed == totalJobsCompleted
            ? _value.totalJobsCompleted
            : totalJobsCompleted // ignore: cast_nullable_to_non_nullable
                as int?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                as String?,
        state: freezed == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                as String?,
        pincode: freezed == pincode
            ? _value.pincode
            : pincode // ignore: cast_nullable_to_non_nullable
                as String?,
        locality: freezed == locality
            ? _value.locality
            : locality // ignore: cast_nullable_to_non_nullable
                as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                as double?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        technicianProfileId: freezed == technicianProfileId
            ? _value.technicianProfileId
            : technicianProfileId // ignore: cast_nullable_to_non_nullable
                as String?,
        isVerified: freezed == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                as bool?,
        profileComplete: freezed == profileComplete
            ? _value.profileComplete
            : profileComplete // ignore: cast_nullable_to_non_nullable
                as bool?,
        profile: freezed == profile
            ? _value.profile
            : profile // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        verificationStatus: freezed == verificationStatus
            ? _value.verificationStatus
            : verificationStatus // ignore: cast_nullable_to_non_nullable
                as String?,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                as double?,
        kycDetails: freezed == kycDetails
            ? _value.kycDetails
            : kycDetails // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        rawData: freezed == rawData
            ? _value.rawData
            : rawData // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        bankDetails: freezed == bankDetails
            ? _value.bankDetails
            : bankDetails // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        bankVerificationStatus: freezed == bankVerificationStatus
            ? _value.bankVerificationStatus
            : bankVerificationStatus // ignore: cast_nullable_to_non_nullable
                as String?,
      ) as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String? userId,
    String? technicianId,
    String? customerId,
    String? firstName,
    String? lastName,
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
    String? bankVerificationStatus,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

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
    return _then(
      _$UserModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                as String?,
        technicianId: freezed == technicianId
            ? _value.technicianId
            : technicianId // ignore: cast_nullable_to_non_nullable
                as String?,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                as String?,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                as String?,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                as String?,
        mobileNumber: freezed == mobileNumber
            ? _value.mobileNumber
            : mobileNumber // ignore: cast_nullable_to_non_nullable
                as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                as String?,
        profileImage: freezed == profileImage
            ? _value.profileImage
            : profileImage // ignore: cast_nullable_to_non_nullable
                as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                as String?,
        defaultAddressId: freezed == defaultAddressId
            ? _value.defaultAddressId
            : defaultAddressId // ignore: cast_nullable_to_non_nullable
                as String?,
        skills: freezed == skills
            ? _value._skills
            : skills // ignore: cast_nullable_to_non_nullable
                as List<String>?,
        experienceYears: freezed == experienceYears
            ? _value.experienceYears
            : experienceYears // ignore: cast_nullable_to_non_nullable
                as int?,
        specialization: freezed == specialization
            ? _value.specialization
            : specialization // ignore: cast_nullable_to_non_nullable
                as String?,
        workStatus: freezed == workStatus
            ? _value.workStatus
            : workStatus // ignore: cast_nullable_to_non_nullable
                as String?,
        availability: freezed == availability
            ? _value._availability
            : availability // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        trainingCompleted: freezed == trainingCompleted
            ? _value.trainingCompleted
            : trainingCompleted // ignore: cast_nullable_to_non_nullable
                as bool?,
        kycStatus: freezed == kycStatus
            ? _value.kycStatus
            : kycStatus // ignore: cast_nullable_to_non_nullable
                as String?,
        kycVerified: freezed == kycVerified
            ? _value.kycVerified
            : kycVerified // ignore: cast_nullable_to_non_nullable
                as bool?,
        bankVerified: freezed == bankVerified
            ? _value.bankVerified
            : bankVerified // ignore: cast_nullable_to_non_nullable
                as bool?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                as double?,
        totalJobsCompleted: freezed == totalJobsCompleted
            ? _value.totalJobsCompleted
            : totalJobsCompleted // ignore: cast_nullable_to_non_nullable
                as int?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                as String?,
        state: freezed == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                as String?,
        pincode: freezed == pincode
            ? _value.pincode
            : pincode // ignore: cast_nullable_to_non_nullable
                as String?,
        locality: freezed == locality
            ? _value.locality
            : locality // ignore: cast_nullable_to_non_nullable
                as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                as double?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        technicianProfileId: freezed == technicianProfileId
            ? _value.technicianProfileId
            : technicianProfileId // ignore: cast_nullable_to_non_nullable
                as String?,
        isVerified: freezed == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                as bool?,
        profileComplete: freezed == profileComplete
            ? _value.profileComplete
            : profileComplete // ignore: cast_nullable_to_non_nullable
                as bool?,
        profile: freezed == profile
            ? _value._profile
            : profile // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        verificationStatus: freezed == verificationStatus
            ? _value.verificationStatus
            : verificationStatus // ignore: cast_nullable_to_non_nullable
                as String?,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                as double?,
        kycDetails: freezed == kycDetails
            ? _value._kycDetails
            : kycDetails // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        rawData: freezed == rawData
            ? _value._rawData
            : rawData // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        bankDetails: freezed == bankDetails
            ? _value._bankDetails
            : bankDetails // ignore: cast_nullable_to_non_nullable
                as Map<String, dynamic>?,
        bankVerificationStatus: freezed == bankVerificationStatus
            ? _value.bankVerificationStatus
            : bankVerificationStatus // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    @JsonKey(name: '_id') this.id,
    this.userId,
    this.technicianId,
    this.customerId,
    this.firstName,
    this.lastName,
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
    this.bankVerificationStatus,
  })  : _skills = skills,
        _availability = availability,
        _profile = profile,
        _kycDetails = kycDetails,
        _rawData = rawData,
        _bankDetails = bankDetails,
        super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

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
  final String? firstName;
  @override
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

  @override
  String toString() {
    return 'UserModel(id: $id, userId: $userId, technicianId: $technicianId, customerId: $customerId, firstName: $firstName, lastName: $lastName, fullName: $fullName, email: $email, mobileNumber: $mobileNumber, gender: $gender, profileImage: $profileImage, role: $role, status: $status, defaultAddressId: $defaultAddressId, skills: $skills, experienceYears: $experienceYears, specialization: $specialization, workStatus: $workStatus, availability: $availability, trainingCompleted: $trainingCompleted, kycStatus: $kycStatus, kycVerified: $kycVerified, bankVerified: $bankVerified, rating: $rating, totalJobsCompleted: $totalJobsCompleted, address: $address, city: $city, state: $state, pincode: $pincode, locality: $locality, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt, technicianProfileId: $technicianProfileId, isVerified: $isVerified, profileComplete: $profileComplete, profile: $profile, verificationStatus: $verificationStatus, averageRating: $averageRating, kycDetails: $kycDetails, rawData: $rawData, bankDetails: $bankDetails, bankVerificationStatus: $bankVerificationStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
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
            const DeepCollectionEquality().equals(
              other._availability,
              _availability,
            ) &&
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
            const DeepCollectionEquality().equals(
              other._kycDetails,
              _kycDetails,
            ) &&
            const DeepCollectionEquality().equals(other._rawData, _rawData) &&
            const DeepCollectionEquality().equals(
              other._bankDetails,
              _bankDetails,
            ) &&
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
        bankVerificationStatus,
      ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
    @JsonKey(name: '_id') final String? id,
    final String? userId,
    final String? technicianId,
    final String? customerId,
    final String? firstName,
    final String? lastName,
    final String? fullName,
    final String? email,
    final String? mobileNumber,
    final String? gender,
    final String? profileImage,
    final String? role,
    final String? status,
    final String? defaultAddressId,
    final List<String>? skills,
    final int? experienceYears,
    final String? specialization,
    final String? workStatus,
    final Map<String, dynamic>? availability,
    final bool? trainingCompleted,
    final String? kycStatus,
    final bool? kycVerified,
    final bool? bankVerified,
    @JsonKey(name: 'rating') final double? rating,
    final int? totalJobsCompleted,
    final String? address,
    final String? city,
    final String? state,
    final String? pincode,
    final String? locality,
    final double? latitude,
    final double? longitude,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    @JsonKey(name: 'technicianProfileId') final String? technicianProfileId,
    final bool? isVerified,
    final bool? profileComplete,
    final Map<String, dynamic>? profile,
    final String? verificationStatus,
    @JsonKey(name: 'averageRating') final double? averageRating,
    @JsonKey(name: 'technician') final Map<String, dynamic>? kycDetails,
    final Map<String, dynamic>? rawData,
    final Map<String, dynamic>? bankDetails,
    final String? bankVerificationStatus,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String? get userId;
  @override
  String? get technicianId;
  @override
  String? get customerId;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get fullName;
  @override
  String? get email;
  @override
  String? get mobileNumber;
  @override
  String? get gender;
  @override
  String? get profileImage;
  @override
  String? get role;
  @override
  String? get status;
  @override
  String? get defaultAddressId; // Technician fields
  @override
  List<String>? get skills;
  @override
  int? get experienceYears;
  @override
  String? get specialization;
  @override
  String? get workStatus;
  @override
  Map<String, dynamic>? get availability;
  @override
  bool? get trainingCompleted;
  @override
  String? get kycStatus;
  @override
  bool? get kycVerified;
  @override
  bool? get bankVerified;
  @override
  @JsonKey(name: 'rating')
  double? get rating;
  @override
  int? get totalJobsCompleted; // Address & Location
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get pincode;
  @override
  String? get locality;
  @override
  double? get latitude;
  @override
  double? get longitude; // Metadata
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Legacy / Compatibility fields
  @override
  @JsonKey(name: 'technicianProfileId')
  String? get technicianProfileId;
  @override
  bool? get isVerified;
  @override
  bool? get profileComplete;
  @override
  Map<String, dynamic>? get profile;
  @override
  String? get verificationStatus;
  @override
  @JsonKey(name: 'averageRating')
  double? get averageRating;
  @override
  @JsonKey(name: 'technician')
  Map<String, dynamic>? get kycDetails;
  @override
  Map<String, dynamic>? get rawData;
  @override
  Map<String, dynamic>? get bankDetails;
  @override
  String? get bankVerificationStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
