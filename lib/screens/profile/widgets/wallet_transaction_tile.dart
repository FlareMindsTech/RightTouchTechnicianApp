import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:right_touch/data/models/wallet_transaction.dart';
import 'package:right_touch/utils/app_theme.dart';

class WalletTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final type = transaction.type;
    final isCredit = type == 'credit' || type == 'earning';
    final date = transaction.createdAt ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? AppTheme.green.withValues(alpha: 0.1)
              : AppTheme.red.withValues(alpha: 0.1),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? AppTheme.green : AppTheme.red,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy • hh:mm a').format(date),
          style: TextStyle(color: AppTheme.grey[600], fontSize: 12),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}${transaction.amount.formatted}',
          style: TextStyle(
            color: isCredit ? AppTheme.green : AppTheme.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
