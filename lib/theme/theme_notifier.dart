import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:moodly_client/theme/app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  late ThemeData _currentTheme;
  late ThemeMode _themeMode;
  Color _primaryColor = AccentColors.blue;

  ThemeNotifier() {
    _themeMode = ThemeMode.system;
    _updateTheme();
  }

  ThemeData get theme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _updateTheme();
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    _updateTheme();
    notifyListeners();
  }

  void _updateTheme() {
    final brightness = PlatformDispatcher.instance.platformBrightness;

    switch (_themeMode) {
      case ThemeMode.system:
        _currentTheme =
            brightness == Brightness.dark
                ? AppTheme.darkTheme(_primaryColor)
                : AppTheme.lightTheme(_primaryColor);
        break;
      case ThemeMode.dark:
        _currentTheme = AppTheme.darkTheme(_primaryColor);
        break;
      case ThemeMode.light:
        _currentTheme = AppTheme.lightTheme(_primaryColor);
        break;
    }
  }
}
