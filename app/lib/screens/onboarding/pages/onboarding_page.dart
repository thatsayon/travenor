import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_storage.dart';
import '../widgets/onboarding_item.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_skip_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  final items = const [
    OnboardingItem(
      image: 'assets/images/onboarding/onboard1.jpg',
      title: 'Life feels bigger when you',
      highlight: 'travel',
      description:
          "New places, new perspectives, and experiences you'll remember long after the trip ends.",
    ),
    OnboardingItem(
      image: 'assets/images/onboarding/onboard2.jpg',
      title: 'The best journeys are',
      highlight: 'shared',
      description:
          'Travel with a well-matched group while we plan the routes, transport, and stays.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding/onboard3.jpg',
      title: "Travel confidently. We've got your",
      highlight: 'safety',
      description:
          'Verified partners, organized coordination, and support throughout the entire trip.',
    ),
  ];

  Future<void> _next() async {
    if (_index < items.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      await AppStorage().setFirstLaunchFalse();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // PageView takes most of the space
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => items[i],
                  ),
                ),

                // Bottom section with indicator and button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      OnboardingIndicator(current: _index),
                      const SizedBox(height: 24),
                      OnboardingButton(
                        isLast: _index == items.length - 1,
                        onTap: _next,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Skip button positioned relative to the padded image
            if (_index < items.length - 1)
              Positioned(
                top: 28,
                right: 36,
                child: OnboardingSkipButton(
                  onTap: () async {
                    await AppStorage().setFirstLaunchFalse();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
