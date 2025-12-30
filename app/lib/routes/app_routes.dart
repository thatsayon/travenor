import 'package:flutter/material.dart';

// Screens
import '../screens/splash/splash_page.dart';
import '../screens/onboarding/pages/onboarding_page.dart';
import '../screens/auth/sign_in_page.dart';
import '../screens/auth/sign_up_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String onboarding = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashPage(),
        );

      case login:
      case signIn:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignInPage(),
        );

      case signUp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignUpPage(),
        );

      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingPage(),
        );
        
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Home Page (TODO)'))),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
