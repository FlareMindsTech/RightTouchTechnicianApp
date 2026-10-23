import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/screens/tabs/widgets/partner_verification_form.dart';
import 'package:right_touch/screens/tabs/widgets/verification_status_views.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/dashboard/modern_dashboard.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class VerificationHomeTab extends ConsumerStatefulWidget {
  final VoidCallback? onVerified;
  const VerificationHomeTab({super.key, this.onVerified});

  @override
  ConsumerState<VerificationHomeTab> createState() =>
      _VerificationHomeTabState();
}

class _VerificationHomeTabState extends ConsumerState<VerificationHomeTab> {
  final bool _isRefreshingKYC = false;
  bool _hasSeenSuccess = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _checkSuccessStatus();
      }
    });
  }

  Future<void> _checkSuccessStatus() async {
    final seen = await ref.read(authProvider.notifier).hasSeenSuccess();
    if (mounted) setState(() => _hasSeenSuccess = seen);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.maybeWhen(
      authenticated: (user) {
        // 1) If fully verified and completed training
        if (user.kycVerified == true && user.trainingCompleted == true) {
          if (_hasSeenSuccess) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(dashboardDataProvider.notifier).refresh(),
              child: const ModernDashboard(showHeader: true),
            );
          } else {
            return VerifiedHomeView(
              user: user,
              onGoToDashboard: () async {
                await ref.read(authProvider.notifier).markSuccessSeen();
                if (mounted) setState(() => _hasSeenSuccess = true);
              },
            );
          }
        }

        // 2) If KYC is submitted but pending, or if training is pending
        if (user.kycVerified == true ||
            (user.kycStatus != null &&
                user.kycStatus != 'none' &&
                user.kycStatus != '')) {
          return PendingHomeView(
            user: user,
            isRefreshingKYC: _isRefreshingKYC,
          );
        }

        // Otherwise show verification form
        return PartnerVerificationForm(
          onVerified: widget.onVerified,
        );
      },
      loading: () => const Center(child: RtLoader()),
      error: (msg) => ErrorBoundary(
        message: ErrorHandler.parseError(msg),
        onRetry: () => ref.read(authProvider.notifier).checkAuth(),
        showTitle: false,
        isElevated: true,
        onLoginAgain: () => ref.read(authProvider.notifier).logout(),
      ),
      orElse: () => ErrorBoundary(
        message: "Your account is not active.\nPlease contact support.",
        onRetry: () => ref.read(authProvider.notifier).checkAuth(),
        showTitle: false,
        isElevated: true,
        onLoginAgain: () => ref.read(authProvider.notifier).logout(),
      ),
    );
  }
}
