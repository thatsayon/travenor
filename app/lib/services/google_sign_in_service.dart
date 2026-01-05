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

  // Production URL
  static const String _backendUrl = 'https://travenor-v1.thatsayon.com/auth/google/';

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
        
        String cleanMessage = 'Something went wrong, please try again.';
        
        if (response.statusCode! >= 500) {
          cleanMessage = 'Server error. Please try again later.';
        } else {
          // Try to extract useful message from backend JSON
          try {
            if (response.data is Map<String, dynamic>) {
              final data = response.data as Map<String, dynamic>;
              if (data.containsKey('detail')) {
                cleanMessage = data['detail'].toString();
              } else if (data.containsKey('message')) {
                cleanMessage = data['message'].toString();
              } else if (data.containsKey('error')) {
                cleanMessage = data['error'].toString();
              } else if (data.containsKey('non_field_errors')) {
                final errors = data['non_field_errors'];
                if (errors is List && errors.isNotEmpty) {
                  cleanMessage = errors.first.toString();
                }
              }
            } else if (response.data is String) {
                // If it's a short string, use it. If HTML, ignore it.
                final String body = response.data;
                if (body.length < 100 && !body.trim().startsWith('<')) {
                   cleanMessage = body;
                }
            }
          } catch (_) {
            // parsing failed, keep default message
          }
        }
        
        throw AuthException(cleanMessage);
      }
    } catch (error) {
      print('💥 Exception caught: $error');
      
      if (error is AuthException) rethrow;

      if (error is DioException) {
         if (error.type == DioExceptionType.connectionTimeout || 
             error.type == DioExceptionType.receiveTimeout ||
             error.type == DioExceptionType.sendTimeout) {
            throw AuthException('Connection timed out. Please check your internet.');
         }
         if (error.type == DioExceptionType.connectionError) {
            throw AuthException('No internet connection.');
         }
      }
      
      throw AuthException('Sign In unexpected error. Please try again.');
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

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
