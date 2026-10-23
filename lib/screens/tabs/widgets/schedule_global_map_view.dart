import 'package:flutter/material.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/features/map/screens/advanced_map_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Upgraded interactive overview map for scheduled jobs with theme switching,
/// place search, and rich interactive markers.
class ScheduleGlobalMapView extends StatelessWidget {
  final List<Job> allJobs;
  final VoidCallback onBack;
  final ValueChanged<Job> onJobTap;

  const ScheduleGlobalMapView({
    super.key,
    required this.allJobs,
    required this.onBack,
    required this.onJobTap,
  });

  @override
  Widget build(BuildContext context) {
    final screen = AdvancedMapScreen(
      mode: MapScreenMode.overview,
      jobs: allJobs,
      onJobTap: onJobTap,
      onBack: onBack,
    );

    try {
      ProviderScope.containerOf(context, listen: false);
      return screen;
    } catch (_) {
      return ProviderScope(child: screen);
    }
  }
}
