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

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    // Auto refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
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
    return ref.read(broadcastJobsProvider.notifier).refresh();
  }

  Future<void> _handleJobTap(Job job) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
    );

    if (result == true) {
      // Refresh after job completion or acceptance
      unawaited(_refreshJobs());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final broadcastJobs = ref.watch(broadcastJobsProvider);

    ref.listen(socketStateProvider, (previous, next) {
      if (next.hasNewJob && !(previous?.hasNewJob ?? false)) {
        HapticFeedback.vibrate();
        _refreshJobs();
      }
      if (next.liveJobs.length < (previous?.liveJobs.length ?? 0)) {
        _refreshJobs();
      }
    });

    return RefreshIndicator(
      onRefresh: _refreshJobs,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
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
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              height: 140,
              child: Container(
                color: AppTheme.white,
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Right Touch",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.black,
                              letterSpacing: 0.5,
                            ),
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
                                  decoration: BoxDecoration(
                                    color: AppTheme.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.notifications_outlined,
                                      size: 24),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: broadcastJobs.when(
                        data: (jobs) => Text(
                          "${jobs.length} ${jobs.length == 1 ? 'new job' : 'new jobs'}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const Text(
                          "Loading jobs...",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        error: (error, stack) => const SizedBox.shrink(),
                      ),
                    ),
                    if (ref.watch(socketStateProvider).isConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Live Feed',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
              child: SizedBox(height: 500, child: ListShimmer()),
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
    );
  }

  Widget _buildEmptyPendingState(WidgetRef ref) {
    final currentJobs = ref.watch(currentJobsProvider).asData?.value ?? [];
    final activeJob = currentJobs.isNotEmpty ? currentJobs.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          if (activeJob != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
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
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF00A859),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Job Accepted & Scheduled!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007A3E),
                              ),
                            ),
                            Text(
                              "You have an active job in your schedule",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5A655A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                      height: 24, thickness: 1, color: Color(0xFFEEEEEE)),
                  Text(
                    activeJob.title.isNotEmpty ? activeJob.title : "Service Job",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activeJob.location.isNotEmpty
                              ? activeJob.location
                              : "Customer Location",
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (activeJob.scheduledTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 15, color: Color(0xFFFFA000)),
                        const SizedBox(width: 4),
                        Text(
                          activeJob.scheduledTime!,
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.grey[700]),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(navProvider.notifier).state = 2;
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: const Text(
                        "View in Schedule",
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
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE8F5E9),
                    border: Border.all(
                      color: const Color(0xFF69F0AE).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.radar_rounded,
                      size: 38,
                      color: Color(0xFF00A859),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Scanning for Nearby Jobs",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activeJob != null
                      ? "Your active job is safe in Schedule. Keep this screen ready for additional requests."
                      : "You're on duty! You'll receive instant sound & vibration alerts when a new job is broadcast near you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _refreshJobs,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Refresh Radar"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
