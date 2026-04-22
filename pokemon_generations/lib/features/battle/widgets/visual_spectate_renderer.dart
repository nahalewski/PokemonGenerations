import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/models/battle_state.dart';
import '../../../domain/models/replay_models.dart';
import '../../../domain/models/pokemon.dart';
import 'battle_widgets.dart';

/// A component that reconstructs a battle's visuals from an event feed.
/// Reuses existing battle UI components for perfect fidelity.
class VisualSpectateRenderer extends StatefulWidget {
  final Stream<ReplayEvent> eventStream;
  final BattleReplay initialData;
  final double playbackSpeed;

  const VisualSpectateRenderer({
    super.key,
    required this.eventStream,
    required this.initialData,
    this.playbackSpeed = 1.0,
  });

  @override
  State<VisualSpectateRenderer> createState() => _VisualSpectateRendererState();
}

class _VisualSpectateRendererState extends State<VisualSpectateRenderer> {
  late BattleState _state;
  StreamSubscription? _subscription;
  int _currentTurn = 0;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _subscribeToEvents();
  }

  void _initializeState() {
    // Reconstruct the initial BattleState from the Replay starting conditions
    _state = BattleState(
      playerPokemon: _convertToPokemon(widget.initialData.p1.team.first),
      opponentPokemon: _convertToPokemon(widget.initialData.p2.team.first),
      playerCurrentHp: widget.initialData.p1.team.first.currentHp,
      opponentCurrentHp: widget.initialData.p2.team.first.currentHp,
      playerMaxHp: widget.initialData.p1.team.first.maxHp,
      opponentMaxHp: widget.initialData.p2.team.first.maxHp,
      player1Name: widget.initialData.p1.username,
      player2Name: widget.initialData.p2.username,
      isSpectator: true,
      message: 'Initialising spectate feed...',
    );
  }

  void _subscribeToEvents() {
    _subscription = widget.eventStream.listen(_handleEvent);
  }

  Future<void> _handleEvent(ReplayEvent event) async {
    final data = event.data ?? {};
    
    switch (event.type) {
      case 'move':
        await _handleMove(data);
        break;
      case 'damage':
        _handleDamage(data);
        break;
      case 'switch':
        _handleSwitch(data);
        break;
      case 'faint':
        _handleFaint(data);
        break;
      case 'status':
        _handleStatus(data);
        break;
      default:
        setState(() => _state = _state.copyWith(message: data['message'] ?? ''));
    }
  }

  Future<void> _handleMove(Map<String, dynamic> data) async {
    final isPlayer = data['actor_id'] == 'p1';
    final moveName = data['move_name'] ?? 'Attack';
    
    setState(() {
      _state = _state.copyWith(
        isAnimating: true,
        message: '${isPlayer ? _state.playerPokemon.name : _state.opponentPokemon.name} used $moveName!',
        lastMoveName: moveName,
      );
    });

    // Wait for the move animation (scaled by playback speed)
    await Future.delayed(Duration(milliseconds: (1500 / widget.playbackSpeed).round()));
    
    if (mounted) {
      setState(() => _state = _state.copyWith(isAnimating: false));
    }
  }

  void _handleDamage(Map<String, dynamic> data) {
    final isPlayer = data['target_id'] == 'p1';
    final remainingHp = data['remaining_hp'] as int;
    
    setState(() {
      if (isPlayer) {
        _state = _state.copyWith(playerCurrentHp: remainingHp);
      } else {
        _state = _state.copyWith(opponentCurrentHp: remainingHp);
      }
    });
  }

  void _handleSwitch(Map<String, dynamic> data) {
    final isPlayer = data['actor_id'] == 'p1';
    // Ideally we would hydrate the full Pokemon model here
    // For now, we update the active pokemon name/hp
    setState(() {
      if (isPlayer) {
        _state = _state.copyWith(message: 'Go, ${data['pokemon_name']}!');
      } else {
        _state = _state.copyWith(message: 'Opponent sent out ${data['pokemon_name']}!');
      }
    });
  }

  void _handleFaint(Map<String, dynamic> data) {
    final isPlayer = data['target_id'] == 'p1';
     setState(() {
      _state = _state.copyWith(
        message: '${isPlayer ? _state.playerPokemon.name : _state.opponentPokemon.name} fainted!',
      );
    });
  }

  void _handleStatus(Map<String, dynamic> data) {
    // Logic for status overlay reconstruction
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  dynamic _convertToPokemon(ReplayPokemonState s) {
    // Return a hydrated Pokemon model for the UI
    return Pokemon(
      id: s.pokemonId,
      name: s.nickname,
      types: ['normal'], // Placeholder types
      baseStats: {'hp': s.maxHp},
      abilities: [],
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reusing the existing Battle components
        BattleHpBar(
          name: _state.opponentPokemon.name,
          currentHp: _state.opponentCurrentHp,
          maxHp: _state.opponentMaxHp,
          level: 50,
          isPlayer: false,
          trainerName: _state.player2Name,
        ),
        const Spacer(),
        // Visual effects layer (particles, etc.) could go here
        const Spacer(),
        BattleHpBar(
          name: _state.playerPokemon.name,
          currentHp: _state.playerCurrentHp,
          maxHp: _state.playerMaxHp,
          level: 50,
          isPlayer: true,
          trainerName: _state.player1Name,
        ),
        BattleMessageBox(message: _state.message),
      ],
    );
  }
}
