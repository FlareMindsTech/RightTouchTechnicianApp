import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class DashboardBalanceCard extends StatelessWidget {
  final AsyncValue<DashboardData> asyncData;

  const DashboardBalanceCard({
    super.key,
    required this.asyncData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(color: AppTheme.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          asyncData.when(
            loading: () => Shimmer.fromColors(
              baseColor: AppTheme.white24,
              highlightColor: AppTheme.white54,
              child: Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            error: (e, s) => const Text(
              '₹0',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            data: (data) => Text(
              '₹${data.totalEarnings.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStat(
                'Pending',
                asyncData.maybeWhen(
                  data: (data) => '${data.pendingJobs}',
                  orElse: () => '0',
                ),
                Icons.hourglass_empty,
              ),
              const SizedBox(width: 24),
              _buildStat(
                'Completed',
                asyncData.maybeWhen(
                  data: (data) => '${data.completedJobs}',
                  orElse: () => '0',
                ),
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppTheme.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
