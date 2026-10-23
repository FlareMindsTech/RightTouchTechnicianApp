import 'package:flutter/material.dart';
import 'package:right_touch/data/models/user_model.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/dashboard/modern_dashboard.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class VerifiedHomeView extends StatelessWidget {
  final UserModel user;
  final VoidCallback onGoToDashboard;

  const VerifiedHomeView({
    super.key,
    required this.user,
    required this.onGoToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 80,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          "Welcome ${user.fullDisplayName}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "You are verified and ready to work!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.grey),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGoToDashboard,
              child: const Text(
                'Go to Dashboard',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Expanded(child: ModernDashboard(showHeader: false)),
      ],
    );
  }
}

class PendingHomeView extends StatelessWidget {
  final UserModel user;
  final bool isRefreshingKYC;

  const PendingHomeView({
    super.key,
    required this.user,
    required this.isRefreshingKYC,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTrainingPending =
        user.kycVerified == true && user.trainingCompleted != true;
    final String statusMessage = isTrainingPending
        ? "Training pending. Please complete your training to proceed!"
        : "Verification pending approval.\nWe'll notify you once complete!";

    return ModernDashboard(
      showHeader: false,
      topSlivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.hourglass_empty_rounded,
                size: 80,
                color: AppTheme.orange,
              ),
              if (isRefreshingKYC) ...[
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RtLoader(
                      size: 14,
                      color: AppTheme.orange,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Checking status...",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                "Hello ${user.fullDisplayName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.grey),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
