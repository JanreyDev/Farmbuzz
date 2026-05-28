import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
class FarmBuzzApp extends StatelessWidget {
  const FarmBuzzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentGreen,
        secondary: AppColors.golden,
        surface: AppColors.cardDarkGreen,
      ),
    );

    return MaterialApp(
      title: 'FarmBuzz App',
      debugShowCheckedModeBanner: false,
      theme: baseTheme,
      home: const HomeScreen(),
    );
  }
}
