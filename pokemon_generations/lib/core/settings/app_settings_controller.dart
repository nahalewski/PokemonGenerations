import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';
import 'visual_mode.dart';

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

final backendBaseUrlProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider).resolvedBackendUrl;
});

class AppSettingsController extends Notifier<AppSettings> {
  static const _backendUrlKey = 'settings.backend_url';
  static const _offlineModeKey = 'settings.offline_mode';
  static const _autoUpdateKey = 'settings.auto_check_updates';
  static const _visualModeKey = 'settings.music.visual_mode_v2';
  static const _showSurfingPikachuKey = 'settings.music.show_surfing_pikachu';
  static const _menuMusicKey = 'settings.music.menu_music_enabled';

  SharedPreferences? _prefs;

  @override
  AppSettings build() {
    _load();
    return AppSettings.defaults();
  }

  Future<void> _load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final prefs = _prefs!;

    final visualModeId = prefs.getString(_visualModeKey);

    state = state.copyWith(
      backendUrl: prefs.getString(_backendUrlKey) ?? state.backendUrl,
      offlineModeEnabled:
          prefs.getBool(_offlineModeKey) ?? state.offlineModeEnabled,
      autoCheckForUpdates:
          prefs.getBool(_autoUpdateKey) ?? state.autoCheckForUpdates,
      visualMode: visualModeId != null ? PlayerVisualModeExtension.fromId(visualModeId) : state.visualMode,
      showSurfingPikachu:
          prefs.getBool(_showSurfingPikachuKey) ?? state.showSurfingPikachu,
      menuMusicEnabled:
          prefs.getBool(_menuMusicKey) ?? state.menuMusicEnabled,
    );
  }

  Future<void> saveBackendUrl(String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    final normalized = _normalizeUrl(value);
    state = state.copyWith(backendUrl: normalized);
    await _prefs!.setString(_backendUrlKey, normalized);
  }

  Future<void> setOfflineMode(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    state = state.copyWith(offlineModeEnabled: enabled);
    await _prefs!.setBool(_offlineModeKey, enabled);
  }

  Future<void> setAutoCheckForUpdates(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    state = state.copyWith(autoCheckForUpdates: enabled);
    await _prefs!.setBool(_autoUpdateKey, enabled);
  }

  Future<void> setVisualMode(PlayerVisualMode mode) async {
    _prefs ??= await SharedPreferences.getInstance();
    state = state.copyWith(visualMode: mode);
    await _prefs!.setString(_visualModeKey, mode.id);
  }

  Future<void> setShowSurfingPikachu(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    state = state.copyWith(showSurfingPikachu: enabled);
    await _prefs!.setBool(_showSurfingPikachuKey, enabled);
  }

  Future<void> setMenuMusicEnabled(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    state = state.copyWith(menuMusicEnabled: enabled);
    await _prefs!.setBool(_menuMusicKey, enabled);
  }

  String _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return AppSettings.defaults().backendUrl;
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
