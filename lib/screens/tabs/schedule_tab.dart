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
        ref.invalidate(scheduledJobsProvider);
      }
    });
  }

  Future<void> _refreshAll() async {
    ref.invalidate(currentJobsProvider);
    ref.invalidate(scheduledJobsProvider);
    ref.invalidate(historyJobsProvider);
    ref.invalidate(dashboardDataProvider);
  }

  String _formatScheduledDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jobDay = DateTime(dt.year, dt.month, dt.day);
    final diffDays = jobDay.difference(today).inDays;

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthName = months[dt.month - 1];

    if (diffDays == 0) {
      return "Today • ${dt.day} $monthName";
    } else if (diffDays == 1) {
      return "Tomorrow • ${dt.day} $monthName";
    } else if (diffDays == -1) {
      return "Yesterday • ${dt.day} $monthName";
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final weekdayName = weekdays[dt.weekday - 1];
      return "$weekdayName, ${dt.day} $monthName ${dt.year}";
    }
  }

  String _formatSlotTime(Job job) {
    if (job.scheduledTime != null && job.scheduledTime!.isNotEmpty) {
      return job.scheduledTime!;
    }
    if (job.scheduledAt != null && job.scheduledAt!.isNotEmpty) {
      final dt = DateTime.tryParse(job.scheduledAt!);
      if (dt != null) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        return "$hour:$minute $period";
      }
    }
    return "Slot Time Not Set";
  }

  @override
  Widget build(BuildContext context) {
    final currentJobsAsync = ref.watch(currentJobsProvider);
    final scheduledJobsAsync = ref.watch(scheduledJobsProvider);
    final historyJobsAsync = ref.watch(historyJobsProvider);

    return DefaultTabController(
      length: 3,
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
                              border: Border.all(
                                color: AppTheme.grey[200] ??
                                    const Color(0xFFEEEEEE),
                              ),
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
                Tab(text: "Scheduled"),
                Tab(text: "Completed"),
              ],
            ),
          Expanded(
            child: _showMap
                ? currentJobsAsync.when(
                    loading: () => const ListShimmer(),
                    error: (err, stack) => ErrorBoundary(
                      message: ErrorHandler.parseError(err),
                      showTitle: false,
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
                      scheduledJobsAsync.when(
                        loading: () => const ListShimmer(),
                        error: (err, stack) => ErrorBoundary(
                          message: ErrorHandler.parseError(err),
                          showTitle: false,
                          isElevated: true,
                          onRetry: _refreshAll,
                          onLoginAgain: () =>
                              ref.read(authProvider.notifier).logout(),
                        ),
                        data: (jobs) => _buildScheduledJobList(jobs),
                      ),
                      _buildSyncJobList(
                        historyJobsAsync,
                        [
                          'completed',
                          'cancelled',
                          'rejected',
                        ],
                        isCompleted: true,
                      ),
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
        showTitle: false,
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
              showCallButton: !isCompleted,
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduledJobList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return _buildEmptyState(
        "No Scheduled Bookings",
        "Accepted upcoming appointments with scheduled slots will appear here.",
      );
    }

    // Sort scheduled jobs by scheduledAt ascending (earliest first)
    final sortedJobs = List<Job>.from(jobs);
    sortedJobs.sort((a, b) {
      final dtA = DateTime.tryParse(a.scheduledAt ?? '') ?? a.createdAt;
      final dtB = DateTime.tryParse(b.scheduledAt ?? '') ?? b.createdAt;
      return dtA.compareTo(dtB);
    });

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: sortedJobs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Showing ${sortedJobs.length} scheduled ${sortedJobs.length == 1 ? 'job' : 'jobs'}",
                    style: const TextStyle(color: AppTheme.grey, fontSize: 12),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            size: 12, color: AppTheme.primaryColor),
                        SizedBox(width: 4),
                        Text(
                          "Confirmed Slots",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final job = sortedJobs[index - 1];
          final scheduledDt =
              DateTime.tryParse(job.scheduledAt ?? '') ?? job.createdAt;
          final dateHeader = _formatScheduledDate(scheduledDt);
          final slotLabel = _formatSlotTime(job);

          return FadeInSlide(
            index: index - 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slot Time Header badge above card
                Container(
                  margin: const EdgeInsets.only(left: 4, bottom: 4, top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        "$dateHeader • $slotLabel",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                JobCard(
                  job: job,
                  onTap: () => _navigateToServiceDetail(job),
                  isClickable: true,
                  showCallButton: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToServiceDetail(Job job) async {
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
