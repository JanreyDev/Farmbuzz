import 'package:flutter/material.dart';

class ThemeModeController {
  ThemeModeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  static void setMode(ThemeMode value) {
    mode.value = value;
  }

  static void setDarkMode(bool enabled) {
    mode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}
