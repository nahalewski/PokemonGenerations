import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../domain/models/replay_models.dart';
import '../../../domain/models/battle_state.dart';

class ReplayRecorder {
  final String battleId;
  final BattleReplay initialReplay;
  final List<ReplayTurn> _turns = [];
  ReplayTurn? _currentTurn;

  ReplayRecorder({
    required this.battleId,
    required this.initialReplay,
  });

  /// Starts a new turn in the recording.
  void startTurn(int turnIndex) {
    if (_currentTurn != null) {
      _turns.add(_currentTurn!);
    }
    _currentTurn = ReplayTurn(turnIndex: turnIndex, events: []);
  }

  /// Logs an event to the current turn.
  void logEvent(String type, Map<String, dynamic> data) {
    if (_currentTurn == null) return;

    final event = ReplayEvent(
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      type: type,
      data: data,
    );
    
    // We update the current turn's events list (recreating for immutability)
    _currentTurn = _currentTurn!.copyWith(
      events: [..._currentTurn!.events, event],
    );
  }

  /// Finalizes the replay and saves it to local storage.
  Future<File?> saveReplay(String winner, {String? endReason}) async {
    if (_currentTurn != null) {
      _turns.add(_currentTurn!);
    }

    final finalReplay = initialReplay.copyWith(
      turns: _turns,
      winner: winner,
      endReason: endReason,
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final replaysDir = Directory('${dir.path}/replays');
      if (!replaysDir.existsSync()) {
        replaysDir.createSync();
      }

      final file = File('${replaysDir.path}/$battleId.replay');
      // For this phase, we use JSON serialization; binary Protobuf 
      // will be enabled in Phase 2 for optimal bandwidth.
      await file.writeAsString(jsonEncode(finalReplay.toJson()));
      
      print('[REPLAY] Saved replay for battle $battleId');
      return file;
    } catch (e) {
      print('[REPLAY] Failed to save replay: $e');
      return null;
    }
  }
}
