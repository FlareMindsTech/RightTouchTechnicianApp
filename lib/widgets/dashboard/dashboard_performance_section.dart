import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/utils/app_theme.dart';

class DashboardPerformanceSection extends ConsumerWidget {
  final bool isVerified;

  const DashboardPerformanceSection({
    super.key,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!isVerified) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: AppTheme.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Verification is Required",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your account is currently being reviewed. Performance insights and withdrawals will unlock once verified.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Performance Insights",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 105,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.grey[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInsightItem(
                      "Rating",
                      "${authState.maybeWhen(authenticated: (u) => u.avgRating.toStringAsFixed(1), orElse: () => '0.0')}/5",
                      Icons.star_rounded,
                      AppTheme.orange,
                    ),
                    _buildInsightItem(
                      "Online Hours",
                      "124h",
                      Icons.timer_rounded,
                      AppTheme.indigo,
                    ),
                    _buildInsightItem(
                      "Success Rate",
                      "98%",
                      Icons.check_circle_rounded,
                      AppTheme.teal,
                    ),
                    _buildInsightItem(
                      "Cancelled",
                      "2",
                      Icons.cancel_rounded,
                      AppTheme.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: AppTheme.grey[600], fontSize: 10),
          ),
        ],
      ),
    );
  }
}
