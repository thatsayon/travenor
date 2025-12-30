import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../../services/booking_service.dart';
import '../../routes/app_routes.dart';
import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you absolutely sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'This will:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            _buildWarningItem(context, 'Permanently delete your profile'),
            _buildWarningItem(context, 'Remove all your booking history'),
            _buildWarningItem(context, 'Sign you out of the app'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppTheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteAccount(context, ref);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Clear all user data
      final profileService = ProfileService();
      final bookingService = BookingService();
      
      await profileService.clearProfile();
      await bookingService.clearAllBookings();
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out
      ref.read(authProvider.notifier).signOut();

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to sign in
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.signIn,
        (route) => false,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account has been deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final profileService = ProfileService();
      final data = await profileService.exportProfileData();
      
      if (!context.mounted) return;
      
      if (data != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Your Data'),
            content: SingleChildScrollView(
              child: Text(data.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export')),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Widget _buildWarningItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: AppTheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Data & Privacy Section
          Text(
            'DATA & PRIVACY',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.textLight,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 12),

          _buildSettingItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          _buildSettingItem(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfServicePage(),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          //Danger Zone
          Text(
            'DANGER ZONE',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.error,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.error.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildSettingItem(
              context,
              icon: Icons.delete_forever_outlined,
              title: 'Delete My Account',
              subtitle: 'Permanently delete your account and data',
              iconColor: AppTheme.error,
              textColor: AppTheme.error,
              onTap: () => _showDeleteAccountDialog(context, ref),
            ),
          ),

          const SizedBox(height: 32),

          // Info text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Your privacy is important to us. We follow industry best practices to protect your data, and you have full control over your information.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryTeal).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryTeal,
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
                          color: textColor,
                        ),
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
