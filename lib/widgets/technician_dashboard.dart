import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:right_touch/utils/app_theme.dart';

class TechnicianDashboard extends StatelessWidget {
  final int pendingJobs;
  final int completedJobs;
  final double totalEarnings;
  final bool isLoading;

  const TechnicianDashboard({
    super.key,
    required this.pendingJobs,
    required this.completedJobs,
    required this.totalEarnings,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            Row(
              children: [
                Expanded(child: _buildShimmerStatCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildShimmerStatCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildShimmerStatCard()),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Pending",
                    pendingJobs.toString(),
                    Icons.hourglass_empty_rounded,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Completed",
                    completedJobs.toString(),
                    Icons.check_circle_outline_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Earnings",
                    "₹${totalEarnings.toStringAsFixed(0)}",
                    Icons.currency_rupee_rounded,
                    AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStatCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
