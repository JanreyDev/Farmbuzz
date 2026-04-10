import 'package:app/app/app.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    FarmBuzzApp(
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
    ),
  );
}
