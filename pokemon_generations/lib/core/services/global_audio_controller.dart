import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/app_settings_controller.dart';

final globalAudioControllerProvider = Provider<GlobalAudioController>((ref) {
  final controller = GlobalAudioController(ref);
  ref.onDispose(() => controller.dispose());
  return controller;
});

class GlobalAudioController {
  final Ref ref;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  GlobalAudioController(this.ref) {
    _player.setReleaseMode(ReleaseMode.loop);
    
    // Listen to settings to auto-stop if disabled
    ref.listen(appSettingsProvider.select((s) => s.menuMusicEnabled), (prev, next) {
      if (!next && _isPlaying) {
        stopMenuMusic();
      }
    });
  }

  Future<void> playMenuMusic() async {
    final enabled = ref.read(appSettingsProvider).menuMusicEnabled;
    if (!enabled || _isPlaying) return;

    try {
      await _player.play(AssetSource('audio/menuost.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('[AUDIO] Failed to play menu music: $e');
    }
  }

  Future<void> stopMenuMusic() async {
    if (!_isPlaying) return;
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      print('[AUDIO] Failed to stop menu music: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
