import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/token_pair.dart';
import '../models/google_sign_in_result.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid', // Explicitly request openid for ID token
    ],
  );

  final Dio _dio = Dio();

  // Local development: 10.0.2.2 for emulator, or use your computer's IP for physical device
  static const String _backendUrl = 'http://10.0.2.2:8000/auth/google/';

  /// Sign in with Google and exchange ID token with backend
  /// Returns GoogleSignInResult containing user and tokens, or null if cancelled
  Future<GoogleSignInResult?> signInWithGoogle() async {
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
          token: null, // Token no longer stored in UserModel
        );

        final tokens = TokenPair(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        print('✅ User authenticated - returning result');
        
        return GoogleSignInResult(user: user, tokens: tokens);
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

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Google Sign Out successful');
    } catch (e) {
      print('❌ Google Sign Out failed: $e');
    }
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
