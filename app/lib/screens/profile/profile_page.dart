import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_data_provider.dart';
import '../../providers/notification_preferences_provider.dart';
import '../../routes/app_routes.dart';
import 'account_settings_page.dart';
import 'edit_profile_page.dart';
import 'help_support_page.dart';
import 'faq_page.dart';
import 'about_page.dart';
import 'notification_preferences_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Prefetch profile and notification preferences data
    // This will populate the cache so pages load instantly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileDataProvider.notifier).revalidate();
      ref.read(notificationPreferencesProvider.notifier).revalidate();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    // Avatar with cached image
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                user.photoUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: AppTheme.primaryBlue,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppTheme.primaryBlue,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.primaryBlue,
                            ),
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
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref.read(authProvider.notifier).signOut();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.signIn,
                              (route) => false,
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: AppTheme.error,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Sign Out',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
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
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
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
