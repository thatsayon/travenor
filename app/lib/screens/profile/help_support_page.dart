import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@travenor.com',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWhatsApp() async {
    // Replace with your business WhatsApp number
    const phoneNumber = '8801758000666'; // Format: country code + number without +
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+8801758000666',
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Help & Support'),
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
              'We\'re here for you - always.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Whether you\'re having trouble signing in, tracking your bookings or just need a little guidance, we\'ve got your back.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Our team is just a message away.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'We\'d love to help:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            
            const SizedBox(height: 20),
            
            // Email
            _buildContactOption(
              context,
              icon: Icons.email_outlined,
              iconColor: AppTheme.primaryTeal,
              title: 'Mail: support@travenor.com',
              onTap: _launchEmail,
            ),
            
            const SizedBox(height: 16),
            
            // Response Time
            _buildInfoItem(
              context,
              icon: Icons.access_time,
              iconColor: AppTheme.textSecondary,
              title: 'Response time: Within 24 hours',
              subtitle: '(Monday-Friday)',
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Quick Contact:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            
            const SizedBox(height: 20),
            
            // Phone
            _buildContactOption(
              context,
              icon: Icons.phone_outlined,
              iconColor: AppTheme.success,
              title: 'Call us: +880 1758-000666',
              onTap: _launchPhone,
            ),
            
            const SizedBox(height: 16),
            
            // WhatsApp
            _buildContactOption(
              context,
              icon: Icons.chat_bubble_outline,
              iconColor: const Color(0xFF25D366), // WhatsApp green
              title: 'WhatsApp: +880 1758-000666',
              onTap: _launchWhatsApp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
