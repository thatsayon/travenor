import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_storage.dart';
import '../../models/auth_state.dart';
import '../../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timeoutTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    
    // Set a timeout to prevent infinite splash screen (max 3 seconds)
    _timeoutTimer = Timer(const Duration(seconds: 3), () {
      if (!_hasNavigated && mounted) {
        print('⚠️ Splash timeout - forcing navigation');
        _forceNavigation();
      }
    });
    
    // Check auth state immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasNavigated) {
        final authState = ref.read(authProvider);
        _handleAuthState(authState);
      }
    });
  }

  void _forceNavigation() {
    final appStorage = AppStorage();
    final isFirstLaunch = appStorage.isFirstLaunchSync();
    
    if (isFirstLaunch) {
      _navigateToOnboarding();
    } else {
      _navigateToLogin();
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _navigate(String route) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _timeoutTimer?.cancel();
    
    // Navigate immediately without waiting for next frame
    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _navigateToLogin() {
    _navigate(AppRoutes.login);
  }

  void _navigateToOnboarding() {
    _navigate(AppRoutes.onboarding);
  }

  void _navigateToHome() {
    _navigate(AppRoutes.home);
  }

  void _handleAuthState(AuthState authState) {
    // Wait for auth check to complete before navigating
    if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
      // Still checking authentication - stay on splash screen
      return;
    }

    final appStorage = AppStorage();
    final isFirstLaunch = appStorage.isFirstLaunchSync();

    if (authState.status == AuthStatus.authenticated) {
      // User is authenticated - go to home
      print('✅ User authenticated - navigating to home');
      appStorage.setAuthenticatedSync(true);
      _navigateToHome();
    } else {
      // User is not authenticated
      appStorage.setAuthenticatedSync(false);
      
      if (isFirstLaunch) {
        print('ℹ️ First launch - navigating to onboarding');
        _navigateToOnboarding();
      } else {
        print('ℹ️ Not authenticated - navigating to login');
        _navigateToLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!_hasNavigated) {
        _handleAuthState(next);
      }
    });

    // Invisible scaffold that keeps native splash visible
    return const Scaffold(
      backgroundColor: Color(0xFF0D6EFD),
      body: SizedBox.shrink(),
    );
  }
}
