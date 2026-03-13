import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/secure_storage_service.dart';

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
    // 1. Load from local cache instantly
    final profileService = ref.read(profileServiceProvider);
    final cachedProfile = await profileService.getProfile();
    
    // 2. Trigger background revalidation
    Future.microtask(() => revalidate());

    if (cachedProfile != null) {
      return CachedProfileData(
        userData: cachedProfile.toJson(),
        lastFetched: cachedProfile.lastUpdated,
      );
    }
    
    return CachedProfileData();
  }

  Future<CachedProfileData> _fetchProfile() async {
    try {
      final profileService = ref.read(profileServiceProvider);
      final response = await profileService.getProfileFromApi();
      
      if (response.success && response.userData != null) {
        // Synchronize with AuthProvider to update user name/photo across the app
        final authNotifier = ref.read(authProvider.notifier);
        final currentAuth = ref.read(authProvider);
        if (currentAuth.user != null) {
          // Add a cache-buster timestamp to the photo URL to force refresh 
          // if the URL hasn't changed but the content has.
          String? photoUrl = response.userData!['profile_pic'] ?? response.userData!['photoUrl'];
          
          if (photoUrl != null && photoUrl.isNotEmpty) {
            final separator = photoUrl.contains('?') ? '&' : '?';
            photoUrl = '$photoUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
          } else {
            // Explicitly clear photo in storage if it's missing in API
            await SecureStorageService.deleteProfilePhoto();
            photoUrl = ''; // Ensure it's empty string, not null, to sync correctly
          }

          final updatedUser = currentAuth.user!.copyWith(
            name: response.userData!['full_name'] ?? response.userData!['name'] ?? currentAuth.user!.name,
            photoUrl: photoUrl,
          );
          authNotifier.setAuthenticatedUser(updatedUser);
          print('✅ AuthProvider synchronized with fresh profile data (photo: ${photoUrl.isEmpty ? "cleared" : "updated"})');
        }

        return CachedProfileData(
          userData: response.userData,
          lastFetched: DateTime.now(),
        );
      }
      
      // ONLY if fetch explicitly returned 404 (Not Found), ensure authProvider is reset
      if (response.statusCode == 404) {
        final authNotifier = ref.read(authProvider.notifier);
        final currentAuth = ref.read(authProvider);
        if (currentAuth.user != null) {
          final resetUser = currentAuth.user!.copyWith(
            name: currentAuth.user!.email.split('@')[0],
            photoUrl: '', // Clear photo URL
          );
          authNotifier.setAuthenticatedUser(resetUser);
          print('⚠️ Profile confirmed deleted (404). Resetting AuthProvider user info.');
        }
        return CachedProfileData();
      }
      
      // On other errors (timeout, 500, etc.), keep existing state if we have it
      print('ℹ️ Profile fetch failed (${response.statusCode}). Keeping existing state.');
      return state.value ?? CachedProfileData();
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return state.value ?? CachedProfileData();
    }
  }

  // Refresh profile data (can be called anytime)
  Future<void> refresh() async {
    // Keep current state while loading to avoid UI flickers
    state = AsyncValue<CachedProfileData>.loading().copyWithPrevious(state);
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
