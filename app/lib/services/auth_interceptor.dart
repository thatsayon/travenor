import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/secure_storage_service.dart';
import '../services/auth_service.dart';

/// Dio interceptor that automatically refreshes access token on 401 errors
class AuthInterceptor extends Interceptor {
  final WidgetRef ref;
  final AuthService authService;

  AuthInterceptor({required this.ref, required this.authService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get current access token from AuthProvider state
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      // Don't add token for auth endpoints (login, register, refresh)
      // This prevents sending expired tokens to the refresh endpoint which causes 401 loops
      final path = options.path;
      if (!path.contains('/auth/token/refresh/') && 
          !path.contains('/auth/login/') && 
          !path.contains('/auth/register/')) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Ignore 401s from the refresh endpoint to prevent infinite loops
      if (err.requestOptions.path.contains('/auth/token/refresh/')) {
        return handler.next(err);
      }

      print('⚠️ 401 Unauthorized - attempting to refresh token');

      try {
        // Get refresh token from secure storage
        final refreshToken = await SecureStorageService.getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) {
          print('❌ No refresh token available - user needs to re-login');
          // Sign out user
          ref.read(authProvider.notifier).signOut();
          return handler.reject(err);
        }

        // Attempt to refresh the access token
        final tokens = await authService.refreshAccessToken(refreshToken);

        if (tokens == null) {
          print('❌ Token refresh failed - clearing tokens');
          await SecureStorageService.deleteRefreshToken();
          ref.read(authProvider.notifier).signOut();
          return handler.reject(err);
        }

        print('✅ Token refreshed successfully');

        // Update refresh token in secure storage
        await SecureStorageService.saveRefreshToken(tokens.refreshToken);

        // Update access token in AuthProvider state
        final authNotifier = ref.read(authProvider.notifier);
        authNotifier.updateAccessToken(tokens.accessToken);

        // Retry the original request with new access token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';

        print('🔄 Retrying original request with new token');

        try {
          final response = await Dio().fetch(options);
          return handler.resolve(response);
        } catch (e) {
          return handler.reject(err);
        }
      } catch (e) {
        print('💥 Error during token refresh: $e');
        return handler.reject(err);
      }
    } else {
      // Not a 401 error, pass through
      handler.next(err);
    }
  }
}
