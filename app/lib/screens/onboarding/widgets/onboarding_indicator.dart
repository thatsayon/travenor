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
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: current == index ? 20 : 6,
          decoration: BoxDecoration(
            color: current == index
                ? const Color(0xFF0A6CFF)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
