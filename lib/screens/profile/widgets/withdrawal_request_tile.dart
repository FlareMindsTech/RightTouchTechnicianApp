import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:right_touch/data/models/wallet_transaction.dart';
import 'package:right_touch/utils/app_theme.dart';

class WithdrawalRequestTile extends StatelessWidget {
  final WithdrawalRequest request;

  const WithdrawalRequestTile({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final status = request.status.toLowerCase();
    final date = request.createdAt ?? DateTime.now();

    Color statusColor = AppTheme.orange;
    if (status == 'completed' || status == 'approved') {
      statusColor = AppTheme.green;
    } else if (status == 'rejected' || status == 'failed') {
      statusColor = AppTheme.red;
    }

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
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(Icons.payment, color: statusColor),
        ),
        title: Text(
          request.amount.formatted,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(date),
              style: TextStyle(color: AppTheme.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                request.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
