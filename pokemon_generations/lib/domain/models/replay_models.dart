import 'package:freezed_annotation/freezed_annotation.dart';
import 'pokemon.dart';
import 'battle_state.dart';

part 'replay_models.freezed.dart';
part 'replay_models.g.dart';

@freezed
class BattleReplay with _$BattleReplay {
  const factory BattleReplay({
    required int version,
    required String battleId,
    required String ruleset,
    required int startTimestampMs,
    required int rngSeed,
    required ReplayPlayer p1,
    required ReplayPlayer p2,
    required List<ReplayTurn> turns,
    required String winner,
    String? endReason,
  }) = _BattleReplay;

  factory BattleReplay.fromJson(Map<String, dynamic> json) => _$BattleReplayFromJson(json);
}

@freezed
class ReplayPlayer with _$ReplayPlayer {
  const factory ReplayPlayer({
    required String username,
    required String displayName,
    required List<ReplayPokemonState> team,
  }) = _ReplayPlayer;

  factory ReplayPlayer.fromJson(Map<String, dynamic> json) => _$ReplayPlayerFromJson(json);
}

@freezed
class ReplayPokemonState with _$ReplayPokemonState {
  const factory ReplayPokemonState({
    required String pokemonId,
    required String nickname,
    required int level,
    required int maxHp,
    required int currentHp,
    required List<String> moveIds,
    String? abilityId,
    String? itemId,
    String? gender,
    @Default(false) bool isShiny,
  }) = _ReplayPokemonState;

  factory ReplayPokemonState.fromJson(Map<String, dynamic> json) => _$ReplayPokemonStateFromJson(json);
}

@freezed
class ReplayTurn with _$ReplayTurn {
  const factory ReplayTurn({
    required int turnIndex,
    required List<ReplayEvent> events,
  }) = _ReplayTurn;

  factory ReplayTurn.fromJson(Map<String, dynamic> json) => _$ReplayTurnFromJson(json);
}

@freezed
class ReplayEvent with _$ReplayEvent {
  const factory ReplayEvent({
    required int timestampMs,
    required String type, // 'move', 'damage', 'heal', 'switch', 'status', 'faint', 'item', 'weather', 'terrain', 'info'
    Map<String, dynamic>? data,
  }) = _ReplayEvent;

  factory ReplayEvent.fromJson(Map<String, dynamic> json) => _$ReplayEventFromJson(json);
}
