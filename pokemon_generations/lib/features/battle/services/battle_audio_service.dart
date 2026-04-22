import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../domain/models/pokemon_form.dart';

final battleAudioServiceProvider = Provider<BattleAudioService>((ref) {
  final service = BattleAudioService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

class BattleAudioService {
  final Ref ref;
  final Map<String, Source> _cachedSources = {};
  late final AudioPlayer _player;

  BattleAudioService(this.ref) {
    _player = AudioPlayer();
  }

  void dispose() {
    _player.dispose();
    clearCache();
  }

  /// Normalizes a move name to match the backend convention "Move Name.mp3"
  String _normalizeMoveName(String moveName) {
    // Backend stores as "10 Mil Volt Thunderbolt.mp3", "Acid Armor.mp3" etc.
    final words = moveName.split('-');
    final capitalized = words.map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
    
    return '$capitalized.mp3';
  }

  Future<void> preloadRosterSounds(List<PokemonForm> roster) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    if (baseUrl.isEmpty) return;

    final moves = <String>{};
    for (final mon in roster) {
      for (final moveName in mon.moves) {
        if (moveName != null) moves.add(moveName);
      }
    }

    for (final move in moves) {
      final filename = _normalizeMoveName(move);
      final url = '${baseUrl.trimRight()}/assets/sfx/attacks/${Uri.encodeComponent(filename)}';
      _cachedSources[move] = UrlSource(url);
    }
    
    print('[BATTLE-AUDIO] Preloaded ${moves.length} move sounds');
  }

  Future<void> playAttackSound(String moveName) async {
    final source = _cachedSources[moveName];
    if (source != null) {
      try {
        await _player.stop();
        await _player.play(source);
      } catch (e) {
        print('[BATTLE-AUDIO] Play error: $e');
      }
    } else {
      // Fallback: Try streaming directly if not preloaded
      final baseUrl = ref.read(backendBaseUrlProvider);
      if (baseUrl.isNotEmpty) {
        final filename = _normalizeMoveName(moveName);
        final url = '${baseUrl.trimRight()}/assets/sfx/attacks/${Uri.encodeComponent(filename)}';
        try {
          await _player.stop();
          await _player.play(UrlSource(url));
        } catch (e) {
          print('[BATTLE-AUDIO] Streaming error: $e');
        }
      }
    }
  }

  void clearCache() {
    _cachedSources.clear();
    print('[BATTLE-AUDIO] Cache cleared');
  }
}
