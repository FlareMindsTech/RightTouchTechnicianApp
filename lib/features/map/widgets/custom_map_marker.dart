import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:right_touch/utils/app_theme.dart';

class UserLocationBeaconMarker extends StatefulWidget {
  final LatLng position;
  final double? heading;
  final double? accuracy;

  const UserLocationBeaconMarker({
    super.key,
    required this.position,
    this.heading,
    this.accuracy,
  });

  static Marker create({
    required LatLng position,
    double? heading,
    double? accuracy,
  }) {
    return Marker(
      point: position,
      width: 70,
      height: 70,
      child: UserLocationBeaconMarker(
        position: position,
        heading: heading,
        accuracy: accuracy,
      ),
    );
  }

  @override
  State<UserLocationBeaconMarker> createState() => _UserLocationBeaconMarkerState();
}

class _UserLocationBeaconMarkerState extends State<UserLocationBeaconMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing radar halo
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.blue.withValues(
                    alpha: (1.0 - _pulseController.value) * 0.35,
                  ),
                ),
              ),
            );
          },
        ),
        // Directional Heading Indicator (if available)
        if (widget.heading != null && widget.heading! > 0)
          Transform.rotate(
            angle: (widget.heading! * (math.pi / 180.0)),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.topCenter,
              child: const Icon(
                Icons.navigation,
                size: 16,
                color: AppTheme.blue,
              ),
            ),
          ),
        // Central blue location dot
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppTheme.blue,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.blue.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class JobPinMarker extends StatelessWidget {
  final LatLng position;
  final String title;
  final String? subtitle;
  final double? price;
  final bool isSelected;
  final VoidCallback? onTap;

  const JobPinMarker({
    super.key,
    required this.position,
    required this.title,
    this.subtitle,
    this.price,
    this.isSelected = false,
    this.onTap,
  });

  static Marker create({
    required LatLng position,
    required String title,
    String? subtitle,
    double? price,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Marker(
      point: position,
      width: isSelected ? 120 : 90,
      height: isSelected ? 90 : 75,
      child: JobPinMarker(
        position: position,
        title: title,
        subtitle: subtitle,
        price: price,
        isSelected: isSelected,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating label bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                price != null && price! > 0 ? '₹${price!.toStringAsFixed(0)}' : title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.white : AppTheme.black,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Pin Icon with bottom needle
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: isSelected ? 44 : 36,
                  color: isSelected ? AppTheme.primaryColor : const Color(0xFFE53935),
                ),
                Positioned(
                  top: isSelected ? 8 : 6,
                  child: Container(
                    width: isSelected ? 16 : 12,
                    height: isSelected ? 16 : 12,
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.build_rounded,
                      size: isSelected ? 10 : 8,
                      color: isSelected ? AppTheme.primaryColor : const Color(0xFFE53935),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
