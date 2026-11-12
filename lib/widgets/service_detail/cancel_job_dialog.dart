import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/repositories/job_repository.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class CancelJobDialog extends ConsumerStatefulWidget {
  final String bookingId;

  const CancelJobDialog({super.key, required this.bookingId});

  static Future<bool?> show(BuildContext context, String bookingId) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CancelJobDialog(bookingId: bookingId),
    );
  }

  @override
  ConsumerState<CancelJobDialog> createState() => _CancelJobDialogState();
}

class _CancelJobDialogState extends ConsumerState<CancelJobDialog> {
  String _selectedReason = 'emergency';
  bool _isLoading = false;

  final List<Map<String, String>> _reasons = [
    {
      'code': 'emergency',
      'title': 'Personal / Medical Emergency',
      'icon': '🚨',
    },
    {
      'code': 'vehicle_breakdown',
      'title': 'Vehicle Breakdown / Transit Delay',
      'icon': '🛵',
    },
    {
      'code': 'technician_unavailable',
      'title': 'Scheduling Conflict / Unavailable',
      'icon': '⏰',
    },
    {
      'code': 'equipment_issue',
      'title': 'Missing Tools or Required Parts',
      'icon': '🧰',
    },
    {
      'code': 'customer_unreachable',
      'title': 'Customer Unreachable / Bad Address',
      'icon': '📍',
    },
    {
      'code': 'other',
      'title': 'Other Reason',
      'icon': '📝',
    },
  ];

  Future<void> _handleConfirmCancel() async {
    setState(() => _isLoading = true);

    try {
      final jobRepo = ref.read(jobRepositoryProvider);
      final result = await jobRepo.cancelJobByTechnician(
        widget.bookingId,
        reason: _selectedReason,
      );

      if (mounted) {
        ref.invalidate(currentJobsProvider);
        ref.invalidate(scheduledJobsProvider);
        ref.invalidate(historyJobsProvider);
        ref.invalidate(dashboardDataProvider);

        final msg = result['message']?.toString() ??
            'Job assignment cancelled and released.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppTheme.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: AppTheme.error,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cancel Assignment",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Release this job back to the dispatch pool",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Policy Notice Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD180)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE65100),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Cancelling an accepted job may incur a platform penalty of ₹200 on your wallet.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown.shade800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Select Cancellation Reason",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 8),

            // Reasons list
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: _reasons.map((r) {
                    final isSelected = _selectedReason == r['code'];
                    return InkWell(
                      onTap: _isLoading
                          ? null
                          : () => setState(() => _selectedReason = r['code']!),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              r['icon'] ?? '',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                r['title'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppTheme.black
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Radio<String>(
                              value: r['code']!,
                              groupValue: _selectedReason,
                              activeColor: AppTheme.primaryColor,
                              onChanged: _isLoading
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() => _selectedReason = val);
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      "Keep Job",
                      style: TextStyle(
                        color: AppTheme.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirmCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const RtLoader.button(color: AppTheme.white)
                        : const Text(
                            "Confirm Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

