import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/tour_model.dart';
import '../../routes/app_routes.dart';

class ThankYouPage extends StatelessWidget {
  final String bookingReference;
  final TourModel tour;

  const ThankYouPage({
    super.key,
    required this.bookingReference,
    required this.tour,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppTheme.success,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Booking Request Submitted!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                'Thank you for choosing Travenor! We\'ve received your booking request and will get in contact with you as soon as possible.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Booking reference
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  children: [
                    Text(
                      'Booking Reference',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bookingReference,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      tour.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryTeal,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What Happens Next?',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.primaryTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your booking is currently pending. Once confirmed by our team, you\'ll see it in "My Tours".',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // View My Tours button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to home and switch to My Tours tab
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('View My Tours'),
                ),
              ),

              const SizedBox(height: 12),

              // Back to home
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
