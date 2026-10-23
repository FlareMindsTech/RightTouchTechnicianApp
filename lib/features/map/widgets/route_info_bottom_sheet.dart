import 'package:flutter/material.dart';
import 'package:right_touch/features/map/models/route_model.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteInfoBottomSheet extends StatelessWidget {
  final RouteData? routeData;
  final bool isNavigating;
  final bool isLoadingRoute;
  final bool isOffRoute;
  final String destinationTitle;
  final String? destinationAddress;
  final String? customerPhone;
  final VoidCallback onStartNavigation;
  final VoidCallback onStopNavigation;
  final VoidCallback onRecalculateRoute;

  const RouteInfoBottomSheet({
    super.key,
    required this.routeData,
    required this.isNavigating,
    required this.isLoadingRoute,
    required this.isOffRoute,
    required this.destinationTitle,
    this.destinationAddress,
    this.customerPhone,
    required this.onStartNavigation,
    required this.onStopNavigation,
    required this.onRecalculateRoute,
  });

  Future<void> _callCustomer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppTheme.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Off-Route Alert Banner (if user diverged from route)
            if (isOffRoute)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.orange.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppTheme.orange, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Off Route! Recalculating directions...",
                        style: TextStyle(
                          color: AppTheme.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppTheme.orange),
                      onPressed: onRecalculateRoute,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // Next maneuver instruction (if navigating & steps available)
            if (isNavigating &&
                routeData != null &&
                routeData!.steps.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E88E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.turn_right_rounded,
                        color: AppTheme.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routeData!.steps.first.instruction,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.black87,
                            ),
                          ),
                          if (routeData!.steps.first.distanceMeters > 0)
                            Text(
                              "in ${(routeData!.steps.first.distanceMeters).toStringAsFixed(0)} meters",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Distance & ETA Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destinationTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (destinationAddress != null && destinationAddress!.isNotEmpty)
                        Text(
                          destinationAddress!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (customerPhone != null && customerPhone!.isNotEmpty)
                  IconButton.filledTonal(
                    icon: const Icon(Icons.phone, color: AppTheme.green),
                    onPressed: () => _callCustomer(customerPhone!),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.green.withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Route metrics pills (ETA & Distance)
            if (routeData != null)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled,
                            color: AppTheme.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          routeData!.durationFormatted,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.straighten,
                            color: AppTheme.blue, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          routeData!.distanceFormatted,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: AppTheme.grey),
                    tooltip: "Recalculate route",
                    onPressed: onRecalculateRoute,
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Primary action button (Start / Stop navigation)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoadingRoute
                    ? null
                    : (isNavigating ? onStopNavigation : onStartNavigation),
                icon: isLoadingRoute
                    ? const RtLoader.button(color: AppTheme.white)
                    : Icon(isNavigating ? Icons.stop_rounded : Icons.navigation_rounded),
                label: Text(
                  isLoadingRoute
                      ? "Calculating Route..."
                      : (isNavigating ? "Exit Navigation" : "Start Navigation"),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isNavigating ? const Color(0xFFD32F2F) : AppTheme.primaryColor,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
