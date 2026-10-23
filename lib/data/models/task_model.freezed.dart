// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskModel {
  String get jobId;
  String get location;
  String get faultReason;
  List<String> get toolsRequired;
  List<String> get rectifySteps;
  List<String> get checklistItems;
  @JsonKey(
      name: 'timeSpentSeconds',
      fromJson: _durationFromSeconds,
      toJson: _durationToSeconds)
  Duration get timeSpent;
  String? get customerId;
  String? get locationType;
  double? get latitude;
  double? get longitude;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskModelCopyWith<TaskModel> get copyWith =>
      _$TaskModelCopyWithImpl<TaskModel>(this as TaskModel, _$identity);

  /// Serializes this TaskModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskModel &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.faultReason, faultReason) ||
                other.faultReason == faultReason) &&
            const DeepCollectionEquality()
                .equals(other.toolsRequired, toolsRequired) &&
            const DeepCollectionEquality()
                .equals(other.rectifySteps, rectifySteps) &&
            const DeepCollectionEquality()
                .equals(other.checklistItems, checklistItems) &&
            (identical(other.timeSpent, timeSpent) ||
                other.timeSpent == timeSpent) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.locationType, locationType) ||
                other.locationType == locationType) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      jobId,
      location,
      faultReason,
      const DeepCollectionEquality().hash(toolsRequired),
      const DeepCollectionEquality().hash(rectifySteps),
      const DeepCollectionEquality().hash(checklistItems),
      timeSpent,
      customerId,
      locationType,
      latitude,
      longitude);

  @override
  String toString() {
    return 'TaskModel(jobId: $jobId, location: $location, faultReason: $faultReason, toolsRequired: $toolsRequired, rectifySteps: $rectifySteps, checklistItems: $checklistItems, timeSpent: $timeSpent, customerId: $customerId, locationType: $locationType, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class $TaskModelCopyWith<$Res> {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) _then) =
      _$TaskModelCopyWithImpl;
  @useResult
  $Res call(
      {String jobId,
      String location,
      String faultReason,
      List<String> toolsRequired,
      List<String> rectifySteps,
      List<String> checklistItems,
      @JsonKey(
          name: 'timeSpentSeconds',
          fromJson: _durationFromSeconds,
          toJson: _durationToSeconds)
      Duration timeSpent,
      String? customerId,
      String? locationType,
      double? latitude,
      double? longitude});
}

/// @nodoc
class _$TaskModelCopyWithImpl<$Res> implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._self, this._then);

  final TaskModel _self;
  final $Res Function(TaskModel) _then;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? location = null,
    Object? faultReason = null,
    Object? toolsRequired = null,
    Object? rectifySteps = null,
    Object? checklistItems = null,
    Object? timeSpent = null,
    Object? customerId = freezed,
    Object? locationType = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_self.copyWith(
      jobId: null == jobId
          ? _self.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      faultReason: null == faultReason
          ? _self.faultReason
          : faultReason // ignore: cast_nullable_to_non_nullable
              as String,
      toolsRequired: null == toolsRequired
          ? _self.toolsRequired
          : toolsRequired // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rectifySteps: null == rectifySteps
          ? _self.rectifySteps
          : rectifySteps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      checklistItems: null == checklistItems
          ? _self.checklistItems
          : checklistItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timeSpent: null == timeSpent
          ? _self.timeSpent
          : timeSpent // ignore: cast_nullable_to_non_nullable
              as Duration,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      locationType: freezed == locationType
          ? _self.locationType
          : locationType // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TaskModel].
extension TaskModelPatterns on TaskModel {
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
    TResult Function(_TaskModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskModel() when $default != null:
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
    TResult Function(_TaskModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskModel():
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
    TResult? Function(_TaskModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskModel() when $default != null:
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
            String jobId,
            String location,
            String faultReason,
            List<String> toolsRequired,
            List<String> rectifySteps,
            List<String> checklistItems,
            @JsonKey(
                name: 'timeSpentSeconds',
                fromJson: _durationFromSeconds,
                toJson: _durationToSeconds)
            Duration timeSpent,
            String? customerId,
            String? locationType,
            double? latitude,
            double? longitude)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskModel() when $default != null:
        return $default(
            _that.jobId,
            _that.location,
            _that.faultReason,
            _that.toolsRequired,
            _that.rectifySteps,
            _that.checklistItems,
            _that.timeSpent,
            _that.customerId,
            _that.locationType,
            _that.latitude,
            _that.longitude);
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
            String jobId,
            String location,
            String faultReason,
            List<String> toolsRequired,
            List<String> rectifySteps,
            List<String> checklistItems,
            @JsonKey(
                name: 'timeSpentSeconds',
                fromJson: _durationFromSeconds,
                toJson: _durationToSeconds)
            Duration timeSpent,
            String? customerId,
            String? locationType,
            double? latitude,
            double? longitude)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskModel():
        return $default(
            _that.jobId,
            _that.location,
            _that.faultReason,
            _that.toolsRequired,
            _that.rectifySteps,
            _that.checklistItems,
            _that.timeSpent,
            _that.customerId,
            _that.locationType,
            _that.latitude,
            _that.longitude);
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
            String jobId,
            String location,
            String faultReason,
            List<String> toolsRequired,
            List<String> rectifySteps,
            List<String> checklistItems,
            @JsonKey(
                name: 'timeSpentSeconds',
                fromJson: _durationFromSeconds,
                toJson: _durationToSeconds)
            Duration timeSpent,
            String? customerId,
            String? locationType,
            double? latitude,
            double? longitude)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskModel() when $default != null:
        return $default(
            _that.jobId,
            _that.location,
            _that.faultReason,
            _that.toolsRequired,
            _that.rectifySteps,
            _that.checklistItems,
            _that.timeSpent,
            _that.customerId,
            _that.locationType,
            _that.latitude,
            _that.longitude);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TaskModel implements TaskModel {
  const _TaskModel(
      {required this.jobId,
      required this.location,
      required this.faultReason,
      final List<String> toolsRequired = const [],
      final List<String> rectifySteps = const [],
      final List<String> checklistItems = const [],
      @JsonKey(
          name: 'timeSpentSeconds',
          fromJson: _durationFromSeconds,
          toJson: _durationToSeconds)
      this.timeSpent = Duration.zero,
      this.customerId,
      this.locationType,
      this.latitude,
      this.longitude})
      : _toolsRequired = toolsRequired,
        _rectifySteps = rectifySteps,
        _checklistItems = checklistItems;
  factory _TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  @override
  final String jobId;
  @override
  final String location;
  @override
  final String faultReason;
  final List<String> _toolsRequired;
  @override
  @JsonKey()
  List<String> get toolsRequired {
    if (_toolsRequired is EqualUnmodifiableListView) return _toolsRequired;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_toolsRequired);
  }

  final List<String> _rectifySteps;
  @override
  @JsonKey()
  List<String> get rectifySteps {
    if (_rectifySteps is EqualUnmodifiableListView) return _rectifySteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rectifySteps);
  }

  final List<String> _checklistItems;
  @override
  @JsonKey()
  List<String> get checklistItems {
    if (_checklistItems is EqualUnmodifiableListView) return _checklistItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checklistItems);
  }

  @override
  @JsonKey(
      name: 'timeSpentSeconds',
      fromJson: _durationFromSeconds,
      toJson: _durationToSeconds)
  final Duration timeSpent;
  @override
  final String? customerId;
  @override
  final String? locationType;
  @override
  final double? latitude;
  @override
  final double? longitude;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TaskModelCopyWith<_TaskModel> get copyWith =>
      __$TaskModelCopyWithImpl<_TaskModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TaskModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TaskModel &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.faultReason, faultReason) ||
                other.faultReason == faultReason) &&
            const DeepCollectionEquality()
                .equals(other._toolsRequired, _toolsRequired) &&
            const DeepCollectionEquality()
                .equals(other._rectifySteps, _rectifySteps) &&
            const DeepCollectionEquality()
                .equals(other._checklistItems, _checklistItems) &&
            (identical(other.timeSpent, timeSpent) ||
                other.timeSpent == timeSpent) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.locationType, locationType) ||
                other.locationType == locationType) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      jobId,
      location,
      faultReason,
      const DeepCollectionEquality().hash(_toolsRequired),
      const DeepCollectionEquality().hash(_rectifySteps),
      const DeepCollectionEquality().hash(_checklistItems),
      timeSpent,
      customerId,
      locationType,
      latitude,
      longitude);

  @override
  String toString() {
    return 'TaskModel(jobId: $jobId, location: $location, faultReason: $faultReason, toolsRequired: $toolsRequired, rectifySteps: $rectifySteps, checklistItems: $checklistItems, timeSpent: $timeSpent, customerId: $customerId, locationType: $locationType, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class _$TaskModelCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$TaskModelCopyWith(
          _TaskModel value, $Res Function(_TaskModel) _then) =
      __$TaskModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String jobId,
      String location,
      String faultReason,
      List<String> toolsRequired,
      List<String> rectifySteps,
      List<String> checklistItems,
      @JsonKey(
          name: 'timeSpentSeconds',
          fromJson: _durationFromSeconds,
          toJson: _durationToSeconds)
      Duration timeSpent,
      String? customerId,
      String? locationType,
      double? latitude,
      double? longitude});
}

/// @nodoc
class __$TaskModelCopyWithImpl<$Res> implements _$TaskModelCopyWith<$Res> {
  __$TaskModelCopyWithImpl(this._self, this._then);

  final _TaskModel _self;
  final $Res Function(_TaskModel) _then;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? jobId = null,
    Object? location = null,
    Object? faultReason = null,
    Object? toolsRequired = null,
    Object? rectifySteps = null,
    Object? checklistItems = null,
    Object? timeSpent = null,
    Object? customerId = freezed,
    Object? locationType = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_TaskModel(
      jobId: null == jobId
          ? _self.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      faultReason: null == faultReason
          ? _self.faultReason
          : faultReason // ignore: cast_nullable_to_non_nullable
              as String,
      toolsRequired: null == toolsRequired
          ? _self._toolsRequired
          : toolsRequired // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rectifySteps: null == rectifySteps
          ? _self._rectifySteps
          : rectifySteps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      checklistItems: null == checklistItems
          ? _self._checklistItems
          : checklistItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timeSpent: null == timeSpent
          ? _self.timeSpent
          : timeSpent // ignore: cast_nullable_to_non_nullable
              as Duration,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      locationType: freezed == locationType
          ? _self.locationType
          : locationType // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
