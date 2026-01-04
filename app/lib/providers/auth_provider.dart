import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/dio_client.dart';
import '../services/google_sign_in_service.dart';
import '../services/secure_storage_service.dart';

// Providers for services
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final googleSignInServiceProvider = Provider<GoogleSignInService>(
  (ref) => GoogleSignInService(),
);

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final GoogleSignInService _googleSignInService;

  AuthNotifier(this._authService, this._googleSignInService)
      : super(const AuthState()) {
    // Check for stored authentication on initialization
    _checkStoredAuth();
  }

  // Check for stored authentication (refresh token)
  Future<void> _checkStoredAuth() async {
    try {
      // Check if refresh token exists in secure storage
      final hasToken = await SecureStorageService.hasRefreshToken();
      if (hasToken) {
        print('✅ Refresh token found in secure storage');
        // Note: In a full implementation, we would attempt to refresh the access token here
        // For now, we just mark as unauthenticated and require manual sign-in
        state = state.copyWith(status: AuthStatus.unauthenticated);
      } else {
        print('ℹ️ No refresh token found - user needs to sign in');
      }
    } catch (e) {
      print('❌ Error checking stored auth: $e');
    }
  }

  // Set authenticated user (useful for testing/mocking)
  void setAuthenticatedUser(UserModel user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  // Sign In with Email & Password (for future use)
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authService.signIn(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Sign Up (for future use)
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Sign In with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _googleSignInService.signInWithGoogle();
      
      if (result != null) {
        // Save refresh token to secure storage
        await SecureStorageService.saveRefreshToken(result.tokens.refreshToken);
        
        // Update state with user and access token (in memory)
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          accessToken: result.tokens.accessToken,
          errorMessage: null,
        );
        
        print('✅ Tokens stored securely - Access: in-memory, Refresh: secure storage');
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Google Sign-In cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _googleSignInService.signOut();
      
      // Clear refresh token from secure storage
      await SecureStorageService.deleteRefreshToken();
      
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        accessToken: null,
      );
      
      print('✅ User signed out - all tokens cleared');
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }
}

// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final googleSignInService = ref.watch(googleSignInServiceProvider);
  return AuthNotifier(authService, googleSignInService);
});
