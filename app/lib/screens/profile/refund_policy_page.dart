import 'package:flutter/material.dart';
import '../../main.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Refund Policy'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: March 12, 2026',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'At Travenor, we understand that plans can change. This Refund Policy outlines the terms and conditions for cancellations and refunds for tours booked through our platform.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              context,
              title: '1. Standard Cancellation Policy',
              content: [
                'Cancellations made 7 days or more before the tour start date: 100% refund of the deposit.',
                'Cancellations made 3-6 days before the tour start date: 50% refund of the deposit.',
                'Cancellations made within 48 hours of the tour start date: No refund.',
              ],
            ),
            
            _buildSection(
              context,
              title: '2. "Refund Guaranteed" Tours',
              content: [
                'Tours marked with the "Refund Guaranteed" badge offer more flexible terms.',
                'For these tours, you can cancel up to 24 hours before the tour start date for a full refund.',
              ],
            ),
            
            _buildSection(
              context,
              title: '3. Operator Cancellations',
              content: [
                'If a tour operator cancels a tour for any reason (e.g., severe weather, minimum capacity not met), you will receive a 100% full refund.',
                'Alternatively, you may choose to rebook the tour for a different date or select an alternative tour of equal value.',
              ],
            ),
            
            _buildSection(
              context,
              title: '4. No-Shows',
              content: [
                'If you fail to arrive at the designated meeting point on time (a "no-show"), you will not be eligible for a refund.',
                'Please ensure you plan your travel accordingly to arrive before the scheduled departure.',
              ],
            ),
            
            _buildSection(
              context,
              title: '5. Refund Processing',
              content: [
                'Approved refunds will be processed back to your original payment method.',
                'Please allow 7-10 business days for the funds to appear in your account, depending on your bank or payment provider.',
              ],
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you need to request a refund or have questions about a cancellation, contact our support team:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: support@travenor.com\nPhone: +880 1758-000666',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<String> content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...content.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),
      ],
    );
  }
}
