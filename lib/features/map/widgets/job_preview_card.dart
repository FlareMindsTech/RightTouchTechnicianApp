import 'package:flutter/material.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class JobPreviewCard extends StatelessWidget {
  final Job job;
  final VoidCallback onNavigate;
  final VoidCallback onClose;

  const JobPreviewCard({
    super.key,
    required this.job,
    required this.onNavigate,
    required this.onClose,
  });

  Future<void> _callCustomer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = job.serviceName ?? job.title;
    final customerName = job.customerName?.isNotEmpty == true
        ? job.customerName!
        : 'Customer';
    final earnings = job.technicianAmount ?? job.earnings ?? job.basePrice;
    final timeStr = job.scheduledTime ?? job.scheduledAt ?? 'Scheduled';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppTheme.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Service Name, Earnings Badge, and Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          size: 13,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (earnings != null && earnings > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '₹${earnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppTheme.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Customer and Location info
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 15,
                color: AppTheme.grey,
              ),
              const SizedBox(width: 4),
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.black87,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppTheme.grey,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Actions Row: Call Customer + Navigate Button
          Row(
            children: [
              if (job.customerPhone != null &&
                  job.customerPhone!.isNotEmpty) ...[
                IconButton.filledTonal(
                  onPressed: () => _callCustomer(job.customerPhone!),
                  icon: const Icon(Icons.phone, size: 20, color: AppTheme.green),
                  tooltip: 'Call Customer',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.green.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.navigation_rounded, size: 18),
                    label: const Text(
                      'NAVIGATE NOW',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

