import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_storage.dart';
import '../../services/google_sign_in_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();

    // Trigger animation on first frame (modern pattern)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _animateIn = true);
    });

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

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: AnimatedOpacity(
          opacity: _animateIn ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: _animateIn ? 1.0 : 0.96,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            child: AnimatedSlide(
              offset: _animateIn ? Offset.zero : const Offset(0, 0.08),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flight_takeoff,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Travenor',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
