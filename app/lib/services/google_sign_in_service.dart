import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/app_storage.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid', // Explicitly request openid for ID token
    ],
  );

  final Dio _dio = Dio();

  static const String _userDataKey = 'user_data';
  static const String _tokenKey = 'auth_token'; // Access Token
  static const String _refreshTokenKey = 'refresh_token'; // Refresh Token

  // Use 10.0.2.2 for Android emulator (points to host machine's localhost)
  // Use your computer's IP address (e.g., 192.168.x.x) for physical device
  static const String _backendUrl = 'http://10.0.2.2:8000/auth/google/';

  // Sign in with Google and verify with backend
  Future<UserModel?> signInWithGoogle() async {
    try {
      // 1. Google Sign In
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Failed to retrieve Google ID Token');
      }

      print('✅ Google Sign In successful');
      print('📧 Email: ${account.email}');
      print('👤 Name: ${account.displayName}');
      print('');
      print('═══════════════════════════════════════');
      print('🔑 ID TOKEN START (COPY EVERYTHING BELOW)');
      print('═══════════════════════════════════════');
      print(idToken);
      print('═══════════════════════════════════════');
      print('🔑 ID TOKEN END (COPY EVERYTHING ABOVE)');
      print('═══════════════════════════════════════');
      print('');
      print('📏 Token Length: ${idToken.length} characters');
      print('📐 Length % 4 = ${idToken.length % 4} (should be 0 for valid base64)');
      print('📤 Sending to backend: $_backendUrl');
      
      final response = await _dio.post(
        _backendUrl,
        data: {
          'token': idToken,
        },
        options: Options(
          validateStatus: (status) => true, // capture all statuses
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('📥 Backend Response Status: ${response.statusCode}');
      print('📥 Backend Response Body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data == null) throw Exception('Backend returned empty data');
        
        final String? accessToken = data['access'];
        final String? refreshToken = data['refresh'];
        
        if (accessToken == null || refreshToken == null) {
          throw Exception('Backend missing tokens. Got: ${data.keys.join(", ")}');
        }

        print('✅ Tokens received successfully!');
        
        final user = UserModel(
          id: account.id,
          name: account.displayName ?? '',
          email: account.email,
          photoUrl: account.photoUrl,
          token: accessToken, 
        );

        await _saveUserData(user);
        await _saveRefreshToken(refreshToken);
        _saveAuthState(true);

        print('✅ User authenticated and saved');
        return user;
      } else {
        print('❌ Backend Error: ${response.statusCode}');
        print('❌ Error Details: ${response.data}');
        throw Exception('Login Failed: ${response.statusCode}. ${response.data}');
      }
    } catch (error) {
      print('💥 Exception caught: $error');
      // Rethrow if it's already an exception, or wrap new one
      if (error is Exception) rethrow;
      throw Exception('Sign In Error: $error');
    }
  }

  // Save user data to local storage
  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = AppStorage.prefs;
      final userData = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'token': user.token,
      };
      await prefs.setString(_userDataKey, jsonEncode(userData));
      if (user.token != null) {
        await prefs.setString(_tokenKey, user.token!);
      }
    } catch (error) {
      // Silently fail
    }
  }

  // Save refresh token
  Future<void> _saveRefreshToken(String token) async {
    try {
      await AppStorage.prefs.setString(_refreshTokenKey, token);
    } catch (error) {
      // Silently fail
    }
  }

  // Save authentication state
  void _saveAuthState(bool isAuthenticated) {
    try {
      AppStorage.prefs.setBool('is_authenticated', isAuthenticated);
    } catch (error) {
      // Silently fail
    }
  }

  // Get stored user data (synchronous)
  UserModel? getStoredUserSync() {
    try {
      final prefs = AppStorage.prefs;
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      
      if (!isAuthenticated) {
        return null;
      }

      final userDataString = prefs.getString(_userDataKey);
      if (userDataString == null) {
        return null;
      }

      final userData = jsonDecode(userDataString);
      return UserModel(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        photoUrl: userData['photoUrl'],
        token: userData['token'],
      );
    } catch (error) {
      return null;
    }
  }

  // Legacy async method for compatibility
  Future<UserModel?> getStoredUser() async {
    return getStoredUserSync();
  }

  // Check if user is authenticated (synchronous)
  bool isAuthenticatedSync() {
    try {
      return AppStorage.prefs.getBool('is_authenticated') ?? false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    return isAuthenticatedSync();
  }

  // Get stored access token (synchronous)
  String? getStoredTokenSync() {
    try {
      return AppStorage.prefs.getString(_tokenKey);
    } catch (error) {
      return null;
    }
  }
  
  // Get stored refresh token (synchronous)
  String? getStoredRefreshTokenSync() {
    try {
      return AppStorage.prefs.getString(_refreshTokenKey);
    } catch (error) {
      return null;
    }
  }

  Future<String?> getStoredToken() async {
    return getStoredTokenSync();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      
      final prefs = AppStorage.prefs;
      await prefs.remove(_userDataKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.setBool('is_authenticated', false);
    } catch (error) {
      // Silently fail
    }
  }

  // Check if current user exists (auto-login check)
  Future<UserModel?> getCurrentUser() async {
    try {
      // 1. Check local storage first
      final storedUser = getStoredUserSync();
      if (storedUser != null) {
        return storedUser;
      }
      return null;

      // Note: We REMOVED silent Google sign-in here because if we depend on backend JWT,
      // we can't just silently sign in with Google and get a valid JWT without calling backend again.
      // If we need to refresh the token, we should do it via refresh token endpoint logic 
      // which creates a new Access Token. 
      // For now, if local storage is empty, we consider user logged out.
      // If we wanted to persistent login across installs (silent sign in), we'd need to:
      // 1. Silent Google Sign In
      // 2. Call backend again to get new JWTs
      // BUT, usually persisted JWTs (Access/Refresh) are enough.
    } catch (error) {
      return null;
    }
  }
}
