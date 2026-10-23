import 'package:intl/intl.dart';

/// Immutable Money value type representing currency as integer paise (1 Rupee = 100 Paise).
/// Eliminates floating-point rounding errors and centralizes currency formatting (₹).
class Money implements Comparable<Money> {
  final int paise;

  const Money._(this.paise);

  /// Creates a [Money] instance from integer paise.
  const Money.fromPaise(this.paise);

  /// Creates a [Money] instance from rupees (num), rounding to nearest paise.
  factory Money.fromRupees(num rupees) {
    return Money._((rupees * 100).round());
  }

  /// Zero amount (₹0.00).
  static const Money zero = Money._(0);

  /// Safely parses dynamic currency values (num, int, double, String, Money, null).
  static Money fromDynamic(dynamic value) {
    if (value == null) return Money.zero;
    if (value is Money) return value;
    if (value is int) {
      return Money.fromRupees(value);
    }
    if (value is num) {
      return Money.fromRupees(value);
    }
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.-]'), '');
      if (cleaned.isEmpty) return Money.zero;
      final parsed = double.tryParse(cleaned);
      if (parsed != null) return Money.fromRupees(parsed);
    }
    return Money.zero;
  }

  /// Amount converted to rupees (e.g. 150 paise -> 1.50 rupees).
  double get inRupees => paise / 100.0;

  bool get isZero => paise == 0;
  bool get isPositive => paise > 0;
  bool get isNegative => paise < 0;

  Money operator +(Money other) => Money._(paise + other.paise);
  Money operator -(Money other) => Money._(paise - other.paise);
  Money operator *(num factor) => Money._((paise * factor).round());
  Money operator /(num divisor) {
    if (divisor == 0) throw ArgumentError('Cannot divide Money by zero');
    return Money._((paise / divisor).round());
  }

  bool operator <(Money other) => paise < other.paise;
  bool operator <=(Money other) => paise <= other.paise;
  bool operator >(Money other) => paise > other.paise;
  bool operator >=(Money other) => paise >= other.paise;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && runtimeType == other.runtimeType && paise == other.paise;

  @override
  int get hashCode => paise.hashCode;

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  /// Standard Indian Rupee format with ₹ symbol and 2 decimal places (e.g. ₹1,234.50).
  String get formatted {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(inRupees);
  }

  /// Compact or integer format if decimals are zero, otherwise 2 decimals (e.g. ₹1,500).
  String get formattedCompact {
    if (paise % 100 == 0) {
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      return formatter.format(inRupees);
    }
    return formatted;
  }

  @override
  String toString() => formatted;
}
