import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:right_touch/data/models/wallet_transaction.dart';
import 'package:right_touch/providers/wallet_provider.dart';
import 'package:right_touch/screens/profile/widgets/withdrawal_receipt_sheet.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';

class WithdrawalRequestTile extends ConsumerStatefulWidget {
  final WithdrawalRequest request;

  const WithdrawalRequestTile({
    super.key,
    required this.request,
  });

  @override
  ConsumerState<WithdrawalRequestTile> createState() =>
      _WithdrawalRequestTileState();
}

class _WithdrawalRequestTileState extends ConsumerState<WithdrawalRequestTile> {
  bool _isCancelling = false;

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cancel Withdrawal Request"),
        content: const Text(
          "Are you sure you want to cancel this withdrawal request? Your reserved balance will be immediately refunded to your available balance.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Keep Request", style: TextStyle(color: AppTheme.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: AppTheme.white,
              elevation: 0,
            ),
            child: const Text("Confirm Cancel"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isCancelling = true);
      try {
        await ref
            .read(walletProvider.notifier)
            .cancelWithdrawal(widget.request.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Withdrawal request cancelled and balance refunded."),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isCancelling = false);
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.request.status.toLowerCase();
    final date = widget.request.createdAt ?? DateTime.now();

    final isPaid = status == 'paid' || status == 'completed';
    final isPending = status == 'requested' || status == 'pending';

    Color statusColor = AppTheme.orange;
    if (isPaid || status == 'approved') {
      statusColor = AppTheme.green;
    } else if (status == 'rejected' || status == 'failed' || status == 'cancelled') {
      statusColor = AppTheme.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(Icons.payment, color: statusColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.amount.formatted,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                        style: TextStyle(color: AppTheme.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
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
                    widget.request.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isPending || isPaid) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isPending)
                    _isCancelling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton.icon(
                            onPressed: _handleCancel,
                            icon: const Icon(Icons.close_rounded,
                                size: 16, color: AppTheme.red),
                            label: const Text(
                              "Cancel Request",
                              style: TextStyle(
                                color: AppTheme.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                  if (isPaid)
                    OutlinedButton.icon(
                      onPressed: () =>
                          WithdrawalReceiptSheet.show(context, widget.request),
                      icon: const Icon(Icons.receipt_long_outlined, size: 15),
                      label: const Text(
                        "View Receipt",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
