import 'package:flutter/material.dart';
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

  final items = const [
    OnboardingItem(
      image: 'assets/images/onboarding/onboard1.jpg',
      title: 'Life feels bigger when you',
      highlight: 'travel',
      description:
          'New places, new perspectives, and experiences you’ll remember long after the trip ends.',
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
      title: 'Travel confidently. We’ve got your',
      highlight: 'safety',
      description:
          'Verified partners, organized coordination, and support throughout the entire trip.',
    ),
  ];

  Future<void> _next() async {
    if (_index < items.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
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
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => items[i],
                  ),
                ),

                const SizedBox(height: 16),
                OnboardingIndicator(current: _index),
                const SizedBox(height: 16),

                OnboardingButton(
                  isLast: _index == items.length - 1,
                  onTap: _next,
                ),

                const SizedBox(height: 24),
              ],
            ),

            // Skip button overlay (over image)
            if (_index < items.length - 1)
              Positioned(
                top: 16,
                right: 16,
                child: OnboardingSkipButton(
                  onTap: _next,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
