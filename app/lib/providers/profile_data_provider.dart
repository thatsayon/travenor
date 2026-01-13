import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_service.dart';
import '../providers/auth_provider.dart';

// Profile data cache with SWR pattern
class CachedProfileData {
  final Map<String, dynamic>? userData;
  final DateTime? lastFetched;

  CachedProfileData({this.userData, this.lastFetched});

  bool get hasData => userData != null;
  bool get isStale => lastFetched == null || 
      DateTime.now().difference(lastFetched!) > const Duration(minutes: 5);
}

// Profile data notifier with caching
class ProfileDataNotifier extends AsyncNotifier<CachedProfileData> {
  @override
  Future<CachedProfileData> build() async {
    // Initial load - fetch from API
    return _fetchProfile();
  }

  Future<CachedProfileData> _fetchProfile() async {
    try {
      final profileService = ref.read(profileServiceProvider);
      final response = await profileService.getProfileFromApi();
      
      if (response.success && response.userData != null) {
        return CachedProfileData(
          userData: response.userData,
          lastFetched: DateTime.now(),
        );
      }
      return CachedProfileData();
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return CachedProfileData();
    }
  }

  // Refresh profile data (can be called anytime)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProfile());
  }

  // Revalidate in background without showing loading state
  Future<void> revalidate() async {
    final currentData = state.value;
    if (currentData == null || !currentData.hasData || currentData.isStale) {
      // Only show loading if we don't have cached data
      if (currentData == null || !currentData.hasData) {
        state = const AsyncValue.loading();
      }
      state = await AsyncValue.guard(() => _fetchProfile());
    }
  }
}

// Provider for profile data
final profileDataProvider = AsyncNotifierProvider<ProfileDataNotifier, CachedProfileData>(() {
  return ProfileDataNotifier();
});
