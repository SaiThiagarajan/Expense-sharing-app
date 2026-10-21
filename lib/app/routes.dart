import 'package:flutter/material.dart';

import '../screens/auth/create_account_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/shell/app_shell.dart';

/// Named-route infrastructure for the app's top-level flow (onboarding,
/// auth, shell). Screens that need arguments (expense details, settle up,
/// ...) are pushed directly with [MaterialPageRoute] from the screen that
/// triggers them instead of going through here.
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String createAccount = '/create-account';
  static const String shell = '/shell';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeThrough(const LoginScreen(), settings);
      case forgotPassword:
        return _slideUp(const ForgotPasswordScreen(), settings);
      case createAccount:
        return _slideUp(const CreateAccountScreen(), settings);
      case shell:
        return _fadeThrough(const AppShell(), settings);
      case onboarding:
      default:
        return _fadeThrough(const OnboardingScreen(), settings);
    }
  }

  static Route<dynamic> _fadeThrough(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, page) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.98, end: 1.0).animate(curved),
            child: page,
          ),
        );
      },
    );
  }

  static Route<dynamic> _slideUp(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, page) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: page,
          ),
        );
      },
    );
  }
}
