import 'package:flutter/material.dart';

class LightColors {
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFF2F2F2);
  static const secondary = Color(0xFF6B7280);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
}

class DarkColors {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const secondary = Color(0xFF9CA3AF);
  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFF9CA3AF);
  static const border = Color(0xFF2C2C2C);
}

class AccentColors {
  static const blue = Color(0xFF3B82F6);
  static const red = Color(0xFFEF4444);
  static const orange = Color(0xFFF97316);
  static const green = Color(0xFF10B981);
  static const yellow = Color(0xFFEAB308);
  static const purple = Color(0xFF8B5CF6);
}

class AppTheme {
  static ThemeData lightTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightColors.background,
      primaryColor: primaryColor,
      cardColor: LightColors.surface,
      dividerColor: LightColors.border,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: LightColors.secondary,
        surface: LightColors.surface,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: LightColors.textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LightColors.surface,
        foregroundColor: LightColors.textPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColors.surface,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: LightColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DarkColors.background,
      primaryColor: primaryColor,
      cardColor: DarkColors.surface,
      dividerColor: DarkColors.border,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: DarkColors.secondary,
        surface: DarkColors.surface,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: DarkColors.textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkColors.surface,
        foregroundColor: DarkColors.textPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.surface,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: DarkColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      useMaterial3: true,
    );
  }
}
