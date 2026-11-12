import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
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
  final LatLng? destinationCoordinates;
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
    this.destinationCoordinates,
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

  Future<void> _sendWhatsAppEta(BuildContext context, String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanPhone = clean.length == 10 ? '91$clean' : clean;
    final duration = routeData?.durationFormatted ?? 'shortly';
    final arrivalClock = routeData != null ? _getArrivalClock(routeData!.durationSeconds) : '';
    final etaStr = arrivalClock.isNotEmpty ? '$arrivalClock ($duration)' : duration;

    final message =
        'Hi! Your Right Touch technician is on the way to your location. Estimated arrival: $etaStr.';
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encoded');
    final webUri = Uri.parse('https://wa.me/$cleanPhone?text=$encoded');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp is not installed on this device.')),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _launchExternalGoogleMaps(BuildContext context) async {
    if (destinationCoordinates == null) return;
    final lat = destinationCoordinates!.latitude;
    final lng = destinationCoordinates!.longitude;

    final nativeUri =
        Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open external Google Maps.')),
          );
        }
      }
    } catch (_) {}
  }

  String _getArrivalClock(double durationSeconds) {
    final arrivalTime =
        DateTime.now().add(Duration(seconds: durationSeconds.round()));
    final hour = arrivalTime.hour > 12
        ? arrivalTime.hour - 12
        : (arrivalTime.hour == 0 ? 12 : arrivalTime.hour);
    final minute = arrivalTime.minute.toString().padLeft(2, '0');
    final period = arrivalTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final clockArrival = routeData != null
        ? _getArrivalClock(routeData!.durationSeconds)
        : null;

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

            // Destination and Quick Contact Row
            Row(
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
                // Quick Call & WhatsApp CTA buttons
                if (customerPhone != null && customerPhone!.isNotEmpty) ...[
                  IconButton.filledTonal(
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF25D366), size: 20),
                    tooltip: 'Send WhatsApp ETA',
                    onPressed: () => _sendWhatsAppEta(context, customerPhone!),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.phone, color: AppTheme.green, size: 20),
                    tooltip: 'Call Customer',
                    onPressed: () => _callCustomer(customerPhone!),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.green.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 14),

            // Route metrics pills (Clock Arrival, Travel Duration & Distance)
            if (routeData != null)
              Row(
                children: [
                  if (clockArrival != null) ...[
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_rounded,
                              color: Color(0xFF1565C0), size: 15),
                          const SizedBox(width: 4),
                          Text(
                            clockArrival,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_filled,
                            color: AppTheme.green, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          routeData!.durationFormatted,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.straighten,
                            color: AppTheme.blue, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          routeData!.distanceFormatted,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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

            // Navigation Actions: In-App Navigation + External Google Maps Voice Nav
            Row(
              children: [
                // In-App Navigation Toggle
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: isLoadingRoute
                          ? null
                          : (isNavigating ? onStopNavigation : onStartNavigation),
                      icon: isLoadingRoute
                          ? const RtLoader.button(color: AppTheme.white)
                          : Icon(isNavigating
                              ? Icons.stop_rounded
                              : Icons.navigation_rounded),
                      label: Text(
                        isLoadingRoute
                            ? "Calculating..."
                            : (isNavigating ? "Exit Nav" : "Start In-App Nav"),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNavigating
                            ? const Color(0xFFD32F2F)
                            : AppTheme.primaryColor,
                        foregroundColor: AppTheme.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                if (destinationCoordinates != null) ...[
                  const SizedBox(width: 10),
                  // External Google Maps Voice Navigation
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _launchExternalGoogleMaps(context),
                        icon: const Icon(Icons.volume_up_rounded,
                            size: 18, color: Color(0xFF1A73E8)),
                        label: const Text(
                          "Voice Nav",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A73E8),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF1A73E8), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
