import 'package:flutter/material.dart';

const Color kGoldAccent = Color(0xFFC9A227);
const Color kGoldSoft = Color(0xFFE7D7A0);
const Color kNeutralText = Color(0xFF2B2B2B);
const Color kNeutralSubtle = Color(0xFF666666);
const Color kSurfaceLight = Color(0xFFF6F6F4);

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kGoldAccent,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: kNeutralText,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: kNeutralText,
        displayColor: kNeutralText,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: kGoldAccent,
        linearTrackColor: Color(0xFFD9D9D9),
      ),
    );
  }
}
