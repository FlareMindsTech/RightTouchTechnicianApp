import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/ux_helpers.dart';
import 'package:right_touch/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image':
          'https://res.cloudinary.com/dp6i6moil/image/upload/v1771396477/iti-solar-technician-electrical_nm8zqn.png',
      'title': "Welcome to Right Touch",
      'description':
          "Your premium destination for professional grooming and lifestyle services. We bring the experts to you.",
    },
    {
      'image':
          'https://res.cloudinary.com/dp6i6moil/image/upload/v1771396415/onboarding_appliance_hgdtrw.webp',
      'title': "Reliable Home Services",
      'description':
          "From plumbing to electrical work, get top-rated professionals for all your home maintenance needs.",
    },
    {
      'image':
          'https://res.cloudinary.com/dp6i6moil/image/upload/v1771396415/onboarding_plumber_y5l9o6.webp',
      'title': "Efficient & Trustworthy",
      'description':
          "Experience seamless service booking with verified technicians and transparent pricing.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              HapticHelper.light();
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                image: _pages[index]['image']!,
                title: _pages[index]['title']!,
                description: _pages[index]['description']!,
                index: index,
              );
            },
          ),

          // Top Skip Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () async {
                    HapticHelper.medium();
                    final router = GoRouter.of(context);
                    await ref
                        .read(authProvider.notifier)
                        .markOnboardingAsSeen();
                    if (!mounted) return;
                    router.go('/login');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Next/Finish Button
                GestureDetector(
                  onTap: () async {
                    HapticHelper.medium();
                    if (_currentPage == _pages.length - 1) {
                      final router = GoRouter.of(context);
                      await ref
                          .read(authProvider.notifier)
                          .markOnboardingAsSeen();
                      if (!mounted) return;
                      router.go('/login');
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 60,
                    width: _currentPage == _pages.length - 1 ? 140 : 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _currentPage == _pages.length - 1
                          ? const Text(
                              "Get Started",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final int index;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              // Image with Hero-like animation effect
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                    onError: (e, s) {},
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              ),
              // If image fails, show placeholder with better style
              Positioned.fill(
                child: FutureBuilder(
                  future: precacheImage(NetworkImage(image), context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppTheme.primaryColor, Colors.black87],
                  ).createShader(bounds),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 48), // Space for bottom controls
              ],
            ),
          ),
        ),
      ],
    );
  }
}
