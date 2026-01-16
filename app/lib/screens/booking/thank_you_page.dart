import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/tour_model.dart';
import '../../routes/app_routes.dart';

class ThankYouPage extends StatelessWidget {
  final String bookingReference;
  final TourModel tour;
  final String? tourTitle;
  final String? location;

  const ThankYouPage({
    super.key,
    required this.bookingReference,
    required this.tour,
    this.tourTitle,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Success Illustration
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'All Set!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  'Your booking request has been submitted successfully. We will contact you soon.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Booking Reference Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Booking Reference',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bookingReference,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: AppTheme.borderGray.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tourTitle ?? tour.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location ?? tour.location,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to home and switch to My Tours tab
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.home,
                            (route) => false,
                            arguments: {'initialTab': 1}, // Assuming My Tours is tab 1
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'View My Tours',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.home,
                            (route) => false,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
