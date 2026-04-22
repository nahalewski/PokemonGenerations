import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F111A);
  static const Color surface = Color(0xFF1A1D2E);
  static const Color primary = Color(0xFF64FFDA);
  static const Color secondary = Color(0xFFBD93F9);
  static const Color accent = Color(0xFF8BE9FD);
  static const Color error = Color(0xFFFF5555);
  static const Color success = Color(0xFF50FA7B);
  static const Color warning = Color(0xFFFFB86C);
  static const Color textBody = Color(0xFFE6E6E6);
  static const Color textDim = Color(0xFFA0A0A0);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -1,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: AppColors.textBody,
      ),
    ),
  );
}
