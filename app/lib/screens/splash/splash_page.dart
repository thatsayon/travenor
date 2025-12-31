import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../utils/app_storage.dart';
import '../../services/google_sign_in_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;


  @override
  void initState() {
    super.initState();
    // Do not remove native splash here. We wait for the timer/loading to complete.
    _timer = Timer(const Duration(seconds: 2), _navigate);
  }

  void _navigate() async {
    final isFirstLaunch = await AppStorage().isFirstLaunch();
    final googleSignInService = GoogleSignInService();
    final isAuthenticated = await googleSignInService.isAuthenticated();

    if (!mounted) return;

    // Determine navigation route
    String route;
    if (isAuthenticated) {
      // User is logged in, go to home
      route = AppRoutes.home;
    } else if (isFirstLaunch) {
      // First time launch, show onboarding
      route = AppRoutes.onboarding;
    } else {
      // Not logged in, show sign in
      route = AppRoutes.login;
    }
    
    // Remove the native splash screen immediately before navigating
    FlutterNativeSplash.remove();

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We show a simple container matching the splash background color
    // This acts as a fallback/buffer if the native splash is removed slightly early
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const SizedBox.shrink(), // No Flutter-side logo needed
    );
  }
}
