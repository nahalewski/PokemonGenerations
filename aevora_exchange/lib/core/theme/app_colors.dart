import 'package:flutter/material.dart';

class AppColors {
  // ── Dark mode foundations ────────────────────────────────────────────────────
  static const Color background = Color(0xFF0E0E0E);
  static const Color surface = Color(0xFF0E0E0E);
  static const Color surfaceDim = Color(0xFF0E0E0E);

  // Containers (Tonal Layering)
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF131313);
  static const Color surfaceContainer = Color(0xFF1A1919);
  static const Color surfaceContainerHigh = Color(0xFF201F1F);
  static const Color surfaceContainerHighest = Color(0xFF262626);

  // ── Accents ──────────────────────────────────────────────────────────────────
  /// Main brand green (replaces blue)
  static const Color primary = Color(0xFF39FF88);
  static const Color primaryDim = Color(0xFF00B358);
  static const Color secondary = Color(0xFF38FA5F); // Plasma Green
  static const Color tertiary = Color(0xFFF4FFC6);  // Electric Yellow

  // ── States ───────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF716C);
  static const Color errorDim = Color(0xFFD7383B);

  // ── On Colors ────────────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFADAAAA);
  static const Color onPrimary = Color(0xFF001A0C);
  static const Color onSecondary = Color(0xFF004411);
  static const Color outline = Color(0xFF777575);
  static const Color outlineVariant = Color(0xFF494847);

  // ── Light mode surfaces ──────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightSurfaceLow = Color(0xFFEEEEEE);
  static const Color lightOnSurface = Color(0xFF111111);
  static const Color lightOnSurfaceVariant = Color(0xFF555555);
}
