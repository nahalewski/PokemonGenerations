import 'package:freezed_annotation/freezed_annotation.dart';
import 'pokemon.dart';

part 'battle_state.freezed.dart';

@freezed
class BattleLogEntry with _$BattleLogEntry {
  const factory BattleLogEntry({
    required String message,
    required String type, // 'attack', 'item', 'switch', 'status', 'faint', 'run', 'info'
    required bool isPlayer,
    String? pokemonId,
    String? itemId,
    String? pokemonName,
    @Default([]) List<String> pokemonSprites,
    DateTime? timestamp,
  }) = _BattleLogEntry;
}

@freezed
class BattleState with _$BattleState {
  const factory BattleState({
    required Pokemon playerPokemon,
    required Pokemon opponentPokemon,
    required int playerCurrentHp,
    required int opponentCurrentHp,
    required int playerMaxHp,
    required int opponentMaxHp,
    @Default(50) int playerLevel,
    @Default(50) int opponentLevel,
    @Default([]) List<Pokemon> playerTeam, // The full roster for swapping
    @Default([]) List<Pokemon> opponentTeam, // NEW: The CPU's random team
    @Default(0) int activePlayerIdx,
    @Default(0) int activeOpponentIdx,
    @Default({}) Map<String, int> playerHpMap,    // id -> current hp
    @Default({}) Map<String, int> playerMaxHpMap, // id -> max hp
    @Default({}) Map<String, int> opponentHpMap,    // id -> current hp
    @Default({}) Map<String, int> opponentMaxHpMap, // id -> max hp
    @Default({}) Map<String, int> inventory, // The user's bag
    @Default([]) List<BattleLogEntry> battleLog,
    @Default(true) bool isPlayerTurn,
    @Default(false) bool isFinished,
    String? winner,
    @Default(false) bool isAnimating,
    @Default(false) bool isWaitingForOpponent,
    @Default(false) bool isWaitingForSwitch, // NEW: Mandatory switch state
    @Default(false) bool isSpectator,
    @Default(true) bool player1Connected,
    @Default(true) bool player2Connected,
    @Default('') String player1Name,
    @Default('') String player2Name,
    @Default('') String message,
    @Default('normal') String difficulty, // 'normal' or 'hard'
    @Default({'potion': 2}) Map<String, int> cpuInventory, // CPU's bag
    @Default('none') String weather, // 'none', 'rain', 'sun', 'sand', 'snow'
    @Default('none') String terrain, // 'none', 'electric', 'grassy', 'misty', 'psychic'
    String? lastMoveName, // For SFX/VFX triggering
    String? lastMoveType, // For particle selection
    @Default(false) bool isRecharging, // For moves like Hyper Beam
    @Default({}) Map<String, String> statusMap, // id -> 'brn', 'psn', 'tox', 'par', 'slp', 'frz', 'none'
    @Default({}) Map<String, int> statusTurns, // id -> number of turns
    @Default({}) Map<String, List<String>> volatileStatusMap, // id -> ['confused', 'taunted', ...]
    @Default({}) Map<String, Map<String, int>> volatileStatusTurns, // id -> { 'taunt': 3 }
    @Default({}) Map<String, String> disabledMoveMap, // id -> name of disabled move
    @Default({}) Map<String, String> encoredMoveMap, // id -> name of encored move
  }) = _BattleState;
}

@freezed
class BattleAction with _$BattleAction {
  const factory BattleAction.attack(PokemonMove move) = AttackAction;
  const factory BattleAction.item(String itemId, {String? targetId}) = ItemAction;
  const factory BattleAction.pokemon(Pokemon pokemon) = PokemonAction;
  const factory BattleAction.run() = RunAction;
}
