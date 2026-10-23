import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/features/map/models/route_model.dart';
import 'package:right_touch/features/map/providers/map_theme_provider.dart';
import 'package:right_touch/features/map/services/geocoding_service.dart';
import 'package:right_touch/features/map/services/map_location_service.dart';
import 'package:right_touch/features/map/services/routing_service.dart';
import 'package:right_touch/features/map/widgets/custom_map_marker.dart';
import 'package:right_touch/features/map/widgets/map_controls_overlay.dart';
import 'package:right_touch/features/map/widgets/route_info_bottom_sheet.dart';
import 'package:right_touch/features/map/widgets/search_places_bar.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';

enum MapScreenMode {
  navigation,
  overview,
  explore,
}

class AdvancedMapScreen extends ConsumerStatefulWidget {
  final MapScreenMode mode;
  final LatLng? destination;
  final String? destinationTitle;
  final String? destinationAddress;
  final String? customerPhone;
  final List<Job> jobs;
  final ValueChanged<Job>? onJobTap;
  final VoidCallback? onBack;

  const AdvancedMapScreen({
    super.key,
    this.mode = MapScreenMode.navigation,
    this.destination,
    this.destinationTitle,
    this.destinationAddress,
    this.customerPhone,
    this.jobs = const [],
    this.onJobTap,
    this.onBack,
  });

  @override
  ConsumerState<AdvancedMapScreen> createState() => _AdvancedMapScreenState();
}

class _AdvancedMapScreenState extends ConsumerState<AdvancedMapScreen> {
  final MapController _mapController = MapController();
  final MapLocationService _locationService = MapLocationService();
  final RoutingService _routingService = RoutingService();
  final GeocodingService _geocodingService = GeocodingService();

  LatLng? _userLocation;
  double? _userHeading;
  double? _userAccuracy;
  bool _isTrackingUser = false;
  double _mapRotation = 0.0;

  // Navigation & Routing state
  RouteData? _currentRoute;
  bool _isLoadingRoute = false;
  bool _isNavigating = false;
  bool _isOffRoute = false;
  TravelMode _selectedTravelMode = TravelMode.driving;
  LatLng? _activeDestination;

  // Selected Job (for overview mode)
  Job? _selectedJob;

  // Search Pin
  PlaceSearchResult? _selectedSearchPlace;

  @override
  void initState() {
    super.initState();
    _activeDestination = widget.destination;
    _initLocationAndRoute();
  }

  @override
  void dispose() {
    _locationService.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndRoute() async {
    // 1. Get initial position
    final pos = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (pos != null) {
      setState(() {
        _userLocation = pos;
      });

      // Fit bounds or center
      if (_activeDestination != null) {
        unawaited(_fetchRoute(pos, _activeDestination!));
        _fitBounds(pos, _activeDestination!);
      } else if (widget.jobs.isNotEmpty) {
        _fitJobsBounds();
      } else {
        _mapController.move(pos, 15.0);
      }
    } else {
      // Default fallback location (Chennai centre or destination)
      final center = _activeDestination ?? const LatLng(13.0827, 80.2707);
      _mapController.move(center, 13.0);
      if (_activeDestination != null) {
        // Still calculate route from default center if GPS permission pending
        unawaited(_fetchRoute(center, _activeDestination!));
      }
    }
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    try {
      final bounds = LatLngBounds.fromPoints([p1, p2]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.only(top: 100, bottom: 200, left: 50, right: 50),
        ),
      );
    } catch (_) {}
  }

  void _fitJobsBounds() {
    final points = widget.jobs
        .where((j) => j.latitude != null && j.longitude != null)
        .map((j) => LatLng(j.latitude!, j.longitude!))
        .toList();

    if (_userLocation != null) points.add(_userLocation!);

    if (points.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    }
  }

  Future<void> _fetchRoute(LatLng origin, LatLng dest) async {
    setState(() => _isLoadingRoute = true);
    final route = await _routingService.calculateRoute(
      origin: origin,
      destination: dest,
      mode: _selectedTravelMode,
    );

    if (!mounted) return;
    setState(() {
      _currentRoute = route;
      _isLoadingRoute = false;
      _isOffRoute = false;
    });

    if (route != null && route.points.isNotEmpty) {
      try {
        final bounds = LatLngBounds.fromPoints(route.points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.only(top: 80, bottom: 220, left: 40, right: 40),
          ),
        );
      } catch (_) {}
    }
  }

  void _startLiveNavigation() {
    if (_userLocation == null && _activeDestination == null) return;
    setState(() => _isNavigating = true);
    _isTrackingUser = true;

    _locationService.startLocationUpdates(
      onUpdate: (newPos, heading, accuracy) {
        if (!mounted) return;
        setState(() {
          _userLocation = newPos;
          _userHeading = heading;
          _userAccuracy = accuracy;
        });

        // Auto pan if tracking
        if (_isTrackingUser) {
          _mapController.move(newPos, 16.5);
          if (heading > 0) {
            _mapController.rotate(-heading);
          }
        }

        // Off-route check
        if (_currentRoute != null && _currentRoute!.points.isNotEmpty) {
          final isDiverged = RoutingService.isOffRoute(
            currentLocation: newPos,
            routePoints: _currentRoute!.points,
            thresholdMeters: 60,
          );

          if (isDiverged && !_isOffRoute) {
            setState(() => _isOffRoute = true);
            if (_activeDestination != null) {
              _fetchRoute(newPos, _activeDestination!);
            }
          }
        }
      },
    );
  }

  void _stopLiveNavigation() {
    _locationService.stopLocationUpdates();
    setState(() {
      _isNavigating = false;
      _isTrackingUser = false;
      _isOffRoute = false;
    });
    _mapController.rotate(0);
  }

  void _recalculateRoute() {
    if (_userLocation != null && _activeDestination != null) {
      _fetchRoute(_userLocation!, _activeDestination!);
    }
  }

  void _onTravelModeChanged(TravelMode mode) {
    if (_selectedTravelMode == mode) return;
    setState(() => _selectedTravelMode = mode);
    _recalculateRoute();
  }

  void _recenterOnUser() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() {
        _userLocation = pos;
        _isTrackingUser = true;
      });
      _mapController.move(pos, 16.0);
    } else {
      final state = await _locationService.checkPermissions();
      if (!mounted) return;
      if (state == LocationPermissionState.serviceDisabled) {
        ErrorHandler.showError(context, "Location services are disabled on device");
      } else if (state == LocationPermissionState.permanentlyDenied) {
        ErrorHandler.showError(context, "Location permission permanently denied. Please enable in Settings.");
      } else {
        ErrorHandler.showError(context, "Unable to get current location");
      }
    }
  }

  void _onPlaceSelected(PlaceSearchResult place) {
    setState(() {
      _selectedSearchPlace = place;
    });
    _mapController.move(place.location, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(mapThemeProvider);
    final isNavMode = widget.mode == MapScreenMode.navigation || _activeDestination != null;

    return Scaffold(
      backgroundColor: currentTheme.isDark ? const Color(0xFF1E1E1E) : AppTheme.white,
      body: Stack(
        children: [
          // 1. FlutterMap Core View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _activeDestination ??
                  _userLocation ??
                  const LatLng(13.0827, 80.2707),
              initialZoom: 14.0,
              minZoom: currentTheme.minZoom,
              maxZoom: currentTheme.maxZoom,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture && _isTrackingUser) {
                  setState(() => _isTrackingUser = false);
                }
                if (camera.rotation != _mapRotation) {
                  setState(() => _mapRotation = camera.rotation);
                }
              },
              onLongPress: (_, point) async {
                // Long press to drop pin and reverse geocode
                final result = await _geocodingService.reverseGeocode(point);
                if (mounted && result != null) {
                  _onPlaceSelected(result);
                }
              },
            ),
            children: [
              // Tile Layer from Theme
              TileLayer(
                urlTemplate: currentTheme.urlTemplate,
                subdomains: currentTheme.subdomains,
                userAgentPackageName: 'com.righttouch.technician',
              ),

              // Destination Geofence Arrival Radius (100m)
              if (_activeDestination != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _activeDestination!,
                      radius: 50,
                      useRadiusInMeter: true,
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // Route Polyline Layer
              if (_currentRoute != null && _currentRoute!.points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Outer outline casing
                    Polyline(
                      points: _currentRoute!.points,
                      color: const Color(0xFF1565C0),
                      strokeWidth: 6.5,
                    ),
                    // Inner glowing path
                    Polyline(
                      points: _currentRoute!.points,
                      color: const Color(0xFF42A5F5),
                      strokeWidth: 4.5,
                    ),
                  ],
                ),

              // Markers Layer
              MarkerLayer(
                markers: [
                  // User Location Beacon Marker
                  if (_userLocation != null)
                    UserLocationBeaconMarker.create(
                      position: _userLocation!,
                      heading: _userHeading,
                      accuracy: _userAccuracy,
                    ),

                  // Destination Job Pin
                  if (_activeDestination != null)
                    JobPinMarker.create(
                      position: _activeDestination!,
                      title: "Destination",
                      subtitle: widget.destinationAddress,
                      isSelected: true,
                    ),

                  // Multi-Job Markers (Overview Mode)
                  ...widget.jobs
                      .where((j) => j.latitude != null && j.longitude != null)
                      .map((job) {
                    final isSel = _selectedJob?.id == job.id;
                    return JobPinMarker.create(
                      position: LatLng(job.latitude!, job.longitude!),
                      title: job.title,
                      price: job.technicianAmount ?? job.basePrice ?? job.earnings,
                      isSelected: isSel,
                      onTap: () {
                        setState(() {
                          _selectedJob = job;
                          _activeDestination = LatLng(job.latitude!, job.longitude!);
                        });
                        if (_userLocation != null) {
                          _fetchRoute(_userLocation!, _activeDestination!);
                        }
                        widget.onJobTap?.call(job);
                      },
                    );
                  }),

                  // Search Result Dropped Pin
                  if (_selectedSearchPlace != null)
                    Marker(
                      point: _selectedSearchPlace!.location,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.place,
                        size: 46,
                        color: Color(0xFFFF6D00),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. Top Controls / Search Bar
          SafeArea(
            child: SearchPlacesBar(
              onBack: widget.onBack ?? (Navigator.canPop(context) ? () => Navigator.pop(context) : null),
              hintText: isNavMode ? "Search places..." : "Search jobs or address...",
              onPlaceSelected: _onPlaceSelected,
            ),
          ),

          // 3. Floating Right-Side Controls
          Positioned(
            right: 16,
            bottom: isNavMode ? 230 : 40,
            child: MapControlsOverlay(
              onZoomIn: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                );
              },
              onZoomOut: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                );
              },
              onRecenter: _recenterOnUser,
              onResetCompass: () => _mapController.rotate(0),
              currentRotation: _mapRotation,
              isTrackingUser: _isTrackingUser,
              currentTravelMode: isNavMode ? _selectedTravelMode : null,
              onTravelModeChanged: _onTravelModeChanged,
            ),
          ),

          // 4. Navigation & Route Info Bottom Sheet
          if (isNavMode && _activeDestination != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RouteInfoBottomSheet(
                routeData: _currentRoute,
                isNavigating: _isNavigating,
                isLoadingRoute: _isLoadingRoute,
                isOffRoute: _isOffRoute,
                destinationTitle: widget.destinationTitle ?? _selectedJob?.title ?? "Service Location",
                destinationAddress: widget.destinationAddress ?? _selectedJob?.location,
                customerPhone: widget.customerPhone ?? _selectedJob?.customerPhone,
                onStartNavigation: _startLiveNavigation,
                onStopNavigation: _stopLiveNavigation,
                onRecalculateRoute: _recalculateRoute,
              ),
            ),
        ],
      ),
    );
  }
}
