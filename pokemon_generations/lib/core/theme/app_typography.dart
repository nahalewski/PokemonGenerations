import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Display (Space Grotesk) - Aggressive, Editorial
  static TextStyle displayLarge = GoogleFonts.spaceGrotesk(
    fontSize: 57,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.1,
  );

  static TextStyle displayMedium = GoogleFonts.spaceGrotesk(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.9,
  );

  static TextStyle displaySmall = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.7,
  );

  // Headline (Space Grotesk)
  static TextStyle headlineLarge = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headlineMedium = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headlineSmall = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  // Title (Plus Jakarta Sans)
  static TextStyle titleLarge = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleMedium = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleSmall = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Body (Manrope) - Clean, Modern Tech
  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Labels (Plus Jakarta Sans) - Micro-data clarity
  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}
