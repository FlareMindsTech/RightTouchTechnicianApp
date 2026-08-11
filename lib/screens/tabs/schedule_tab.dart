import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
import 'package:right_touch/models/job.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/list_shimmer.dart';
import 'package:right_touch/providers/nav_provider.dart'; // Added as per snippet
import 'package:right_touch/config/api_config.dart';
import 'package:right_touch/widgets/empty_state.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/models/task_model.dart';
import 'package:right_touch/widgets/service_detail_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/widgets/fade_in_slide.dart';
import 'package:right_touch/widgets/job_card.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:right_touch/services/network_service.dart';
import 'package:right_touch/providers/socket_state_provider.dart';
import 'package:right_touch/widgets/error_boundary.dart';

class ScheduleTab extends ConsumerStatefulWidget {
  const ScheduleTab({super.key});

  @override
  ConsumerState<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends ConsumerState<ScheduleTab> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  bool _showMap = false;
  bool _isSearching = false;
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
    _searchController.dispose();
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

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.righttouch.technician'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);

          _mapController.move(LatLng(lat, lon), 15.0);
        } else {
          if (mounted) {
            ErrorHandler.showError(context, 'Location not found');
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching location: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
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
                                  color: Colors.orange,
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
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
    final faultReason = (job.faultReasonsList != null && job.faultReasonsList!.isNotEmpty)
        ? job.faultReasonsList!.join('\n• ')
        : (job.description.isNotEmpty
            ? job.description
            : "Reported issue needs investigation");

    final toolsRequired = (job.toolsEquipments != null && job.toolsEquipments!.isNotEmpty)
        ? job.toolsEquipments!
        : ["Standard Tool Kit", "Safety Equipment", "Cleaning Solution"];

    final rectifySteps = (job.rectifyMethod != null && job.rectifyMethod!.isNotEmpty)
        ? job.rectifyMethod!
        : [
            "Initial assessment and diagnostics",
            "Clean filter and internal components",
            "Check for leaks or loose connections",
            "Final testing and performance validation",
          ];

    final checklistItems = (job.serviceChecklist != null && job.serviceChecklist!.isNotEmpty)
        ? job.serviceChecklist!
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
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: ServiceDetailView(task: task),
        ),
      ),
    );

    if (result == true) {
      // Job was completed successfully
      if (mounted) {
        _refreshAll();
      }
    }
  }

  Widget _buildGlobalMap(List<Job> allJobs) {
    final jobsWithCoords = allJobs
        .where((j) => j.latitude != null && j.longitude != null)
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: jobsWithCoords.isNotEmpty
                ? LatLng(
                    jobsWithCoords.first.latitude!,
                    jobsWithCoords.first.longitude!,
                  )
                : const LatLng(13.0827, 80.2707),
            initialZoom: 12.0,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=${ApiConfig.mapTilerKey}',
              userAgentPackageName: 'com.righttouch.technician',
            ),
            MarkerLayer(
              markers: jobsWithCoords.map((job) {
                return Marker(
                  point: LatLng(job.latitude!, job.longitude!),
                  width: 100,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _navigateToServiceDetail(job),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(color: AppTheme.primaryColor),
                          ),
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.location_on,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Search Bar
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => setState(() => _showMap = false),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Search Input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _searchLocation,
                    decoration: InputDecoration(
                      hintText: "Search location...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      suffixIcon: _isSearching
                          ? const UnconstrainedBox(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  _searchLocation(_searchController.text),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
