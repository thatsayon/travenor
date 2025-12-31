import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool _newTourNotifications = true;
  bool _bookingUpdates = true;
  bool _marketingEmails = false;
  bool _marketingNotifications = false;
  bool _tourReminders = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _newTourNotifications = prefs.getBool('newTourNotifications') ?? true;
      _bookingUpdates = prefs.getBool('bookingUpdates') ?? true;
      _marketingEmails = prefs.getBool('marketingEmails') ?? false;
      _marketingNotifications = prefs.getBool('marketingNotifications') ?? false;
      _tourReminders = prefs.getBool('tourReminders') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'TOUR UPDATES',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.textLight,
                  letterSpacing: 1.2,
                ),
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'New Tour Notifications',
            subtitle: 'Get notified when new tours are available',
            value: _newTourNotifications,
            onChanged: (value) {
              setState(() => _newTourNotifications = value);
              _savePreference('newTourNotifications', value);
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Booking Updates',
            subtitle: 'Updates about your bookings and confirmations',
            value: _bookingUpdates,
            onChanged: (value) {
              setState(() => _bookingUpdates = value);
              _savePreference('bookingUpdates', value);
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Tour Reminders',
            subtitle: 'Reminders before your scheduled tours',
            value: _tourReminders,
            onChanged: (value) {
              setState(() => _tourReminders = value);
              _savePreference('tourReminders', value);
            },
          ),
          
          const SizedBox(height: 32),
          
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
            onChanged: (value) {
              setState(() => _marketingEmails = value);
              _savePreference('marketingEmails', value);
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Marketing Notifications',
            subtitle: 'Receive promotional push notifications',
            value: _marketingNotifications,
            onChanged: (value) {
              setState(() => _marketingNotifications = value);
              _savePreference('marketingNotifications', value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
            activeThumbColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}
