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
  final dioClient = ref.watch(dioClientProvider);
  return AuthService(dioClient);
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
    _checkStoredAuth();
  }

  // Check for stored authentication (refresh token)
  Future<void> _checkStoredAuth() async {
    try {
      // Check if refresh token exists in secure storage
      final refreshToken = await SecureStorageService.getRefreshToken();
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        print('✅ Refresh token found - attempting to refresh access token');
        state = state.copyWith(status: AuthStatus.loading);
        
        // Attempt to refresh the access token
        final tokens = await _authService.refreshAccessToken(refreshToken);
        
        if (tokens != null) {
          // Successfully refreshed - update tokens
          await SecureStorageService.saveRefreshToken(tokens.refreshToken);
          
          state = state.copyWith(
            status: AuthStatus.authenticated,
            accessToken: tokens.accessToken,
          );
          
          print('✅ Access token refreshed successfully - user auto-logged in');
        } else {
          // Refresh failed - token expired or invalid
          print('❌ Token refresh failed - clearing refresh token');
          await SecureStorageService.deleteRefreshToken();
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        print('ℹ️ No refresh token found - user needs to sign in');
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('❌ Error checking stored auth: $e');
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  void setAuthenticatedUser(UserModel user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  /// Sign In with Email & Password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.accessToken != null) {
        // Save refresh token
        if (response.refreshToken != null) {
          await SecureStorageService.saveRefreshToken(response.refreshToken!);
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          user: UserModel(
            email: email,
            name: email.split('@')[0],
          ),
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.error ?? 'Login failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sign Up - returns verification token for OTP flow
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        fullName: name,
      );

      if (response.success && response.verificationToken != null) {
        state = state.copyWith(
          status: AuthStatus.pendingVerification,
          verificationToken: response.verificationToken,
          pendingEmail: email,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.error ?? response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Verify OTP for registration
  Future<bool> verifyOTP(String otp) async {
    if (state.verificationToken == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No verification token found',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.verifyOTP(
        otp: otp,
        verificationToken: state.verificationToken!,
      );

      if (response.success && response.accessToken != null) {
        if (response.refreshToken != null) {
          await SecureStorageService.saveRefreshToken(response.refreshToken!);
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          verificationToken: null,
          user: UserModel(
            email: state.pendingEmail ?? '',
            name: state.pendingEmail?.split('@')[0] ?? '',
          ),
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.pendingVerification,
          errorMessage: response.error ?? 'OTP verification failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.pendingVerification,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Resend registration OTP
  Future<bool> resendOTP() async {
    if (state.verificationToken == null) return false;

    try {
      final response = await _authService.resendRegistrationOTP(
        verificationToken: state.verificationToken!,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Forgot password - request OTP
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.forgotPassword(email: email);

      if (response.success && response.passResetToken != null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          passResetToken: response.passResetToken,
          pendingEmail: email,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.error ?? response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Verify forgot password OTP
  Future<bool> forgotPasswordVerifyOTP(String otp) async {
    if (state.passResetToken == null) return false;

    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.forgotPasswordVerifyOTP(
        otp: otp,
        passResetToken: state.passResetToken!,
      );

      if (response.success && response.passwordResetVerified != null) {
        state = state.copyWith(
          status: AuthStatus.pendingPasswordReset,
          passwordResetVerified: response.passwordResetVerified,
          passResetToken: null,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: response.error ?? response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String newPassword) async {
    if (state.passwordResetVerified == null) return false;

    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.resetPassword(
        newPassword: newPassword,
        passwordResetVerified: state.passwordResetVerified!,
      );

      if (response.success) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          passwordResetVerified: null,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.pendingPasswordReset,
          errorMessage: response.error ?? response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.pendingPasswordReset,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Resend forgot password OTP
  Future<bool> resendForgotPasswordOTP() async {
    if (state.passResetToken == null) return false;

    try {
      final response = await _authService.resendForgotPasswordOTP(
        passResetToken: state.passResetToken!,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Sign In with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _googleSignInService.signInWithGoogle();
      
      if (result != null) {
        await SecureStorageService.saveRefreshToken(result.tokens.refreshToken);
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          accessToken: result.tokens.accessToken,
          refreshToken: result.tokens.refreshToken,
          errorMessage: null,
        );
        
        print('✅ Google sign-in successful');
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

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignInService.signOut();
      await SecureStorageService.deleteRefreshToken();
      
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        accessToken: null,
        refreshToken: null,
        verificationToken: null,
        passResetToken: null,
        passwordResetVerified: null,
      );
      
      print('✅ User signed out - all tokens cleared');
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update access token (used by AuthInterceptor after automatic refresh)
  void updateAccessToken(String accessToken) {
    state = state.copyWith(accessToken: accessToken);
    print('🔄 Access token updated in state');
  }

  /// Clear Error
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
