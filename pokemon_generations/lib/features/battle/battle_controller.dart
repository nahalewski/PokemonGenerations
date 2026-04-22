import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/battle_state.dart';
import '../../domain/models/pokemon.dart';
import '../../data/services/api_client.dart';
import '../../core/utils/type_chart.dart';
import '../../core/utils/damage_calculator.dart';
import '../roster/roster_provider.dart';
import '../inventory/inventory_provider.dart';
import '../../domain/models/pokemon_form.dart';
import 'services/telemetry_service.dart';
import 'services/battle_audio_service.dart';
import '../../data/providers.dart';
import '../auth/auth_controller.dart';

final battleControllerProvider =
    StateNotifierProvider.autoDispose.family<BattleController, BattleState, BattleParams>(
  (ref, params) => BattleController(ref, params),
);

class BattleParams {
  final String playerPokemonId;
  final String opponentPokemonId;
  final bool isCPUBattle;
  final String difficulty;

  const BattleParams({
    required this.playerPokemonId,
    required this.opponentPokemonId,
    this.isCPUBattle = false,
    this.difficulty = 'hard',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BattleParams &&
          runtimeType == other.runtimeType &&
          playerPokemonId == other.playerPokemonId &&
          opponentPokemonId == other.opponentPokemonId &&
          isCPUBattle == other.isCPUBattle;

  @override
  int get hashCode => playerPokemonId.hashCode ^ opponentPokemonId.hashCode ^ isCPUBattle.hashCode ^ difficulty.hashCode;
}

class BattleController extends StateNotifier<BattleState> {
  final Ref ref;
  final BattleParams params;
  final Random _random = Random();
  late String _battleId;
  final _telemetry = TelemetryService();

  BattleController(this.ref, this.params)
      : super(BattleState(
          playerPokemon: const Pokemon(id: '', name: 'Loading...', types: [], baseStats: {}, abilities: []),
          opponentPokemon: const Pokemon(id: '', name: 'Loading...', types: [], baseStats: {}, abilities: []),
          playerCurrentHp: 100,
          opponentCurrentHp: 100,
          playerMaxHp: 100,
          opponentMaxHp: 100,
        )) {
    _initializeBattle();
  }

  @override
  void dispose() {
    ref.read(battleAudioServiceProvider).clearCache();
    super.dispose();
  }

  Future<void> _initializeBattle() async {
    _battleId = 'cpu_${DateTime.now().millisecondsSinceEpoch}';
    state = state.copyWith(difficulty: params.difficulty);
    final api = ref.read(apiClientProvider.notifier);
    
    // 1. Resolve Player Team (max 6)
    final allRosterForms = await ref.read(rosterProvider.future);
    final rosterForms = allRosterForms.take(6).toList();
    List<Pokemon> playerTeam = [];

    if (rosterForms.isEmpty) {
      state = state.copyWith(message: 'No Pokémon in roster! Returning...');
      return;
    }

    final playerTeamResults = await Future.wait(
      rosterForms.map((f) => api.getPokemonDetail(f.pokemonId))
    );

    // Build player team: apply form moves + compute actual stats from EVs/IVs/nature/level
    for (int i = 0; i < playerTeamResults.length; i++) {
      final pokemon = playerTeamResults[i];
      if (pokemon == null) continue;
      final form = rosterForms[i];

      // Moves: use the user's selected 4, fall back to top API moves
      final selectedMoveNames = form.moves.where((m) => m.isNotEmpty && m != 'None').toList();
      List<PokemonMove> battleMoves;
      if (selectedMoveNames.isNotEmpty) {
        final allMoves = pokemon.availableMoves;
        battleMoves = selectedMoveNames.map((name) {
          return allMoves.firstWhere(
            (m) => m.name.toLowerCase() == name.toLowerCase(),
            orElse: () => PokemonMove(name: name, learnLevel: 1, learnMethod: 'level-up'),
          );
        }).toList();
      } else {
        battleMoves = pokemon.availableMoves.take(4).toList();
      }

      // Effective stats: base stats scaled by level, EVs, IVs, and nature
      final effectiveStats = _computeEffectiveStats(pokemon.baseStats, form);

      playerTeam.add(pokemon.copyWith(
        availableMoves: battleMoves,
        baseStats: effectiveStats,
      ));
    }

    // 2. Resolve Opponent Team
    List<Pokemon> opponentTeam = [];
    if (params.isCPUBattle) {
      opponentTeam = await _generateRandomCPUTeam();
    } else {
      final op = await api.getPokemonDetail(params.opponentPokemonId);
      if (op != null) opponentTeam = [op];
    }

    if (opponentTeam.isEmpty) {
      state = state.copyWith(message: 'Error loading opponent Pokémon.');
      return;
    }

    // 3. Initialize active mons
    final player = playerTeam[0];
    final opponent = opponentTeam[0];

    final baseLevel = rosterForms.isNotEmpty ? rosterForms[0].level : 50;

    // 4. HP maps — player uses effective HP stat already baked in; opponent uses standard formula
    final Map<String, int> pHP = {};
    final Map<String, int> oHP = {};

    for (int i = 0; i < playerTeam.length; i++) {
      // Scale EVERY member's HP mapping to their level-scaled max
      final mon = playerTeam[i];
      final form = rosterForms[i];
      final effectiveStats = _computeEffectiveStats(mon.baseStats, form);
      pHP[mon.id] = effectiveStats['hp'] ?? 100;
    }

    for (final o in opponentTeam) {
      final level = baseLevel;
      final maxHp = (((2 * (o.baseStats['hp'] ?? 100) + 31 + 63) * level) / 100).floor() + level + 10;
      oHP[o.id] = maxHp;
    }

    final pMax = pHP[player.id] ?? 100;
    final oMax = oHP[opponent.id] ?? 100;

    final inventory = ref.read(inventoryProvider);

    state = state.copyWith(
      playerPokemon: player,
      opponentPokemon: opponent,
      playerTeam: playerTeam,
      opponentTeam: opponentTeam,
      playerHpMap: pHP,
      playerMaxHpMap: Map<String, int>.from(pHP),
      opponentHpMap: Map<String, int>.from(oHP),
      opponentMaxHpMap: Map<String, int>.from(oHP),
      playerMaxHp: pMax,
      playerCurrentHp: pMax,
      opponentMaxHp: oMax,
      opponentCurrentHp: oMax,
      playerLevel: baseLevel,
      opponentLevel: baseLevel,
      inventory: inventory,
      message: 'What will ${player.name} do?',
    );

    // 5. Preload Audio (Streaming SFX)
    ref.read(battleAudioServiceProvider).preloadRosterSounds(rosterForms);
    
    _sendTelemetry();
  }

  void _sendTelemetry() {
    if (!params.isCPUBattle) return;
    _telemetry.sendBattleUpdate(
      battleId: _battleId,
      playerPokemon: state.playerPokemon,
      opponentPokemon: state.opponentPokemon,
      playerHp: state.playerCurrentHp,
      playerMaxHp: state.playerMaxHp,
      opponentHp: state.opponentCurrentHp,
      opponentMaxHp: state.opponentMaxHp,
      log: state.battleLog.map((e) => e.message).toList(),
      status: state.isFinished ? 'finished' : 'active',
    );
  }

  void _addLogEntry({
    required String message,
    required String type,
    required bool isPlayer,
    String? pokemonId,
    String? itemId,
    String? pokemonName,
    List<String>? sprites,
  }) {
    final entry = BattleLogEntry(
      message: message,
      type: type,
      isPlayer: isPlayer,
      pokemonId: pokemonId,
      itemId: itemId,
      pokemonName: pokemonName,
      pokemonSprites: sprites ?? [],
      timestamp: DateTime.now(),
    );
    state = state.copyWith(battleLog: [...state.battleLog, entry]);
  }

  Future<List<Pokemon>> _generateRandomCPUTeam() async {
    final api = ref.read(apiClientProvider.notifier);
    
    try {
      debugPrint('BATTLE_CPU: Attempting to load pokemon_database.json asset...');
      final String jsonStr = await rootBundle.loadString('assets/pokemon_database.json');
      
      if (!jsonStr.trim().startsWith('{')) {
        throw FormatException('Invalid JSON format or Not Found: ${jsonStr.length > 20 ? jsonStr.substring(0, 20) : jsonStr}...');
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(jsonStr));
      final List results = data['results'] ?? [];

      if (results.isEmpty) {
        throw Exception('results are empty in database');
      }

      final candidates = (results.toList()..shuffle()).take(6).toList();
      final fetched = await Future.wait(
        candidates.map((c) {
          final url = c['url'] as String;
          final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
          final numericId = cleanUrl.split('/').last;
          return api.getPokemonDetail(numericId)
            .catchError((e) {
              debugPrint('BATTLE_CPU_ERROR: Detail fetch fail for ${c['name']} (ID: $numericId): $e');
              return null;
            });
        }),
      );
      final team = fetched.whereType<Pokemon>().take(6).toList();
      if (team.isNotEmpty) return team;
      
      debugPrint('BATTLE_CPU_ERROR: Asset loaded but no pokemon details fetched. Falling back to API.');
    } catch (e) {
      debugPrint('BATTLE_CPU_ERROR: Asset load failed ($e). Falling back to PokeAPI...');
    }

    try {
      final results = await api.searchPokemon('');
      if (results.isEmpty) return [];

      final candidates = (results.toList()..shuffle()).take(6).toList();
      final fetched = await Future.wait(
        candidates.map((c) => api.getPokemonDetail(c.id))
      );
      return fetched.whereType<Pokemon>().take(6).toList();
    } catch (e) {
      debugPrint('BATTLE_CPU_ERROR: PokeAPI fallback also failed: $e');
      return [];
    }
  }


  Future<void> handleAction(BattleAction action) async {
    if (state.isAnimating || state.isFinished || (!state.isPlayerTurn && action is! PokemonAction)) return;

    state = state.copyWith(isAnimating: true);

    await action.when(
      attack: (move) async {
        if (state.isRecharging) {
          state = state.copyWith(message: '${state.playerPokemon.name} is recharging!', isAnimating: true);
          await Future.delayed(const Duration(milliseconds: 1200));
          state = state.copyWith(isRecharging: false, isPlayerTurn: false, isAnimating: false);
          return;
        }
        final encoredMove = state.encoredMoveMap[state.playerPokemon.id];
        if (encoredMove != null && move.name != encoredMove) {
          state = state.copyWith(message: '${state.playerPokemon.name} must use $encoredMove!', isAnimating: false);
          return;
        }
        await _playerAttack(move);
      },
      item: (itemId, targetId) async => await _playerUseItem(itemId, targetId: targetId),
      pokemon: (pokemon) async => await _playerSwap(pokemon),
      run: () async {
        _addLogEntry(
          message: '${state.playerPokemon.name} tried to run!',
          type: 'run',
          isPlayer: true,
          pokemonId: state.playerPokemon.id,
          pokemonName: state.playerPokemon.name,
          sprites: state.playerPokemon.backSpriteUrls,
        );
        state = state.copyWith(message: 'Got away safely!');
        await Future.delayed(const Duration(milliseconds: 1000));
        state = state.copyWith(isFinished: true, winner: 'none');
      },
    );

    if (!state.isFinished && !state.isPlayerTurn) {
      await Future.delayed(const Duration(milliseconds: 1000));
      await _cpuTurn();
    }
    
    // End of full turn (both moved)
    if (!state.isFinished && state.isPlayerTurn && !state.isAnimating) {
        await _processEndOfTurnEffects();
    }

    _sendTelemetry();
  }

  Future<void> _playerAttack(PokemonMove move) async {
    _addLogEntry(
      message: '${state.playerPokemon.name} used ${move.name}!',
      type: 'attack',
      isPlayer: true,
      pokemonId: state.playerPokemon.id,
      pokemonName: state.playerPokemon.name,
      sprites: state.playerPokemon.backSpriteUrls,
    );

    state = state.copyWith(
      message: '${state.playerPokemon.name} used ${move.name}!',
      lastMoveName: move.name,
      lastMoveType: move.type,
    );
    
    if (!await _canExecuteMove(state.playerPokemon, move)) return;

    await Future.delayed(const Duration(milliseconds: 300));
    // Play attack sound
    unawaited(ref.read(battleAudioServiceProvider).playAttackSound(move.name));

    await Future.delayed(const Duration(milliseconds: 500));

    final isCrit = _random.nextDouble() < 0.0625;
    final damage = _calculateDamage(state.playerPokemon, state.opponentPokemon, move, crit: isCrit);
    final newOpponentHp = max(0, state.opponentCurrentHp - damage);

    final newHpMap = Map<String, int>.from(state.opponentHpMap);
    newHpMap[state.opponentPokemon.id] = newOpponentHp;

    final effectiveness = _getEffectiveness(move, state.opponentPokemon);
    String feedback = '';
    if (effectiveness > 1.0) feedback = 'It\'s super effective!';
    if (effectiveness < 1.0 && effectiveness > 0) feedback = 'It\'s not very effective...';
    if (effectiveness == 0) feedback = 'It had no effect...';
    if (isCrit) feedback = 'A critical hit! $feedback';

    if (feedback.isNotEmpty) {
      _addLogEntry(
        message: feedback,
        type: 'status',
        isPlayer: true,
      );
    }

    final isRechargeMove = [
      'hyper-beam', 'giga-impact', 'frenzy-plant', 'blast-burn', 
      'hydro-cannon', 'rock-wrecker', 'roar-of-time', 'meteor-assault'
    ].contains(move.name.toLowerCase().replaceAll(' ', '-'));

    state = state.copyWith(
      opponentCurrentHp: newOpponentHp,
      opponentHpMap: newHpMap,
      message: (feedback.isNotEmpty ? '$feedback ' : '') + state.message,
      isRecharging: isRechargeMove,
    );

    // Inflict Status check
    if (newOpponentHp > 0) {
      await _attemptStatusInfliction(move, state.opponentPokemon, false);
    await _attemptVolatileStatusInfliction(move, state.opponentPokemon, false);
    }

    await Future.delayed(const Duration(milliseconds: 1200));

    if (newOpponentHp <= 0) {
      _addLogEntry(
        message: '${state.opponentPokemon.name} fainted!',
        type: 'faint',
        isPlayer: false,
        pokemonId: state.opponentPokemon.id,
        pokemonName: state.opponentPokemon.name,
        sprites: state.opponentPokemon.frontSpriteUrls,
      );

      // Update individual win/loss stats
      _updatePokemonStats(state.playerPokemon.id, isWin: true);

      int nextIdx = -1;
      for (int i = 0; i < state.opponentTeam.length; i++) {
        if ((state.opponentHpMap[state.opponentTeam[i].id] ?? 0) > 0 && i != state.activeOpponentIdx) {
          nextIdx = i;
          break;
        }
      }

      if (nextIdx != -1) {
        final nextMon = state.opponentTeam[nextIdx];
        final nextCurHp = state.opponentHpMap[nextMon.id] ?? 100;
        final nextMaxHp = state.opponentMaxHpMap[nextMon.id] ?? nextCurHp;

        _addLogEntry(
          message: 'CPU sent out ${nextMon.name}!',
          type: 'switch',
          isPlayer: false,
          pokemonId: nextMon.id,
          pokemonName: nextMon.name,
          sprites: nextMon.frontSpriteUrls,
        );

        state = state.copyWith(
          message: '${state.opponentPokemon.name} fainted! CPU sent out ${nextMon.name}!',
          opponentPokemon: nextMon,
          activeOpponentIdx: nextIdx,
          opponentMaxHp: nextMaxHp,
          opponentCurrentHp: nextCurHp,
          isAnimating: false,
          isPlayerTurn: false,
        );
      } else {
        state = state.copyWith(
          isFinished: true,
          winner: 'player',
          message: 'All of CPU\'s Pokémon fainted! You win!',
          isAnimating: true, // Keep animating for the popup
        );
        
        // --- High Fidelity Reward Sequence ---
        if (params.isCPUBattle) {
            await _processCPUVictoryReward();
        }
        
        state = state.copyWith(isAnimating: false);
      }
    } else {
      // Clear volatile statuses on switch out
      final newVolatileMap = Map<String, List<String>>.from(state.volatileStatusMap);
      final newVolatileTurns = Map<String, Map<String, int>>.from(state.volatileStatusTurns);
      newVolatileMap[state.playerPokemon.id] = [];
      newVolatileTurns[state.playerPokemon.id] = {};

      state = state.copyWith(
        isPlayerTurn: false,
        isAnimating: false,
        volatileStatusMap: newVolatileMap,
        volatileStatusTurns: newVolatileTurns,
      );
    }
  }

  Future<void> _playerUseItem(String itemId, {String? targetId}) async {
    final inventory = state.inventory;
    final count = inventory[itemId] ?? 0;

    if (count <= 0) {
      state = state.copyWith(message: 'You don\'t have any ${itemId}s left!', isAnimating: false);
      return;
    }

    await ref.read(inventoryProvider.notifier).useItem(itemId);
    final updatedInventory = ref.read(inventoryProvider);

    int newHp = state.playerCurrentHp;
    bool isInstantWin = false;
    String? healedMonName;

    final targetMon = targetId != null 
        ? state.playerTeam.firstWhere((p) => p.id == targetId, orElse: () => state.playerPokemon)
        : state.playerPokemon;
    
    final currentTargetHp = state.playerHpMap[targetMon.id] ?? 0;
    final targetMaxHp = state.playerMaxHpMap[targetMon.id] ?? 100;

    _addLogEntry(
      message: 'You used a ${itemId.replaceAll('-', ' ')}!',
      type: 'item',
      isPlayer: true,
      itemId: itemId,
      pokemonId: targetMon.id,
      pokemonName: targetMon.name,
      sprites: targetMon.backSpriteUrls,
    );

    if (itemId == 'dark-ball') {
      state = state.copyWith(message: 'DARK BALL DEPLOYED. DISTORTING SPACE...', isAnimating: true);
      await Future.delayed(const Duration(milliseconds: 1500));
      state = state.copyWith(message: 'TARGET ${state.opponentPokemon.name.toUpperCase()} CAPTURED. BATTLE TERMINATED.');
      await Future.delayed(const Duration(milliseconds: 1500));
      isInstantWin = true;
    } else if (itemId == 'revive') {
      if (currentTargetHp > 0) {
        state = state.copyWith(message: '${targetMon.name} is already conscious!', isAnimating: false);
        return;
      }
      newHp = (targetMaxHp * 0.5).toInt();
      healedMonName = targetMon.name;
    } else if (itemId == 'potion') {
      if (currentTargetHp <= 0) {
        state = state.copyWith(message: '${targetMon.name} is fainted and needs a Revive!', isAnimating: false);
        return;
      }
      final healAmount = (targetMaxHp * 0.5).toInt();
      newHp = min(targetMaxHp, currentTargetHp + healAmount);
      healedMonName = targetMon.name;
    } else if (itemId == 'sitrus-berry') {
      if (currentTargetHp <= 0) return;
      final healAmount = (targetMaxHp * 0.25).toInt();
      newHp = min(targetMaxHp, currentTargetHp + healAmount);
      healedMonName = targetMon.name;
    } else if (itemId == 'oran-berry') {
      if (currentTargetHp <= 0) return;
      newHp = min(targetMaxHp, currentTargetHp + 10);
      healedMonName = targetMon.name;
    }

    if (isInstantWin) {
      state = state.copyWith(isFinished: true, winner: 'player', isAnimating: false);
      return;
    }

    final newHpMap = Map<String, int>.from(state.playerHpMap);
    newHpMap[targetMon.id] = newHp;

    final isTargetActive = targetMon.id == state.playerPokemon.id;

    state = state.copyWith(
      playerCurrentHp: isTargetActive ? newHp : state.playerCurrentHp,
      playerHpMap: newHpMap,
      inventory: updatedInventory,
      message: 'You used a ${itemId.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}${healedMonName != null ? ' on $healedMonName' : ''}! Its health was restored.',
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    state = state.copyWith(
      isPlayerTurn: false,
      isAnimating: false,
    );
  }

  Future<void> _playerSwap(Pokemon newPokemon) async {
    if (newPokemon.id == state.playerPokemon.id) {
      state = state.copyWith(message: '${newPokemon.name} is already in battle!', isAnimating: false);
      return;
    }

    final isMandatory = state.isWaitingForSwitch;
    final volatiles = state.volatileStatusMap[state.playerPokemon.id] ?? [];
    if (volatiles.contains('trapped') && !isMandatory) {
      state = state.copyWith(
        message: '${state.playerPokemon.name} is trapped and cannot switch!',
        isAnimating: false,
      );
      return;
    }
    final pHPMap = Map<String, int>.from(state.playerHpMap);
    pHPMap[state.playerPokemon.id] = state.playerCurrentHp;

    _addLogEntry(
      message: 'Come back, ${state.playerPokemon.name}! Go, ${newPokemon.name}!',
      type: 'switch',
      isPlayer: true,
      pokemonId: newPokemon.id,
      pokemonName: newPokemon.name,
      sprites: newPokemon.backSpriteUrls,
    );

    state = state.copyWith(
      message: 'Come back, ${state.playerPokemon.name}! Go, ${newPokemon.name}!',
      playerHpMap: pHPMap,
    );

    await Future.delayed(const Duration(milliseconds: 600));

    final rosterForms = ref.read(rosterProvider).value ?? [];
    final idx = state.playerTeam.indexWhere((p) => p.id == newPokemon.id);
    final level = (idx != -1 && idx < rosterForms.length) ? rosterForms[idx].level : 50;
    final newMaxHp = (((2 * (newPokemon.baseStats['hp'] ?? 100) + 31 + 63) * level) / 100).floor() + level + 10;
    
    final savedHp = state.playerHpMap[newPokemon.id] ?? newMaxHp;

    // Clear volatile statuses on switch out
    final newVolatileMap = Map<String, List<String>>.from(state.volatileStatusMap);
    final newVolatileTurns = Map<String, Map<String, int>>.from(state.volatileStatusTurns);
    newVolatileMap[state.playerPokemon.id] = [];
    newVolatileTurns[state.playerPokemon.id] = {};

    state = state.copyWith(
      playerPokemon: newPokemon,
      activePlayerIdx: idx,
      playerLevel: level,
      playerMaxHp: newMaxHp,
      playerCurrentHp: savedHp,
      isPlayerTurn: isMandatory,
      isAnimating: false,
      isWaitingForSwitch: false,
      volatileStatusMap: newVolatileMap,
      volatileStatusTurns: newVolatileTurns,
      message: isMandatory
          ? 'What will ${newPokemon.name} do?'
          : state.message,
    );
  }

  Future<void> _cpuTurn() async {
    if (state.isFinished || state.isWaitingForSwitch) return;

    state = state.copyWith(isAnimating: true, message: '${state.opponentPokemon.name}\'s turn.');
    await Future.delayed(const Duration(milliseconds: 1200));

    if (state.difficulty == 'hard') {
      await _cpuHardTurnLogic();
    } else {
      final moves = state.opponentPokemon.availableMoves;
      final move = moves.isNotEmpty ? moves[_random.nextInt(moves.length)] : const PokemonMove(name: 'Tackle', learnLevel: 1, learnMethod: 'level-up');
      await _executeCpuMove(move);
    }
  }

  Future<void> _cpuHardTurnLogic() async {
    final cpuHpPercent = state.opponentCurrentHp / state.opponentMaxHp;
    final potionCount = state.cpuInventory['potion'] ?? 0;

    if (cpuHpPercent < 0.3 && potionCount > 0) {
      final healAmount = (state.opponentMaxHp * 0.5).toInt();
      final newHp = min(state.opponentMaxHp, state.opponentCurrentHp + healAmount);
      
      final newInventory = Map<String, int>.from(state.cpuInventory);
      newInventory['potion'] = potionCount - 1;

      final newHpMap = Map<String, int>.from(state.opponentHpMap);
      newHpMap[state.opponentPokemon.id] = newHp;

      state = state.copyWith(
        opponentCurrentHp: newHp,
        opponentHpMap: newHpMap,
        cpuInventory: newInventory,
        message: 'CPU used a Potion! ${state.opponentPokemon.name} recovered health.',
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      _endCpuTurn();
      return;
    }

    bool isMatchupBad = false;
    for (final pType in state.playerPokemon.types) {
        final pTypeEnum = TypeChart.stringToType(pType);
        final defenderTypes = state.opponentPokemon.types.map((t) => TypeChart.stringToType(t)).toList();
        if (TypeChart.getEffectiveness(pTypeEnum, defenderTypes) > 1.0) {
            isMatchupBad = true;
            break;
        }
    }

    if (isMatchupBad && _random.nextDouble() < 0.4) {
        int bestBenchIdx = -1;
        double bestEffectiveness = 0.0;

        for (int i = 0; i < state.opponentTeam.length; i++) {
            final mon = state.opponentTeam[i];
            if ((state.opponentHpMap[mon.id] ?? 0) <= 0 || i == state.activeOpponentIdx) continue;

            double resistance = 1.0;
            for (final pType in state.playerPokemon.types) {
                final pTypeEnum = TypeChart.stringToType(pType);
                final mTypes = mon.types.map((t) => TypeChart.stringToType(t)).toList();
                resistance /= TypeChart.getEffectiveness(pTypeEnum, mTypes);
            }
            if (resistance > bestEffectiveness) {
                bestEffectiveness = resistance;
                bestBenchIdx = i;
            }
        }

        if (bestBenchIdx != -1 && bestEffectiveness > 1.0) {
            final nextMon = state.opponentTeam[bestBenchIdx];
            final nextCurHp = state.opponentHpMap[nextMon.id] ?? 100;
            final nextMaxHp = state.opponentMaxHpMap[nextMon.id] ?? nextCurHp;

            _addLogEntry(
                message: 'CPU withdrew ${state.opponentPokemon.name} and sent out ${nextMon.name}!',
                type: 'switch',
                isPlayer: false,
                pokemonId: nextMon.id,
                pokemonName: nextMon.name,
                sprites: nextMon.frontSpriteUrls,
            );

            state = state.copyWith(
                message: 'CPU withdrew ${state.opponentPokemon.name} and sent out ${nextMon.name}!',
                opponentPokemon: nextMon,
                activeOpponentIdx: bestBenchIdx,
                opponentMaxHp: nextMaxHp,
                opponentCurrentHp: nextCurHp,
            );
            await Future.delayed(const Duration(milliseconds: 1200));
            _endCpuTurn();
            return;
        }
    }

    final moves = state.opponentPokemon.availableMoves;
    if (moves.isEmpty) {
        await _executeCpuMove(const PokemonMove(name: 'Tackle', learnLevel: 1, learnMethod: 'level-up'));
        return;
    }

    PokemonMove bestMove = moves[0];
    double bestScore = -1.0;

    for (final m in moves) {
      if (m.power <= 0) continue;
      final eff  = _getEffectiveness(m, state.playerPokemon);
      if (eff == 0) continue;
      final stab = state.opponentPokemon.types.map((t) => t.toLowerCase()).contains(m.type.toLowerCase()) ? 1.5 : 1.0;
      final score = m.power * eff * stab;
      if (score > bestScore) {
        bestScore = score;
        bestMove  = m;
      }
    }
    if (bestScore < 0) bestMove = moves[0];

    if (state.isRecharging) {
      state = state.copyWith(message: '${state.opponentPokemon.name} is recharging!', isAnimating: true);
      await Future.delayed(const Duration(milliseconds: 1200));
      state = state.copyWith(isAnimating: false, isPlayerTurn: !state.isFinished && !state.isPlayerTurn);
      _sendTelemetry();
      return;
    }

    await _executeCpuMove(bestMove);
  }

  Future<void> _executeCpuMove(PokemonMove move) async {
    _addLogEntry(
      message: '${state.opponentPokemon.name} used ${move.name}!',
      type: 'attack',
      isPlayer: false,
      pokemonId: state.opponentPokemon.id,
      pokemonName: state.opponentPokemon.name,
      sprites: state.opponentPokemon.frontSpriteUrls,
    );

    state = state.copyWith(
      message: '${state.opponentPokemon.name} used ${move.name}!',
      lastMoveName: move.name,
      lastMoveType: move.type,
    );

    if (!await _canExecuteMove(state.opponentPokemon, move)) {
      _endCpuTurn();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    final damage = _calculateDamage(state.opponentPokemon, state.playerPokemon, move);
    final newPlayerHp = max(0, state.playerCurrentHp - damage);

    final pHPMap = Map<String, int>.from(state.playerHpMap);
    pHPMap[state.playerPokemon.id] = newPlayerHp;

    final effectiveness = _getEffectiveness(move, state.playerPokemon);
    String feedback = '';
    if (effectiveness > 1.0) feedback = 'It\'s super effective!';
    if (effectiveness < 1.0 && effectiveness > 0) feedback = 'It\'s not very effective...';
    if (effectiveness == 0) feedback = 'It had no effect...';

    if (feedback.isNotEmpty) {
      _addLogEntry(
        message: feedback,
        type: 'status',
        isPlayer: false,
      );
    }

    final isRechargeMove = [
      'hyper-beam', 'giga-impact', 'frenzy-plant', 'blast-burn', 
      'hydro-cannon', 'rock-wrecker', 'roar-of-time', 'meteor-assault'
    ].contains(move.name.toLowerCase().replaceAll(' ', '-'));

    state = state.copyWith(
      playerCurrentHp: newPlayerHp,
      playerHpMap: pHPMap,
      message: (feedback.isNotEmpty ? '$feedback ' : '') + state.message,
      isRecharging: isRechargeMove,
    );

    // Inflict Status check
    if (newPlayerHp > 0) {
      await _attemptStatusInfliction(move, state.playerPokemon, true);
    await _attemptVolatileStatusInfliction(move, state.playerPokemon, true);
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    _handlePlayerDamage(newPlayerHp);
  }

  void _endCpuTurn() {
    state = state.copyWith(
      isPlayerTurn: true,
      isAnimating: false,
      message: 'What will ${state.playerPokemon.name} do?',
    );
  }

  void _handlePlayerDamage(int newPlayerHp) {
    if (newPlayerHp <= 0) {
      _addLogEntry(
        message: '${state.playerPokemon.name} fainted!',
        type: 'faint',
        isPlayer: true,
        pokemonId: state.playerPokemon.id,
        pokemonName: state.playerPokemon.name,
        sprites: state.playerPokemon.backSpriteUrls,
      );

      // Check for available Pokémon
      bool anyAlive = false;
      for (final p in state.playerTeam) {
          if ((state.playerHpMap[p.id] ?? 0) > 0) {
              anyAlive = true;
              break;
          }
      }

      if (anyAlive) {
        _addLogEntry(
          message: '${state.playerPokemon.name} fainted! Select another Pokémon!',
          type: 'info',
          isPlayer: true,
          pokemonId: state.playerPokemon.id,
          pokemonName: state.playerPokemon.name,
          sprites: state.playerPokemon.backSpriteUrls,
        );
        state = state.copyWith(
          isWaitingForSwitch: true,
          message: '${state.playerPokemon.name} fainted! Select another Pokémon!',
          isAnimating: false,
        );
      } else {
        state = state.copyWith(
          isFinished: true,
          winner: 'opponent',
          message: 'All your Pokémon fainted! You lost...',
          isAnimating: false,
        );
      }
      
      // Update individual win/loss stats
      _updatePokemonStats(state.playerPokemon.id, isWin: false);
    } else {
      state = state.copyWith(
        isPlayerTurn: true,
        isAnimating: false,
        message: 'What will ${state.playerPokemon.name} do?',
      );
    }
  }

  int _calculateDamage(Pokemon attacker, Pokemon defender, PokemonMove move, {bool crit = false}) {
    final bool isUserAttacking = attacker.id == state.playerPokemon.id;
    
    // Status Modifiers
    double statusDmgMod = 1.0;
    final attackerStatus = state.statusMap[attacker.id] ?? 'none';
    if (attackerStatus == 'brn' && move.damageClass == 'physical') {
      statusDmgMod = 0.5;
    } else if (attackerStatus == 'frb' && move.damageClass == 'special') {
      statusDmgMod = 0.5;
    }

    final damage = DamageCalculator.calculate(
      attacker: attacker,
      defender: defender,
      move: move,
      attackerLevel: isUserAttacking ? state.playerLevel : state.opponentLevel,
      defenderLevel: isUserAttacking ? state.opponentLevel : state.playerLevel,
      weather: state.weather,
      terrain: state.terrain,
      isCrit: crit,
    );
    
    return (damage * statusDmgMod).floor();
  }

  double _getEffectiveness(PokemonMove move, Pokemon defender) {
    final attackType = TypeChart.stringToType(move.type);
    final defenderTypes = defender.types.map((t) => TypeChart.stringToType(t)).toList();
    return TypeChart.getEffectiveness(attackType, defenderTypes);
  }

  /// Computes actual in-battle stats using the Gen 9 stat formula.
  /// Returns a map suitable for replacing baseStats on the battle Pokemon.
  Map<String, int> _computeEffectiveStats(Map<String, int> base, PokemonForm form) {
    final level = form.level;
    final evs = form.evs;
    final ivs = form.ivs;
    final natureMods = _natureModifiers[form.nature] ?? {};

    final result = <String, int>{};
    for (final stat in ['hp', 'atk', 'def', 'spa', 'spd', 'spe']) {
      final b = base[stat] ?? 50;
      final iv = ivs[stat] ?? 31;
      final ev = evs[stat] ?? 0;
      if (stat == 'hp') {
        result[stat] = ((2 * b + iv + (ev ~/ 4)) * level ~/ 100) + level + 10;
      } else {
        final raw = ((2 * b + iv + (ev ~/ 4)) * level ~/ 100) + 5;
        result[stat] = (raw * (natureMods[stat] ?? 1.0)).floor();
      }
    }
    return result;
  }

  static const _natureModifiers = <String, Map<String, double>>{
    'Lonely':  {'atk': 1.1, 'def': 0.9},
    'Brave':   {'atk': 1.1, 'spe': 0.9},
    'Adamant': {'atk': 1.1, 'spa': 0.9},
    'Naughty': {'atk': 1.1, 'spd': 0.9},
    'Bold':    {'def': 1.1, 'atk': 0.9},
    'Relaxed': {'def': 1.1, 'spe': 0.9},
    'Impish':  {'def': 1.1, 'spa': 0.9},
    'Lax':     {'def': 1.1, 'spd': 0.9},
    'Timid':   {'spe': 1.1, 'atk': 0.9},
    'Hasty':   {'spe': 1.1, 'def': 0.9},
    'Jolly':   {'spe': 1.1, 'spa': 0.9},
    'Naive':   {'spe': 1.1, 'spd': 0.9},
    'Modest':  {'spa': 1.1, 'atk': 0.9},
    'Mild':    {'spa': 1.1, 'def': 0.9},
    'Quiet':   {'spa': 1.1, 'spe': 0.9},
    'Rash':    {'spa': 1.1, 'spd': 0.9},
    'Calm':    {'spd': 1.1, 'atk': 0.9},
    'Gentle':  {'spd': 1.1, 'def': 0.9},
    'Sassy':   {'spd': 1.1, 'spe': 0.9},
    'Careful': {'spd': 1.1, 'spa': 0.9},
  };

  Future<void> _attemptStatusInfliction(PokemonMove move, Pokemon target, bool isPlayerTarget) async {
    if (move.statusEffect == 'none' || move.statusChance <= 0) return;
    
    final currentStatus = state.statusMap[target.id] ?? 'none';
    if (currentStatus != 'none') return; // Only one status at a time

    if (_random.nextInt(100) < move.statusChance) {
      final newStatusMap = Map<String, String>.from(state.statusMap);
      final newStatusTurns = Map<String, int>.from(state.statusTurns);
      
      newStatusMap[target.id] = move.statusEffect;
      newStatusTurns[target.id] = 1; // Start turn count at 1

      String statusMsg = '';
      switch (move.statusEffect) {
        case 'brn': statusMsg = '${target.name} was burned!'; break;
        case 'psn': statusMsg = '${target.name} was poisoned!'; break;
        case 'tox': 
          statusMsg = '${target.name} was badly poisoned!'; 
          newStatusTurns[target.id] = 1; // Toxic counter starts at 1
          break;
        case 'par': statusMsg = '${target.name} is paralyzed! It may be unable to move!'; break;
        case 'slp': 
          statusMsg = '${target.name} fell asleep!';
          newStatusTurns[target.id] = _random.nextInt(3) + 1; // 1-3 turns
          break;
        case 'frz': statusMsg = '${target.name} was frozen solid!'; break;
        case 'frb': statusMsg = '${target.name} got frostbite!'; break;
      }

      state = state.copyWith(
        statusMap: newStatusMap,
        statusTurns: newStatusTurns,
        message: statusMsg,
      );
      
      _addLogEntry(
        message: statusMsg,
        type: 'status',
        isPlayer: !isPlayerTarget,
      );
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  Future<void> _attemptVolatileStatusInfliction(PokemonMove move, Pokemon target, bool isPlayerTarget) async {
    final monId = target.id;
    final volatiles = List<String>.from(state.volatileStatusMap[monId] ?? []);
    final volatileTurns = Map<String, int>.from(state.volatileStatusTurns[monId] ?? {});
    
    String? effectToApply;
    int duration = 0;
    String statusMsg = '';

    // Move to Volatile Effect mapping
    final moveName = move.name.toLowerCase().replaceAll(' ', '-');
    
    if (moveName == 'confuse-ray' || moveName == 'supersonic' || moveName == 'sweet-kiss' || moveName == 'teeter-dance') {
      effectToApply = 'confusion';
      duration = _random.nextInt(4) + 2; // 2-5 turns
      statusMsg = '${target.name} became confused!';
    } else if (moveName == 'taunt') {
      effectToApply = 'taunt';
      duration = 3;
      statusMsg = '${target.name} fell for the taunt!';
    } else if (moveName == 'leech-seed') {
      effectToApply = 'leech_seed';
      statusMsg = '${target.name} was seeded!';
    } else if (moveName == 'fake-out' || moveName == 'stomp' || moveName == 'bite' || moveName == 'rock-slide' || moveName == 'air-slash') {
      // Moves with flinch chance (Simplified for this version - 30% chance if move allows)
      if (_random.nextInt(100) < 30 || moveName == 'fake-out') {
        effectToApply = 'flinch';
        statusMsg = '${target.name} flinched!';
      }
    } else if (moveName == 'encore') {
      effectToApply = 'encore';
      duration = 3;
      statusMsg = '${target.name} got an encore!';
    } else if (moveName == 'disable') {
      effectToApply = 'disable';
      duration = 4;
      statusMsg = '${target.name}\'s move was disabled!';
    } else if (moveName == 'curse' && (state.playerPokemon.types.contains('ghost') || state.opponentPokemon.types.contains('ghost'))) {
       effectToApply = 'curse';
       statusMsg = '${target.name} was cursed!';
    } else if (moveName == 'perish-song') {
       effectToApply = 'perish_song';
       duration = 3;
       statusMsg = 'All Pokémon hearing the song will faint in three turns!';
    } else if (moveName == 'yawn') {
       effectToApply = 'yawn';
       duration = 1;
       statusMsg = '${target.name} made ${target.name} drowsy!';
    } else if (moveName == 'mean-look' || moveName == 'block' || moveName == 'spider-web') {
       effectToApply = 'trapped';
       statusMsg = '${target.name} was trapped!';
    }

    if (effectToApply != null && !volatiles.contains(effectToApply)) {
      volatiles.add(effectToApply);
      if (duration > 0) volatileTurns[effectToApply] = duration;

      final newVolatileMap = Map<String, List<String>>.from(state.volatileStatusMap);
      final newVolatileTurns = Map<String, Map<String, int>>.from(state.volatileStatusTurns);
      newVolatileMap[monId] = volatiles;
      newVolatileTurns[monId] = volatileTurns;

      state = state.copyWith(
        volatileStatusMap: newVolatileMap,
        volatileStatusTurns: newVolatileTurns,
        message: statusMsg,
      );

      _addLogEntry(
        message: statusMsg,
        type: 'status',
        isPlayer: !isPlayerTarget,
      );
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  Future<void> _processEndOfTurnEffects() async {
    final participants = [state.playerPokemon, state.opponentPokemon];
    
    for (final mon in participants) {
      final isPlayer = mon.id == state.playerPokemon.id;
      final curHp = isPlayer ? state.playerCurrentHp : state.opponentCurrentHp;
      if (curHp <= 0) continue;

      final status = state.statusMap[mon.id] ?? 'none';
      final volatiles = state.volatileStatusMap[mon.id] ?? [];
      final maxHp = isPlayer ? state.playerMaxHp : state.opponentMaxHp;

      // 1. Primary Status Effects
      int statusDmg = 0;
      String statusMsg = '';
      
      switch (status) {
        case 'brn':
          statusDmg = (maxHp / 16).floor().clamp(1, maxHp);
          statusMsg = '${mon.name} was hurt by its burn!';
          break;
        case 'psn':
          statusDmg = (maxHp / 8).floor().clamp(1, maxHp);
          statusMsg = '${mon.name} was hurt by poison!';
          break;
        case 'tox':
          final counter = state.statusTurns[mon.id] ?? 1;
          statusDmg = (maxHp * counter / 16).floor().clamp(1, maxHp);
          statusMsg = '${mon.name} was hurt by poison!';
          // Increment Toxic counter
          final newStatusTurns = Map<String, int>.from(state.statusTurns);
          newStatusTurns[mon.id] = counter + 1;
          state = state.copyWith(statusTurns: newStatusTurns);
          break;
        case 'frb':
          statusDmg = (maxHp / 16).floor().clamp(1, maxHp);
          statusMsg = '${mon.name} was hurt by frostbite!';
          break;
      }

      if (statusDmg > 0) {
        if (isPlayer) {
          _handlePlayerDamage(max(0, state.playerCurrentHp - statusDmg));
        } else {
          _handleOpponentDamage(max(0, state.opponentCurrentHp - statusDmg));
        }
        state = state.copyWith(message: statusMsg);
        _addLogEntry(message: statusMsg, type: 'status', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (state.isFinished) return;
      }

      // 2. Volatile Effects (Leech Seed, Curse, Nightmare)
      int volatileDmg = 0;
      String volMsg = '';

      if (volatiles.contains('leech_seed')) {
        volatileDmg = (maxHp / 8).floor().clamp(1, maxHp);
        volMsg = '${mon.name}\'s energy was drained by Leech Seed!';
        // Heal the other side
        if (isPlayer) {
          final heal = min(state.opponentMaxHp - state.opponentCurrentHp, volatileDmg);
          _handleOpponentDamage(state.opponentCurrentHp + heal);
        } else {
          final heal = min(state.playerMaxHp - state.playerCurrentHp, volatileDmg);
          _handlePlayerDamage(state.playerCurrentHp + heal);
        }
      } else if (volatiles.contains('curse')) {
        volatileDmg = (maxHp / 4).floor().clamp(1, maxHp);
        volMsg = '${mon.name} is afflicted by the curse!';
      } else if (volatiles.contains('nightmare') && status == 'slp') {
        volatileDmg = (maxHp / 4).floor().clamp(1, maxHp);
        volMsg = '${mon.name} is locked in a nightmare!';
      }

      if (volatileDmg > 0) {
        if (isPlayer) {
          _handlePlayerDamage(max(0, state.playerCurrentHp - volatileDmg));
        } else {
          _handleOpponentDamage(max(0, state.opponentCurrentHp - volatileDmg));
        }
        state = state.copyWith(message: volMsg);
        _addLogEntry(message: volMsg, type: 'status', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (state.isFinished) return;
      }

      // 3. Status Transitions (Yawn, Perish Song)
      if (volatiles.contains('yawn')) {
        final turns = state.volatileStatusTurns[mon.id]?['yawn'] ?? 0;
        if (turns <= 0) {
          // Fall asleep
          if (status == 'none') {
            final newStatusMap = Map<String, String>.from(state.statusMap);
            newStatusMap[mon.id] = 'slp';
            final newStatusTurns = Map<String, int>.from(state.statusTurns);
            newStatusTurns[mon.id] = _random.nextInt(3) + 1;
            state = state.copyWith(statusMap: newStatusMap, statusTurns: newStatusTurns, message: '${mon.name} fell asleep!');
            _addLogEntry(message: '${mon.name} fell asleep!', type: 'status', isPlayer: isPlayer);
          }
          // Remove yawn
          final newVolMap = Map<String, List<String>>.from(state.volatileStatusMap);
          newVolMap[mon.id] = List<String>.from(volatiles)..remove('yawn');
          state = state.copyWith(volatileStatusMap: newVolMap);
          await Future.delayed(const Duration(milliseconds: 1000));
        } else {
          final newVolTurns = Map<String, Map<String, int>>.from(state.volatileStatusTurns);
          final monTurns = Map<String, int>.from(newVolTurns[mon.id] ?? {});
          monTurns['yawn'] = turns - 1;
          newVolTurns[mon.id] = monTurns;
          state = state.copyWith(volatileStatusTurns: newVolTurns);
        }
      }

      if (volatiles.contains('perish_song')) {
        final count = state.volatileStatusTurns[mon.id]?['perish_song'] ?? 0;
        state = state.copyWith(message: 'The perish count fell to $count for ${mon.name}!');
        _addLogEntry(message: 'Perish count: $count', type: 'info', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));

        if (count <= 0) {
          if (isPlayer) {
            _handlePlayerDamage(0);
          } else {
            _handleOpponentDamage(0);
          }
          state = state.copyWith(message: '${mon.name}\'s perish count reached zero!');
          _addLogEntry(message: '${mon.name} fainted!', type: 'faint', isPlayer: isPlayer);
          await Future.delayed(const Duration(milliseconds: 1000));
        } else {
          final newVolTurns = Map<String, Map<String, int>>.from(state.volatileStatusTurns);
          final monTurns = Map<String, int>.from(newVolTurns[mon.id] ?? {});
          monTurns['perish_song'] = count - 1;
          newVolTurns[mon.id] = monTurns;
          state = state.copyWith(volatileStatusTurns: newVolTurns);
        }
      }
    }
  }

  Future<bool> _canExecuteMove(Pokemon mon, PokemonMove move) async {
    final status = state.statusMap[mon.id] ?? 'none';
    final isPlayer = mon.id == state.playerPokemon.id;
    final volatiles = state.volatileStatusMap[mon.id] ?? [];

    // 1. Flinch (Volatile - lasts one turn)
    if (volatiles.contains('flinch')) {
      final newVolatileMap = Map<String, List<String>>.from(state.volatileStatusMap);
      newVolatileMap[mon.id] = List<String>.from(volatiles)..remove('flinch');
      state = state.copyWith(
        volatileStatusMap: newVolatileMap,
        message: '${mon.name} flinched and couldn\'t move!',
      );
      _addLogEntry(message: '${mon.name} flinched!', type: 'info', isPlayer: isPlayer);
      await Future.delayed(const Duration(milliseconds: 1000));
      return false;
    }

    // 2. Freeze
    if (status == 'frz') {
      if (_random.nextDouble() < 0.2) {
        final newStatusMap = Map<String, String>.from(state.statusMap);
        newStatusMap[mon.id] = 'none';
        state = state.copyWith(statusMap: newStatusMap, message: '${mon.name} thawed out!');
        _addLogEntry(message: '${mon.name} thawed out!', type: 'status', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        state = state.copyWith(message: '${mon.name} is frozen solid!');
        _addLogEntry(message: '${mon.name} is frozen solid!', type: 'status', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));
        return false;
      }
    }

    // 3. Sleep
    if (status == 'slp') {
      final turns = state.statusTurns[mon.id] ?? 0;
      if (turns <= 0) {
        final newStatusMap = Map<String, String>.from(state.statusMap);
        newStatusMap[mon.id] = 'none';
        state = state.copyWith(statusMap: newStatusMap, message: '${mon.name} woke up!');
        _addLogEntry(message: '${mon.name} woke up!', type: 'status', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        final newTurns = Map<String, int>.from(state.statusTurns);
        newTurns[mon.id] = turns - 1;
        state = state.copyWith(statusTurns: newTurns, message: '${mon.name} is fast asleep.');
        _addLogEntry(message: '${mon.name} is fast asleep.', type: 'status', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));
        return false;
      }
    }

    // 4. Paralysis
    if (status == 'par') {
      if (_random.nextDouble() < 0.25) {
        state = state.copyWith(message: '${mon.name} is paralyzed! It can\'t move!');
        _addLogEntry(message: '${mon.name} is paralyzed! It can\'t move!', type: 'status', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));
        return false;
      }
    }

    // 5. Confusion (Volatile)
    if (volatiles.contains('confusion')) {
      final turnsRemaining = state.volatileStatusTurns[mon.id]?['confusion'] ?? 0;
      if (turnsRemaining <= 0) {
        final newVolatileMap = Map<String, List<String>>.from(state.volatileStatusMap);
        newVolatileMap[mon.id] = List<String>.from(volatiles)..remove('confusion');
        state = state.copyWith(volatileStatusMap: newVolatileMap, message: '${mon.name} snapped out of its confusion!');
        _addLogEntry(message: '${mon.name} snapped out of confusion!', type: 'info', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        // Decrement turns
        final newVolatileTurns = Map<String, Map<String, int>>.from(state.volatileStatusTurns);
        final monTurns = Map<String, int>.from(newVolatileTurns[mon.id] ?? {});
        monTurns['confusion'] = turnsRemaining - 1;
        newVolatileTurns[mon.id] = monTurns;
        state = state.copyWith(volatileStatusTurns: newVolatileTurns, message: '${mon.name} is confused...');
        _addLogEntry(message: '${mon.name} is confused...', type: 'info', isPlayer: isPlayer);
        await Future.delayed(const Duration(milliseconds: 800));

        if (_random.nextDouble() < 0.5) {
          // Hits self
          final damage = ((((2 * 50 / 5 + 2) * 40 * (mon.baseStats['atk'] ?? 100) / (mon.baseStats['def'] ?? 100)) / 50) + 2).floor();
          state = state.copyWith(message: 'It hurt itself in its confusion!', isAnimating: true);
          _addLogEntry(message: 'It hurt itself in its confusion!', type: 'info', isPlayer: isPlayer);
          
          if (isPlayer) {
            final newHp = max(0, state.playerCurrentHp - damage);
            _handlePlayerDamage(newHp);
          } else {
            final newHp = max(0, state.opponentCurrentHp - damage);
            _handleOpponentDamage(newHp);
          }
          await Future.delayed(const Duration(milliseconds: 1000));
          return false;
        }
      }
    }

    // 6. Taunt (Volatile)
    if (volatiles.contains('taunt') && move.damageClass == 'status') {
      state = state.copyWith(message: '${mon.name} can\'t use status moves while taunted!');
      _addLogEntry(message: '${mon.name} is taunted!', type: 'info', isPlayer: isPlayer);
      await Future.delayed(const Duration(milliseconds: 1000));
      return false;
    }

    // 7. Disable
    final disabledMove = state.disabledMoveMap[mon.id];
    if (disabledMove == move.name) {
      state = state.copyWith(message: '${move.name} is disabled!');
      _addLogEntry(message: '${move.name} is disabled!', type: 'info', isPlayer: isPlayer);
      await Future.delayed(const Duration(milliseconds: 1000));
      return false;
    }

    return true;
  }


  void _handleOpponentDamage(int newHp) {
    final newHpMap = Map<String, int>.from(state.opponentHpMap);
    newHpMap[state.opponentPokemon.id] = newHp;
    state = state.copyWith(opponentCurrentHp: newHp, opponentHpMap: newHpMap);
  }

  Future<void> _updatePokemonStats(String pokemonFormId, {required bool isWin}) async {
    final repo = ref.read(rosterRepositoryProvider);
    final allRoster = await repo.getRosterPokemon();
    final idx = allRoster.indexWhere((p) => p.id == pokemonFormId);
    
    if (idx != -1) {
      final mon = allRoster[idx];
      final updated = mon.copyWith(
        wins: isWin ? mon.wins + 1 : mon.wins,
        losses: !isWin ? mon.losses + 1 : mon.losses,
      );
      await repo.updateRosterPokemon(updated);
    }
  }
  Future<void> _processCPUVictoryReward() async {
    state = state.copyWith(message: 'VICTORY! Processing rewards...');
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Default reward: 500 Pokedollars
    final repo = ref.read(rosterRepositoryProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (profile != null) {
      final updatedProfile = profile.copyWith(
        pokedollars: profile.pokedollars + 500,
      );
      // await ref.read(authControllerProvider.notifier).updateProfile(updatedProfile);
      state = state.copyWith(message: 'You received 500 Pokedollars!');
    }
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}
