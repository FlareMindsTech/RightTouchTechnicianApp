// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletTransaction {
  String get id;
  Money get amount;
  String get type;
  String get description;
  DateTime? get createdAt;
  String? get status;
  String? get bookingId;
  String? get bookingCode;
  String? get utr;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WalletTransactionCopyWith<WalletTransaction> get copyWith =>
      _$WalletTransactionCopyWithImpl<WalletTransaction>(
          this as WalletTransaction, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WalletTransaction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.bookingCode, bookingCode) ||
                other.bookingCode == bookingCode) &&
            (identical(other.utr, utr) || other.utr == utr));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, amount, type, description,
      createdAt, status, bookingId, bookingCode, utr);

  @override
  String toString() {
    return 'WalletTransaction(id: $id, amount: $amount, type: $type, description: $description, createdAt: $createdAt, status: $status, bookingId: $bookingId, bookingCode: $bookingCode, utr: $utr)';
  }
}

/// @nodoc
abstract mixin class $WalletTransactionCopyWith<$Res> {
  factory $WalletTransactionCopyWith(
          WalletTransaction value, $Res Function(WalletTransaction) _then) =
      _$WalletTransactionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      Money amount,
      String type,
      String description,
      DateTime? createdAt,
      String? status,
      String? bookingId,
      String? bookingCode,
      String? utr});
}

/// @nodoc
class _$WalletTransactionCopyWithImpl<$Res>
    implements $WalletTransactionCopyWith<$Res> {
  _$WalletTransactionCopyWithImpl(this._self, this._then);

  final WalletTransaction _self;
  final $Res Function(WalletTransaction) _then;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? type = null,
    Object? description = null,
    Object? createdAt = freezed,
    Object? status = freezed,
    Object? bookingId = freezed,
    Object? bookingCode = freezed,
    Object? utr = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Money,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingId: freezed == bookingId
          ? _self.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingCode: freezed == bookingCode
          ? _self.bookingCode
          : bookingCode // ignore: cast_nullable_to_non_nullable
              as String?,
      utr: freezed == utr
          ? _self.utr
          : utr // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WalletTransaction].
extension WalletTransactionPatterns on WalletTransaction {
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
    TResult Function(_WalletTransaction value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WalletTransaction() when $default != null:
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
    TResult Function(_WalletTransaction value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletTransaction():
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
    TResult? Function(_WalletTransaction value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletTransaction() when $default != null:
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
            Money amount,
            String type,
            String description,
            DateTime? createdAt,
            String? status,
            String? bookingId,
            String? bookingCode,
            String? utr)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WalletTransaction() when $default != null:
        return $default(
            _that.id,
            _that.amount,
            _that.type,
            _that.description,
            _that.createdAt,
            _that.status,
            _that.bookingId,
            _that.bookingCode,
            _that.utr);
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
            Money amount,
            String type,
            String description,
            DateTime? createdAt,
            String? status,
            String? bookingId,
            String? bookingCode,
            String? utr)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletTransaction():
        return $default(
            _that.id,
            _that.amount,
            _that.type,
            _that.description,
            _that.createdAt,
            _that.status,
            _that.bookingId,
            _that.bookingCode,
            _that.utr);
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
            Money amount,
            String type,
            String description,
            DateTime? createdAt,
            String? status,
            String? bookingId,
            String? bookingCode,
            String? utr)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletTransaction() when $default != null:
        return $default(
            _that.id,
            _that.amount,
            _that.type,
            _that.description,
            _that.createdAt,
            _that.status,
            _that.bookingId,
            _that.bookingCode,
            _that.utr);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _WalletTransaction implements WalletTransaction {
  const _WalletTransaction(
      {this.id = '',
      this.amount = Money.zero,
      this.type = 'unknown',
      this.description = 'Transaction',
      this.createdAt,
      this.status,
      this.bookingId,
      this.bookingCode,
      this.utr});

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final Money amount;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String description;
  @override
  final DateTime? createdAt;
  @override
  final String? status;
  @override
  final String? bookingId;
  @override
  final String? bookingCode;
  @override
  final String? utr;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WalletTransactionCopyWith<_WalletTransaction> get copyWith =>
      __$WalletTransactionCopyWithImpl<_WalletTransaction>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WalletTransaction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.bookingCode, bookingCode) ||
                other.bookingCode == bookingCode) &&
            (identical(other.utr, utr) || other.utr == utr));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, amount, type, description,
      createdAt, status, bookingId, bookingCode, utr);

  @override
  String toString() {
    return 'WalletTransaction(id: $id, amount: $amount, type: $type, description: $description, createdAt: $createdAt, status: $status, bookingId: $bookingId, bookingCode: $bookingCode, utr: $utr)';
  }
}

/// @nodoc
abstract mixin class _$WalletTransactionCopyWith<$Res>
    implements $WalletTransactionCopyWith<$Res> {
  factory _$WalletTransactionCopyWith(
          _WalletTransaction value, $Res Function(_WalletTransaction) _then) =
      __$WalletTransactionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      Money amount,
      String type,
      String description,
      DateTime? createdAt,
      String? status,
      String? bookingId,
      String? bookingCode,
      String? utr});
}

/// @nodoc
class __$WalletTransactionCopyWithImpl<$Res>
    implements _$WalletTransactionCopyWith<$Res> {
  __$WalletTransactionCopyWithImpl(this._self, this._then);

  final _WalletTransaction _self;
  final $Res Function(_WalletTransaction) _then;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? type = null,
    Object? description = null,
    Object? createdAt = freezed,
    Object? status = freezed,
    Object? bookingId = freezed,
    Object? bookingCode = freezed,
    Object? utr = freezed,
  }) {
    return _then(_WalletTransaction(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Money,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingId: freezed == bookingId
          ? _self.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingCode: freezed == bookingCode
          ? _self.bookingCode
          : bookingCode // ignore: cast_nullable_to_non_nullable
              as String?,
      utr: freezed == utr
          ? _self.utr
          : utr // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$WithdrawalRequest {
  String get id;
  Money get amount;
  String get status;
  DateTime? get createdAt;
  String? get remarks;
  String? get utr;
  DateTime? get updatedAt;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WithdrawalRequestCopyWith<WithdrawalRequest> get copyWith =>
      _$WithdrawalRequestCopyWithImpl<WithdrawalRequest>(
          this as WithdrawalRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WithdrawalRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.utr, utr) || other.utr == utr) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, amount, status, createdAt, remarks, utr, updatedAt);

  @override
  String toString() {
    return 'WithdrawalRequest(id: $id, amount: $amount, status: $status, createdAt: $createdAt, remarks: $remarks, utr: $utr, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $WithdrawalRequestCopyWith<$Res> {
  factory $WithdrawalRequestCopyWith(
          WithdrawalRequest value, $Res Function(WithdrawalRequest) _then) =
      _$WithdrawalRequestCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      Money amount,
      String status,
      DateTime? createdAt,
      String? remarks,
      String? utr,
      DateTime? updatedAt});
}

/// @nodoc
class _$WithdrawalRequestCopyWithImpl<$Res>
    implements $WithdrawalRequestCopyWith<$Res> {
  _$WithdrawalRequestCopyWithImpl(this._self, this._then);

  final WithdrawalRequest _self;
  final $Res Function(WithdrawalRequest) _then;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? remarks = freezed,
    Object? utr = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Money,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      remarks: freezed == remarks
          ? _self.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      utr: freezed == utr
          ? _self.utr
          : utr // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WithdrawalRequest].
extension WithdrawalRequestPatterns on WithdrawalRequest {
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
    TResult Function(_WithdrawalRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WithdrawalRequest() when $default != null:
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
    TResult Function(_WithdrawalRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WithdrawalRequest():
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
    TResult? Function(_WithdrawalRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WithdrawalRequest() when $default != null:
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
            Money amount,
            String status,
            DateTime? createdAt,
            String? remarks,
            String? utr,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WithdrawalRequest() when $default != null:
        return $default(_that.id, _that.amount, _that.status, _that.createdAt,
            _that.remarks, _that.utr, _that.updatedAt);
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
            Money amount,
            String status,
            DateTime? createdAt,
            String? remarks,
            String? utr,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WithdrawalRequest():
        return $default(_that.id, _that.amount, _that.status, _that.createdAt,
            _that.remarks, _that.utr, _that.updatedAt);
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
            Money amount,
            String status,
            DateTime? createdAt,
            String? remarks,
            String? utr,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WithdrawalRequest() when $default != null:
        return $default(_that.id, _that.amount, _that.status, _that.createdAt,
            _that.remarks, _that.utr, _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _WithdrawalRequest implements WithdrawalRequest {
  const _WithdrawalRequest(
      {this.id = '',
      this.amount = Money.zero,
      this.status = 'pending',
      this.createdAt,
      this.remarks,
      this.utr,
      this.updatedAt});

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final Money amount;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? createdAt;
  @override
  final String? remarks;
  @override
  final String? utr;
  @override
  final DateTime? updatedAt;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WithdrawalRequestCopyWith<_WithdrawalRequest> get copyWith =>
      __$WithdrawalRequestCopyWithImpl<_WithdrawalRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WithdrawalRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.utr, utr) || other.utr == utr) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, amount, status, createdAt, remarks, utr, updatedAt);

  @override
  String toString() {
    return 'WithdrawalRequest(id: $id, amount: $amount, status: $status, createdAt: $createdAt, remarks: $remarks, utr: $utr, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$WithdrawalRequestCopyWith<$Res>
    implements $WithdrawalRequestCopyWith<$Res> {
  factory _$WithdrawalRequestCopyWith(
          _WithdrawalRequest value, $Res Function(_WithdrawalRequest) _then) =
      __$WithdrawalRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      Money amount,
      String status,
      DateTime? createdAt,
      String? remarks,
      String? utr,
      DateTime? updatedAt});
}

/// @nodoc
class __$WithdrawalRequestCopyWithImpl<$Res>
    implements _$WithdrawalRequestCopyWith<$Res> {
  __$WithdrawalRequestCopyWithImpl(this._self, this._then);

  final _WithdrawalRequest _self;
  final $Res Function(_WithdrawalRequest) _then;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? remarks = freezed,
    Object? utr = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_WithdrawalRequest(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Money,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      remarks: freezed == remarks
          ? _self.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      utr: freezed == utr
          ? _self.utr
          : utr // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$WalletData {
  Money get balance;
  Money get totalEarnings;
  int get jobsDone;
  List<WalletTransaction> get transactions;
  List<WithdrawalRequest> get withdrawRequests;

  /// Create a copy of WalletData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WalletDataCopyWith<WalletData> get copyWith =>
      _$WalletDataCopyWithImpl<WalletData>(this as WalletData, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WalletData &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.jobsDone, jobsDone) ||
                other.jobsDone == jobsDone) &&
            const DeepCollectionEquality()
                .equals(other.transactions, transactions) &&
            const DeepCollectionEquality()
                .equals(other.withdrawRequests, withdrawRequests));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      balance,
      totalEarnings,
      jobsDone,
      const DeepCollectionEquality().hash(transactions),
      const DeepCollectionEquality().hash(withdrawRequests));

  @override
  String toString() {
    return 'WalletData(balance: $balance, totalEarnings: $totalEarnings, jobsDone: $jobsDone, transactions: $transactions, withdrawRequests: $withdrawRequests)';
  }
}

/// @nodoc
abstract mixin class $WalletDataCopyWith<$Res> {
  factory $WalletDataCopyWith(
          WalletData value, $Res Function(WalletData) _then) =
      _$WalletDataCopyWithImpl;
  @useResult
  $Res call(
      {Money balance,
      Money totalEarnings,
      int jobsDone,
      List<WalletTransaction> transactions,
      List<WithdrawalRequest> withdrawRequests});
}

/// @nodoc
class _$WalletDataCopyWithImpl<$Res> implements $WalletDataCopyWith<$Res> {
  _$WalletDataCopyWithImpl(this._self, this._then);

  final WalletData _self;
  final $Res Function(WalletData) _then;

  /// Create a copy of WalletData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? totalEarnings = null,
    Object? jobsDone = null,
    Object? transactions = null,
    Object? withdrawRequests = null,
  }) {
    return _then(_self.copyWith(
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as Money,
      totalEarnings: null == totalEarnings
          ? _self.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as Money,
      jobsDone: null == jobsDone
          ? _self.jobsDone
          : jobsDone // ignore: cast_nullable_to_non_nullable
              as int,
      transactions: null == transactions
          ? _self.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<WalletTransaction>,
      withdrawRequests: null == withdrawRequests
          ? _self.withdrawRequests
          : withdrawRequests // ignore: cast_nullable_to_non_nullable
              as List<WithdrawalRequest>,
    ));
  }
}

/// Adds pattern-matching-related methods to [WalletData].
extension WalletDataPatterns on WalletData {
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
    TResult Function(_WalletData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WalletData() when $default != null:
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
    TResult Function(_WalletData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletData():
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
    TResult? Function(_WalletData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletData() when $default != null:
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
            Money balance,
            Money totalEarnings,
            int jobsDone,
            List<WalletTransaction> transactions,
            List<WithdrawalRequest> withdrawRequests)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WalletData() when $default != null:
        return $default(_that.balance, _that.totalEarnings, _that.jobsDone,
            _that.transactions, _that.withdrawRequests);
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
            Money balance,
            Money totalEarnings,
            int jobsDone,
            List<WalletTransaction> transactions,
            List<WithdrawalRequest> withdrawRequests)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletData():
        return $default(_that.balance, _that.totalEarnings, _that.jobsDone,
            _that.transactions, _that.withdrawRequests);
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
            Money balance,
            Money totalEarnings,
            int jobsDone,
            List<WalletTransaction> transactions,
            List<WithdrawalRequest> withdrawRequests)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletData() when $default != null:
        return $default(_that.balance, _that.totalEarnings, _that.jobsDone,
            _that.transactions, _that.withdrawRequests);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _WalletData implements WalletData {
  const _WalletData(
      {this.balance = Money.zero,
      this.totalEarnings = Money.zero,
      this.jobsDone = 0,
      final List<WalletTransaction> transactions = const [],
      final List<WithdrawalRequest> withdrawRequests = const []})
      : _transactions = transactions,
        _withdrawRequests = withdrawRequests;

  @override
  @JsonKey()
  final Money balance;
  @override
  @JsonKey()
  final Money totalEarnings;
  @override
  @JsonKey()
  final int jobsDone;
  final List<WalletTransaction> _transactions;
  @override
  @JsonKey()
  List<WalletTransaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  final List<WithdrawalRequest> _withdrawRequests;
  @override
  @JsonKey()
  List<WithdrawalRequest> get withdrawRequests {
    if (_withdrawRequests is EqualUnmodifiableListView)
      return _withdrawRequests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_withdrawRequests);
  }

  /// Create a copy of WalletData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WalletDataCopyWith<_WalletData> get copyWith =>
      __$WalletDataCopyWithImpl<_WalletData>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WalletData &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.jobsDone, jobsDone) ||
                other.jobsDone == jobsDone) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions) &&
            const DeepCollectionEquality()
                .equals(other._withdrawRequests, _withdrawRequests));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      balance,
      totalEarnings,
      jobsDone,
      const DeepCollectionEquality().hash(_transactions),
      const DeepCollectionEquality().hash(_withdrawRequests));

  @override
  String toString() {
    return 'WalletData(balance: $balance, totalEarnings: $totalEarnings, jobsDone: $jobsDone, transactions: $transactions, withdrawRequests: $withdrawRequests)';
  }
}

/// @nodoc
abstract mixin class _$WalletDataCopyWith<$Res>
    implements $WalletDataCopyWith<$Res> {
  factory _$WalletDataCopyWith(
          _WalletData value, $Res Function(_WalletData) _then) =
      __$WalletDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Money balance,
      Money totalEarnings,
      int jobsDone,
      List<WalletTransaction> transactions,
      List<WithdrawalRequest> withdrawRequests});
}

/// @nodoc
class __$WalletDataCopyWithImpl<$Res> implements _$WalletDataCopyWith<$Res> {
  __$WalletDataCopyWithImpl(this._self, this._then);

  final _WalletData _self;
  final $Res Function(_WalletData) _then;

  /// Create a copy of WalletData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? balance = null,
    Object? totalEarnings = null,
    Object? jobsDone = null,
    Object? transactions = null,
    Object? withdrawRequests = null,
  }) {
    return _then(_WalletData(
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as Money,
      totalEarnings: null == totalEarnings
          ? _self.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as Money,
      jobsDone: null == jobsDone
          ? _self.jobsDone
          : jobsDone // ignore: cast_nullable_to_non_nullable
              as int,
      transactions: null == transactions
          ? _self._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<WalletTransaction>,
      withdrawRequests: null == withdrawRequests
          ? _self._withdrawRequests
          : withdrawRequests // ignore: cast_nullable_to_non_nullable
              as List<WithdrawalRequest>,
    ));
  }
}

// dart format on
