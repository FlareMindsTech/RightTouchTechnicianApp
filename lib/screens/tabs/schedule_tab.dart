import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/data/models/task_model.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/providers/nav_provider.dart';
import 'package:right_touch/providers/socket_state_provider.dart';
import 'package:right_touch/screens/tabs/widgets/schedule_global_map_view.dart';
import 'package:right_touch/services/network_service.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/empty_state.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/widgets/fade_in_slide.dart';
import 'package:right_touch/widgets/job_card.dart';
import 'package:right_touch/widgets/list_shimmer.dart';
import 'package:right_touch/widgets/service_detail_view.dart';

class ScheduleTab extends ConsumerStatefulWidget {
  const ScheduleTab({super.key});

  @override
  ConsumerState<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends ConsumerState<ScheduleTab> {
  bool _showMap = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
    NetworkService().isConnected.addListener(_onNetworkBack);
  }

  void _onNetworkBack() {
    if (NetworkService().isConnected.value) {
      _refreshAll();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    NetworkService().isConnected.removeListener(_onNetworkBack);
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        ref.invalidate(currentJobsProvider);
      }
    });
  }

  Future<void> _refreshAll() async {
    ref.invalidate(currentJobsProvider);
    ref.invalidate(historyJobsProvider);
    ref.invalidate(dashboardDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentJobsAsync = ref.watch(currentJobsProvider);
    final historyJobsAsync = ref.watch(historyJobsProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Schedule",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showMap ? Icons.list : Icons.map_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () => setState(() => _showMap = !_showMap),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(navProvider.notifier).state =
                            1; // New Jobs tab
                      },
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.grey[200] ?? const Color(0xFFEEEEEE)),
                            ),

                            child: const Icon(Icons.notifications_outlined,
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
              ],
            ),
          ),
          if (!_showMap)
            const TabBar(
              isScrollable: false,
              labelColor: AppTheme.black,
              unselectedLabelColor: AppTheme.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                Tab(text: "Pending"),
                Tab(text: "Completed"),
              ],
            ),
          Expanded(
            child: _showMap
                ? currentJobsAsync.when(
                    loading: () => const ListShimmer(),
                    error: (err, stack) => ErrorBoundary(
                      message: ErrorHandler.parseError(err),
                      showTitle: false, // Removed as per request
                      isElevated: true,
                      onRetry: _refreshAll,
                      onLoginAgain: () =>
                          ref.read(authProvider.notifier).logout(),
                    ),
                    data: (jobs) => _buildGlobalMap(jobs),
                  )
                : TabBarView(
                    children: [
                      _buildSyncJobList(currentJobsAsync, [
                        'pending',
                        'accepted',
                        'assigned',
                        'upcoming',
                        'in_progress',
                      ]),
                      _buildSyncJobList(
                          historyJobsAsync,
                          [
                            'completed',
                            'cancelled',
                            'rejected',
                          ],
                          isCompleted: true),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncJobList(
    AsyncValue<List<Job>> jobsAsync,
    List<String> statuses, {
    bool isCompleted = false,
  }) {
    return jobsAsync.when(
      loading: () => const ListShimmer(),
      error: (err, stack) => ErrorBoundary(
        message: ErrorHandler.parseError(err),
        showTitle: false, // Removed as per request
        isElevated: true,
        onRetry: _refreshAll,
        onLoginAgain: () => ref.read(authProvider.notifier).logout(),
      ),
      data: (allJobs) {
        final jobs = allJobs
            .where((j) => statuses.contains(j.status.toLowerCase()))
            .toList();
        return _buildScheduleList(jobs, isCompleted: isCompleted);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: title,
      subtitle: subtitle,
      onRetry: _refreshAll,
    );
  }

  Widget _buildScheduleList(List<Job> jobs, {bool isCompleted = false}) {
    if (jobs.isEmpty) {
      return _buildEmptyState(
        "No Jobs Found",
        "Start working to see jobs here",
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: jobs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Showing ${jobs.length} items",
                style: const TextStyle(color: AppTheme.grey, fontSize: 12),
              ),
            );
          }
          final job = jobs[index - 1];
          return FadeInSlide(
            index: index - 1,
            child: JobCard(
              job: job,
              onTap: isCompleted ? null : () => _navigateToServiceDetail(job),
              isClickable: !isCompleted,
              showCallButton:
                  !isCompleted, // Only show call button in Pending tab
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToServiceDetail(Job job) async {
    // Use real API data, with sensible fallbacks
    final faultReasons = job.faultReasonsList;
    final faultReason = (faultReasons != null && faultReasons.isNotEmpty)
        ? faultReasons.join('\n• ')
        : (job.description.isNotEmpty
            ? job.description
            : "Reported issue needs investigation");

    final tools = job.toolsEquipments;
    final toolsRequired = (tools != null && tools.isNotEmpty)
        ? tools
        : ["Standard Tool Kit", "Safety Equipment", "Cleaning Solution"];

    final methods = job.rectifyMethod;
    final rectifySteps = (methods != null && methods.isNotEmpty)
        ? methods
        : [
            "Initial assessment and diagnostics",
            "Clean filter and internal components",
            "Check for leaks or loose connections",
            "Final testing and performance validation",
          ];

    final checklist = job.serviceChecklist;
    final checklistItems = (checklist != null && checklist.isNotEmpty)
        ? checklist
        : [
            "Safety check completed",
            "Tools collected and cleaned",
            "Service area cleaned",
            "Customer updated on repair status",
          ];


    final task = TaskModel(
      jobId: job.id,
      location: job.location,
      faultReason: faultReason,
      toolsRequired: toolsRequired,
      rectifySteps: rectifySteps,
      checklistItems: checklistItems,
      timeSpent: Duration.zero,
      customerId: job.customerId,
      locationType: job.locationType,
      latitude: job.latitude,
      longitude: job.longitude,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Technician View"),
            backgroundColor: AppTheme.white,
            foregroundColor: AppTheme.black,
            elevation: 0,
          ),
          body: ServiceDetailView(task: task),
        ),
      ),
    );

    if (result == true) {
      // Job was completed successfully
      if (mounted) {
        unawaited(_refreshAll());
      }
    }
  }

  Widget _buildGlobalMap(List<Job> allJobs) {
    return ScheduleGlobalMapView(
      allJobs: allJobs,
      onBack: () => setState(() => _showMap = false),
      onJobTap: _navigateToServiceDetail,
    );
  }
}
