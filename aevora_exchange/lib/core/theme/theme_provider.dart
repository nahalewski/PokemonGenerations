import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores and restores the user's preferred ThemeMode.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('theme_dark') ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark', next == ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}
