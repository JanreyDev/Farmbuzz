import 'package:app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

const Color kGoldAccent = AppColors.lightPrimary;
const Color kGoldSoft = Color(0xFFE7D7A0);
const Color kNeutralText = AppColors.lightText;
const Color kNeutralSubtle = Color(0xFF666666);
const Color kSurfaceLight = AppColors.lightSecondaryBackground;

class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.lightPrimary,
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightText,
    );

    final baseTheme = ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSecondaryBackground,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: AppColors.lightText,
        displayColor: AppColors.lightText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightText,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.darkPrimary,
      onSecondary: Colors.white,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
    );

    final baseTheme = ThemeData.dark(useMaterial3: true);

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkText,
        elevation: 0,
      ),
    );
  }

  static ThemeData light() => lightTheme();

  static ThemeData dark() => darkTheme();
}
