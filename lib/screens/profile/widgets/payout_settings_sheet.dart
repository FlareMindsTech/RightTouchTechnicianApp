import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/repositories/dashboard_repository.dart';
import 'package:right_touch/providers/wallet_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class PayoutSettingsSheet extends ConsumerStatefulWidget {
  const PayoutSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PayoutSettingsSheet(),
    );
  }

  @override
  ConsumerState<PayoutSettingsSheet> createState() =>
      _PayoutSettingsSheetState();
}

class _PayoutSettingsSheetState extends ConsumerState<PayoutSettingsSheet> {
  final TextEditingController _maintenanceController =
      TextEditingController(text: '100');
  String _preferredMode = 'bank_transfer';
  bool _isSaving = false;

  @override
  void dispose() {
    _maintenanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final maintenanceVal = double.tryParse(_maintenanceController.text.trim());
    if (maintenanceVal == null || maintenanceVal < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid maintenance balance (≥ 0)"),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      await repo.updatePayoutSettings(
        minimumMaintenance: maintenanceVal,
        preferredPayoutMode: _preferredMode,
      );
      if (mounted) {
        ref.invalidate(walletProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payout settings updated successfully"),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            "Payout Preferences",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Configure your minimum wallet reserve floor and preferred payout destination",
            style: TextStyle(fontSize: 12, color: AppTheme.grey[600]),
          ),
          const SizedBox(height: 20),

          // Maintenance floor
          const Text(
            "Minimum Maintenance Floor (₹)",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _maintenanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: "₹ ",
              hintText: "100",
              helperText: "Minimum balance kept in wallet to remain active",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preferred Mode
          const Text(
            "Preferred Payout Destination",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _preferredMode = 'bank_transfer'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _preferredMode == 'bank_transfer'
                          ? AppTheme.primaryColor.withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _preferredMode == 'bank_transfer'
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        width: _preferredMode == 'bank_transfer' ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: _preferredMode == 'bank_transfer'
                              ? AppTheme.primaryColor
                              : AppTheme.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Bank Account",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _preferredMode == 'bank_transfer'
                                ? AppTheme.primaryColor
                                : AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _preferredMode = 'upi'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _preferredMode == 'upi'
                          ? AppTheme.primaryColor.withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _preferredMode == 'upi'
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        width: _preferredMode == 'upi' ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          color: _preferredMode == 'upi'
                              ? AppTheme.primaryColor
                              : AppTheme.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "UPI ID",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _preferredMode == 'upi'
                                ? AppTheme.primaryColor
                                : AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const RtLoader.button(color: AppTheme.white)
                  : const Text(
                      "Save Preferences",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

