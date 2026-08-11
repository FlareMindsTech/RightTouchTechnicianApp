import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:right_touch/config/api_config.dart';

class JobMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;

  const JobMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
  });

  @override
  State<JobMapScreen> createState() => _JobMapScreenState();
}

class _JobMapScreenState extends State<JobMapScreen> {
  List<LatLng> _routePoints = [];
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  bool _isNavigating = false;

  double? _distance; // in meters
  double? _duration; // in seconds
  StreamSubscription<Position>? _positionStream;

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startNavigation() async {
    setState(() => _isNavigating = true);

    try {
      // 1. Get current location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar("Location permission denied");
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // 2. Fetch route from OSRM
      await _fetchRoute(
        _currentLocation!,
        LatLng(widget.latitude, widget.longitude),
      );

      // 3. Fit bounds
      if (_routePoints.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      }

      // 4. Start listening to location updates
      _startLocationUpdates();
    } catch (e) {
      _showSnackBar("Error starting navigation: $e");
    } finally {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    }
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((
      Position position,
    ) {
      if (!mounted) return;

      final newLocation = LatLng(position.latitude, position.longitude);
      // final destLocation = LatLng(widget.latitude, widget.longitude); // Unused

      // Calculate straight line distance (or simple geodesic)
      // For more accurate road distance, we would need to ping OSRM again,
      // but that might be customizable. For "shorter distance" feedback,
      // simple calculation or just subtracting moved distance might work,
      // but re-calculating from OSRM periodically is better.
      // Let's just do straight line distance for immediate feedback or
      // re-trigger OSRM if distance is significant.

      // Efficient approach: Calculate distance using Geolocator
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.latitude,
        widget.longitude,
      );

      setState(() {
        _currentLocation = newLocation;
        // Update distance with the direct distance (approximation for remaining travel)
        // OR subtract distance traveled.
        // Direct distance is 'as the crow flies' which is usually shorter than driving.
        // Better: periodic OSRM update or just use the geolocator distance for "proximity"
        _distance = distanceInMeters;

        // Approximate time: 30km/h avg speed (8.33 m/s) in city?
        _duration = distanceInMeters / 8.33;
      });
    });
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        final double dist = data['routes'][0]['distance'].toDouble(); // meters
        final double dur = data['routes'][0]['duration'].toDouble(); // seconds

        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
          _distance = dist;
          _duration = dur;
        });
      }
    } catch (e) {
      debugPrint("Error fetching OSRM route: $e");
      _showSnackBar("Failed to fetch route");
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ErrorHandler.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.latitude, widget.longitude),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=${ApiConfig.mapTilerKey}',
                userAgentPackageName: 'com.righttouch.technician',
              ),
              PolylineLayer(
                polylines: [
                  if (_routePoints.isNotEmpty)
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Destination Marker
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude),
                    width: 80,
                    height: 80,
                    child: const Column(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppTheme.primaryColor,
                          size: 40,
                        ),
                        Text(
                          "Job",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // Current Location Marker
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 60,
                      height: 60,
                      child: const Column(
                        children: [
                          Icon(Icons.my_location, color: Colors.blue, size: 30),
                          Text(
                            "You",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (_distance != null && _duration != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.directions_car, color: Colors.blue),
                          const SizedBox(height: 4),
                          Text(
                            "${(_duration! / 60).toStringAsFixed(0)} min",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.straighten, color: Colors.orange),
                          const SizedBox(height: 4),
                          Text(
                            "${(_distance! / 1000).toStringAsFixed(1)} km",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Custom Back Button in the map
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isNavigating ? null : _startNavigation,
        label: Text(_isNavigating ? "Locating..." : "Start Navigation"),
        icon: _isNavigating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.navigation),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
