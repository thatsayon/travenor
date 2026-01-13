import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../providers/auth_provider.dart';

// Notification preferences cache with SWR pattern
class CachedNotificationPreferences {
  final NotificationPreference? preferences;
  final DateTime? lastFetched;

  CachedNotificationPreferences({this.preferences, this.lastFetched});

  bool get hasData => preferences != null;
  bool get isStale => lastFetched == null || 
      DateTime.now().difference(lastFetched!) > const Duration(minutes: 5);
}

// Notification preferences notifier with caching
class NotificationPreferencesNotifier extends AsyncNotifier<CachedNotificationPreferences> {
  @override
  Future<CachedNotificationPreferences> build() async {
    // Initial load - fetch from API
    return _fetchPreferences();
  }

  Future<CachedNotificationPreferences> _fetchPreferences() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final response = await notificationService.getNotificationPreference();
      
      if (response.success && response.preferences != null) {
        return CachedNotificationPreferences(
          preferences: response.preferences,
          lastFetched: DateTime.now(),
        );
      }
      return CachedNotificationPreferences();
    } catch (e) {
      print('❌ Error fetching notification preferences: $e');
      return CachedNotificationPreferences();
    }
  }

  // Refresh preferences (can be called anytime)
  // This updates cache in background WITHOUT showing loading state
  Future<void> refresh() async {
    // Fetch new data and update cache silently
    final newData = await _fetchPreferences();
    state = AsyncValue.data(newData);
  }

  // Revalidate in background without showing loading state
  Future<void> revalidate() async {
    final currentData = state.value;
    if (currentData == null || !currentData.hasData || currentData.isStale) {
      // Only show loading if we don't have cached data
      if (currentData == null || !currentData.hasData) {
        state = const AsyncValue.loading();
      }
      state = await AsyncValue.guard(() => _fetchPreferences());
    }
  }
}

// Provider for notification preferences
final notificationPreferencesProvider = 
    AsyncNotifierProvider<NotificationPreferencesNotifier, CachedNotificationPreferences>(() {
  return NotificationPreferencesNotifier();
});
