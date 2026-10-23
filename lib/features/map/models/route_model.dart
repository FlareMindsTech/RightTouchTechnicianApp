import 'package:latlong2/latlong.dart';

enum TravelMode {
  driving,
  cycling,
  walking;

  String get osrmProfile {
    switch (this) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.cycling:
        return 'bike'; // or cycling depending on server
      case TravelMode.walking:
        return 'foot';
    }
  }

  String get label {
    switch (this) {
      case TravelMode.driving:
        return 'Drive';
      case TravelMode.cycling:
        return 'Ride';
      case TravelMode.walking:
        return 'Walk';
    }
  }
}

class RouteStep {
  final String instruction;
  final double distanceMeters;
  final double durationSeconds;
  final String streetName;
  final LatLng location;
  final String? modifier; // left, right, straight, etc.
  final String? type; // turn, depart, arrive

  const RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.streetName,
    required this.location,
    this.modifier,
    this.type,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final locationRaw = maneuver['location'] as List<dynamic>? ?? [0.0, 0.0];
    final lng = (locationRaw[0] as num).toDouble();
    final lat = (locationRaw[1] as num).toDouble();

    final stepType = maneuver['type']?.toString();
    final modifier = maneuver['modifier']?.toString();
    final street = json['name']?.toString() ?? '';

    String instruction = maneuver['instruction']?.toString() ?? '';
    if (instruction.isEmpty) {
      if (stepType == 'depart') {
        instruction = street.isNotEmpty ? 'Head on $street' : 'Depart';
      } else if (stepType == 'arrive') {
        instruction = 'Arrive at destination';
      } else if (modifier != null) {
        instruction = 'Turn $modifier${street.isNotEmpty ? ' onto $street' : ''}';
      } else {
        instruction = street.isNotEmpty ? 'Continue on $street' : 'Continue';
      }
    }

    return RouteStep(
      instruction: instruction,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (json['duration'] as num?)?.toDouble() ?? 0.0,
      streetName: street,
      location: LatLng(lat, lng),
      modifier: modifier,
      type: stepType,
    );
  }
}

class RouteData {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final TravelMode travelMode;
  final List<RouteStep> steps;

  const RouteData({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.travelMode,
    this.steps = const [],
  });

  String get distanceFormatted {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toStringAsFixed(0)} m';
  }

  String get durationFormatted {
    final mins = (durationSeconds / 60).round();
    if (mins >= 60) {
      final hours = mins ~/ 60;
      final remainingMins = mins % 60;
      return remainingMins > 0 ? '${hours}h ${remainingMins}m' : '${hours}h';
    }
    return '${mins < 1 ? 1 : mins} min';
  }
}
