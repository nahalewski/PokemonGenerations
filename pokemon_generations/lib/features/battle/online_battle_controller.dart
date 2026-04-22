import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/battle_state.dart';
import '../../domain/models/pokemon.dart';
import '../../core/utils/damage_calculator.dart';
import '../../domain/models/social.dart';
import '../../data/services/api_client.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/services/battle_reconnect_service.dart';
import '../auth/auth_controller.dart';
import '../../data/providers.dart';
import '../roster/roster_provider.dart';
import '../replays/services/replay_recorder.dart';
import '../../domain/models/replay_models.dart';

/// Tracks when the current player's turn expires (null = no active battle or spectating).
final battleTurnDeadlineProvider =
    StateProvider.autoDispose.family<DateTime?, String>((ref, battleId) => null);

final onlineBattleControllerProvider =
    StateNotifierProvider.autoDispose.family<OnlineBattleController, BattleState, String>(
  (ref, battleId) => OnlineBattleController(ref, battleId),
);

class OnlineBattleController extends StateNotifier<BattleState> {
  final Ref ref;
  final String battleId;
  Timer? _pollingTimer;
  bool _teamHydrated = false;
  int _historyIndex = 0;
  final _random = Random();
  ReplayRecorder? _recorder;

  OnlineBattleController(this.ref, this.battleId)
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

  Future<void> _initializeBattle() async {
    await BattleReconnectService.saveBattleId(battleId);
    
    // Initialize Recorder with starting state
    _recorder = ReplayRecorder(
      battleId: battleId,
      initialReplay: BattleReplay(
        version: 1,
        battleId: battleId,
        ruleset: 'standard',
        startTimestampMs: DateTime.now().millisecondsSinceEpoch,
        rngSeed: _random.nextInt(1000000),
        p1: ReplayPlayer(username: 'Player 1', displayName: 'Player 1', team: []), // Will hydrate
        p2: ReplayPlayer(username: 'Player 2', displayName: 'Player 2', team: []),
        turns: [],
        winner: '',
      ),
    );

    await _pollState();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollState());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _pollState() async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return;

    final api = ref.read(apiClientProvider.notifier);
    final session = await api.getBattleSession(baseUrl, battleId);
    if (session == null) return;

    final myUsername = profile.username;
    final isSpectator = session.player1 != myUsername && session.player2 != myUsername;
    final effectivePlayer = isSpectator ? session.player1 : myUsername;
    final effectiveOpponent = isSpectator
        ? session.player2
        : (session.player1 == myUsername ? session.player2 : session.player1);

    // Full team hydration — runs once, loads all pokemon + warms sprite cache
    if (!_teamHydrated && session.rosters.isNotEmpty) {
      await _hydrateFullTeam(
        session: session,
        myUsername: effectivePlayer,
        opponentUsername: effectiveOpponent,
        api: api,
        baseUrl: baseUrl,
        isSpectator: isSpectator,
      );
    }

    // Monitor connectivity
    final allUsers = await api.fetchGlobalUsers(baseUrl);
    final p1Profile = allUsers.firstWhere(
      (u) => u.username == session.player1,
      orElse: () => SocialUser(username: '', displayName: ''),
    );
    final p2Profile = allUsers.firstWhere(
      (u) => u.username == session.player2,
      orElse: () => SocialUser(username: '', displayName: ''),
    );

    final isMyTurn = !isSpectator && session.currentTurn == myUsername;

    // Update turn deadline for countdown display
    if (!isSpectator && session.lastUpdate != null && session.status == 'active') {
      final deadline = session.lastUpdate!.add(const Duration(seconds: 90));
      if (mounted) {
        ref.read(battleTurnDeadlineProvider(battleId).notifier).state = deadline;
      }
    }

    if (!mounted) return;

    state = state.copyWith(
      isPlayerTurn: isMyTurn,
      player1Connected: p1Profile.status != 'offline',
      player2Connected: p2Profile.status != 'offline',
      isWaitingForOpponent: !isSpectator && !isMyTurn && session.status == 'active',
      isSpectator: isSpectator,
      message: state.isAnimating
          ? state.message
          : (isSpectator
              ? 'SPECTATING: ${session.currentTurn}\'s turn'
              : (isMyTurn ? 'Your turn! Select a move.' : 'Waiting for opponent...')),
      isFinished: session.status == 'finished',
      winner: session.status == 'finished' ? session.currentTurn : null,
      player1Name: session.player1,
      player2Name: session.player2,
    );

    if (session.status == 'finished') {
      _pollingTimer?.cancel();
      _recorder?.saveReplay(session.currentTurn ?? 'Draw', endReason: 'faint');
      await BattleReconnectService.clearBattleId();
      ref.read(rosterRepositoryProvider).syncWithCloud().then((_) {
        ref.invalidate(rosterProvider);
      }).catchError((e) {
        // ignore: avoid_print
        print('[BATTLE] Post-battle sync failed: $e');
        return null;
      });
    }

    // Authoritative HP Sync (Matches Truth)
    if (session.hpState.isNotEmpty) {
      final myHpData = session.hpState[myUsername] as Map<String, dynamic>? ?? {};
      final oppHpData = session.hpState[effectiveOpponent] as Map<String, dynamic>? ?? {};

      final myActiveHp = myHpData['active'];
      final oppActiveHp = oppHpData['active'];

      if (myActiveHp != null && (myActiveHp as num).toInt() != state.playerCurrentHp) {
         state = state.copyWith(playerCurrentHp: (myActiveHp as num).toInt());
      }
      if (oppActiveHp != null && (oppActiveHp as num).toInt() != state.opponentCurrentHp) {
         state = state.copyWith(opponentCurrentHp: (oppActiveHp as num).toInt());
      }
    }

    // Playback new history items if it's not my turn
    if (session.history.length > _historyIndex) {
      final newItems = session.history.sublist(_historyIndex);
      _historyIndex = session.history.length;
      
      // Log to recorder
      for (final item in newItems) {
        _recorder?.logEvent(item['type'] ?? 'info', item['results'] ?? {});
      }

      // Filter for opponent's moves if we are the active player
      final playbackItems = newItems.where((item) => item['username'] != myUsername).toList();
      if (playbackItems.isNotEmpty) {
        _playbackHistory(playbackItems);
      }
    }
  }

  Future<void> _playbackHistory(List<Map<String, dynamic>> items) async {
    for (final item in items) {
      final results = item['results'] as Map<String, dynamic>?;
      if (results == null) continue;

      state = state.copyWith(isAnimating: true, message: results['message'] ?? 'Opponent moved...');
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (results['type'] == 'attack') {
        // Health will catch up on the next poll/authority block
      }
      
      state = state.copyWith(isAnimating: false);
    }
  }

  Future<void> _hydrateFullTeam({
    required BattleSession session,
    required String myUsername,
    required String opponentUsername,
    required ApiClient api,
    required String baseUrl,
    required bool isSpectator,
  }) async {
    try {
      // 1. Fetch full PokemonForm roster for both players
      final myFormsFuture = api.fetchRoster(baseUrl, myUsername);
      final oppFormsFuture = api.fetchRoster(baseUrl, opponentUsername);
      final results = await Future.wait([myFormsFuture, oppFormsFuture]);
      final myForms = results[0];
      final oppForms = results[1];

      if (myForms.isEmpty && oppForms.isEmpty) {
        // Fall back to the minimal roster stored in the session
        final mySessionRoster = session.rosters[myUsername] ?? [];
        final oppSessionRoster = session.rosters[opponentUsername] ?? [];
        if (mySessionRoster.isEmpty || oppSessionRoster.isEmpty) return;

        final myLeadId = mySessionRoster[0]['pokemonId'].toString();
        final oppLeadId = oppSessionRoster[0]['pokemonId'].toString();
        final myLead = await api.getPokemonDetail(myLeadId);
        final oppLead = await api.getPokemonDetail(oppLeadId);
        if (myLead != null && oppLead != null && mounted) {
          state = state.copyWith(
            playerPokemon: myLead,
            opponentPokemon: oppLead,
            playerMaxHp: myLead.baseStats['hp'] ?? 100,
            opponentMaxHp: oppLead.baseStats['hp'] ?? 100,
            playerCurrentHp: myLead.baseStats['hp'] ?? 100,
            opponentCurrentHp: oppLead.baseStats['hp'] ?? 100,
          );
          _warmSpriteCache([myLead, oppLead]);
        }
        _teamHydrated = true;
        return;
      }

      // 2. Fetch Pokemon details for every form
      final myPokemonFutures = myForms.map((f) => api.getPokemonDetail(f.pokemonId.toString()));
      final oppPokemonFutures = oppForms.map((f) => api.getPokemonDetail(f.pokemonId.toString()));

      final myPokemonResults = await Future.wait(myPokemonFutures);
      final oppPokemonResults = await Future.wait(oppPokemonFutures);

      final myTeam = myPokemonResults.whereType<Pokemon>().toList();
      final oppTeam = oppPokemonResults.whereType<Pokemon>().toList();

      if (myTeam.isEmpty || oppTeam.isEmpty) return;

      // 3. Warm sprite cache for all pokemon
      _warmSpriteCache([...myTeam, ...oppTeam]);

      if (!mounted) return;

      state = state.copyWith(
        playerPokemon: myTeam.first,
        opponentPokemon: oppTeam.first,
        playerTeam: myTeam,
        playerMaxHp: myTeam.first.baseStats['hp'] ?? 100,
        opponentMaxHp: oppTeam.first.baseStats['hp'] ?? 100,
        playerCurrentHp: myTeam.first.baseStats['hp'] ?? 100,
        opponentCurrentHp: oppTeam.first.baseStats['hp'] ?? 100,
        player1Name: session.player1,
        player2Name: session.player2,
        isSpectator: isSpectator,
      );

      _teamHydrated = true;
      print('[BATTLE] Team hydrated: ${myTeam.length} player pokemon, ${oppTeam.length} opponent pokemon');
    } catch (e) {
      print('[BATTLE] Team hydration failed: $e');
    }
  }

  void _warmSpriteCache(List<Pokemon> pokemon) {
    for (final p in pokemon) {
      for (final url in [...p.frontSpriteUrls, ...p.backSpriteUrls]) {
        try {
          CachedNetworkImageProvider(url).resolve(const ImageConfiguration());
        } catch (_) {}
      }
    }
  }

  Future<void> handleAction(BattleAction action) async {
    if (state.isWaitingForOpponent || state.isFinished || state.isAnimating) return;

    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return;

    state = state.copyWith(isAnimating: true);

    final results = await _calculateActionResults(action);
    _applyLocalAction(action, results);

    final api = ref.read(apiClientProvider.notifier);
    final actionMap = action.when(
      attack: (move) => {'type': 'attack', 'move': move.name},
      item: (itemId, targetId) => {'type': 'item', 'itemId': itemId, 'targetId': targetId},
      pokemon: (p) => {'type': 'swap', 'pokemonId': p.id},
      run: () => {'type': 'run'},
    );

    final success = await action.when(
      attack: (_) async => true, // handled by server/submit
      item: (_, __) async => true,
      pokemon: (_) async => true,
      run: () async {
        state = state.copyWith(message: 'Got away safely!');
        await Future.delayed(const Duration(milliseconds: 1000));
        return true;
      },
    );

    if (action is RunAction) {
       state = state.copyWith(isFinished: true, winner: 'none');
       return;
    }

    final submitSuccess = await api.submitOnlineMove(
      baseUrl,
      battleId,
      profile.username,
      actionMap,
      results: results,
    );

    if (!submitSuccess && mounted) {

      state = state.copyWith(
        isAnimating: false,
        isWaitingForOpponent: false,
        message: 'Failed to submit move. Try again.',
      );
    }
  }

  Future<Map<String, dynamic>> _calculateActionResults(BattleAction action) async {
    return action.when(
      attack: (move) {
        final damage = _calculateDamage(state.playerPokemon, state.opponentPokemon, move);
        final isCrit = _random.nextDouble() < 0.06;
        final newHp = (state.opponentCurrentHp - damage).clamp(0, state.opponentMaxHp);
        return {
          'type': 'attack',
          'damage': damage,
          'newHp': newHp,
          'targetPokemonId': 'active',
          'effectiveness': 1.0,
          'isCrit': isCrit,
          'message': '${state.playerPokemon.name} used ${move.name}!',
          'isFinished': newHp <= 0,
        };
      },
      item: (itemId, targetId) {
        final isDarkBall = itemId == 'dark-ball';
        return {
          'type': 'item',
          'itemId': itemId,
          'message': isDarkBall 
              ? 'DARK BALL DEPLOYED. TARGET CAPTURED.' 
              : 'Trainer used $itemId!',
          'isFinished': isDarkBall,
        };
      },
      pokemon: (p) => {'type': 'swap', 'pokemonId': p.id, 'message': 'Go, ${p.name}!'},
      run: () => {
        'type': 'run',
        'message': 'You ran away!',
        'isFinished': true,
      },
    );
  }

  void _applyLocalAction(BattleAction action, Map<String, dynamic> results) {
    final myUsername = ref.read(authControllerProvider).profile?.username;
    action.when(
      attack: (move) {
        final damage = results['damage'] as int;
        state = state.copyWith(
          opponentCurrentHp: (state.opponentCurrentHp - damage).clamp(0, state.opponentMaxHp),
          message: results['message'],
          isWaitingForOpponent: true,
          isAnimating: false,
        );
      },
      item: (itemId, targetId) {
        final isDarkBall = itemId == 'dark-ball';
        state = state.copyWith(
          message: results['message'],
          isWaitingForOpponent: !isDarkBall,
          isFinished: isDarkBall,
          winner: isDarkBall ? myUsername : null,
          isAnimating: false,
        );
      },
      pokemon: (p) => state = state.copyWith(
        playerPokemon: p,
        message: results['message'],
        isWaitingForOpponent: true,
        isAnimating: false,
      ),
      run: () => state = state.copyWith(
        message: results['message'],
        isFinished: true,
        isAnimating: false,
      ),
    );
  }

  int _calculateDamage(Pokemon attacker, Pokemon defender, PokemonMove move) {
    return DamageCalculator.calculate(
      attacker: attacker,
      defender: defender,
      move: move,
      attackerLevel: 50, // Standard online level
      defenderLevel: 50,
      weather: state.weather,
      terrain: state.terrain,
    );
  }
}
