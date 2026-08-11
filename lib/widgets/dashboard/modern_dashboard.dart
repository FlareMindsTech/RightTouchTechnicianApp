import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/providers/nav_provider.dart';
import 'package:right_touch/providers/socket_state_provider.dart';

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
    // Selective watch: only rebuild if verification status or basic profile data changes.
    // This prevents rebuilds on every location timestamp update.
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

    // Watch ONLY the type of the state to avoid rebuilds on irrelevant data changes
    return ref.watch(authProvider).maybeWhen(
          authenticated: (user) {
            final List<Widget> scrollableSlivers = [
              if (widget.topSlivers != null) ...widget.topSlivers!,
              if (!isVerified) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildLockedSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ] else ...[
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                      child: _buildJobSummary(dashboardAsync)),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: _buildTimeFilters()),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver:
                      SliverToBoxAdapter(child: _buildChart(dashboardAsync)),
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
                      Colors.green,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ];

            return Column(
              children: [
                // Fixed Header and Balance Card section
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
                  child: _buildBalanceCard(dashboardAsync),
                ),

                // Scrollable content section
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
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage) : null,
                child: profileImage == null
                    ? const Icon(Icons.person, color: Colors.grey)
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            ref.read(navProvider.notifier).state = 1; // 1 is New Jobs
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
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
                      color: Colors.orange,
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
        color: Colors.grey[100],
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
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                  color: isSelected ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBalanceCard(AsyncValue<DashboardData> asyncData) {
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
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          asyncData.when(
            loading: () => Shimmer.fromColors(
              baseColor: Colors.white24,
              highlightColor: Colors.white54,
              child: Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            error: (e, s) => const Text(
              '₹0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            data: (data) => Text(
              '₹${data.totalEarnings.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
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
    // Assuming ApiConfig is a separate class, adding these here would be syntactically incorrect.
    // The instruction implies updating an existing ApiConfig class, which is not present in this document.
    // If ApiConfig were present, these lines would be added as static members within that class.
    // static const String walletHistoryEndpoint =
    //     '/api/technician/wallet/withdrawalhistory';
    // static const String withdrawFundEndpoint = '/api/technician/wallet/withdrawal';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
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
                Colors.orange,
                () {
                  ref.read(navProvider.notifier).state = 2; // 2 is My Schedule
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
                Colors.green,
                () {
                  ref.read(navProvider.notifier).state =
                      2; // index 2 is Schedule
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
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
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(AsyncValue<DashboardData> asyncData) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: asyncData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
              data: (data) => data.earningTrend.isEmpty
                  ? Center(
                      child: Text(
                        'No data available for this period',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: _getInterval(
                                ref.watch(dashboardFilterProvider),
                              ),
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    _getBottomTitle(
                                      value,
                                      ref.watch(dashboardFilterProvider),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: data.earningTrend,
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Widget _buildLockedSection() {
    final authState = ref.watch(authProvider);
    // Selective watch: only rebuild if verification status or basic profile data changes.
    // This prevents rebuilds on every location timestamp update.
    final (displayName, profileImage, isVerified) = authState.maybeWhen(
      authenticated: (user) =>
          (user.fullDisplayName, user.profileImage, user.kycVerified == true),
      orElse: () => ('User', null, false),
    );

    if (!isVerified) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: Colors.orange,
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
                  color: Colors.grey[600],
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
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
                      Colors.orange,
                    ),
                    _buildInsightItem(
                      "Online Hours",
                      "124h",
                      Icons.timer_rounded,
                      Colors.indigo,
                    ),
                    _buildInsightItem(
                      "Success Rate",
                      "98%",
                      Icons.check_circle_rounded,
                      Colors.teal,
                    ),
                    _buildInsightItem(
                      "Cancelled",
                      "2",
                      Icons.cancel_rounded,
                      Colors.red,
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
        color: color.withOpacity(0.05),
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
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
        ],
      ),
    );
  }

  double _getInterval(String filter) {
    if (filter == 'Week') return 1;
    if (filter == 'Month') return 5;
    if (filter == '3M') return 15;
    if (filter == 'Year') return 30;
    return 1;
  }

  String _getBottomTitle(double value, String filter) {
    if (filter == 'Week') {
      final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      int idx = value.toInt() % 7;
      return days[idx];
    }
    // For other filters, we just show a generic index or could do dates
    return value.toInt().toString();
  }
}
