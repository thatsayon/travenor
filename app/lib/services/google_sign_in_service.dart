import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  static const String _userDataKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _isAuthenticatedKey = 'is_authenticated';

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
         // print('Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      
      // Create user model from Google account data
      final user = UserModel(
        id: account.id,
        name: account.displayName ?? '',
        email: account.email,
        photoUrl: account.photoUrl,
        token: auth.idToken,
      );

      // Store user data and token locally
      await _saveUserData(user);
      await _saveAuthState(true);

       // print('✅ Google Sign-In Success:');
       // print('  Name: ${user.name}');
       // print('  Email: ${user.email}');
       // print('  Photo URL: ${user.photoUrl}');
       // print('  Stored locally');

      return user;
    } catch (error) {
       // print('❌ Google Sign-In Error: $error');
      return null;
    }
  }

  // Save user data to local storage
  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
       // print('❌ Error saving user data: $error');
    }
  }

  // Save authentication state
  Future<void> _saveAuthState(bool isAuthenticated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAuthenticatedKey, isAuthenticated);
    } catch (error) {
       // print('❌ Error saving auth state: $error');
    }
  }

  // Get stored user data
  Future<UserModel?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool(_isAuthenticatedKey) ?? false;
      
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
       // print('❌ Error getting stored user: $error');
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isAuthenticatedKey) ?? false;
    } catch (error) {
       // print('❌ Error checking auth status: $error');
      return false;
    }
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (error) {
       // print('❌ Error getting stored token: $error');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_tokenKey);
      await prefs.setBool(_isAuthenticatedKey, false);
      
       // print('✅ Google Sign-Out Success');
    } catch (error) {
       // print('❌ Google Sign-Out Error: $error');
    }
  }

  // Check if already signed in (from Google)
  Future<UserModel?> getCurrentUser() async {
    try {
      // First check local storage
      final storedUser = await getStoredUser();
      if (storedUser != null) {
        return storedUser;
      }

      // Then try silent sign-in with Google
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      
      final user = UserModel(
        id: account.id,
        name: account.displayName ?? '',
        email: account.email,
        photoUrl: account.photoUrl,
        token: auth.idToken,
      );

      // Store for next time
      await _saveUserData(user);
      await _saveAuthState(true);

      return user;
    } catch (error) {
       // print('❌ Get Current User Error: $error');
      return null;
    }
  }
}
