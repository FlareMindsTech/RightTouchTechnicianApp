import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/job.dart';
import 'package:right_touch/providers/job_provider.dart';
import 'package:right_touch/providers/nav_provider.dart';
import 'package:right_touch/providers/socket_state_provider.dart';
import 'package:right_touch/utils/app_theme.dart';

class BroadcastAlertOverlay extends ConsumerStatefulWidget {
  const BroadcastAlertOverlay({super.key});

  @override
  ConsumerState<BroadcastAlertOverlay> createState() =>
      _BroadcastAlertOverlayState();
}

class _BroadcastAlertOverlayState extends ConsumerState<BroadcastAlertOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _countdownTimer;
  int _remainingSeconds = 30;
  static const int _totalSeconds = 30;
  bool _alertTriggered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startAlert() {
    if (_alertTriggered) return;
    _alertTriggered = true;
    _remainingSeconds = _totalSeconds;

    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);

    _animController.forward();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _dismissAlert();
      }
    });
  }

  void _dismissAlert() {
    _countdownTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) {
        _alertTriggered = false;
        ref.read(socketStateProvider.notifier).clearNewJobAlert();
      }
    });
  }

  void _viewOffer() {
    _countdownTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) {
        _alertTriggered = false;
        ref.read(socketStateProvider.notifier).clearNewJobAlert();
        ref.read(navProvider.notifier).state = 1; // New Jobs Tab
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final socketState = ref.watch(socketStateProvider);
    final broadcastAsync = ref.watch(broadcastJobsProvider);

    final hasAlert = socketState.hasNewJob;

    if (hasAlert && !_alertTriggered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startAlert();
      });
    } else if (!hasAlert && _alertTriggered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dismissAlert();
      });
    }

    if (!hasAlert && !_alertTriggered && _animController.isDismissed) {
      return const SizedBox.shrink();
    }

    // Try finding the latest broadcast job for rich preview
    Job? latestJob;
    broadcastAsync.whenData((jobs) {
      if (jobs.isNotEmpty) {
        latestJob = jobs.first;
      }
    });

    final serviceTitle = latestJob?.serviceName ??
        latestJob?.title ??
        'New Service Broadcast';
    final earnings = latestJob?.technicianAmount ??
        latestJob?.earnings ??
        latestJob?.basePrice;
    final locationText = latestJob?.location ?? 'Nearby location';

    final progressRatio = _remainingSeconds / _totalSeconds;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 12,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B263B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row with badge, timer countdown, and close button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.radar_rounded,
                              size: 14,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'BROADCAST LIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Circular Countdown Ring
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progressRatio,
                              strokeWidth: 2.5,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _remainingSeconds <= 10
                                    ? Colors.redAccent
                                    : AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              '$_remainingSeconds',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _remainingSeconds <= 10
                                    ? Colors.redAccent
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dismiss button
                      GestureDetector(
                        onTap: _dismissAlert,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Job Title and Payout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: Colors.white60,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    locationText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (earnings != null && earnings > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF2ECC71).withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '₹${earnings.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2ECC71),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _viewOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flash_on_rounded, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'VIEW & ACCEPT OFFER',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

