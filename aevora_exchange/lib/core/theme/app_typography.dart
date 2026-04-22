import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get _baseHeadline => GoogleFonts.spaceGrotesk(
    color: AppColors.onSurface,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get _baseBody => GoogleFonts.manrope(
    color: AppColors.onSurface,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: _baseHeadline.copyWith(fontSize: 56, letterSpacing: -2, fontWeight: FontWeight.w900),
    displayMedium: _baseHeadline.copyWith(fontSize: 40, letterSpacing: -1.5, fontWeight: FontWeight.w800),
    headlineMedium: _baseHeadline.copyWith(fontSize: 24, letterSpacing: -1, fontWeight: FontWeight.w700),
    headlineSmall: _baseHeadline.copyWith(fontSize: 18, letterSpacing: 0.5, fontWeight: FontWeight.w700),
    
    bodyLarge: _baseBody.copyWith(fontSize: 16, height: 1.5),
    bodyMedium: _baseBody.copyWith(fontSize: 14, height: 1.4),
    bodySmall: _baseBody.copyWith(fontSize: 12, color: AppColors.onSurfaceVariant),
    
    labelLarge: _baseHeadline.copyWith(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
    labelMedium: _baseHeadline.copyWith(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
    labelSmall: _baseHeadline.copyWith(fontSize: 8, letterSpacing: 1, fontWeight: FontWeight.w600),
  );
}
