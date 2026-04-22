import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import '../constants/api_constants.dart';
import '../settings/app_settings_controller.dart';

final audioSourceServiceProvider = Provider<AudioSourceService>((ref) {
  final baseUrl = ref.watch(backendBaseUrlProvider);
  return AudioSourceService(baseUrl: baseUrl);
});

class AudioSourceService {
  AudioSourceService({required this.baseUrl});

  final String baseUrl;

  /// Resolves a battle music filename (e.g. 'battlemusic42.mp3') to a playable Source.
  /// Native: local downloaded file → server stream fallback.
  /// Web: always streams from server.
  Future<Source> resolveBattleTrack(String filename) async {
    if (!kIsWeb) {
      final localPath = await _localAudioPath(filename);
      if (localPath != null) return DeviceFileSource(localPath);
    }
    final url = '${baseUrl.trimRight()}/assets/battle-audio/$filename';
    return UrlSource(url);
  }

  /// Synchronous version — always returns a UrlSource (no disk check).
  /// Use when you can't await (e.g. in non-async context).
  Source resolveBattleTrackSync(String filename) {
    if (kIsWeb) {
      final url = '${baseUrl.trimRight()}/assets/battle-audio/$filename';
      return UrlSource(url);
    }
    // Native without await: fallback to server stream; download runs in background.
    final url = '${baseUrl.trimRight()}/assets/battle-audio/$filename';
    return UrlSource(url);
  }

  /// Resolves a FX sound to AssetSource (still bundled in the app).
  Source resolveFxSound(String assetPath) {
    return AssetSource(assetPath.replaceFirst('assets/', ''));
  }

  Future<String?> _localAudioPath(String filename) async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final file = File(p.join(base.path, 'asset_packages', 'battle_audio', filename));
      return await file.exists() ? file.path : null;
    } catch (_) {
      return null;
    }
  }

  /// Resolves an OST track from the official soundtrack library.
  Source resolveOstTrack(String album, String filename) {
    final url = '${baseUrl.trimRight()}/assets/ost/${Uri.encodeComponent(album)}/${Uri.encodeComponent(filename)}';
    return UrlSource(url);
  }

  /// Returns the URL for an album's cover artwork.
  String getAlbumArtUrl(String album) {
    return '${baseUrl.trimRight()}/assets/ost/${Uri.encodeComponent(album)}/cover.png';
  }

  String get effectiveBaseUrl =>
      baseUrl.isNotEmpty ? baseUrl : ApiConstants.baseUrl;
}
