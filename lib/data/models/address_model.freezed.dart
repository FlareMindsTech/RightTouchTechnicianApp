// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddressModel {
  @JsonKey(name: '_id')
  String? get id;
  String? get addressId;
  String? get label;
  String? get name;
  String? get phone;
  String? get addressLine;
  String? get city;
  String? get state;
  String? get pincode;
  double? get latitude;
  double? get longitude;
  bool? get isDefault; // Metadata
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of AddressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddressModelCopyWith<AddressModel> get copyWith =>
      _$AddressModelCopyWithImpl<AddressModel>(
          this as AddressModel, _$identity);

  /// Serializes this AddressModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddressModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.addressLine, addressLine) ||
                other.addressLine == addressLine) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      addressId,
      label,
      name,
      phone,
      addressLine,
      city,
      state,
      pincode,
      latitude,
      longitude,
      isDefault,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'AddressModel(id: $id, addressId: $addressId, label: $label, name: $name, phone: $phone, addressLine: $addressLine, city: $city, state: $state, pincode: $pincode, latitude: $latitude, longitude: $longitude, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $AddressModelCopyWith<$Res> {
  factory $AddressModelCopyWith(
          AddressModel value, $Res Function(AddressModel) _then) =
      _$AddressModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      String? addressId,
      String? label,
      String? name,
      String? phone,
      String? addressLine,
      String? city,
      String? state,
      String? pincode,
      double? latitude,
      double? longitude,
      bool? isDefault,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$AddressModelCopyWithImpl<$Res> implements $AddressModelCopyWith<$Res> {
  _$AddressModelCopyWithImpl(this._self, this._then);

  final AddressModel _self;
  final $Res Function(AddressModel) _then;

  /// Create a copy of AddressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? addressId = freezed,
    Object? label = freezed,
    Object? name = freezed,
    Object? phone = freezed,
    Object? addressLine = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pincode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isDefault = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      addressId: freezed == addressId
          ? _self.addressId
          : addressId // ignore: cast_nullable_to_non_nullable
              as String?,
      label: freezed == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLine: freezed == addressLine
          ? _self.addressLine
          : addressLine // ignore: cast_nullable_to_non_nullable
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
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      isDefault: freezed == isDefault
          ? _self.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AddressModel].
extension AddressModelPatterns on AddressModel {
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
    TResult Function(_AddressModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AddressModel() when $default != null:
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
    TResult Function(_AddressModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AddressModel():
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
    TResult? Function(_AddressModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AddressModel() when $default != null:
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
            String? addressId,
            String? label,
            String? name,
            String? phone,
            String? addressLine,
            String? city,
            String? state,
            String? pincode,
            double? latitude,
            double? longitude,
            bool? isDefault,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AddressModel() when $default != null:
        return $default(
            _that.id,
            _that.addressId,
            _that.label,
            _that.name,
            _that.phone,
            _that.addressLine,
            _that.city,
            _that.state,
            _that.pincode,
            _that.latitude,
            _that.longitude,
            _that.isDefault,
            _that.createdAt,
            _that.updatedAt);
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
            String? addressId,
            String? label,
            String? name,
            String? phone,
            String? addressLine,
            String? city,
            String? state,
            String? pincode,
            double? latitude,
            double? longitude,
            bool? isDefault,
            DateTime? createdAt,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AddressModel():
        return $default(
            _that.id,
            _that.addressId,
            _that.label,
            _that.name,
            _that.phone,
            _that.addressLine,
            _that.city,
            _that.state,
            _that.pincode,
            _that.latitude,
            _that.longitude,
            _that.isDefault,
            _that.createdAt,
            _that.updatedAt);
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
            String? addressId,
            String? label,
            String? name,
            String? phone,
            String? addressLine,
            String? city,
            String? state,
            String? pincode,
            double? latitude,
            double? longitude,
            bool? isDefault,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AddressModel() when $default != null:
        return $default(
            _that.id,
            _that.addressId,
            _that.label,
            _that.name,
            _that.phone,
            _that.addressLine,
            _that.city,
            _that.state,
            _that.pincode,
            _that.latitude,
            _that.longitude,
            _that.isDefault,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AddressModel implements AddressModel {
  const _AddressModel(
      {@JsonKey(name: '_id') this.id,
      this.addressId,
      this.label,
      this.name,
      this.phone,
      this.addressLine,
      this.city,
      this.state,
      this.pincode,
      this.latitude,
      this.longitude,
      this.isDefault,
      this.createdAt,
      this.updatedAt});
  factory _AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? addressId;
  @override
  final String? label;
  @override
  final String? name;
  @override
  final String? phone;
  @override
  final String? addressLine;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? pincode;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final bool? isDefault;
// Metadata
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of AddressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddressModelCopyWith<_AddressModel> get copyWith =>
      __$AddressModelCopyWithImpl<_AddressModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AddressModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddressModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.addressLine, addressLine) ||
                other.addressLine == addressLine) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      addressId,
      label,
      name,
      phone,
      addressLine,
      city,
      state,
      pincode,
      latitude,
      longitude,
      isDefault,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'AddressModel(id: $id, addressId: $addressId, label: $label, name: $name, phone: $phone, addressLine: $addressLine, city: $city, state: $state, pincode: $pincode, latitude: $latitude, longitude: $longitude, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$AddressModelCopyWith<$Res>
    implements $AddressModelCopyWith<$Res> {
  factory _$AddressModelCopyWith(
          _AddressModel value, $Res Function(_AddressModel) _then) =
      __$AddressModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      String? addressId,
      String? label,
      String? name,
      String? phone,
      String? addressLine,
      String? city,
      String? state,
      String? pincode,
      double? latitude,
      double? longitude,
      bool? isDefault,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$AddressModelCopyWithImpl<$Res>
    implements _$AddressModelCopyWith<$Res> {
  __$AddressModelCopyWithImpl(this._self, this._then);

  final _AddressModel _self;
  final $Res Function(_AddressModel) _then;

  /// Create a copy of AddressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? addressId = freezed,
    Object? label = freezed,
    Object? name = freezed,
    Object? phone = freezed,
    Object? addressLine = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pincode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isDefault = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_AddressModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      addressId: freezed == addressId
          ? _self.addressId
          : addressId // ignore: cast_nullable_to_non_nullable
              as String?,
      label: freezed == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLine: freezed == addressLine
          ? _self.addressLine
          : addressLine // ignore: cast_nullable_to_non_nullable
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
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      isDefault: freezed == isDefault
          ? _self.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
