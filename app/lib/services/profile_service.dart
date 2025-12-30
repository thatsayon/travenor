import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile_model.dart';

class ProfileService {
  static const String _profileKey = 'user_profile';

  // Save profile
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final updatedProfile = profile.copyWith(lastUpdated: now);
      await prefs.setString(_profileKey, jsonEncode(updatedProfile.toJson()));
      print('✅ Profile saved successfully');
    } catch (error) {
      print('❌ Error saving profile: $error');
      rethrow;
    }
  }

  // Get profile
  Future<UserProfileModel?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString(_profileKey);
      
      if (profileString == null) {
        return null;
      }

      final profileJson = jsonDecode(profileString);
      return UserProfileModel.fromJson(profileJson);
    } catch (error) {
      print('❌ Error getting profile: $error');
      return null;
    }
  }

  // Check if profile is complete
  Future<bool> isProfileComplete() async {
    final profile = await getProfile();
    return profile?.isComplete ?? false;
  }

  // Clear profile
  Future<void> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      print('✅ Profile cleared');
    } catch (error) {
      print('❌ Error clearing profile: $error');
    }
  }

  // Update specific fields
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? emergencyContact,
  }) async {
    final currentProfile = await getProfile();
    
    if (currentProfile == null) {
      // Create new profile
      final newProfile = UserProfileModel(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        emergencyContact: emergencyContact,
        lastUpdated: DateTime.now(),
      );
      await saveProfile(newProfile);
    } else {
      // Update existing profile
      final updatedProfile = currentProfile.copyWith(
        fullName: fullName ?? currentProfile.fullName,
        phoneNumber: phoneNumber ?? currentProfile.phoneNumber,
        email: email ?? currentProfile.email,
        emergencyContact: emergencyContact ?? currentProfile.emergencyContact,
        lastUpdated: DateTime.now(),
      );
      await saveProfile(updatedProfile);
    }
  }

  // Export profile data (GDPR compliance)
  Future<Map<String, dynamic>?> exportProfileData() async {
    final profile = await getProfile();
    return profile?.toJson();
  }
}
