import 'user_model.dart';

enum AuthStatus { 
  initial, 
  loading, 
  authenticated, 
  unauthenticated, 
  pendingVerification,  // After registration, waiting for OTP
  pendingPasswordReset, // After forgot password OTP verified, waiting for new password
  error 
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final String? verificationToken;    // For registration OTP
  final String? passResetToken;       // For forgot password OTP
  final String? passwordResetVerified; // After forgot password OTP verified
  final String? pendingEmail;          // Email for pending verification
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.verificationToken,
    this.passResetToken,
    this.passwordResetVerified,
    this.pendingEmail,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? accessToken,
    String? refreshToken,
    String? verificationToken,
    String? passResetToken,
    String? passwordResetVerified,
    String? pendingEmail,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      verificationToken: verificationToken ?? this.verificationToken,
      passResetToken: passResetToken ?? this.passResetToken,
      passwordResetVerified: passwordResetVerified ?? this.passwordResetVerified,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isPendingVerification => status == AuthStatus.pendingVerification;
  bool get isPendingPasswordReset => status == AuthStatus.pendingPasswordReset;
  bool get hasError => status == AuthStatus.error;

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, accessToken: ${accessToken != null ? "***" : null}, errorMessage: $errorMessage)';
  }
}
