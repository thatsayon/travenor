import 'package:flutter/material.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const OnboardingSkipButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const StadiumBorder(), // 👈 pill shape
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: const SizedBox(
          height: 36, // 👈 fixed height
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18), // 👈 controls width
            child: Center(
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
