import 'package:flutter/material.dart';

class LightColors {
  static const background = Color(0xFFF9FBFB);
  static const surface = Color(0xFFF4F9F9);
  static const secondary = Color(0xFF6B7280);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
}

class DarkColors {
  static const background = Color(0xFF1B150B);
  static const surface = Color(0xFF292424);
  static const secondary = Color(0xFF9CA3AF);
  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFF9CA3AF);
  static const border = Color(0xFF2C2C2C);
}

class AccentColors {
  static const blue = Color(0xFF579AD1);
  static const red = Color(0xFFF783AC);
  static const orange = Color(0xFFE99234);
  static const green = Color(0xFF249271);
  static const yellow = Color(0xFFEFD126);
  static const purple = Color(0xFF9775FA);
}

class AccentBackgroundColors {
  static const blue = Color(0x33579AD1);
  static const red = Color(0x33F783AC);
  static const orange = Color(0x33E99234);
  static const green = Color(0x33249271);
  static const yellow = Color(0x33EFD126);
  static const purple = Color(0x339775FA);
}

Color getAccentBackgroundColor(Color primaryColor) {
  if (primaryColor == AccentColors.blue) return AccentBackgroundColors.blue;
  if (primaryColor == AccentColors.red) return AccentBackgroundColors.red;
  if (primaryColor == AccentColors.orange) return AccentBackgroundColors.orange;
  if (primaryColor == AccentColors.green) return AccentBackgroundColors.green;
  if (primaryColor == AccentColors.yellow) return AccentBackgroundColors.yellow;
  if (primaryColor == AccentColors.purple) return AccentBackgroundColors.purple;
  return AccentBackgroundColors.blue; // fallback
}

class AppTheme {
  static ThemeData lightTheme(Color primaryColor) {
    return ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightColors.background,
      primaryColor: primaryColor,
      cardColor: LightColors.surface,
      dividerColor: LightColors.border,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: LightColors.secondary,
        surface: const Color.fromARGB(255, 236, 240, 243),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: LightColors.textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LightColors.surface,
        foregroundColor: LightColors.textPrimary,
        elevation: 0,
        centerTitle: true,
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
      fontFamily: 'Montserrat',
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
        centerTitle: true,
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
