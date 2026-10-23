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

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(mapThemeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Map Styles & Themes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppMapTheme.availableThemes.map((theme) {
                  final isSelected = theme.type == currentTheme.type;
                  return InkWell(
                    onTap: () {
                      ref.read(mapThemeProvider.notifier).setTheme(theme.type);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 64) / 2,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : AppTheme.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            theme.icon,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.black87,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              theme.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Attribution text
              Center(
                child: Text(
                  currentTheme.attribution,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

        // Map Theme Selector
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCircleButton(
            icon: Icons.layers_outlined,
            onTap: () => _showThemePicker(context, ref),
            tooltip: "Change Map Style",
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
