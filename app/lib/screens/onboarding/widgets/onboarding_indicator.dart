import 'package:flutter/material.dart';

class OnboardingIndicator extends StatelessWidget {
  final int current;

  const OnboardingIndicator({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: current == index ? 24 : 8,
          decoration: BoxDecoration(
            color: current == index
                ? const Color(0xFF0D6EFD)
                : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
