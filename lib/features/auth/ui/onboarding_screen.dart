import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingItem {
  final String image;
  final String tagline;
  final String text;

  const OnboardingItem({
    required this.image,
    required this.tagline,
    required this.text,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<OnboardingItem> onboardingData = const [
    OnboardingItem(
      image: "assets/images/onboarding1.png",
      tagline: "COMFORT",
      text: "Report your issues from the comfort of your own house",
    ),
    OnboardingItem(
      image: "assets/images/onboarding2.png",
      tagline: "TRUST",
      text: "Providing you with the trusted authorities to fix your issues",
    ),
    OnboardingItem(
      image: "assets/images/onboarding3.png",
      tagline: "SAFETY",
      text: "Create a safe and peaceful neighborhood",
    ),
  ];

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _nextPage() {
    if (currentIndex == onboardingData.length - 1) {
      _goToLogin();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ─── TOP BAR: Back + Skip ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back arrow
                  AnimatedOpacity(
                    opacity: currentIndex > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: currentIndex > 0 ? _previousPage : null,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.navBar,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.navBar,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Skip button
                  GestureDetector(
                    onTap: _goToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navBar,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── PAGE CONTENT ───
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  final item = onboardingData[index];
                  return Column(
                    children: [
                      const Spacer(flex: 2),

                      // Illustration
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: SizedBox(
                          height: screenHeight * 0.28,
                          child: Image.asset(
                            item.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Title
                      Text(
                        item.tagline,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          item.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),
                    ],
                  );
                },
              ),
            ),

            // ─── DOT INDICATORS ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 8,
                  width: currentIndex == index ? 26 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? AppColors.navBar
                        : AppColors.navBar.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // ─── BOTTOM BUTTON ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navBar,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    currentIndex == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
          ],
        ),
      ),
    );
  }
}
