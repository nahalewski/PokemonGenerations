import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/services/audio_source_service.dart';
import 'online_battle_controller.dart';
import 'widgets/battle_widgets.dart';
import 'widgets/battle_overlay_widgets.dart';
import 'widgets/environmental_effects.dart';
import '../../core/services/weather_service.dart';
import '../../core/services/voice_action_service.dart';
import '../../domain/models/battle_state.dart';
import '../../core/services/gamepad_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/global_audio_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnlineBattleScreen extends ConsumerStatefulWidget {
  final String battleId;

  const OnlineBattleScreen({
    super.key,
    required this.battleId,
  });

  @override
  ConsumerState<OnlineBattleScreen> createState() => _OnlineBattleScreenState();
}

class _OnlineBattleScreenState extends ConsumerState<OnlineBattleScreen> {
  bool _showMoveMenu = false;
  int _selectedActionIndex = 0;
  int _selectedMoveIndex = 0;
  late AudioPlayer _audioPlayer;
  StreamSubscription<GamepadAction>? _gamepadSub;
  WeatherData? _currentWeather;
  bool _weatherHydrated = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();
    
    // Stop global menu music
    Future.microtask(() => ref.read(globalAudioControllerProvider).stopMenuMusic());
    
    _initWeather();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initGamepad());
  }

  Future<void> _initWeather() async {
    final weather = await ref.read(weatherServiceProvider).getCurrentWeather();
    if (mounted) {
      setState(() {
        _currentWeather = weather;
        _weatherHydrated = true;
      });
      // Update music if it's night
      if (!weather.isDay) {
        _playBackgroundMusic(isNight: true);
      }
    }
  }

  void _initGamepad() {
    final stream = ref.read(gamepadActionStreamProvider.stream);
    _gamepadSub = stream.listen(_onGamepadAction);
  }

  void _onGamepadAction(GamepadAction action) {
    if (!mounted) return;
    ref.read(gamepadConnectedProvider.notifier).state = true;
    final state = ref.read(onlineBattleControllerProvider(widget.battleId));
    final controller = ref.read(onlineBattleControllerProvider(widget.battleId).notifier);

    if (state.isFinished) {
      if (action == GamepadAction.confirm || action == GamepadAction.start) context.pop();
      return;
    }
    if (!state.isPlayerTurn || state.isWaitingForOpponent) return;

    if (_showMoveMenu) {
      _handleMoveMenuInput(action, state, controller);
    } else {
      _handleActionMenuInput(action, state, controller);
    }
  }

  void _handleActionMenuInput(GamepadAction action, BattleState state, OnlineBattleController controller) {
    switch (action) {
      case GamepadAction.up:
      case GamepadAction.left:
        setState(() => _selectedActionIndex = (_selectedActionIndex - 1).clamp(0, 3));
      case GamepadAction.down:
      case GamepadAction.right:
        setState(() => _selectedActionIndex = (_selectedActionIndex + 1).clamp(0, 3));
      case GamepadAction.confirm:
        _executeAction(_selectedActionIndex, state, controller);
      case GamepadAction.bagAction:
        _showBagModal(context, state, controller);
      case GamepadAction.cancel:
        controller.handleAction(const BattleAction.run());
      case GamepadAction.start:
        context.pop();
      default:
        break;
    }
  }

  void _handleMoveMenuInput(GamepadAction action, BattleState state, OnlineBattleController controller) {
    final moveCount = state.playerPokemon.availableMoves.take(4).length;
    switch (action) {
      case GamepadAction.up:
      case GamepadAction.left:
        setState(() => _selectedMoveIndex = (_selectedMoveIndex - 1).clamp(0, moveCount));
      case GamepadAction.down:
      case GamepadAction.right:
        setState(() => _selectedMoveIndex = (_selectedMoveIndex + 1).clamp(0, moveCount));
      case GamepadAction.confirm:
        if (_selectedMoveIndex == moveCount) {
          setState(() { _showMoveMenu = false; _selectedMoveIndex = 0; });
        } else {
          final move = state.playerPokemon.availableMoves.take(4).toList()[_selectedMoveIndex];
          setState(() { _showMoveMenu = false; _selectedMoveIndex = 0; });
          controller.handleAction(BattleAction.attack(move));
        }
      case GamepadAction.cancel:
        setState(() { _showMoveMenu = false; _selectedMoveIndex = 0; });
      default:
        break;
    }
  }

  void _executeAction(int index, BattleState state, OnlineBattleController controller) {
    switch (index) {
      case 0: setState(() { _showMoveMenu = true; _selectedMoveIndex = 0; });
      case 1: _showBagModal(context, state, controller);
      case 2: _showPokemonModal(context, state, controller);
      case 3: controller.handleAction(const BattleAction.run());

    }
  }

  Future<void> _playBackgroundMusic({bool isNight = false}) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    final filename = isNight ? 'battlemusic_night.mp3' : 'battlemusic.mp3';
    final source = await ref.read(audioSourceServiceProvider).resolveBattleTrack(filename);
    await _audioPlayer.play(source);
  }

  @override
  void dispose() {
    _gamepadSub?.cancel();
    _audioPlayer.dispose();
    
    // Resume global menu music
    Future.microtask(() => ref.read(globalAudioControllerProvider).playMenuMusic());
    
    super.dispose();
  }

  void _showBagModal(BuildContext context, BattleState state, OnlineBattleController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BagSelectionModal(
        inventory: state.inventory,
        onItemSelected: (itemId) {
          Navigator.pop(context);
          controller.handleAction(BattleAction.item(itemId));
        },
      ),
    );
  }

  void _showPokemonModal(BuildContext context, BattleState state, OnlineBattleController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PokemonSelectionModal(
        team: state.playerTeam,
        activePokemon: state.playerPokemon,
        hpMap: state.playerHpMap,
        maxHpMap: state.playerMaxHpMap,
        onPokemonSelected: (pokemon) {
          Navigator.pop(context);
          controller.handleAction(BattleAction.pokemon(pokemon));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onlineBattleControllerProvider(widget.battleId));
    final controller = ref.read(onlineBattleControllerProvider(widget.battleId).notifier);
    final controllerConnected = ref.watch(gamepadConnectedProvider);
    final turnDeadline = ref.watch(battleTurnDeadlineProvider(widget.battleId));

    // Listen for battle conclusion to navigate back
    ref.listen<BattleState>(onlineBattleControllerProvider(widget.battleId), (previous, next) {
      if (next.isFinished && !(previous?.isFinished ?? false)) {
        context.pop();
      }
    });

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          return isLandscape
              ? _buildLandscape(context, state, controller, controllerConnected, turnDeadline)
              : _buildPortrait(context, state, controller, controllerConnected, turnDeadline);
        },
      ),
    );
  }

  Widget _buildPortrait(BuildContext context, BattleState state, OnlineBattleController controller, bool controllerConnected, DateTime? turnDeadline) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBattleArena(state, compact: false)),
            _buildUIPanel(context, state, controller, controllerConnected, compact: false, turnDeadline: turnDeadline),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscape(BuildContext context, BattleState state, OnlineBattleController controller, bool controllerConnected, DateTime? turnDeadline) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: _buildBattleArena(state, compact: true),
            ),
            Container(width: 1, color: Colors.white24),
            Expanded(
              flex: 4,
              child: _buildUIPanel(context, state, controller, controllerConnected, compact: true, turnDeadline: turnDeadline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleArena(BattleState state, {required bool compact}) {
    final opponentSize = compact ? 130.0 : 180.0;
    final playerSize = compact ? 170.0 : 240.0;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/battle/battle_bg.png', fit: BoxFit.cover),
        ),
        // Environmental Graphics Layer
        Positioned.fill(
          child: BattleEnvironmentOverlay(weather: _currentWeather),
        ),
        Positioned(
          top: compact ? 10 : 40,
          left: 20,
          child: BattleHpBar(
            name: state.opponentPokemon.name,
            currentHp: state.opponentCurrentHp,
            maxHp: state.opponentMaxHp,
            level: state.opponentLevel,
            isPlayer: false,
            isConnected: state.player2Connected,
            trainerName: state.player2Name,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInQuad,
          top: state.opponentCurrentHp <= 0 ? 600 : (compact ? 30 : 60),
          right: compact ? 60 : 110,
          child: _buildPokemonSprite(state.opponentPokemon.frontSpriteUrls, size: opponentSize),
        ),
        Positioned(
          bottom: compact ? 60 : 110,
          right: 20,
          child: BattleHpBar(
            name: state.playerPokemon.name,
            currentHp: state.playerCurrentHp,
            maxHp: state.playerMaxHp,
            level: state.playerLevel,
            isPlayer: true,
            isConnected: state.player1Connected,
            trainerName: state.player1Name,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInQuad,
          bottom: state.playerCurrentHp <= 0 ? -200 : (compact ? 30 : 65),
          left: compact ? 55 : 100,
          child: _buildPokemonSprite(state.playerPokemon.backSpriteUrls, size: playerSize),
        ),
        if (state.isWaitingForOpponent && !state.isFinished)
          Container(
            color: Colors.black45,
            child: Center(
              child: Image.asset(
                'assets/battle/indicators/waiting.png',
                width: 280,
                fit: BoxFit.contain,
              ).animate().fade().scale(
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ).shimmer(duration: 2.seconds, color: Colors.white24),
            ),
          ),
        
        if (state.isPlayerTurn && !state.isWaitingForOpponent && !state.isFinished && !state.isAnimating && !state.isSpectator)
          Positioned(
            top: compact ? 100 : 150,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/battle/indicators/your_turn.png',
                width: 300,
                fit: BoxFit.contain,
              ).animate().fade().scale(
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ).then().shimmer(duration: 3.seconds),
            ),
          ),
        if (state.isSpectator)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('SPECTATING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        
        // Voice Control Bubble & Status
        _buildVoiceHUD(),
      ],
    );
  }

  Widget _buildVoiceHUD() {
    final voiceState = ref.watch(voiceControllerProvider);
    if (!voiceState.isListening && voiceState.lastRecognizedWords.isEmpty) return const SizedBox();

    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: Center(
        child: AnimatedOpacity(
          opacity: voiceState.lastRecognizedWords.isNotEmpty ? 1.0 : 0.0,
          duration: 300.ms,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  voiceState.lastRecognizedWords.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms),
    );
  }

  Widget _buildUIPanel(BuildContext context, BattleState state, OnlineBattleController controller, bool controllerConnected, {required bool compact, DateTime? turnDeadline}) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (turnDeadline != null && state.isPlayerTurn && !state.isFinished && !state.isSpectator)
            _TurnCountdown(deadline: turnDeadline),
          if (controllerConnected)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: ControllerIndicator(),
            ),
          if (state.isFinished)
            BattleMessageBox(
              message: state.message,
              onTap: () => context.pop(),
              compact: compact,
            )
          else if (!_showMoveMenu || !state.isPlayerTurn || state.isWaitingForOpponent)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: BattleMessageBox(message: state.message, compact: compact),
                ),
                if (state.isPlayerTurn && !state.isWaitingForOpponent && !state.isAnimating && !state.isSpectator)
                  Expanded(
                    flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BattleActionMenu(
                            onFight: () => setState(() { _showMoveMenu = true; _selectedMoveIndex = 0; }),
                            onBag: () => _showBagModal(context, state, controller),
                            onPokemon: () => _showPokemonModal(context, state, controller),
                            onRun: () => controller.handleAction(const BattleAction.run()),
                            selectedIndex: controllerConnected ? _selectedActionIndex : -1,
                            compact: compact,
                            showControllerIcons: controllerConnected,
                          ),
                          const SizedBox(height: 8),
                          _VoiceToggleButton(battleId: widget.battleId),
                        ],
                      ),
                  )
                else if (state.isSpectator)
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text('WATCHING...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
              ],
            )
          else
            BattleMoveMenu(
              moves: state.playerPokemon.availableMoves,
              onMoveSelected: (move) {
                setState(() { _showMoveMenu = false; _selectedMoveIndex = 0; });
                controller.handleAction(BattleAction.attack(move));
              },
              onCancel: () => setState(() { _showMoveMenu = false; _selectedMoveIndex = 0; }),
              selectedIndex: controllerConnected ? _selectedMoveIndex : -1,
              compact: compact,
            ),
        ],
      ),
    );
  }

  Widget _buildPokemonSprite(List<String> urls, {required double size}) =>
      _buildRecursiveSprite(urls, 0, size);

  Widget _buildRecursiveSprite(List<String> urls, int index, double size) {
    if (index >= urls.length) {
      return SizedBox(width: size, height: size, child: const Icon(Icons.error, color: Colors.white24));
    }
    return CachedNetworkImage(
      imageUrl: urls[index],
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      placeholder: (_, __) => SizedBox(width: size, height: size, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
      errorWidget: (_, __, ___) => _buildRecursiveSprite(urls, index + 1, size),
    );
  }
}

class _TurnCountdown extends StatefulWidget {
  final DateTime deadline;
  const _TurnCountdown({required this.deadline});

  @override
  State<_TurnCountdown> createState() => _TurnCountdownState();
}

class _TurnCountdownState extends State<_TurnCountdown> {
  late Timer _timer;
  int _secondsLeft = 90;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final left = widget.deadline.difference(DateTime.now()).inSeconds.clamp(0, 90);
    if (mounted) setState(() => _secondsLeft = left);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _secondsLeft <= 15;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 14, color: urgent ? Colors.redAccent : Colors.orange),
          const SizedBox(width: 4),
          Text(
            '$_secondsLeft s',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: urgent ? Colors.redAccent : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceToggleButton extends ConsumerWidget {
  final String battleId;
  const _VoiceToggleButton({required this.battleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceControllerProvider);
    final active = voiceState.isListening;

    return InkWell(
      onTap: () => ref.read(voiceControllerProvider.notifier).toggleListening(battleId),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.15) : Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? AppColors.primary : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            if (active)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: active ? AppColors.primary : Colors.white60,
              size: 18,
            ).animate(target: active ? 1 : 0).scale(duration: 200.ms).shimmer(duration: 1.5.seconds, color: Colors.white24),
            const SizedBox(width: 10),
            Text(
              active ? 'LISTENING...' : 'VOICE HUD',
              style: TextStyle(
                color: active ? AppColors.primary : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
