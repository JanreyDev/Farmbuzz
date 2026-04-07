import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/auth/presentation/login_screen.dart';
import 'package:app/features/auth/presentation/signup_screen.dart';
import 'package:app/features/home/presentation/home_screen.dart';
import 'package:app/features/splash/presentation/splash_screen.dart';
import 'package:app/features/subscription/presentation/subscription_screen.dart';
import 'package:flutter/material.dart';

class FarmBuzzApp extends StatelessWidget {
  const FarmBuzzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmBuzz',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignUpScreen(),
        AppRoutes.subscription: (_) => const SubscriptionScreen(),
      },
    );
  }
}
