import '../constants/api_constants.dart';
import 'visual_mode.dart';

class AppSettings {
  const AppSettings({
    required this.backendUrl,
    required this.offlineModeEnabled,
    required this.autoCheckForUpdates,
    required this.visualMode,
    required this.showSurfingPikachu,
    required this.menuMusicEnabled,
  });

  factory AppSettings.defaults() => const AppSettings(
    backendUrl: ApiConstants.baseUrl,
    offlineModeEnabled: false,
    autoCheckForUpdates: true,
    visualMode: PlayerVisualMode.vinyl,
    showSurfingPikachu: false,
    menuMusicEnabled: true,
  );

  final String backendUrl;
  final bool offlineModeEnabled;
  final bool autoCheckForUpdates;
  final PlayerVisualMode visualMode;
  final bool showSurfingPikachu;
  final bool menuMusicEnabled;

  String get resolvedBackendUrl {
    final trimmed = backendUrl.trim();
    if (trimmed.isEmpty) {
      return ApiConstants.baseUrl;
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  AppSettings copyWith({
    String? backendUrl,
    bool? offlineModeEnabled,
    bool? autoCheckForUpdates,
    PlayerVisualMode? visualMode,
    bool? showSurfingPikachu,
    bool? menuMusicEnabled,
  }) {
    return AppSettings(
      backendUrl: backendUrl ?? this.backendUrl,
      offlineModeEnabled: offlineModeEnabled ?? this.offlineModeEnabled,
      autoCheckForUpdates: autoCheckForUpdates ?? this.autoCheckForUpdates,
      visualMode: visualMode ?? this.visualMode,
      showSurfingPikachu: showSurfingPikachu ?? this.showSurfingPikachu,
      menuMusicEnabled: menuMusicEnabled ?? this.menuMusicEnabled,
    );
  }
}
