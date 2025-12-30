import 'package:flutter/material.dart';
import '../../main.dart';
import '../../data/dummy_data.dart';
import '../../widgets/tour_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tours = DummyData.allTours;
    final availableCount = tours.length;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryTeal,
                      AppTheme.primaryTealDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Bangladesh',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join curated group tours. Pay small,\ntravel big.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Why Travel With Us
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHY TRAVEL WITH US',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textLight,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderGray),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            context,
                            icon: Icons.verified_user_outlined,
                            title: 'Verified Leads',
                            description: 'Every guide is\nbackground-checked',
                          ),
                          const Divider(height: 24),
                          _buildFeatureItem(
                            context,
                            icon: Icons.currency_exchange,
                            title: 'Refund Guarantee',
                            description: 'Full refund if trip\ndoesn\'t happen',
                          ),
                          const Divider(height: 24),
                          _buildFeatureItem(
                            context,
                            icon: Icons.groups_outlined,
                            title: 'Fixed Groups',
                            description: 'No last-minute\nsurprises',
                          ),
                          const Divider(height: 24),
                          _buildFeatureItem(
                            context,
                            icon: Icons.calendar_month_outlined,
                            title: 'Set Schedule',
                            description: 'Clear timelines &\nitineraries',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Upcoming Tours
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Tours',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$availableCount available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tour Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tours.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    return TourCard(tour: tours[index]);
                  },
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryTeal,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
