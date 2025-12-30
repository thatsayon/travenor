import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import 'account_settings_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: user?.photoUrl != null 
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      backgroundColor: Colors.white,
                      child: user?.photoUrl == null
                          ? Icon(
                              Icons.person,
                              size: 48,
                              color: AppTheme.primaryTeal,
                            )
                          : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name
                    Text(
                      user?.name ?? 'Guest User',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      user?.email ?? 'guest@travenor.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
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
                      'PREFERENCES',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textLight,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'App version 1.0.0',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Travenor v1.0.0')),
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
