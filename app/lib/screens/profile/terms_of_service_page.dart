import 'package:flutter/material.dart';
import '../../main.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              'Last Updated: December 31, 2024',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Please read these Terms of Service carefully before using the Travenor mobile application. By accessing or using our app, you agree to be bound by these terms.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              context,
              title: '1. Acceptance of Terms',
              content: [
                'By creating an account or using Travenor, you accept these Terms of Service.',
                'If you do not agree to these terms, please do not use our services.',
                'We reserve the right to modify these terms at any time.',
                'Continued use of the app after changes constitutes acceptance.',
              ],
            ),
            
            _buildSection(
              context,
              title: '2. User Accounts',
              content: [
                'You must be at least 18 years old to create an account.',
                'You are responsible for maintaining the security of your account.',
                'You must provide accurate and complete information.',
                'You are responsible for all activities under your account.',
                'Notify us immediately of any unauthorized access.',
              ],
            ),
            
            _buildSection(
              context,
              title: '3. Booking and Payments',
              content: [
                'All bookings are subject to availability and confirmation.',
                'Prices are displayed in BDT and may change without notice.',
                'Payment must be made through our secure payment system.',
                'Refunds are subject to our refund policy and tour-specific terms.',
                'You are responsible for reviewing tour details before booking.',
              ],
            ),
            
            _buildSection(
              context,
              title: '4. Cancellation and Refunds',
              content: [
                'Cancellation policies vary by tour and are displayed on each tour page.',
                'Refund Guaranteed tours offer full refunds if the tour is cancelled.',
                'User-initiated cancellations may incur fees as per the tour policy.',
                'Refunds will be processed within 7-10 business days.',
                'Force majeure events may affect cancellation terms.',
              ],
            ),
            
            _buildSection(
              context,
              title: '5. User Conduct',
              content: [
                'You agree not to use the app for any unlawful purpose.',
                'Harassment, abuse, or threatening behavior is prohibited.',
                'You may not impersonate others or provide false information.',
                'Spam, malware, or unauthorized access attempts are forbidden.',
                'We reserve the right to suspend or terminate accounts for violations.',
              ],
            ),
            
            _buildSection(
              context,
              title: '6. Tour Operator Responsibilities',
              content: [
                'Tour operators are independent third parties.',
                'Travenor acts as a platform connecting users with tour operators.',
                'Tour operators are responsible for the execution of tours.',
                'Safety, quality, and conduct during tours are the operator\'s responsibility.',
                'Travenor is not liable for tour operator actions or omissions.',
              ],
            ),
            
            _buildSection(
              context,
              title: '7. Limitation of Liability',
              content: [
                'Travenor is provided "as is" without warranties of any kind.',
                'We are not liable for indirect, incidental, or consequential damages.',
                'Our total liability shall not exceed the amount paid for the booking.',
                'We are not responsible for third-party services or content.',
                'Users participate in tours at their own risk.',
              ],
            ),
            
            _buildSection(
              context,
              title: '8. Intellectual Property',
              content: [
                'All content in the app is owned by Travenor or licensed to us.',
                'You may not copy, modify, or distribute our content without permission.',
                'User-generated content may be used by Travenor for promotional purposes.',
                'Trademarks and logos are the property of their respective owners.',
              ],
            ),
            
            _buildSection(
              context,
              title: '9. Dispute Resolution',
              content: [
                'Any disputes shall be resolved through binding arbitration.',
                'Arbitration will be conducted in Dhaka, Bangladesh.',
                'You waive the right to participate in class action lawsuits.',
                'Governing law is the laws of Bangladesh.',
              ],
            ),
            
            _buildSection(
              context,
              title: '10. Termination',
              content: [
                'We may suspend or terminate your account at any time for violations.',
                'You may delete your account at any time through app settings.',
                'Upon termination, your right to use the app ceases immediately.',
                'Certain provisions survive termination, including liability limitations.',
              ],
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have questions about these Terms of Service, contact us at:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: legal@travenor.com\nPhone: +880 1758-000666',
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
