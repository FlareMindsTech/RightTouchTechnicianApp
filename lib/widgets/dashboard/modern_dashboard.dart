import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/providers/nav_provider.dart';
import 'package:right_touch/providers/socket_state_provider.dart';
import 'package:right_touch/widgets/dashboard/dashboard_balance_card.dart';
import 'package:right_touch/widgets/dashboard/dashboard_performance_section.dart';
import 'package:right_touch/widgets/dashboard/earnings_trend_chart.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/utils/app_theme.dart';

class ModernDashboard extends ConsumerStatefulWidget {
  final bool showHeader;
  final List<Widget>? topSlivers;
  const ModernDashboard({
    super.key,
    this.showHeader = true,
    this.topSlivers,
  });

  @override
  ConsumerState<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends ConsumerState<ModernDashboard> {
  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    final (displayName, profileImage, isVerified) = ref.watch(
      authProvider.select((state) => state.maybeWhen(
            authenticated: (user) => (
              user.fullDisplayName,
              user.profileImage,
              user.kycVerified == true
            ),
            orElse: () => ('User', null, false),
          )),
    );

    return ref.watch(authProvider).maybeWhen(
          authenticated: (user) {
            final List<Widget> scrollableSlivers = [
              if (widget.topSlivers != null) ...widget.topSlivers!,
              if (!isVerified) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: DashboardPerformanceSection(isVerified: isVerified),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ] else ...[
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _buildJobSummary(dashboardAsync),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: _buildTimeFilters()),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: EarningsTrendChart(asyncData: dashboardAsync),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _buildAccountItem(
                      'Wallet',
                      'Available for withdrawal',
                      dashboardAsync.maybeWhen(
                        data: (data) =>
                            '₹${data.availableBalance.toStringAsFixed(0)}',
                        orElse: () => '₹0',
                      ),
                      Icons.account_balance_wallet,
                      AppTheme.green,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ];

            return Column(
              children: [
                if (widget.showHeader) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildHeader(displayName, profileImage),
                  ),
                  const SizedBox(height: 24),
                ] else
                  const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DashboardBalanceCard(asyncData: dashboardAsync),
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: isVerified
                        ? const AlwaysScrollableScrollPhysics()
                        : const ClampingScrollPhysics(),
                    slivers: scrollableSlivers,
                  ),
                ),
              ],
            );
          },
          orElse: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: ErrorBoundary(
                message: "Your account is not active.\nPlease contact support.",
                onRetry: () => ref.read(authProvider.notifier).checkAuth(),
              ),
            ),
          ),
        );
  }

  Widget _buildHeader(String name, String? profileImage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.grey[200],
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage) : null,
                child: profileImage == null
                    ? const Icon(Icons.person, color: AppTheme.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome $name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Here are your recent updates',
                      style: TextStyle(fontSize: 14, color: AppTheme.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(navProvider.notifier).state = 1;
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.grey[200]!),
                ),
                child: const Icon(Icons.notifications_outlined, size: 24),
              ),
              if (ref.watch(socketStateProvider).hasNewJob)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilters() {
    final filters = ['Week', 'Month', '3M', 'Year'];
    final selectedFilter = ref.watch(dashboardFilterProvider);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(dashboardFilterProvider.notifier).state = filter;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.white : AppTheme.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.black : AppTheme.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJobSummary(AsyncValue<DashboardData> asyncData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildJobStatCard(
                'Pending Jobs',
                asyncData.maybeWhen(
                  data: (data) => '${data.pendingJobs}',
                  orElse: () => '0',
                ),
                Icons.schedule,
                AppTheme.orange,
                () {
                  ref.read(navProvider.notifier).state = 2;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildJobStatCard(
                'Completed',
                asyncData.maybeWhen(
                  data: (data) => '${data.completedJobs}',
                  orElse: () => '0',
                ),
                Icons.check_circle,
                AppTheme.green,
                () {
                  ref.read(navProvider.notifier).state = 2;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: AppTheme.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(
    String title,
    String subtitle,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
