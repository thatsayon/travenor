import 'package:flutter/material.dart';
import '../../main.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              'Travenor is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              context,
              title: '1. Information We Collect',
              content: [
                'Personal Information: Name, email address, phone number, and profile photo.',
                'Booking Information: Tour preferences, payment details, and travel history.',
                'Device Information: Device type, operating system, and unique device identifiers.',
                'Location Data: GPS location when you use location-based features (with your permission).',
                'Usage Data: How you interact with our app, including pages viewed and features used.',
              ],
            ),
            
            _buildSection(
              context,
              title: '2. How We Use Your Information',
              content: [
                'To provide and maintain our tour booking services.',
                'To process your bookings and payments.',
                'To send you booking confirmations, updates, and customer support.',
                'To improve our app and develop new features.',
                'To send you marketing communications (with your consent).',
                'To comply with legal obligations and prevent fraud.',
              ],
            ),
            
            _buildSection(
              context,
              title: '3. Information Sharing',
              content: [
                'Tour Operators: We share necessary information with tour leads to facilitate your bookings.',
                'Service Providers: We work with third-party service providers for payment processing, analytics, and customer support.',
                'Legal Requirements: We may disclose information when required by law or to protect our rights.',
                'Business Transfers: In case of merger or acquisition, your information may be transferred.',
              ],
            ),
            
            _buildSection(
              context,
              title: '4. Data Security',
              content: [
                'We implement industry-standard security measures to protect your data.',
                'All payment information is encrypted using SSL technology.',
                'Access to personal data is restricted to authorized personnel only.',
                'However, no method of transmission over the internet is 100% secure.',
              ],
            ),
            
            _buildSection(
              context,
              title: '5. Your Rights',
              content: [
                'Access: You can request a copy of your personal data.',
                'Correction: You can update or correct your information in the app.',
                'Deletion: You can request deletion of your account and data.',
                'Opt-out: You can opt out of marketing communications at any time.',
                'Data Portability: You can request your data in a portable format.',
              ],
            ),
            
            _buildSection(
              context,
              title: '6. Cookies and Tracking',
              content: [
                'We use cookies and similar technologies to track activity and improve user experience.',
                'You can control cookie preferences through your device settings.',
                'Third-party analytics tools may collect data about your app usage.',
              ],
            ),
            
            _buildSection(
              context,
              title: '7. Children\'s Privacy',
              content: [
                'Our services are not intended for children under 13 years of age.',
                'We do not knowingly collect personal information from children.',
                'If we discover we have collected data from a child, we will delete it promptly.',
              ],
            ),
            
            _buildSection(
              context,
              title: '8. Changes to This Policy',
              content: [
                'We may update this Privacy Policy from time to time.',
                'We will notify you of any changes by posting the new policy in the app.',
                'Changes are effective immediately upon posting.',
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
                    'Contact Us',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have questions about this Privacy Policy, please contact us at:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: privacy@travenor.com\nPhone: +880 1758-000666',
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
