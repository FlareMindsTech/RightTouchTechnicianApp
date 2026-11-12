import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/features/map/models/route_model.dart';
import 'package:right_touch/features/map/models/map_theme.dart';
import 'package:right_touch/features/map/providers/map_theme_provider.dart';
import 'package:right_touch/features/map/services/cached_tile_provider.dart';
import 'package:right_touch/features/map/services/geocoding_service.dart';
import 'package:right_touch/features/map/services/map_location_service.dart';
import 'package:right_touch/features/map/services/routing_service.dart';
import 'package:right_touch/features/map/widgets/custom_map_marker.dart';
import 'package:right_touch/features/map/widgets/job_preview_card.dart';
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
  double _currentSpeedKmh = 0.0;
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
  int _selectedFilterIndex = 0; // 0: All, 1: Today, 2: Upcoming
  bool _arrivalDismissed = false;

  List<Job> get _filteredJobs {
    if (_selectedFilterIndex == 1) {
      final now = DateTime.now();
      return widget.jobs.where((j) {
        if (j.scheduledAt != null) {
          final dt = DateTime.tryParse(j.scheduledAt!);
          if (dt != null) {
            return dt.year == now.year &&
                dt.month == now.month &&
                dt.day == now.day;
          }
        }
        return true;
      }).toList();
    } else if (_selectedFilterIndex == 2) {
      final now = DateTime.now();
      return widget.jobs.where((j) {
        if (j.scheduledAt != null) {
          final dt = DateTime.tryParse(j.scheduledAt!);
          if (dt != null) {
            return dt.isAfter(DateTime(now.year, now.month, now.day, 23, 59));
          }
        }
        return false;
      }).toList();
    }
    return widget.jobs;
  }

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

    // 2. Start continuous high-accuracy location tracking
    _startContinuousLocationUpdates();
  }

  void _startContinuousLocationUpdates() {
    _locationService.startLocationUpdates(
      onUpdate: (newPos, heading, accuracy, speedKmh) {
        if (!mounted) return;
        final wasInitial = _userLocation == null;
        setState(() {
          _userLocation = newPos;
          _userHeading = heading;
          _userAccuracy = accuracy;
          _currentSpeedKmh = speedKmh;
        });

        // Auto-snap to real GPS if opened on fallback
        if (wasInitial && _activeDestination == null && widget.jobs.isEmpty) {
          _mapController.move(newPos, 16.0);
        }

        // Auto pan if tracking
        if (_isTrackingUser) {
          _mapController.move(newPos, _isNavigating ? 17.0 : 16.0);
          if (heading > 0 && _isNavigating) {
            _mapController.rotate(-heading);
          }
        }

        // Off-route check during navigation
        if (_isNavigating && _currentRoute != null && _currentRoute!.points.isNotEmpty) {
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
    setState(() {
      _isNavigating = true;
      _isTrackingUser = true;
      _arrivalDismissed = false;
    });
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 17.0);
    }
  }

  void _stopLiveNavigation() {
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
              initialZoom: 16.0,
              minZoom: currentTheme.minZoom,
              maxZoom: currentTheme.maxZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
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
              // High-Reliability Persistent Cached Tile Layer
              TileLayer(
                urlTemplate: currentTheme.urlTemplate,
                subdomains: currentTheme.subdomains,
                userAgentPackageName: 'com.righttouch.technician',
                tileProvider: CachedTileProvider.instance,
                zoomOffset: currentTheme.zoomOffset,
                minZoom: currentTheme.minZoom,
                maxZoom: currentTheme.maxZoom,
                keepBuffer: 4,
                panBuffer: 2,
                evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
              ),

              // User GPS Accuracy Circle (Google Maps style)
              if (_userLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _userLocation!,
                      radius: (_userAccuracy ?? 25.0).clamp(10.0, 50.0),
                      useRadiusInMeter: true,
                      color: const Color(0x1A1E88E5),
                      borderColor: const Color(0x4D1E88E5),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
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

              // Route Polyline Layer with Theme-Adaptive Contrast
              if (_currentRoute != null && _currentRoute!.points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Outer outline casing
                    Polyline(
                      points: _currentRoute!.points,
                      color: currentTheme.type == MapThemeType.satellite
                          ? Colors.black87
                          : const Color(0xFF1565C0),
                      strokeWidth: currentTheme.type == MapThemeType.satellite ? 7.5 : 6.5,
                    ),
                    // Inner glowing path
                    Polyline(
                      points: _currentRoute!.points,
                      color: currentTheme.type == MapThemeType.satellite
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF42A5F5),
                      strokeWidth: currentTheme.type == MapThemeType.satellite ? 5.0 : 4.5,
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
                  ..._filteredJobs
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
                        _mapController.move(LatLng(job.latitude!, job.longitude!), 16.5);
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

          // 2. Top Controls / Search Bar, Filter Chips or Navigation HUD / Arrival Alert
          if (_isNavigating) ...[
            if (_userLocation != null &&
                _activeDestination != null &&
                !_arrivalDismissed &&
                const Distance().as(
                        LengthUnit.Meter, _userLocation!, _activeDestination!) <=
                    50)
              _buildArrivalBanner()
            else
              _buildTopNavigationHUD()
          ] else
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchPlacesBar(
                    onBack: widget.onBack ??
                        (Navigator.canPop(context)
                            ? () => Navigator.pop(context)
                            : null),
                    hintText: isNavMode
                        ? "Search places..."
                        : "Search jobs or address...",
                    onPlaceSelected: _onPlaceSelected,
                  ),
                  if (!isNavMode && widget.jobs.isNotEmpty)
                    _buildFilterChips(),
                ],
              ),
            ),

          // 3. Floating Right-Side Controls
          Positioned(
            right: 16,
            bottom: isNavMode
                ? 230
                : (_selectedJob != null ? 190 : 40),
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
                destinationTitle: widget.destinationTitle ??
                    _selectedJob?.title ??
                    "Service Location",
                destinationAddress:
                    widget.destinationAddress ?? _selectedJob?.location,
                customerPhone:
                    widget.customerPhone ?? _selectedJob?.customerPhone,
                destinationCoordinates: _activeDestination,
                onStartNavigation: _startLiveNavigation,
                onStopNavigation: _stopLiveNavigation,
                onRecalculateRoute: _recalculateRoute,
              ),
            ),

          // 5. Floating Job Preview Card (Overview Mode)
          if (!isNavMode && _selectedJob != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: JobPreviewCard(
                job: _selectedJob!,
                onNavigate: () {
                  final jobLat = _selectedJob!.latitude;
                  final jobLng = _selectedJob!.longitude;
                  if (jobLat != null && jobLng != null) {
                    setState(() {
                      _activeDestination = LatLng(jobLat, jobLng);
                    });
                    if (_userLocation != null) {
                      _fetchRoute(_userLocation!, _activeDestination!);
                    }
                    _startLiveNavigation();
                  }
                },
                onClose: () {
                  setState(() => _selectedJob = null);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final todayCount = widget.jobs.where((j) {
      if (j.scheduledAt != null) {
        final dt = DateTime.tryParse(j.scheduledAt!);
        if (dt != null) {
          final now = DateTime.now();
          return dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day;
        }
      }
      return true;
    }).length;

    final upcomingCount = widget.jobs.length - todayCount;

    return Container(
      margin: const EdgeInsets.only(top: 6, left: 16, right: 16),
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(0, "All (${widget.jobs.length})"),
          const SizedBox(width: 8),
          _buildChip(1, "Today ($todayCount)"),
          const SizedBox(width: 8),
          _buildChip(2, "Upcoming ($upcomingCount)"),
        ],
      ),
    );
  }

  Widget _buildChip(int index, String label) {
    final isSel = _selectedFilterIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
          _selectedJob = null;
        });
        _fitJobsBounds();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.primaryColor : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSel ? AppTheme.primaryColor : AppTheme.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
            color: isSel ? Colors.white : AppTheme.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildArrivalBanner() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: const Color(0xFF81C784), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF81C784),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You Have Arrived!",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "At customer premises • Ready to begin",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
              onPressed: () => setState(() => _arrivalDismissed = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigationHUD() {
    final step = _currentRoute?.steps.isNotEmpty == true ? _currentRoute!.steps.first : null;
    final instruction = step?.instruction ?? "Proceed along the route";
    final distanceText = step != null && step.distanceMeters > 0
        ? "${step.distanceMeters.toStringAsFixed(0)} m"
        : "";

    IconData maneuverIcon = Icons.straight_rounded;
    if (step != null) {
      final mod = (step.modifier ?? '').toLowerCase();
      final type = (step.type ?? '').toLowerCase();
      if (type == 'arrive') {
        maneuverIcon = Icons.sports_score_rounded;
      } else if (mod.contains('left')) {
        maneuverIcon = Icons.turn_left_rounded;
      } else if (mod.contains('right')) {
        maneuverIcon = Icons.turn_right_rounded;
      } else if (mod.contains('u-turn') || mod.contains('uturn')) {
        maneuverIcon = Icons.u_turn_left_rounded;
      }
    }

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                maneuverIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (distanceText.isNotEmpty)
                    Text(
                      distanceText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  Text(
                    instruction,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Live Speedometer chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentSpeedKmh.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                  const Text(
                    "km/h",
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
