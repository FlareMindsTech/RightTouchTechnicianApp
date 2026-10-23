import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:right_touch/utils/money.dart';

part 'wallet_transaction.freezed.dart';

@freezed
abstract class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    @Default('') String id,
    @Default(Money.zero) Money amount,
    @Default('unknown') String type,
    @Default('Transaction') String description,
    DateTime? createdAt,
    String? status,
    String? bookingId,
    String? bookingCode,
    String? utr,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      amount: Money.fromDynamic(json['amount']),
      type: (json['type'] ?? 'unknown').toString(),
      description: (json['description'] ?? 'Transaction').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      status: json['status']?.toString(),
      bookingId: json['bookingId']?.toString(),
      bookingCode: json['bookingCode']?.toString(),
      utr: json['utr']?.toString(),
    );
  }
}

@freezed
abstract class WithdrawalRequest with _$WithdrawalRequest {
  const factory WithdrawalRequest({
    @Default('') String id,
    @Default(Money.zero) Money amount,
    @Default('pending') String status,
    DateTime? createdAt,
    String? remarks,
    String? utr,
    DateTime? updatedAt,
  }) = _WithdrawalRequest;

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      amount: Money.fromDynamic(json['amount']),
      status: (json['status'] ?? 'pending').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      remarks: json['remarks']?.toString(),
      utr: json['utr']?.toString(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}

@freezed
abstract class WalletData with _$WalletData {
  const factory WalletData({
    @Default(Money.zero) Money balance,
    @Default(Money.zero) Money totalEarnings,
    @Default(0) int jobsDone,
    @Default([]) List<WalletTransaction> transactions,
    @Default([]) List<WithdrawalRequest> withdrawRequests,
  }) = _WalletData;

  factory WalletData.fromJson(Map<String, dynamic> json) {
    final txRaw = json['transactions'];
    final wrRaw = json['withdrawRequests'];
    return WalletData(
      balance: Money.fromDynamic(json['balance']),
      transactions: txRaw is List
          ? txRaw
              .map((e) => WalletTransaction.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      withdrawRequests: wrRaw is List
          ? wrRaw
              .map((e) => WithdrawalRequest.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }
}
