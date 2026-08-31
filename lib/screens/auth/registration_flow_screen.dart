import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/screens/auth/profile_setup_screen.dart';
import 'package:right_touch/screens/kyc/kyc_documents_screen.dart';
import 'package:right_touch/screens/kyc/bank_details_screen.dart';

class RegistrationFlowScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const RegistrationFlowScreen({super.key, this.initialPage = 0});

  @override
  ConsumerState<RegistrationFlowScreen> createState() =>
      _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState
    extends ConsumerState<RegistrationFlowScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_pageController.page != null && _pageController.page! < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onComplete() {
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isFullySubmitted = authState.maybeWhen(
      authenticated: (user) => user.isProfileComplete && user.isKycSubmitted,
      orElse: () => false,
    );

    // The Scaffold here is minimal since the child screens provide their own AppBars.
    // However, to ensure smooth swiping, the children should ideally not have Scaffolds with their own background colors,
    // or we can wrap them directly. The existing screens currently have Scaffolds.
    // That works fine inside a PageView.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_pageController.hasClients &&
            _pageController.page != null &&
            _pageController.page! > 0) {
          _goToPreviousPage();
        } else {
          // Allow popping the route if we are on the first page
          if (context.mounted && context.canPop()) {
            context.pop();
          } else if (context.mounted) {
            context.go('/'); // Fallback
          }
        }
      },
      child: PageView(
        controller: _pageController,
        physics: isFullySubmitted
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(), // 1️⃣ VALIDATION HARD LOCK
        children: [
          ProfileSetupScreen(
            onNext: _goToNextPage,
            onComplete: _onComplete,
          ),
          KycDocumentsScreen(
            onNext: _goToNextPage,
            onBack: _goToPreviousPage,
          ),
          BankDetailsScreen(
            onBack: _goToPreviousPage,
            onComplete: _onComplete,
          ),
        ],
      ),
    );
  }
}
