import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/home/presentation/home_screen.dart';
import 'package:app/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';

class FarmBuzzApp extends StatelessWidget {
  const FarmBuzzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmBuzz',
      theme: AppTheme.light(),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}
