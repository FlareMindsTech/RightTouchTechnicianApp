import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/features/map/models/map_theme.dart';
import 'package:right_touch/features/map/models/route_model.dart';
import 'package:right_touch/features/map/providers/map_theme_provider.dart';
import 'package:right_touch/utils/app_theme.dart';

class MapControlsOverlay extends ConsumerWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;
  final VoidCallback onResetCompass;
  final double currentRotation;
  final bool isTrackingUser;
  final TravelMode? currentTravelMode;
  final ValueChanged<TravelMode>? onTravelModeChanged;

  const MapControlsOverlay({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
    required this.onResetCompass,
    required this.currentRotation,
    required this.isTrackingUser,
    this.currentTravelMode,
    this.onTravelModeChanged,
  });

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    String? tooltip,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Tooltip(
            message: tooltip ?? '',
            child: Icon(
              icon,
              size: 22,
              color: iconColor ?? AppTheme.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(mapThemeProvider);
    final isSatellite = currentTheme.type == MapThemeType.satellite;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Travel Mode Selector (if in routing mode)
        if (currentTravelMode != null && onTravelModeChanged != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: TravelMode.values.map((mode) {
                final isSelected = mode == currentTravelMode;
                IconData icon;
                switch (mode) {
                  case TravelMode.driving:
                    icon = Icons.directions_car;
                    break;
                  case TravelMode.cycling:
                    icon = Icons.directions_bike;
                    break;
                  case TravelMode.walking:
                    icon = Icons.directions_walk;
                    break;
                }
                return InkWell(
                  onTap: () => onTravelModeChanged!(mode),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? AppTheme.white : AppTheme.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Compass orientation reset (visible when rotated)
        if (currentRotation.abs() > 0.05)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Transform.rotate(
              angle: -currentRotation,
              child: _buildCircleButton(
                icon: Icons.navigation_outlined,
                iconColor: AppTheme.primaryColor,
                onTap: onResetCompass,
                tooltip: "Reset Orientation",
              ),
            ),
          ),

        // Instant 1-Tap Map Style Switcher (Street <-> Satellite)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCircleButton(
            icon: isSatellite ? Icons.map_rounded : Icons.satellite_alt_rounded,
            iconColor: isSatellite ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
            onTap: () {
              final newTheme =
                  isSatellite ? MapThemeType.buildings : MapThemeType.satellite;
              ref.read(mapThemeProvider.notifier).setTheme(newTheme);

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSatellite
                        ? '🗺️ Switched to Google Streets'
                        : '🛰️ Switched to Google Satellite Hybrid',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  duration: const Duration(milliseconds: 1400),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.4,
                    left: 50,
                    right: 50,
                  ),
                  backgroundColor: const Color(0xFF0D1B2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
            tooltip: isSatellite ? "Switch to Streets" : "Switch to Satellite",
          ),
        ),

        // Recenter / Follow GPS Button
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCircleButton(
            icon: isTrackingUser ? Icons.my_location : Icons.location_searching,
            iconColor: isTrackingUser ? AppTheme.primaryColor : AppTheme.grey,
            onTap: onRecenter,
            tooltip: "My Location",
          ),
        ),

        // Zoom In / Out Group
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add, size: 22, color: AppTheme.black87),
                onPressed: onZoomIn,
                tooltip: "Zoom In",
              ),
              Container(
                height: 1,
                width: 24,
                color: AppTheme.grey.shade200,
              ),
              IconButton(
                icon: const Icon(Icons.remove, size: 22, color: AppTheme.black87),
                onPressed: onZoomOut,
                tooltip: "Zoom Out",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
