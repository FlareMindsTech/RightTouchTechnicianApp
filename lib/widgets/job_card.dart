import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/models/job.dart';
import 'package:url_launcher/url_launcher.dart';

class JobCard extends StatelessWidget {
  final Job? job;
  final VoidCallback? onTap;
  final bool isClickable;
  final bool showCallButton; // New parameter

  const JobCard({
    super.key,
    this.job,
    this.onTap,
    this.isClickable = true,
    this.showCallButton = false, // Default to hidden
  });

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use dummy data if job is null (for backward compatibility)
    final displayJob = job;
    double earnings = displayJob?.technicianAmount ??
        displayJob?.basePrice ??
        displayJob?.totalAmount ??
        displayJob?.earnings ??
        0.0;
    if (earnings <= 0.0) earnings = 0.0; // Allow 0.0, don't force 1.0 if not needed, but keeping it 0.0 for now
    final isExclusive = displayJob?.isExclusive ?? false;
    final hasPhone = displayJob?.customerPhone != null &&
        displayJob!.customerPhone!.isNotEmpty;

    return GestureDetector(
      onTap: isClickable
          ? () {
              HapticFeedback.lightImpact();
              onTap?.call();
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isClickable ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Decorative Gradient Side Bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isClickable
                          ? [AppTheme.primaryColor, AppTheme.successColor]
                          : [Colors.grey.shade400, Colors.grey.shade300],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Time and Earnings
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isExclusive)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.orange, Colors.deepOrange],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "EXCLUSIVE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            Text(
                              _getTimeAgo(
                                displayJob?.createdAt ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Earnings Badge with Call Icon
                        Row(
                          children: [
                            // Call Icon Button - Only show if specifically requested and phone exists
                            if (showCallButton && hasPhone)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.phone,
                                    size: 20,
                                    color: Colors.green.shade700,
                                  ),
                                  onPressed: () =>
                                      _makeCall(displayJob.customerPhone!),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                ),
                              ),
                            // Earnings
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.currency_rupee_rounded,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  Text(
                                    earnings.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Main Content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconForTitle(displayJob?.title),
                            color: AppTheme.secondaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayJob?.title ?? "Service Request",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                (displayJob?.customerName == null ||
                                        displayJob!.customerName!
                                            .trim()
                                            .isEmpty)
                                    ? 'Customer'
                                    : displayJob.customerName!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (displayJob?.faultReasonsList != null &&
                                  displayJob!.faultReasonsList!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 14,
                                            color: Colors.red.shade800,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Fault Reason",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.red.shade800,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        displayJob.faultReasonsList!.join(', '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red.shade900,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 14),

                    // Footer: Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            displayJob?.location ?? 'Location not specified',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isClickable)
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppTheme.primaryColor.withValues(alpha: 0.6),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String? title) {
    if (title == null) return Icons.handyman_rounded;
    final t = title.toLowerCase();
    if (t.contains('ac') || t.contains('cool')) {
      return Icons.ac_unit_rounded;
    }
    if (t.contains('water') || t.contains('plumb')) {
      return Icons.water_drop_rounded;
    }
    if (t.contains('electric') || t.contains('power')) {
      return Icons.electrical_services_rounded;
    }
    if (t.contains('clean')) {
      return Icons.cleaning_services_rounded;
    }
    return Icons.handyman_rounded;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}
