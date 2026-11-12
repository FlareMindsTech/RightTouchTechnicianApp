import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/wallet_transaction.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class WithdrawalReceiptSheet extends ConsumerStatefulWidget {
  final WithdrawalRequest request;

  const WithdrawalReceiptSheet({super.key, required this.request});

  static Future<void> show(BuildContext context, WithdrawalRequest request) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WithdrawalReceiptSheet(request: request),
    );
  }

  @override
  ConsumerState<WithdrawalReceiptSheet> createState() =>
      _WithdrawalReceiptSheetState();
}

class _WithdrawalReceiptSheetState
    extends ConsumerState<WithdrawalReceiptSheet> {
  Map<String, dynamic>? _receiptData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final data = await repo.getWithdrawalReceipt(widget.request.id);
      if (mounted) {
        setState(() {
          _receiptData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final utr = _receiptData?['utr']?.toString() ??
        widget.request.utr ??
        'Processing';
    final paymentMode = _receiptData?['paymentMode']?.toString() ??
        _receiptData?['payoutMode']?.toString() ??
        'IMPS Bank Transfer';
    final adminNote = _receiptData?['adminNote']?.toString() ??
        widget.request.remarks ??
        'Settled by Admin';
    final paidAt = _receiptData?['paidAt'] != null
        ? DateTime.tryParse(_receiptData!['paidAt'].toString())
        : widget.request.updatedAt ?? widget.request.createdAt;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Success Icon Badge
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F5E9),
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: AppTheme.green,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            "Payout Receipt",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.request.amount.formatted,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "PAID & VERIFIED",
              style: TextStyle(
                color: AppTheme.green,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: RtLoader(size: 28),
            )
          else ...[
            // Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: "UTR / Reference",
                    value: utr,
                    trailing: utr != 'Processing'
                        ? InkWell(
                            onTap: () => _copyToClipboard(utr, "UTR"),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    label: "Payment Mode",
                    value: paymentMode,
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    label: "Status",
                    value: "Completed (Manual Transfer)",
                  ),
                  if (paidAt != null) ...[
                    const Divider(height: 20),
                    _buildDetailRow(
                      label: "Date & Time",
                      value: _formatDate(paidAt),
                    ),
                  ],
                  if (adminNote.isNotEmpty && adminNote != 'null') ...[
                    const Divider(height: 20),
                    _buildDetailRow(
                      label: "Admin Note",
                      value: adminNote,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Done",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing,
            ],
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period";
  }
}

