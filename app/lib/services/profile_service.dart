import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/user_profile_model.dart';
import 'dio_client.dart';

/// Response model for profile API operations
class ProfileApiResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? userData;
  final String? error;

  ProfileApiResponse({
    required this.success,
    this.message,
    this.userData,
    this.error,
  });

  factory ProfileApiResponse.fromJson(Map<String, dynamic> json) {
    return ProfileApiResponse(
      success: json['success'] ?? true,
      message: json['message'],
      userData: json['user'] ?? json,
      error: json['error']?.toString(),
    );
  }
}

class ProfileService {
  final DioClient? _dioClient;
  static const String _profileKey = 'user_profile';

  ProfileService([this._dioClient]);

  // Save profile
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final updatedProfile = profile.copyWith(lastUpdated: now);
      await prefs.setString(_profileKey, jsonEncode(updatedProfile.toJson()));
       // print('✅ Profile saved successfully');
    } catch (error) {
       // print('❌ Error saving profile: $error');
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
       // print('❌ Error getting profile: $error');
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
       // print('✅ Profile cleared');
    } catch (error) {
       // print('❌ Error clearing profile: $error');
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

  // ============ API Methods ============

  /// Get profile from backend API
  Future<ProfileApiResponse> getProfileFromApi() async {
    if (_dioClient == null) {
      return ProfileApiResponse(
        success: false,
        error: 'DioClient not initialized',
      );
    }

    try {
      final response = await _dioClient.dio.get('/auth/profile/');
      
      if (response.statusCode == 200) {
        final apiResponse = ProfileApiResponse.fromJson(response.data);
        
        // Cache the profile locally
        if (apiResponse.success && apiResponse.userData != null) {
          await _cacheProfileFromApi(apiResponse.userData!);
        }
        
        return apiResponse;
      }
      return ProfileApiResponse(
        success: false,
        error: 'Failed to fetch profile',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ProfileApiResponse.fromJson(e.response!.data);
      }
      return ProfileApiResponse(
        success: false,
        error: e.message ?? 'Failed to fetch profile',
      );
    }
  }

  /// Update profile via backend API
  /// Uses FormData for multipart/form-data requests (supports file uploads)
  Future<ProfileApiResponse> updateProfileApi({
    String? fullName,
    String? gender,
    String? dateOfBirth, // ISO format: "2004-02-28"
    String? bloodGroup,
    String? presentAddress,
    String? mobileNumber,
    String? emergencyContactNumber,
    String? emergencyContactRelationship,
    String? profilePicPath, // Path to profile picture file
  }) async {
    if (_dioClient == null) {
      return ProfileApiResponse(
        success: false,
        error: 'DioClient not initialized',
      );
    }

    try {
      final formData = FormData.fromMap({
        if (fullName != null) 'full_name': fullName,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (bloodGroup != null) 'blood_group': bloodGroup,
        if (presentAddress != null) 'present_address': presentAddress,
        if (mobileNumber != null) 'mobile_number': mobileNumber,
        if (emergencyContactNumber != null) 'emergency_contact_number': emergencyContactNumber,
        if (emergencyContactRelationship != null) 'emergency_contact_relationship': emergencyContactRelationship,
        if (profilePicPath != null) 'profile_pic': await MultipartFile.fromFile(profilePicPath),
      });

      final response = await _dioClient.dio.patch(
        '/auth/profile/',
        data: formData,
      );
      
      print('✅ Profile updated successfully: ${response.statusCode}');
      
      final apiResponse = ProfileApiResponse.fromJson(response.data);
      
      // Update local cache
      if (apiResponse.success && apiResponse.userData != null) {
        await _cacheProfileFromApi(apiResponse.userData!);
      }
      
      return apiResponse;
    } on DioException catch (e) {
      print('❌ Error updating profile: ${e.response?.data}');
      if (e.response?.data != null) {
        return ProfileApiResponse.fromJson(e.response!.data);
      }
      return ProfileApiResponse(
        success: false,
        error: e.message ?? 'Failed to update profile',
      );
    }
  }

  /// Cache profile data from API response
  Future<void> _cacheProfileFromApi(Map<String, dynamic> userData) async {
    try {
      // Map API response to UserProfileModel
      final profile = UserProfileModel(
        fullName: userData['full_name'] ?? userData['fullName'],
        phoneNumber: userData['phone_number'] ?? userData['phoneNumber'],
        email: userData['email'],
        emergencyContact: userData['emergency_contact'] ?? userData['emergencyContact'],
        lastUpdated: DateTime.now(),
      );
      
      await saveProfile(profile);
    } catch (e) {
      print('⚠️ Error caching profile: $e');
    }
  }
}

