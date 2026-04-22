import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/graphics_service.dart';

final battleFxServiceProvider = Provider((ref) => BattleFxService());

class BattleFxService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playMoveSound(String moveName) async {
    try {
      final path = DynamicAssetMapper.getMoveSound(moveName);
      await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (e) {
      print('Error playing move sound: $e');
    }
  }

  // VFX logic would typically be handled by a widget overlay in BattleScreen,
  // but we can provide the path here.
  String getParticlePath(String moveType) {
    return DynamicAssetMapper.getMoveParticle(moveType);
  }
}
