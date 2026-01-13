import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_preferences_provider.dart';
import '../../services/notification_service.dart';

class NotificationPreferencesPage extends ConsumerStatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  ConsumerState<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends ConsumerState<NotificationPreferencesPage> {
  bool _marketingEmails = false;
  bool _isLoading = false; // Only show loading if no cached data
  
  // Notification preferences
  bool _newTourNotifications = true;
  bool _bookingUpdates = true;
  bool _marketingNotifications = false;
  bool _tourReminders = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // Check if we have cached data from provider
    final cachedData = ref.read(notificationPreferencesProvider);
    
    if (cachedData.hasValue && cachedData.value!.hasData) {
      // Show cached data immediately (no loading state!)
      _populateFromPreferences(cachedData.value!.preferences!);
    } else {
      // Only show loading if we truly have no data
      setState(() {
        _isLoading = true;
      });
    }

    // Trigger background revalidation to get fresh data
    ref.read(notificationPreferencesProvider.notifier).revalidate();
    
    // Listen for when fresh data arrives
    ref.listen(notificationPreferencesProvider, (previous, next) {
      if (next.hasValue && next.value!.hasData && mounted) {
        _populateFromPreferences(next.value!.preferences!);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _populateFromPreferences(NotificationPreference preferences) {
    setState(() {
      _newTourNotifications = preferences.newTourNotifications;
      _bookingUpdates = preferences.bookingUpdates;
      _tourReminders = preferences.tourReminders;
      _marketingEmails = preferences.marketingEmails;
      _marketingNotifications = preferences.marketingNotifications;
    });
  }

  Future<void> _updatePreference(String preferenceName, bool value) async {
    // Optimistically update UI immediately for smooth transition
    setState(() {
      switch (preferenceName) {
        case 'new_tour':
          _newTourNotifications = value;
          break;
        case 'booking':
          _bookingUpdates = value;
          break;
        case 'reminders':
          _tourReminders = value;
          break;
        case 'marketing_emails':
          _marketingEmails = value;
          break;
        case 'marketing_notif':
          _marketingNotifications = value;
          break;
      }
    });

    // Silently update API in background
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.updateNotificationPreference(
        newTourNotifications: preferenceName == 'new_tour' ? value : null,
        bookingUpdates: preferenceName == 'booking' ? value : null,
        tourReminders: preferenceName == 'reminders' ? value : null,
        marketingEmails: preferenceName == 'marketing_emails' ? value : null,
        marketingNotifications: preferenceName == 'marketing_notif' ? value : null,
      );
      
      // Hard refresh to get latest data from server without loading spinner
      ref.read(notificationPreferencesProvider.notifier).refresh();
    } catch (e) {
      // Silently fail - no error messages shown
      print('❌ Error updating preference (silent): $e');
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Tour Notifications Section
                Text(
                  'TOUR NOTIFICATIONS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.textLight,
                        letterSpacing: 1.2,
                      ),
                ),
                
                const SizedBox(height: 12),
                
                _buildSwitchTile(
                  title: 'New Tour Alerts',
                  subtitle: 'Get notified when new tours are posted',
                  value: _newTourNotifications,
                  onChanged: (val) => _updatePreference('new_tour', val),
                ),
                
                _buildSwitchTile(
                  title: 'Booking Updates',
                  subtitle: 'Receive updates about your bookings',
                  value: _bookingUpdates,
                  onChanged: (val) => _updatePreference('booking', val),
                ),
                
                _buildSwitchTile(
                  title: 'Tour Reminders',
                  subtitle: 'Reminders before your upcoming tours',
                  value: _tourReminders,
                  onChanged: (val) => _updatePreference('reminders', val),
                ),
                
                const SizedBox(height: 32),
                
                // Marketing Section
                Text(
                  'MARKETING',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.textLight,
                        letterSpacing: 1.2,
                      ),
                ),
                
                const SizedBox(height: 12),
                
                _buildSwitchTile(
                  title: 'Marketing Emails',
                  subtitle: 'Receive promotional emails and offers',
                  value: _marketingEmails,
                  onChanged: (val) => _updatePreference('marketing_emails', val),
                ),
                
                _buildSwitchTile(
                  title: 'Marketing Notifications',
                  subtitle: 'Get push notifications about promotions',
                  value: _marketingNotifications,
                  onChanged: (val) => _updatePreference('marketing_notif', val),
                ),
              ],
            ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
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
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}
