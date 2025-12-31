import 'package:flutter/material.dart';
import '../../main.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About Travenor'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.explore,
                  size: 60,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Travenor',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'About Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Travenor is your trusted companion for exploring Bangladesh through curated group tours. We connect adventurers with verified tour leads, ensuring safe, memorable, and hassle-free travel experiences.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Our Mission',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'To make group travel accessible, safe, and enjoyable for everyone. We believe in the power of shared experiences and creating lasting memories through well-organized tours across Bangladesh.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
            ),
            
            const SizedBox(height: 32),
            
           _buildInfoCard(
              context,
              icon: Icons.verified_user,
              title: 'Verified Tour Leads',
              description: 'All our tour guides are background-checked and verified',
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoCard(
              context,
              icon: Icons.shield_outlined,
              title: 'Refund Guarantee',
              description: 'Full refund if the tour doesn\'t happen as scheduled',
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoCard(
              context,
              icon: Icons.support_agent,
              title: '24/7 Support',
              description: 'Our team is always here to help you',
            ),
            
            const SizedBox(height: 32),
            
            Text(
              '© 2024 Travenor. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
