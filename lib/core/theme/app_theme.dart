import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class AppTheme {
  static Future<ThemeMode> get themeMode async {
    return await PreferencesService.getThemeMode();
  }

  static void setThemeMode(ThemeMode mode) {
    PreferencesService.setThemeMode(mode);
  }
}
