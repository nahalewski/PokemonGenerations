import 'package:flutter/material.dart';
import 'package:pokemon_generations/core/theme/app_colors.dart';
import 'package:pokemon_generations/core/theme/app_typography.dart';

class AppTheme {
  static const Color neonBlue = Color(0xFF00E5FF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurface,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.onSurface),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.onSurface),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.onSurface),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.onSurface),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.onSurface),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.onSurface),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.onSurface),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.onSurface),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.onSurface),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.onSurface),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
