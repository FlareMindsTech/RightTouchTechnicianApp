import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/features/map/screens/advanced_map_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Upgraded production-ready Job Map Screen with OSRM turn-by-turn navigation,
/// live GPS tracking, off-route detection, multiple map themes, and place search.
class JobMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String title;
  final Job? job;

  const JobMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.job,
  });

  @override
  Widget build(BuildContext context) {
    final screen = AdvancedMapScreen(
      mode: MapScreenMode.navigation,
      destination: LatLng(latitude, longitude),
      destinationTitle: title,
      destinationAddress: job?.location,
      customerPhone: job?.customerPhone,
      onBack: () => Navigator.pop(context),
    );

    try {
      ProviderScope.containerOf(context, listen: false);
      return screen;
    } catch (_) {
      return ProviderScope(child: screen);
    }
  }
}
