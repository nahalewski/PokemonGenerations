import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  // ── Dark ─────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
        ),
        textTheme: AppTypography.textTheme,
        cardTheme: const CardThemeData(
          color: AppColors.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.zero,
        ),
        buttonTheme: const ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: AppColors.surfaceContainerHighest,
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white24,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          unselectedLabelStyle: TextStyle(fontSize: 9),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xE5000000),
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
        dividerColor: Colors.white10,
        dialogBackgroundColor: Color(0xFF0D0D0D),
      );

  // ── Light ─────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDim,
          brightness: Brightness.light,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightOnSurface,
          primary: AppColors.primaryDim,
          secondary: AppColors.primaryDim,
        ),
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.lightOnSurface,
          displayColor: AppColors.lightOnSurface,
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurfaceLow,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: EdgeInsets.zero,
          shadowColor: Colors.black12,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDim,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.lightSurfaceLow,
          filled: true,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.black12)),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.black12)),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primaryDim, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.primaryDim),
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryDim,
          unselectedItemColor: Colors.black38,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontSize: 9),
          elevation: 4,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDim,
          elevation: 1,
          shadowColor: Colors.black12,
        ),
        dividerColor: Colors.black12,
        dialogBackgroundColor: Colors.white,
      );
}
