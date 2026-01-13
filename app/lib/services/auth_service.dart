import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../models/token_pair.dart';

/// Response model for register API
class RegisterResponse {
  final bool success;
  final String message;
  final String? verificationToken;
  final String? userId;
  final String? email;
  final String? error;

  RegisterResponse({
    required this.success,
    required this.message,
    this.verificationToken,
    this.userId,
    this.email,
    this.error,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      verificationToken: json['verificationToken'],
      userId: user?['id'],
      email: user?['email'],
      error: json['error']?.toString(),
    );
  }
}

/// Response model for login API
class LoginResponse {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? error;

  LoginResponse({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      accessToken: json['access'],
      refreshToken: json['refresh'],
      error: json['error']?.toString(),
    );
  }
}

/// Response model for OTP verification
class VerifyOTPResponse {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? error;

  VerifyOTPResponse({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponse(
      success: json['success'] ?? false,
      accessToken: json['access'],
      refreshToken: json['refresh'],
      error: json['error']?.toString(),
    );
  }
}

/// Response model for forgot password
class ForgotPasswordResponse {
  final bool success;
  final String message;
  final String? passResetToken;
  final String? error;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.passResetToken,
    this.error,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      passResetToken: json['passResetToken'],
      error: json['error']?.toString(),
    );
  }
}

/// Response model for forgot password OTP verify
class ForgotPasswordOTPVerifyResponse {
  final bool success;
  final String message;
  final String? passwordResetVerified;
  final String? error;

  ForgotPasswordOTPVerifyResponse({
    required this.success,
    required this.message,
    this.passwordResetVerified,
    this.error,
  });

  factory ForgotPasswordOTPVerifyResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordOTPVerifyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      passwordResetVerified: json['passwordResetVerified'],
      error: json['error']?.toString(),
    );
  }
}

/// Response model for simple success/error responses
class SimpleResponse {
  final bool success;
  final String message;
  final String? error;

  SimpleResponse({
    required this.success,
    required this.message,
    this.error,
  });

  factory SimpleResponse.fromJson(Map<String, dynamic> json) {
    return SimpleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error']?.toString(),
    );
  }
}

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  /// Register a new user
  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register/',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return RegisterResponse.fromJson(e.response!.data);
      }
      return RegisterResponse(
        success: false,
        message: 'Registration failed',
        error: e.message,
      );
    }
  }

  /// Login with email and password
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return LoginResponse.fromJson(e.response!.data);
      }
      return LoginResponse(
        success: false,
        error: e.message ?? 'Login failed',
      );
    }
  }

  /// Verify OTP for registration
  Future<VerifyOTPResponse> verifyOTP({
    required String otp,
    required String verificationToken,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/verify-otp/',
        data: {
          'otp': otp,
          'verificationToken': verificationToken,
        },
      );
      return VerifyOTPResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return VerifyOTPResponse.fromJson(e.response!.data);
      }
      return VerifyOTPResponse(
        success: false,
        error: e.message ?? 'OTP verification failed',
      );
    }
  }

  /// Resend registration OTP
  Future<SimpleResponse> resendRegistrationOTP({
    required String verificationToken,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/resend-registration-otp/',
        data: {
          'verificationToken': verificationToken,
        },
      );
      return SimpleResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return SimpleResponse.fromJson(e.response!.data);
      }
      return SimpleResponse(
        success: false,
        message: 'Failed to resend OTP',
        error: e.message,
      );
    }
  }

  /// Request forgot password OTP
  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/forget-password/',
        data: {
          'email': email,
        },
      );
      return ForgotPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ForgotPasswordResponse.fromJson(e.response!.data);
      }
      return ForgotPasswordResponse(
        success: false,
        message: 'Failed to send reset code',
        error: e.message,
      );
    }
  }

  /// Verify forgot password OTP
  Future<ForgotPasswordOTPVerifyResponse> forgotPasswordVerifyOTP({
    required String otp,
    required String passResetToken,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/forget-password-otp-verify/',
        data: {
          'otp': otp,
          'passResetToken': passResetToken,
        },
      );
      return ForgotPasswordOTPVerifyResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ForgotPasswordOTPVerifyResponse.fromJson(e.response!.data);
      }
      return ForgotPasswordOTPVerifyResponse(
        success: false,
        message: 'OTP verification failed',
        error: e.message,
      );
    }
  }

  /// Reset password with verified token
  Future<SimpleResponse> resetPassword({
    required String newPassword,
    required String passwordResetVerified,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/forgot-password-set/',
        data: {
          'new_password': newPassword,
          'passwordResetVerified': passwordResetVerified,
        },
      );
      return SimpleResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return SimpleResponse.fromJson(e.response!.data);
      }
      return SimpleResponse(
        success: false,
        message: 'Password reset failed',
        error: e.message,
      );
    }
  }

  /// Resend forgot password OTP
  Future<SimpleResponse> resendForgotPasswordOTP({
    required String passResetToken,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/resend-forget-password-otp/',
        data: {
          'passResetToken': passResetToken,
        },
      );
      return SimpleResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return SimpleResponse.fromJson(e.response!.data);
      }
      return SimpleResponse(
        success: false,
        message: 'Failed to resend OTP',
        error: e.message,
      );
    }
  }

  /// Refresh access token using refresh token
  Future<TokenPair?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/token/refresh/',
        data: {
          'refresh': refreshToken,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final String? accessToken = data['access'];
        final String? newRefreshToken = data['refresh'];
        
        if (accessToken != null) {
          return TokenPair(
            accessToken: accessToken,
            refreshToken: newRefreshToken ?? refreshToken, // Use new if provided, else keep old
          );
        }
      }
      return null;
    } on DioException catch (e) {
      print('❌ Token refresh failed: ${e.message}');
      return null;
    }
  }

  /// Delete account
  Future<SimpleResponse> deleteAccount() async {
    try {
      final response = await _dioClient.dio.delete('/auth/delete-account/');
      return SimpleResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return SimpleResponse.fromJson(e.response!.data);
      }
      return SimpleResponse(
        success: false,
        message: 'Failed to delete account',
        error: e.message,
      );
    }
  }

  /// Sign out (placeholder - can be extended)
  Future<void> signOut() async {
    // Clear any server-side sessions if needed
  }
}
