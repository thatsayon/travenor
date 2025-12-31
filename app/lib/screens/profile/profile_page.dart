import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import 'account_settings_page.dart';
import 'edit_profile_page.dart';
import 'help_support_page.dart';
import 'faq_page.dart';
import 'about_page.dart';
import 'notification_preferences_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple Profile Header (White Background)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFFD6E0), // Pink background
                      backgroundImage: user?.photoUrl != null 
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.primaryBlue,
                            )
                          : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name
                    Text(
                      user?.name ?? 'Guest User',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      user?.email ?? 'guest@travenor.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Settings options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCOUNT',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textLight,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notification Preferences',
                      subtitle: 'Manage tour and marketing notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPreferencesPage(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.payment_outlined,
                      title: 'Payment Methods',
                      subtitle: 'Manage saved payment methods',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Account Settings',
                      subtitle: 'Privacy, data & account deletion',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsPage(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'SUPPORT',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textLight,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help or contact us',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportPage(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.quiz_outlined,
                      title: 'Frequently Asked Questions',
                      subtitle: 'Find answers to common questions',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQPage(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'About Travenor',
                      subtitle: 'App version & information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign out button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(authProvider.notifier).signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.signIn,
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: BorderSide(color: AppTheme.error, width: 1.5),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(12),
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
