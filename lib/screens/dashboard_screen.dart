import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/socket_state_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/widgets/error_boundary.dart';
import 'package:right_touch/widgets/rt_loader.dart';

import 'package:right_touch/screens/profile_screen.dart';
import 'package:right_touch/screens/tabs/earnings_tab.dart';
import 'package:right_touch/screens/tabs/new_jobs_tab.dart';
import 'package:right_touch/screens/tabs/verification_home_tab.dart';
import 'package:right_touch/screens/tabs/schedule_tab.dart';

import 'package:right_touch/services/location_tracking_service.dart';
import 'package:right_touch/widgets/custom_bottom_nav_bar.dart';
import 'package:right_touch/providers/nav_provider.dart';
import 'package:right_touch/widgets/network_status_banner.dart';
import 'package:right_touch/widgets/tab_navigator.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime? _lastBackPressTime;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    Future.microtask(() {
      if (!mounted) return;
      final initialIndex = ref.read(navProvider);
      if (initialIndex != 0 && _pageController.hasClients) {
        _pageController.jumpToPage(initialIndex);
      }
      ref.read(locationServiceProvider).startTracking();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    Future.microtask(() {
      if (mounted) {
        ref.read(locationServiceProvider).stopTracking();
      }
    });
    super.dispose();
  }

  Widget _buildDeactivationOverlay(String message) {
    return Stack(
      children: [
        // The background is blurred
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: AppTheme.black.withValues(alpha: 0.3),
            ),
          ),
        ),
        // The content
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ErrorBoundary(
              message: message,
              showTitle: true,
              isOverlay: true,
              onRetry: () => ref.read(authProvider.notifier).checkAuth(),
              onLoginAgain: () => ref.read(authProvider.notifier).logout(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    ref.watch(socketStateProvider);

    return authState.maybeWhen(
      authenticated: (user) => _buildScaffold(context),
      error: (msg) {
        if (msg.contains('deactivated') || msg.contains('support')) {
          return Stack(
            children: [
              _buildScaffold(context),
              _buildDeactivationOverlay(msg),
            ],
          );
        }
        return _buildErrorState(msg);
      },
      loading: () => const Scaffold(
        body: Center(
          child: RtLoader(),
        ),
      ),
      orElse: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final route = GoRouterState.of(context).uri.toString();
            if (route != '/login' && route != '/') {
              context.go('/login');
            }
          }
        });
        return const Scaffold(
          body: Center(
            child: RtLoader(),
          ),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final navState = ref.read(navProvider.notifier);
    final navIndex = ref.watch(navProvider);

    ref.listen<int>(navProvider, (previous, next) {
      if (_pageController.hasClients) {
        final int currentPage = _pageController.page?.round() ?? 0;
        if (currentPage != next) {
          final int difference = (next - currentPage).abs();
          if (difference > 1) {
            _pageController.jumpToPage(next);
          } else {
            _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });

    final List<Widget> tabs = [
      TabNavigator(
        navigatorKey: navState.navigatorKeys[0],
        root: VerificationHomeTab(
          onVerified: () {
            ref.read(authProvider.notifier).checkAuth();
          },
        ),
      ),
      TabNavigator(
        navigatorKey: navState.navigatorKeys[1],
        root: const NewJobsTab(),
      ),
      TabNavigator(
        navigatorKey: navState.navigatorKeys[2],
        root: const ScheduleTab(),
      ),
      TabNavigator(
        navigatorKey: navState.navigatorKeys[3],
        root: const EarningsTab(),
      ),
      TabNavigator(
        navigatorKey: navState.navigatorKeys[4],
        root: const ProfileScreen(),
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final navigator = navState.currentNavigatorKey.currentState;
          if (navigator != null && navigator.canPop()) {
            navigator.pop();
            return;
          }
          if (navIndex != 0) {
            ref.read(navProvider.notifier).state = 0;
            return;
          }
          final now = DateTime.now();
          if (_lastBackPressTime == null ||
              now.difference(_lastBackPressTime!) >
                  const Duration(seconds: 2)) {
            _lastBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Press back again to exit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                duration: Duration(seconds: 2),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
            return;
          }
          unawaited(SystemNavigator.pop());
        },
        child: Scaffold(
          extendBody: true,
          body: SafeArea(
            child: Column(
              children: [
                const NetworkStatusBanner(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const ClampingScrollPhysics(),
                    onPageChanged: (index) {
                      if (ref.read(navProvider) != index) {
                        ref.read(navProvider.notifier).state = index;
                      }
                    },
                    children: tabs,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: navIndex,
            onTap: (index) {
              if (navIndex != index) {
                ref.read(navProvider.notifier).state = index;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String msg) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: ErrorBoundary(
            message: ErrorHandler.parseError(msg),
            onRetry: () => ref.read(authProvider.notifier).checkAuth(),
          ),
        ),
      ),
    );
  }
}

class ScreenPlaceholder extends StatelessWidget {
  const ScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(color: AppTheme.white); // Basic placeholder
  }
}
