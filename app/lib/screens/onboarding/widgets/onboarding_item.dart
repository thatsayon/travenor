import 'package:flutter/material.dart';

class OnboardingItem extends StatelessWidget {
  final String image;
  final String title;
  final String highlight;
  final String description;

  const OnboardingItem({
    super.key,
    required this.image,
    required this.title,
    required this.highlight,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              
              // Gradient overlay for better text contrast
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(flex: 1),

        // Title with highlighted word
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.2,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: '$title '),
                TextSpan(
                  text: highlight,
                  style: const TextStyle(
                    color: Color(0xFF0A6CFF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.6,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ),
        
        const Spacer(flex: 1),
      ],
    );
  }
}