import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_storage.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigate immediately - SharedPreferences already loaded in main()
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // All reads are now synchronous (instant) because SharedPreferences was pre-loaded
    final appStorage = AppStorage();
    final isFirstLaunch = appStorage.isFirstLaunchSync();
    final isAuthenticated = appStorage.isAuthenticatedSync();

    // Determine navigation route
    String route;
    if (isAuthenticated) {
      route = AppRoutes.home;
    } else if (isFirstLaunch) {
      route = AppRoutes.onboarding;
    } else {
      route = AppRoutes.login;
    }

    // Use addPostFrameCallback to ensure widget is fully built before navigating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Invisible scaffold that keeps native splash visible
    return const Scaffold(
      backgroundColor: Color(0xFF0D6EFD),
      body: SizedBox.shrink(),
    );
  }
}
