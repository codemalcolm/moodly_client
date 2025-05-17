import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moodly_client/theme/app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  static const String _primaryColorKey = 'primaryColor';

  late ThemeData _currentTheme;
  late ThemeMode _themeMode;
  Color _primaryColor = AccentColors.blue;

  ThemeNotifier() {
    _themeMode = ThemeMode.system;
    _loadSettings();
  }

  ThemeData get theme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey);
    final colorValue = prefs.getInt(_primaryColorKey);

    if (modeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.toString() == modeString,
        orElse: () => ThemeMode.system,
      );
    }

    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }

    _updateTheme();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
    _updateTheme();
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
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
