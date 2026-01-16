import 'package:flutter/material.dart';

// Screens
import '../screens/splash/splash_page.dart';
import '../screens/onboarding/pages/onboarding_page.dart';
import '../screens/auth/sign_in_page.dart';
import '../screens/auth/sign_up_page.dart';
import '../screens/auth/forgot_password_page.dart';
import '../screens/auth/otp_verification_page.dart';
import '../screens/auth/reset_password_page.dart';
import '../screens/auth/reset_password_page.dart';
import '../screens/main_navigation.dart';
import '../screens/tour/tour_details_page.dart';
import '../models/tour_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String tourDetails = '/tour-details';

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

      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordPage(),
        );

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtpVerificationPage(
            email: args?['email'] ?? '',
            isPasswordReset: args?['isPasswordReset'] ?? false,
          ),
        );

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordPage(
            email: args?['email'] ?? '',
          ),
        );

      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingPage(),
        );
        
      case tourDetails:
        final tour = settings.arguments as TourModel;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => TourDetailsPage(tour: tour),
        );

      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MainNavigation(
            initialIndex: args?['initialTab'] ?? 0,
          ),
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
