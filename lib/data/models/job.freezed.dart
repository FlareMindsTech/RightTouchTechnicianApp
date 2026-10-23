// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Job {
  String get id;
  String? get bookingId;
  String get title;
  String? get serviceName;
  String? get serviceId;
  String? get technicianId;
  String get description;
  String get location;
  String? get customerName;
  String? get customerPhone;
  double? get earnings;
  double? get totalAmount;
  String? get scheduledTime;
  String? get scheduledAt;
  String get status;
  String? get bookingStatus;
  String? get paymentStatus;
  String? get paymentMode;
  bool get isExclusive;
  DateTime get createdAt;
  DateTime? get updatedAt;
  double? get latitude;
  double? get longitude;
  String? get customerId;
  String? get locationType;
  List<String>? get faultReasonsList;
  List<String>? get toolsEquipments;
  List<String>? get rectifyMethod;
  List<String>? get serviceChecklist;
  double? get basePrice;
  double? get technicianAmount;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $JobCopyWith<Job> get copyWith =>
      _$JobCopyWithImpl<Job>(this as Job, _$identity);

  /// Serializes this Job to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Job &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.technicianId, technicianId) ||
                other.technicianId == technicianId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.earnings, earnings) ||
                other.earnings == earnings) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.isExclusive, isExclusive) ||
                other.isExclusive == isExclusive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.locationType, locationType) ||
                other.locationType == locationType) &&
            const DeepCollectionEquality()
                .equals(other.faultReasonsList, faultReasonsList) &&
            const DeepCollectionEquality()
                .equals(other.toolsEquipments, toolsEquipments) &&
            const DeepCollectionEquality()
                .equals(other.rectifyMethod, rectifyMethod) &&
            const DeepCollectionEquality()
                .equals(other.serviceChecklist, serviceChecklist) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.technicianAmount, technicianAmount) ||
                other.technicianAmount == technicianAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        bookingId,
        title,
        serviceName,
        serviceId,
        technicianId,
        description,
        location,
        customerName,
        customerPhone,
        earnings,
        totalAmount,
        scheduledTime,
        scheduledAt,
        status,
        bookingStatus,
        paymentStatus,
        paymentMode,
        isExclusive,
        createdAt,
        updatedAt,
        latitude,
        longitude,
        customerId,
        locationType,
        const DeepCollectionEquality().hash(faultReasonsList),
        const DeepCollectionEquality().hash(toolsEquipments),
        const DeepCollectionEquality().hash(rectifyMethod),
        const DeepCollectionEquality().hash(serviceChecklist),
        basePrice,
        technicianAmount
      ]);

  @override
  String toString() {
    return 'Job(id: $id, bookingId: $bookingId, title: $title, serviceName: $serviceName, serviceId: $serviceId, technicianId: $technicianId, description: $description, location: $location, customerName: $customerName, customerPhone: $customerPhone, earnings: $earnings, totalAmount: $totalAmount, scheduledTime: $scheduledTime, scheduledAt: $scheduledAt, status: $status, bookingStatus: $bookingStatus, paymentStatus: $paymentStatus, paymentMode: $paymentMode, isExclusive: $isExclusive, createdAt: $createdAt, updatedAt: $updatedAt, latitude: $latitude, longitude: $longitude, customerId: $customerId, locationType: $locationType, faultReasonsList: $faultReasonsList, toolsEquipments: $toolsEquipments, rectifyMethod: $rectifyMethod, serviceChecklist: $serviceChecklist, basePrice: $basePrice, technicianAmount: $technicianAmount)';
  }
}

/// @nodoc
abstract mixin class $JobCopyWith<$Res> {
  factory $JobCopyWith(Job value, $Res Function(Job) _then) = _$JobCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? bookingId,
      String title,
      String? serviceName,
      String? serviceId,
      String? technicianId,
      String description,
      String location,
      String? customerName,
      String? customerPhone,
      double? earnings,
      double? totalAmount,
      String? scheduledTime,
      String? scheduledAt,
      String status,
      String? bookingStatus,
      String? paymentStatus,
      String? paymentMode,
      bool isExclusive,
      DateTime createdAt,
      DateTime? updatedAt,
      double? latitude,
      double? longitude,
      String? customerId,
      String? locationType,
      List<String>? faultReasonsList,
      List<String>? toolsEquipments,
      List<String>? rectifyMethod,
      List<String>? serviceChecklist,
      double? basePrice,
      double? technicianAmount});
}

/// @nodoc
class _$JobCopyWithImpl<$Res> implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._self, this._then);

  final Job _self;
  final $Res Function(Job) _then;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = freezed,
    Object? title = null,
    Object? serviceName = freezed,
    Object? serviceId = freezed,
    Object? technicianId = freezed,
    Object? description = null,
    Object? location = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? earnings = freezed,
    Object? totalAmount = freezed,
    Object? scheduledTime = freezed,
    Object? scheduledAt = freezed,
    Object? status = null,
    Object? bookingStatus = freezed,
    Object? paymentStatus = freezed,
    Object? paymentMode = freezed,
    Object? isExclusive = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? customerId = freezed,
    Object? locationType = freezed,
    Object? faultReasonsList = freezed,
    Object? toolsEquipments = freezed,
    Object? rectifyMethod = freezed,
    Object? serviceChecklist = freezed,
    Object? basePrice = freezed,
    Object? technicianAmount = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: freezed == bookingId
          ? _self.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      serviceName: freezed == serviceName
          ? _self.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceId: freezed == serviceId
          ? _self.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      technicianId: freezed == technicianId
          ? _self.technicianId
          : technicianId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      earnings: freezed == earnings
          ? _self.earnings
          : earnings // ignore: cast_nullable_to_non_nullable
              as double?,
      totalAmount: freezed == totalAmount
          ? _self.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      scheduledTime: freezed == scheduledTime
          ? _self.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: freezed == scheduledAt
          ? _self.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      bookingStatus: freezed == bookingStatus
          ? _self.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: freezed == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMode: freezed == paymentMode
          ? _self.paymentMode
          : paymentMode // ignore: cast_nullable_to_non_nullable
              as String?,
      isExclusive: null == isExclusive
          ? _self.isExclusive
          : isExclusive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      locationType: freezed == locationType
          ? _self.locationType
          : locationType // ignore: cast_nullable_to_non_nullable
              as String?,
      faultReasonsList: freezed == faultReasonsList
          ? _self.faultReasonsList
          : faultReasonsList // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      toolsEquipments: freezed == toolsEquipments
          ? _self.toolsEquipments
          : toolsEquipments // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      rectifyMethod: freezed == rectifyMethod
          ? _self.rectifyMethod
          : rectifyMethod // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      serviceChecklist: freezed == serviceChecklist
          ? _self.serviceChecklist
          : serviceChecklist // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      basePrice: freezed == basePrice
          ? _self.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as double?,
      technicianAmount: freezed == technicianAmount
          ? _self.technicianAmount
          : technicianAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Job].
extension JobPatterns on Job {
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
    TResult Function(_Job value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Job() when $default != null:
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
    TResult Function(_Job value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Job():
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
    TResult? Function(_Job value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Job() when $default != null:
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
            String id,
            String? bookingId,
            String title,
            String? serviceName,
            String? serviceId,
            String? technicianId,
            String description,
            String location,
            String? customerName,
            String? customerPhone,
            double? earnings,
            double? totalAmount,
            String? scheduledTime,
            String? scheduledAt,
            String status,
            String? bookingStatus,
            String? paymentStatus,
            String? paymentMode,
            bool isExclusive,
            DateTime createdAt,
            DateTime? updatedAt,
            double? latitude,
            double? longitude,
            String? customerId,
            String? locationType,
            List<String>? faultReasonsList,
            List<String>? toolsEquipments,
            List<String>? rectifyMethod,
            List<String>? serviceChecklist,
            double? basePrice,
            double? technicianAmount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Job() when $default != null:
        return $default(
            _that.id,
            _that.bookingId,
            _that.title,
            _that.serviceName,
            _that.serviceId,
            _that.technicianId,
            _that.description,
            _that.location,
            _that.customerName,
            _that.customerPhone,
            _that.earnings,
            _that.totalAmount,
            _that.scheduledTime,
            _that.scheduledAt,
            _that.status,
            _that.bookingStatus,
            _that.paymentStatus,
            _that.paymentMode,
            _that.isExclusive,
            _that.createdAt,
            _that.updatedAt,
            _that.latitude,
            _that.longitude,
            _that.customerId,
            _that.locationType,
            _that.faultReasonsList,
            _that.toolsEquipments,
            _that.rectifyMethod,
            _that.serviceChecklist,
            _that.basePrice,
            _that.technicianAmount);
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
            String id,
            String? bookingId,
            String title,
            String? serviceName,
            String? serviceId,
            String? technicianId,
            String description,
            String location,
            String? customerName,
            String? customerPhone,
            double? earnings,
            double? totalAmount,
            String? scheduledTime,
            String? scheduledAt,
            String status,
            String? bookingStatus,
            String? paymentStatus,
            String? paymentMode,
            bool isExclusive,
            DateTime createdAt,
            DateTime? updatedAt,
            double? latitude,
            double? longitude,
            String? customerId,
            String? locationType,
            List<String>? faultReasonsList,
            List<String>? toolsEquipments,
            List<String>? rectifyMethod,
            List<String>? serviceChecklist,
            double? basePrice,
            double? technicianAmount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Job():
        return $default(
            _that.id,
            _that.bookingId,
            _that.title,
            _that.serviceName,
            _that.serviceId,
            _that.technicianId,
            _that.description,
            _that.location,
            _that.customerName,
            _that.customerPhone,
            _that.earnings,
            _that.totalAmount,
            _that.scheduledTime,
            _that.scheduledAt,
            _that.status,
            _that.bookingStatus,
            _that.paymentStatus,
            _that.paymentMode,
            _that.isExclusive,
            _that.createdAt,
            _that.updatedAt,
            _that.latitude,
            _that.longitude,
            _that.customerId,
            _that.locationType,
            _that.faultReasonsList,
            _that.toolsEquipments,
            _that.rectifyMethod,
            _that.serviceChecklist,
            _that.basePrice,
            _that.technicianAmount);
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
            String id,
            String? bookingId,
            String title,
            String? serviceName,
            String? serviceId,
            String? technicianId,
            String description,
            String location,
            String? customerName,
            String? customerPhone,
            double? earnings,
            double? totalAmount,
            String? scheduledTime,
            String? scheduledAt,
            String status,
            String? bookingStatus,
            String? paymentStatus,
            String? paymentMode,
            bool isExclusive,
            DateTime createdAt,
            DateTime? updatedAt,
            double? latitude,
            double? longitude,
            String? customerId,
            String? locationType,
            List<String>? faultReasonsList,
            List<String>? toolsEquipments,
            List<String>? rectifyMethod,
            List<String>? serviceChecklist,
            double? basePrice,
            double? technicianAmount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Job() when $default != null:
        return $default(
            _that.id,
            _that.bookingId,
            _that.title,
            _that.serviceName,
            _that.serviceId,
            _that.technicianId,
            _that.description,
            _that.location,
            _that.customerName,
            _that.customerPhone,
            _that.earnings,
            _that.totalAmount,
            _that.scheduledTime,
            _that.scheduledAt,
            _that.status,
            _that.bookingStatus,
            _that.paymentStatus,
            _that.paymentMode,
            _that.isExclusive,
            _that.createdAt,
            _that.updatedAt,
            _that.latitude,
            _that.longitude,
            _that.customerId,
            _that.locationType,
            _that.faultReasonsList,
            _that.toolsEquipments,
            _that.rectifyMethod,
            _that.serviceChecklist,
            _that.basePrice,
            _that.technicianAmount);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Job implements Job {
  const _Job(
      {required this.id,
      this.bookingId,
      this.title = 'Service Request',
      this.serviceName,
      this.serviceId,
      this.technicianId,
      this.description = 'No description provided',
      this.location = 'Unknown Location',
      this.customerName,
      this.customerPhone,
      this.earnings,
      this.totalAmount,
      this.scheduledTime,
      this.scheduledAt,
      this.status = 'pending',
      this.bookingStatus,
      this.paymentStatus,
      this.paymentMode,
      this.isExclusive = false,
      required this.createdAt,
      this.updatedAt,
      this.latitude,
      this.longitude,
      this.customerId,
      this.locationType = 'home',
      final List<String>? faultReasonsList,
      final List<String>? toolsEquipments,
      final List<String>? rectifyMethod,
      final List<String>? serviceChecklist,
      this.basePrice,
      this.technicianAmount})
      : _faultReasonsList = faultReasonsList,
        _toolsEquipments = toolsEquipments,
        _rectifyMethod = rectifyMethod,
        _serviceChecklist = serviceChecklist;
  factory _Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  @override
  final String id;
  @override
  final String? bookingId;
  @override
  @JsonKey()
  final String title;
  @override
  final String? serviceName;
  @override
  final String? serviceId;
  @override
  final String? technicianId;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String location;
  @override
  final String? customerName;
  @override
  final String? customerPhone;
  @override
  final double? earnings;
  @override
  final double? totalAmount;
  @override
  final String? scheduledTime;
  @override
  final String? scheduledAt;
  @override
  @JsonKey()
  final String status;
  @override
  final String? bookingStatus;
  @override
  final String? paymentStatus;
  @override
  final String? paymentMode;
  @override
  @JsonKey()
  final bool isExclusive;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? customerId;
  @override
  @JsonKey()
  final String? locationType;
  final List<String>? _faultReasonsList;
  @override
  List<String>? get faultReasonsList {
    final value = _faultReasonsList;
    if (value == null) return null;
    if (_faultReasonsList is EqualUnmodifiableListView)
      return _faultReasonsList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _toolsEquipments;
  @override
  List<String>? get toolsEquipments {
    final value = _toolsEquipments;
    if (value == null) return null;
    if (_toolsEquipments is EqualUnmodifiableListView) return _toolsEquipments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _rectifyMethod;
  @override
  List<String>? get rectifyMethod {
    final value = _rectifyMethod;
    if (value == null) return null;
    if (_rectifyMethod is EqualUnmodifiableListView) return _rectifyMethod;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _serviceChecklist;
  @override
  List<String>? get serviceChecklist {
    final value = _serviceChecklist;
    if (value == null) return null;
    if (_serviceChecklist is EqualUnmodifiableListView)
      return _serviceChecklist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? basePrice;
  @override
  final double? technicianAmount;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$JobCopyWith<_Job> get copyWith =>
      __$JobCopyWithImpl<_Job>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$JobToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Job &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.technicianId, technicianId) ||
                other.technicianId == technicianId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.earnings, earnings) ||
                other.earnings == earnings) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.isExclusive, isExclusive) ||
                other.isExclusive == isExclusive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.locationType, locationType) ||
                other.locationType == locationType) &&
            const DeepCollectionEquality()
                .equals(other._faultReasonsList, _faultReasonsList) &&
            const DeepCollectionEquality()
                .equals(other._toolsEquipments, _toolsEquipments) &&
            const DeepCollectionEquality()
                .equals(other._rectifyMethod, _rectifyMethod) &&
            const DeepCollectionEquality()
                .equals(other._serviceChecklist, _serviceChecklist) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.technicianAmount, technicianAmount) ||
                other.technicianAmount == technicianAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        bookingId,
        title,
        serviceName,
        serviceId,
        technicianId,
        description,
        location,
        customerName,
        customerPhone,
        earnings,
        totalAmount,
        scheduledTime,
        scheduledAt,
        status,
        bookingStatus,
        paymentStatus,
        paymentMode,
        isExclusive,
        createdAt,
        updatedAt,
        latitude,
        longitude,
        customerId,
        locationType,
        const DeepCollectionEquality().hash(_faultReasonsList),
        const DeepCollectionEquality().hash(_toolsEquipments),
        const DeepCollectionEquality().hash(_rectifyMethod),
        const DeepCollectionEquality().hash(_serviceChecklist),
        basePrice,
        technicianAmount
      ]);

  @override
  String toString() {
    return 'Job(id: $id, bookingId: $bookingId, title: $title, serviceName: $serviceName, serviceId: $serviceId, technicianId: $technicianId, description: $description, location: $location, customerName: $customerName, customerPhone: $customerPhone, earnings: $earnings, totalAmount: $totalAmount, scheduledTime: $scheduledTime, scheduledAt: $scheduledAt, status: $status, bookingStatus: $bookingStatus, paymentStatus: $paymentStatus, paymentMode: $paymentMode, isExclusive: $isExclusive, createdAt: $createdAt, updatedAt: $updatedAt, latitude: $latitude, longitude: $longitude, customerId: $customerId, locationType: $locationType, faultReasonsList: $faultReasonsList, toolsEquipments: $toolsEquipments, rectifyMethod: $rectifyMethod, serviceChecklist: $serviceChecklist, basePrice: $basePrice, technicianAmount: $technicianAmount)';
  }
}

/// @nodoc
abstract mixin class _$JobCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$JobCopyWith(_Job value, $Res Function(_Job) _then) =
      __$JobCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? bookingId,
      String title,
      String? serviceName,
      String? serviceId,
      String? technicianId,
      String description,
      String location,
      String? customerName,
      String? customerPhone,
      double? earnings,
      double? totalAmount,
      String? scheduledTime,
      String? scheduledAt,
      String status,
      String? bookingStatus,
      String? paymentStatus,
      String? paymentMode,
      bool isExclusive,
      DateTime createdAt,
      DateTime? updatedAt,
      double? latitude,
      double? longitude,
      String? customerId,
      String? locationType,
      List<String>? faultReasonsList,
      List<String>? toolsEquipments,
      List<String>? rectifyMethod,
      List<String>? serviceChecklist,
      double? basePrice,
      double? technicianAmount});
}

/// @nodoc
class __$JobCopyWithImpl<$Res> implements _$JobCopyWith<$Res> {
  __$JobCopyWithImpl(this._self, this._then);

  final _Job _self;
  final $Res Function(_Job) _then;

  /// Create a copy of Job
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? bookingId = freezed,
    Object? title = null,
    Object? serviceName = freezed,
    Object? serviceId = freezed,
    Object? technicianId = freezed,
    Object? description = null,
    Object? location = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? earnings = freezed,
    Object? totalAmount = freezed,
    Object? scheduledTime = freezed,
    Object? scheduledAt = freezed,
    Object? status = null,
    Object? bookingStatus = freezed,
    Object? paymentStatus = freezed,
    Object? paymentMode = freezed,
    Object? isExclusive = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? customerId = freezed,
    Object? locationType = freezed,
    Object? faultReasonsList = freezed,
    Object? toolsEquipments = freezed,
    Object? rectifyMethod = freezed,
    Object? serviceChecklist = freezed,
    Object? basePrice = freezed,
    Object? technicianAmount = freezed,
  }) {
    return _then(_Job(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: freezed == bookingId
          ? _self.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      serviceName: freezed == serviceName
          ? _self.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      serviceId: freezed == serviceId
          ? _self.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      technicianId: freezed == technicianId
          ? _self.technicianId
          : technicianId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      earnings: freezed == earnings
          ? _self.earnings
          : earnings // ignore: cast_nullable_to_non_nullable
              as double?,
      totalAmount: freezed == totalAmount
          ? _self.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      scheduledTime: freezed == scheduledTime
          ? _self.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: freezed == scheduledAt
          ? _self.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      bookingStatus: freezed == bookingStatus
          ? _self.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: freezed == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMode: freezed == paymentMode
          ? _self.paymentMode
          : paymentMode // ignore: cast_nullable_to_non_nullable
              as String?,
      isExclusive: null == isExclusive
          ? _self.isExclusive
          : isExclusive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      locationType: freezed == locationType
          ? _self.locationType
          : locationType // ignore: cast_nullable_to_non_nullable
              as String?,
      faultReasonsList: freezed == faultReasonsList
          ? _self._faultReasonsList
          : faultReasonsList // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      toolsEquipments: freezed == toolsEquipments
          ? _self._toolsEquipments
          : toolsEquipments // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      rectifyMethod: freezed == rectifyMethod
          ? _self._rectifyMethod
          : rectifyMethod // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      serviceChecklist: freezed == serviceChecklist
          ? _self._serviceChecklist
          : serviceChecklist // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      basePrice: freezed == basePrice
          ? _self.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as double?,
      technicianAmount: freezed == technicianAmount
          ? _self.technicianAmount
          : technicianAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
