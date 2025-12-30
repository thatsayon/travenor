import 'package:flutter/material.dart';

class OnboardingButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;

  const OnboardingButton({
    super.key,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A6CFF),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF0A6CFF).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          child: Text(isLast ? 'Get Started' : 'Next'),
        ),
      ),
    );
  }
}