import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/data/models/job.dart';

import 'package:right_touch/data/repositories/job_repository.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/providers/dashboard_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/features/map/providers/map_theme_provider.dart';
import 'package:right_touch/utils/app_theme.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  bool _isLoading = false;

  Future<void> _respondToJob(String status) async {
    setState(() => _isLoading = true);

    try {
      final result =
          await ref.read(jobRepositoryProvider).respondToJob(widget.job.id, status);


      if (result['success'] == true) {
        if (mounted) {
          if (status == 'accepted') {
            ref.invalidate(currentJobsProvider);
            ref.invalidate(dashboardDataProvider);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'accepted'
                    ? 'Job accepted! Check "Pending" in Schedule tab.'
                    : 'Job $status successfully',
              ),
              backgroundColor:
                  status == 'accepted' ? AppTheme.green : AppTheme.orange,
            ),
          );
          Navigator.pop(context, true); // Return result to refresh list
        }
      } else {
        if (mounted) {
          ErrorHandler.showError(
            context,
            result['message'] ?? 'Failed to update job',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint("Could not launch phone call: $e");
    }
  }

  Future<void> _openMap() async {
    // ALWAYS use Flutter map - never external Google Maps
    double lat =
        widget.job.latitude ?? 13.0827; // Default to Chennai if no coordinates
    double lng = widget.job.longitude ?? 80.2707;

    unawaited(context.push(
      '/job-map',
      extra: {
        'latitude': lat,
        'longitude': lng,
        'title': widget.job.location.isNotEmpty
            ? widget.job.location
            : widget.job.title,
        'job': widget.job,
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Safety 1: Simple date handling
    String timeDisplay = widget.job.scheduledTime ?? "TBD";

    // Safety 2: Default location text
    String locationText = widget.job.location.isNotEmpty
        ? widget.job.location
        : "No Address Provided";
    final double lat = widget.job.latitude ?? 13.0827;
    final double lng = widget.job.longitude ?? 80.2707;
    final mapTheme = ref.watch(mapThemeProvider);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text("Job Details", style: TextStyle(color: AppTheme.black)),
        backgroundColor: AppTheme.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppTheme.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Header
          Text(
            widget.job.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppTheme.grey),
              const SizedBox(width: 4),
              Text(
                timeDisplay,
                style: const TextStyle(color: AppTheme.grey, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Earnings (Safe check)
          if (widget.job.technicianAmount != null ||
              widget.job.earnings != null ||
              widget.job.basePrice != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.green.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Estimated Earnings",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "₹${(widget.job.technicianAmount ?? widget.job.basePrice ?? widget.job.earnings ?? 0.0).toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.green,
                    ),
                  ),
                ],
              ),
            ),

          // 3. Location
          const Text(
            "Location",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Location Map Preview (FlutterMap)
          GestureDetector(
            onTap: _openMap,
            child: Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(lat, lng),
                        initialZoom: 14.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: mapTheme.urlTemplate,
                          subdomains: mapTheme.subdomains,
                          userAgentPackageName: 'com.righttouch.technician',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(lat, lng),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: AppTheme.primaryColor,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions,
                              color: AppTheme.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Get Directions",
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppTheme.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationText,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Customer (Only if exists)
          if (widget.job.customerName != null ||
              widget.job.customerPhone != null) ...[
            const Text(
              "Customer Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppTheme.blue.shade50,
                child: const Icon(Icons.person, color: AppTheme.blue),
              ),
              title: Text(widget.job.customerName ?? "No Name Provided"),
              subtitle: Text(widget.job.customerPhone ?? "No Phone"),
              trailing: widget.job.customerPhone != null
                  ? IconButton(
                      icon: const Icon(Icons.phone, color: AppTheme.green),
                      onPressed: () =>
                          _makePhoneCall(widget.job.customerPhone!),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
          ],

          // 5. Actions
          if (_isLoading)
            const Center(child: RtLoader())
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respondToJob('rejected'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.red),
                    ),
                    child: const Text(
                      "Decline",
                      style: TextStyle(color: AppTheme.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToJob('accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green, // Hardcoded green
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Accept Job",
                      style: TextStyle(color: AppTheme.white),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
