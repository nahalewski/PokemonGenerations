import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/services/audio_source_service.dart';
import '../../domain/models/pokemon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import 'battle_controller.dart';
import 'widgets/battle_widgets.dart';
import 'widgets/battle_overlay_widgets.dart';
import '../../domain/models/battle_state.dart';
import '../../core/services/gamepad_service.dart';
import '../../core/services/graphics_service.dart';
import '../../core/widgets/pokemon_visual_widget.dart';
import 'services/battle_fx_service.dart';

class BattleScreen extends ConsumerStatefulWidget {
  final String playerPokemonId;
  final String opponentPokemonId;
  final bool isCPUBattle;

  const BattleScreen({
    super.key,
    required this.playerPokemonId,
    required this.opponentPokemonId,
    this.isCPUBattle = false,
  });

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

// Fraction of arena width/height where each circle center sits
const _kOpponentCircleX = 0.66;
const _kOpponentCircleY = 0.57;
const _kPlayerCircleX   = 0.29;
const _kPlayerCircleY   = 0.81;

const _kCpuBattleBgs = [
  'assets/battle/battlearea1.png',
  'assets/battle/battlearea2.png',
  'assets/battle/battlearea3.png',
  'assets/battle/battlearea4.png',
  'assets/battle/battlearea5.png',
  'assets/battle/battlearea6.png',
  'assets/battle/battlearea7.png',
  'assets/battle/battlearea8.png',
  'assets/battle/battlearea9.png',
  'assets/battle/battlearea10.png',
  'assets/battle/battlearea11.png',
  'assets/battle/battlearea12.png',
  'assets/battle/battlearea13.png',
  'assets/battle/battlearea30thaniversary.png',
  'assets/battle/battlestadium.png',
];

class _BattleScreenState extends ConsumerState<BattleScreen> {
  bool _showMoveMenu = false;
  int _selectedActionIndex = 0;
  int _selectedMoveIndex = 0;
  late AudioPlayer _audioPlayer;
  bool _isMuted = false;
  StreamSubscription<GamepadAction>? _gamepadSub;
  late String _selectedBg;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();
    if (widget.isCPUBattle) {
      _selectedBg = _kCpuBattleBgs[Random().nextInt(_kCpuBattleBgs.length)];
    } else {
      _selectedBg = 'assets/battle/battle_bg.png';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _initGamepad());
  }

  void _initGamepad() {
    final stream = ref.read(gamepadActionStreamProvider.stream);
    _gamepadSub = stream.listen(_onGamepadAction);
  }

  void _onGamepadAction(GamepadAction action) {
    if (!mounted) return;
    ref.read(gamepadConnectedProvider.notifier).state = true;
    final params = BattleParams(
      playerPokemonId: widget.playerPokemonId,
      opponentPokemonId: widget.opponentPokemonId,
      isCPUBattle: widget.isCPUBattle,
    );
    final state = ref.read(battleControllerProvider(params));
    final controller = ref.read(battleControllerProvider(params).notifier);

    if (state.isFinished) {
      if (action == GamepadAction.confirm || action == GamepadAction.start) context.pop();
      return;
    }
    if (!state.isPlayerTurn || state.isAnimating) return;

    if (_showMoveMenu) {
      _handleMoveMenuInput(action, state, controller);
    } else {
      _handleActionMenuInput(action, state, controller);
    }
  }

  void _handleActionMenuInput(GamepadAction action, BattleState state, BattleController controller) {
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
      case GamepadAction.pokemonAction:
        _showPokemonModal(context, state, controller);
      case GamepadAction.cancel:
        controller.handleAction(const BattleAction.run());
      case GamepadAction.start:
        context.pop();
      default:
        break;
    }
  }

  void _handleMoveMenuInput(GamepadAction action, BattleState state, BattleController controller) {
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

  void _executeAction(int index, BattleState state, BattleController controller) {
    switch (index) {
      case 0: setState(() { _showMoveMenu = true; _selectedMoveIndex = 0; });
      case 1: _showBagModal(context, state, controller);
      case 2: _showPokemonModal(context, state, controller);
      case 3: controller.handleAction(const BattleAction.run());
    }
  }

  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    final String filename;
    if (widget.isCPUBattle) {
      final trackIndex = Random().nextInt(81);
      filename = trackIndex == 0 ? 'battlemusic.mp3' : 'battlemusic$trackIndex.mp3';
    } else {
      filename = 'battlemusic.mp3';
    }

    final audioService = ref.read(audioSourceServiceProvider);
    final source = await audioService.resolveBattleTrack(filename);
    await _audioPlayer.play(source);
  }

  @override
  void dispose() {
    _gamepadSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showBagModal(BuildContext context, BattleState state, BattleController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BagSelectionModal(
        inventory: state.inventory,
        onItemSelected: (itemId) {
          Navigator.pop(context);
          if (itemId == 'revive' || itemId == 'potion' || itemId.contains('berry')) {
            _showTargetSelectionModal(context, state, controller, itemId);
          } else {
            controller.handleAction(BattleAction.item(itemId));
          }
        },
      ),
    );
  }

  void _showTargetSelectionModal(BuildContext context, BattleState state, BattleController controller, String itemId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: PokemonSelectionModal(
          team: state.playerTeam,
          activePokemon: state.playerPokemon,
          hpMap: state.playerHpMap,
          maxHpMap: state.playerMaxHpMap,
          allowActive: true, // Items can be used on active mon too
          allowFainted: itemId == 'revive', // Only Revive can target fainted
          title: 'USE ${itemId.toUpperCase()} ON:',
          onPokemonSelected: (pokemon) {
            Navigator.pop(context);
            controller.handleAction(BattleAction.item(itemId, targetId: pokemon.id));
          },
        ),
      ),
    );
  }

  void _showPokemonModal(BuildContext context, BattleState state, BattleController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: PokemonSelectionModal(
          team: state.playerTeam,
          activePokemon: state.playerPokemon,
          hpMap: state.playerHpMap,
          maxHpMap: state.playerMaxHpMap,
          onPokemonSelected: (pokemon) {
            Navigator.pop(context);
            controller.handleAction(BattleAction.pokemon(pokemon));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = BattleParams(
      playerPokemonId: widget.playerPokemonId,
      opponentPokemonId: widget.opponentPokemonId,
      isCPUBattle: widget.isCPUBattle,
    );
    final state = ref.watch(battleControllerProvider(params));
    final controller = ref.read(battleControllerProvider(params).notifier);
    final controllerConnected = ref.watch(gamepadConnectedProvider);

    // Listen for battle conclusion to navigate back
    ref.listen<BattleState>(battleControllerProvider(params), (previous, next) {
      if (next.isFinished && !(previous?.isFinished ?? false)) {
        Navigator.of(context).pop();
      }

      // Trigger SFX and VFX for moves
      if (next.lastMoveName != null && next.lastMoveName != previous?.lastMoveName) {
        ref.read(battleFxServiceProvider).playMoveSound(next.lastMoveName!);
        // Particles could be triggered here by showing a temporary overlay
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;
              return isLandscape
                  ? _buildLandscape(context, state, controller, controllerConnected)
                  : _buildPortrait(context, state, controller, controllerConnected);
            },
          ),
          if (state.isWaitingForSwitch)
            Container(
              color: Colors.black54,
              child: Center(
                child: GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
                      const SizedBox(height: 16),
                      Text('YOUR POKÉMON FAINTED!', style: AppTypography.headlineSmall),
                      Text('SELECT A NEW ONE TO CONTINUE', style: AppTypography.bodyMedium),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: () => _showPokemonModal(context, state, controller),
                        child: const Text('SWITCH POKÉMON'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPortrait(BuildContext context, BattleState state, BattleController controller, bool controllerConnected) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBattleArena(state, compact: false)),
            _buildUIPanel(context, state, controller, controllerConnected, compact: false),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscape(BuildContext context, BattleState state, BattleController controller, bool controllerConnected) {
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
              child: _buildUIPanel(context, state, controller, controllerConnected, compact: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleArena(BattleState state, {required bool compact}) {
    final opponentSize = compact ? 240.0 : 320.0;
    final playerSize   = compact ? 310.0 : 420.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final W = constraints.maxWidth;
        final H = constraints.maxHeight;

        // Bottom of each sprite sits at the circle center
        final oppLeft = W * _kOpponentCircleX - opponentSize / 2;
        final oppTop  = H * _kOpponentCircleY - opponentSize;
        final plyLeft = W * _kPlayerCircleX   - playerSize   / 2;
        final plyTop  = H * _kPlayerCircleY   - playerSize;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Background - use fill to ensure all arena images match dimensions exactly
            Positioned.fill(
              child: Image.asset(_selectedBg, fit: BoxFit.fill),
            ),

            // Shadow under opponent
            Positioned(
              left: W * _kOpponentCircleX - opponentSize * 0.38,
              top:  H * _kOpponentCircleY - opponentSize * 0.08,
              child: _buildSpriteShadow(opponentSize * 0.76, opponentSize * 0.14),
            ),

            // Shadow under player
            Positioned(
              left: W * _kPlayerCircleX - playerSize * 0.38,
              top:  H * _kPlayerCircleY - playerSize * 0.08,
              child: _buildSpriteShadow(playerSize * 0.76, playerSize * 0.14),
            ),

            // Opponent sprite – slides down when fainted
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInQuad,
              left: oppLeft,
              top:  state.opponentCurrentHp <= 0 ? H + 80 : oppTop,
              child: PokemonVisualWidget(
                pokemonId: int.tryParse(state.opponentPokemon.id) ?? 1,
                size: opponentSize,
                isBack: false,
              ),
            ),

            // Player sprite – slides down when fainted
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInQuad,
              left: plyLeft,
              top:  state.playerCurrentHp <= 0 ? H + 80 : plyTop,
              child: PokemonVisualWidget(
                pokemonId: int.tryParse(state.playerPokemon.id) ?? 1,
                size: playerSize,
                isBack: true,
              ),
            ),

            // Opponent HP bar – top left
            Positioned(
              top: compact ? 8 : 20,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BattleHpBar(
                    name: state.opponentPokemon.name,
                    currentHp: state.opponentCurrentHp,
                    maxHp: state.opponentMaxHp,
                    level: state.opponentLevel,
                    isPlayer: false,
                    status: state.statusMap[state.opponentPokemon.id] ?? 'none',
                  ),
                  const SizedBox(height: 4),
                  _buildTeamBalls(state.opponentTeam, state.opponentHpMap),
                ],
              ),
            ),

            // Player HP bar – bottom right
            Positioned(
              bottom: compact ? 8 : 20,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BattleHpBar(
                    name: state.playerPokemon.name,
                    currentHp: state.playerCurrentHp,
                    maxHp: state.playerMaxHp,
                    level: state.playerLevel,
                    isPlayer: true,
                    status: state.statusMap[state.playerPokemon.id] ?? 'none',
                  ),
                  const SizedBox(height: 4),
                  _buildTeamBalls(state.playerTeam, state.playerHpMap),
                ],
              ),
            ),

            // Removed close button (Run action is sufficient)
          ],
        );
      },
    );
  }

  Widget _buildSpriteShadow(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.all(Radius.elliptical(width / 2, height / 2)),
      ),
    );
  }

  Widget _buildTeamBalls(List<Pokemon> team, Map<String, int> hpMap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (index) {
        if (index >= team.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Icon(Icons.circle_outlined, size: 8, color: Colors.white24),
          );
        }
        final hp = hpMap[team[index].id] ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.circle,
            size: 10,
            color: hp > 0 ? Colors.greenAccent : Colors.redAccent.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildUIPanel(BuildContext context, BattleState state, BattleController controller, bool controllerConnected, {required bool compact}) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D2D2D), Color(0xFF141414)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (controllerConnected)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ControllerIndicator(),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  if (state.isFinished)
                    BattleMessageBox(
                      message: state.message,
                      onTap: () => context.pop(),
                      compact: compact,
                    )
                  else if (!_showMoveMenu || !state.isPlayerTurn)
                    Column(
                      children: [
                        BattleMessageBox(message: state.message, compact: compact),
                        SizedBox(height: compact ? 8 : 16),
                        if (state.isPlayerTurn && !state.isAnimating)
                          BattleActionMenu(
                            onFight: () => setState(() { _showMoveMenu = true; _selectedMoveIndex = 0; }),
                            onBag: () => _showBagModal(context, state, controller),
                            onPokemon: () => _showPokemonModal(context, state, controller),
                            onRun: () => controller.handleAction(const BattleAction.run()),
                            selectedIndex: controllerConnected ? _selectedActionIndex : -1,
                            compact: compact,
                            showControllerIcons: controllerConnected,
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
                  if (!compact) ...[
                    const SizedBox(height: 16),
                    BattleLog(entries: state.battleLog, compact: compact),
                  ],
                ],
              ),
            ),
          ),
          // Console details at the bottom
          Container(
            height: 40,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('SYSTEM: GENERATIONS OMNI', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white24,
                        size: 14,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                          _audioPlayer.setVolume(_isMuted ? 0 : 1);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Container(
                  width: 30,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonSprite(List<String> urls, {required double size}) {
     if (urls.isEmpty) return SizedBox(width: size, height: size);
     return _buildRecursiveSprite(urls, 0, size);
  }

  Widget _buildRecursiveSprite(List<String> urls, int index, double size) {
    if (index >= urls.length) {
      return SizedBox(
        width: size,
        height: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white24, size: 32),
            const SizedBox(height: 8),
            Text('SPRITE ERROR', style: TextStyle(color: Colors.white24, fontSize: 8)),
          ],
        ),
      );
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
