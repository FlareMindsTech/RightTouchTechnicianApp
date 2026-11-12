import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/providers/nav_provider.dart';
import 'package:right_touch/providers/socket_state_provider.dart';
import 'package:right_touch/screens/job_details_screen.dart';
import 'package:right_touch/screens/profile/help_support_screen.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/widgets/fade_in_slide.dart';
import 'package:right_touch/widgets/job_card.dart';
import 'package:right_touch/widgets/kyc_reminder_banner.dart';
import 'package:right_touch/widgets/list_shimmer.dart';

class NewJobsTab extends ConsumerStatefulWidget {
  const NewJobsTab({super.key});

  @override
  ConsumerState<NewJobsTab> createState() => _NewJobsTabState();
}

class _NewJobsTabState extends ConsumerState<NewJobsTab> {
  Timer? _refreshTimer;
  bool _isManualRefreshing = false;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    // Auto refresh every 25 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      if (mounted) {
        _refreshJobs();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshJobs() async {
    setState(() => _isManualRefreshing = true);
    try {
      await ref.read(broadcastJobsProvider.notifier).refresh();
    } finally {
      if (mounted) {
        setState(() => _isManualRefreshing = false);
      }
    }
  }

  Future<void> _handleJobTap(Job job) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
    );

    if (result == true) {
      unawaited(_refreshJobs());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final broadcastJobs = ref.watch(broadcastJobsProvider);
    final socketState = ref.watch(socketStateProvider);

    ref.listen(socketStateProvider, (previous, next) {
      if (next.hasNewJob && !(previous?.hasNewJob ?? false)) {
        HapticFeedback.vibrate();
        _refreshJobs();
      }
      if (next.liveJobs.length < (previous?.liveJobs.length ?? 0)) {
        _refreshJobs();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: RefreshIndicator(
        onRefresh: _refreshJobs,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // KYC Reminder Banner if not complete
            SliverToBoxAdapter(
              child: authState.maybeWhen(
                authenticated: (user) {
                  if (!user.isProfileComplete || user.kycVerified != true) {
                    return KycReminderBanner(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ),

            // Clean Sticky Header
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Title + Notification & Refresh
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Available Jobs",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: _isManualRefreshing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.primaryColor,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh_rounded,
                                        color: Color(0xFF4B5563),
                                        size: 22,
                                      ),
                                onPressed: _isManualRefreshing
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        _refreshJobs();
                                      },
                                tooltip: 'Refresh jobs',
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(socketStateProvider.notifier)
                                      .clearNewJobAlert();
                                  _refreshJobs();
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F4F6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.notifications_outlined,
                                        size: 20,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    if (socketState.hasNewJob)
                                      Positioned(
                                        right: 2,
                                        top: 2,
                                        child: Container(
                                          width: 9,
                                          height: 9,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF5722),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Bottom Row: Job count + Live Status Chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          broadcastJobs.when(
                            data: (jobs) => Text(
                              jobs.isEmpty
                                  ? "0 New Requests"
                                  : "${jobs.length} ${jobs.length == 1 ? 'New Request' : 'New Requests'}",
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: jobs.isEmpty
                                    ? const Color(0xFF6B7280)
                                    : AppTheme.primaryColor,
                              ),
                            ),
                            loading: () => const Text(
                              "Checking for requests...",
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),

                          // Live Socket Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: socketState.isConnected
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: socketState.isConnected
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFE65100),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  socketState.isConnected ? 'LIVE FEED' : 'CONNECTING',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: socketState.isConnected
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFE65100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Job List or Clean Empty State
            broadcastJobs.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyPendingState(ref),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final job = jobs[index];
                    return FadeInSlide(
                      index: index,
                      child: JobCard(
                        job: job,
                        showCallButton: false,
                        onTap: () => _handleJobTap(job),
                      ),
                    );
                  }, childCount: jobs.length),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(height: 400, child: ListShimmer()),
              ),
              error: (err, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorBoundary(
                  message: ErrorHandler.parseError(err),
                  onRetry: _refreshJobs,
                  showTitle: false,
                  isElevated: true,
                  onLoginAgain: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPendingState(WidgetRef ref) {
    final currentJobs = ref.watch(currentJobsProvider).asData?.value ?? [];
    final activeJob = currentJobs.isNotEmpty ? currentJobs.first : null;

    if (activeJob != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF69F0AE),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              size: 10,
                              color: Color(0xFF00A859),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "JOB IS ONGOING",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007A3E),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((activeJob.earnings ?? activeJob.totalAmount) != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "₹${(activeJob.earnings ?? activeJob.totalAmount)?.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    activeJob.serviceName ?? "Ongoing Service",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppTheme.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activeJob.location ?? "Customer Location",
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (activeJob.scheduledTime != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 16, color: Color(0xFFFFA000)),
                        const SizedBox(width: 4),
                        Text(
                          activeJob.scheduledTime!,
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.grey[700]),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleJobTap(activeJob),
                          icon: const Icon(Icons.touch_app_rounded, size: 18),
                          label: const Text(
                            "View Ongoing Job",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(navProvider.notifier).state = 2; // Schedule tab
                          },
                          icon: const Icon(Icons.map_outlined, size: 17),
                          label: const Text(
                            "Schedule",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(
                                color: AppTheme.primaryColor, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Clean, Premium Empty State (no radar sweep, no 15 km text)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: Color(0xFF059669),
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No New Job Requests",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You are active and on duty. New customer requests will appear here automatically.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _refreshJobs();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  "Refresh Feed",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}
