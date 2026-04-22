import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../domain/models/battle_state.dart';
import '../../features/battle/online_battle_controller.dart';

final voiceControllerProvider = StateNotifierProvider<VoiceActionController, VoiceState>((ref) {
  return VoiceActionController(ref);
});

class VoiceState {
  final bool isListening;
  final String lastRecognizedWords;
  final bool isAvailable;
  final String? error;

  VoiceState({
    this.isListening = false,
    this.lastRecognizedWords = '',
    this.isAvailable = false,
    this.error,
  });

  VoiceState copyWith({
    bool? isListening,
    String? lastRecognizedWords,
    bool? isAvailable,
    String? error,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      lastRecognizedWords: lastRecognizedWords ?? this.lastRecognizedWords,
      isAvailable: isAvailable ?? this.isAvailable,
      error: error,
    );
  }
}

class VoiceActionController extends StateNotifier<VoiceState> {
  final Ref _ref;
  final SpeechToText _speech = SpeechToText();

  VoiceActionController(this._ref) : super(VoiceState()) {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => print('[VOICE] Status: $status'),
        onError: (error) => state = state.copyWith(error: error.errorMsg),
      );
      state = state.copyWith(isAvailable: available);
    } catch (e) {
      state = state.copyWith(isAvailable: false, error: e.toString());
    }
  }

  void toggleListening(String battleId) async {
    if (state.isListening) {
      _stopListening();
    } else {
      _startListening(battleId);
    }
  }

  void _startListening(String battleId) async {
    if (!state.isAvailable) return;

    state = state.copyWith(isListening: true, lastRecognizedWords: '');
    
    await _speech.listen(
      onResult: (result) {
        state = state.copyWith(lastRecognizedWords: result.recognizedWords);
        if (result.finalResult) {
          _processVoiceCommand(result.recognizedWords, battleId);
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false);
  }

  void _processVoiceCommand(String text, String battleId) {
    final lower = text.toLowerCase();
    print('[VOICE] Processing: $lower');

    // 1. Get current battle state
    final battleState = _ref.read(onlineBattleControllerProvider(battleId));
    final controller = _ref.read(onlineBattleControllerProvider(battleId).notifier);

    // 2. Map Move Commands ("Use Thunderbolt", "Thunderbolt!", etc.)
    for (final move in battleState.playerPokemon.availableMoves) {
      if (lower.contains(move.name.toLowerCase())) {
        print('[VOICE] Executing move: ${move.name}');
        controller.handleAction(BattleAction.attack(move));
        _stopListening();
        return;
      }
    }

    // 3. Map System Commands
    if (lower.contains('switch') || lower.contains('go')) {
       // Look for pokemon names in the team
       for (final p in battleState.playerTeam) {
         if (lower.contains(p.name.toLowerCase()) && p.id != battleState.playerPokemon.id) {
           controller.handleAction(BattleAction.pokemon(p));
           _stopListening();
           return;
         }
       }
    }

    if (lower.contains('run') || lower.contains('flee') || lower.contains('escape')) {
      controller.handleAction(const BattleAction.run());
      _stopListening();
      return;
    }

    if (lower.contains('bag') || lower.contains('item')) {
      // For now, vocal "bag" just logs; actual item selection 
      // via voice requires deeper dynamic mapping.
      print('[VOICE] Bag command recognized.');
    }
  }
}
