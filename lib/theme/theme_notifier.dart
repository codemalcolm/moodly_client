import 'package:flutter/material.dart';
import 'package:moodly_client/theme/app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  late ThemeData _currentTheme;
  bool _isDarkMode = false;
  Color _primaryColor = AccentColors.blue;

  ThemeNotifier() {
    _currentTheme = AppTheme.lightTheme(_primaryColor);
  }

  ThemeData get theme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  void toggleDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _currentTheme =
        isDark
            ? AppTheme.darkTheme(_primaryColor)
            : AppTheme.lightTheme(_primaryColor);
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    _currentTheme =
        _isDarkMode
            ? AppTheme.darkTheme(_primaryColor)
            : AppTheme.lightTheme(_primaryColor);
    notifyListeners();
  }
}
