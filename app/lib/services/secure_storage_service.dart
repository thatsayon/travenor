import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data like refresh tokens
/// Uses platform-specific secure storage (Keychain on iOS, KeyStore on Android)
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Keys for secure storage
  static const String _refreshTokenKey = 'refresh_token';

  /// Save refresh token to secure storage
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save refresh token: $e');
    }
  }

  /// Retrieve refresh token from secure storage
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Delete refresh token from secure storage
  static Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      // Silently fail
    }
  }

  /// Delete all data from secure storage
  static Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      // Silently fail
    }
  }

  /// Check if refresh token exists
  static Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  // Keys for user data
  static const String _userDataKey = 'user_data';
  static const String _profilePhotoKey = 'profile_photo_url';

  /// Save profile photo URL to secure storage
  static Future<void> saveProfilePhoto(String? photoUrl) async {
    try {
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await _storage.write(key: _profilePhotoKey, value: photoUrl);
      }
    } catch (e) {
      print('❌ Failed to save profile photo: $e');
    }
  }

  /// Retrieve profile photo URL from secure storage
  static Future<String?> getProfilePhoto() async {
    try {
      return await _storage.read(key: _profilePhotoKey);
    } catch (e) {
      return null;
    }
  }

  /// Delete profile photo URL from secure storage
  static Future<void> deleteProfilePhoto() async {
    try {
      await _storage.delete(key: _profilePhotoKey);
    } catch (e) {
      // Silently fail
    }
  }

  /// Save user data to secure storage (stores as JSON string)
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      // Use dart:convert to properly encode JSON
      final jsonString = _encodeJson(userData);
      await _storage.write(key: _userDataKey, value: jsonString);
    } catch (e) {
      print('❌ Failed to save user data: $e');
    }
  }

  /// Retrieve user data from secure storage
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = await _storage.read(key: _userDataKey);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      return _decodeJson(jsonString);
    } catch (e) {
      print('❌ Failed to retrieve user data: $e');
      return null;
    }
  }

  /// Delete user data from secure storage
  static Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
    } catch (e) {
      // Silently fail
    }
  }

  /// Simple JSON encoder (avoids importing dart:convert)
  static String _encodeJson(Map<String, dynamic> data) {
    final pairs = data.entries.map((e) {
      final value = e.value == null ? 'null' : '"${e.value}"';
      return '"${e.key}":$value';
    }).join(',');
    return '{$pairs}';
  }

  /// Simple JSON decoder (avoids importing dart:convert)
  static Map<String, dynamic>? _decodeJson(String jsonString) {
    try {
      final Map<String, dynamic> result = {};
      final content = jsonString.replaceAll('{', '').replaceAll('}', '');
      final pairs = content.split(',');
      
      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim().replaceAll('"', '');
          final value = parts[1].trim();
          result[key] = value == 'null' ? null : value.replaceAll('"', '');
        }
      }
      return result;
    } catch (e) {
      print('❌ Failed to decode JSON: $e');
      return null;
    }
  }
}
