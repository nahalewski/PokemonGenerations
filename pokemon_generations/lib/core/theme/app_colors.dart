import 'package:flutter/material.dart';

class AppColors {
  // Competitive Red
  static const Color primary = Color(0xFFBB0100);
  static const Color primaryContainer = Color(0xFF4D0000);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFFFFDAD4);

  // Tactical Blue
  static const Color secondary = Color(0xFF425A93);
  static const Color secondaryContainer = Color(0xFFD9E2FF);
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF001945);

  // Elite Gold
  static const Color tertiary = Color(0xFF705900);
  static const Color tertiaryContainer = Color(0xFFFFDF9E);
  static const Color onTertiary = Colors.white;
  static const Color onTertiaryContainer = Color(0xFF231B00);

  // Surface Hierarchy (Tonal Layering)
  static const Color surface = Color(0xFF1A1C1E);
  static const Color onSurface = Color(0xFFE2E2E6);
  static const Color surfaceContainerLow = Color(0xFF1D2024);
  static const Color surfaceContainer = Color(0xFF212429);
  static const Color surfaceContainerHigh = Color(0xFF2B2F33);
  static const Color surfaceContainerHighest = Color(0xFF363B40);

  // Accents & Functional
  static const Color outline = Color(0xFF8E9199);
  static const Color outlineVariant = Color(0xFF44474E); // Ghost Border at 15% opacity
  static const Color error = Color(0xFFFFB4AB);
  
  // Specific Type Colors (for Badges)
  static const Map<String, Color> typeColors = {
    'Fire': primary,
    'Water': secondary,
    'Electric': Color(0xFFEED535),
    'Grass': Color(0xFF7AC74C),
    'Ice': Color(0xFF96D9D6),
    'Fighting': Color(0xFFC22E28),
    'Poison': Color(0xFFA33EA1),
    'Ground': Color(0xFFE2BF65),
    'Flying': Color(0xFFA98FF3),
    'Psychic': Color(0xFFF95587),
    'Bug': Color(0xFFA6B91A),
    'Rock': Color(0xFFB6A136),
    'Ghost': Color(0xFF735797),
    'Dragon': Color(0xFF6F35FC),
    'Dark': Color(0xFF705746),
    'Steel': Color(0xFFB7B7CE),
    'Fairy': Color(0xFFD685AD),
    'Normal': Color(0xFFA8A77A),
  };
}
