import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pokemon_sprite.dart';
import '../../../domain/models/pokemon_form.dart';

class BattleTurn {
  final String attackerName;
  final String moveName;
  final String defenderName;
  final int damagePct;
  final bool isSuperEffective;
  final bool attackerIsUser;
  final int myTeamIndex;
  final int opTeamIndex;

  const BattleTurn({
    required this.attackerName,
    required this.moveName,
    required this.defenderName,
    required this.damagePct,
    required this.isSuperEffective,
    required this.attackerIsUser,
    required this.myTeamIndex,
    required this.opTeamIndex,
  });
}

/// Parses the simulation log into structured turns, tracking team indices
/// as Pokémon are knocked out and replacements are sent in.
List<BattleTurn> parseTurns(
  List<String> log,
  String myLeadName,
  String opLeadName,
) {
  final turns = <BattleTurn>[];
  final myNames = <String>{myLeadName};
  final opNames = <String>{opLeadName};
  int myTeamIndex = 0;
  int opTeamIndex = 0;
  String? currentAttacker;
  String? currentMove;

  for (int i = 0; i < log.length; i++) {
    final line = log[i];

    // Track send-outs to advance team index
    final playerOut = RegExp(r'>> PLAYER sends out (.+?)!').firstMatch(line);
    if (playerOut != null) {
      myNames.add(playerOut.group(1)!.trim());
      myTeamIndex++;
      continue;
    }
    final opOut = RegExp(r'>> OPPONENT sends out (.+?)!').firstMatch(line);
    if (opOut != null) {
      opNames.add(opOut.group(1)!.trim());
      opTeamIndex++;
      continue;
    }

    // Attack line: "1. Charizard used FLAMETHROWER!"
    final attackMatch =
        RegExp(r'^\d+\.\s+(.+?)\s+used\s+(.+?)!$').firstMatch(line.trim());
    if (attackMatch != null) {
      currentAttacker = attackMatch.group(1);
      currentMove = attackMatch.group(2);
      continue;
    }

    // Damage line: "   ▸ ~42% damage to Garchomp"
    final dmgMatch = RegExp(r'~(\d+)%\s+damage\s+to\s+(.+)').firstMatch(line);
    if (dmgMatch != null && currentAttacker != null && currentMove != null) {
      final pct = int.tryParse(dmgMatch.group(1) ?? '20') ?? 20;
      final defender = dmgMatch.group(2)?.trim() ?? 'Opponent';
      final nextLine = i + 1 < log.length ? log[i + 1] : '';
      final isSe = nextLine.contains('SUPER EFFECTIVE');

      // Determine side: prefer explicit membership; fall back to "not in opNames"
      final inMy = myNames.contains(currentAttacker);
      final inOp = opNames.contains(currentAttacker);
      final attackerIsUser = inMy && !inOp;

      turns.add(BattleTurn(
        attackerName: currentAttacker!,
        moveName: currentMove!,
        defenderName: defender,
        damagePct: pct,
        isSuperEffective: isSe,
        attackerIsUser: attackerIsUser,
        myTeamIndex: myTeamIndex,
        opTeamIndex: opTeamIndex,
      ));
      currentAttacker = null;
      currentMove = null;
    }
  }
  return turns;
}

class BattleReplayWidget extends StatefulWidget {
  final List<String> simulationLog;
  final List<PokemonForm> myTeam;
  final List<PokemonForm> opponentTeam;

  const BattleReplayWidget({
    super.key,
    required this.simulationLog,
    required this.myTeam,
    required this.opponentTeam,
  });

  @override
  State<BattleReplayWidget> createState() => _BattleReplayWidgetState();
}

class _BattleReplayWidgetState extends State<BattleReplayWidget>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  int _currentTurnIdx = -1;
  late List<BattleTurn> _turns;
  late AnimationController _userController;
  late AnimationController _opController;
  late AnimationController _flashController;

  late Animation<double> _userSlide;
  late Animation<double> _opSlide;
  late Animation<double> _flash;

  int _myActiveIdx = 0;
  int _opActiveIdx = 0;
  double _myHp = 100.0;
  double _opHp = 100.0;
  bool _battleEnded = false;
  String _koMessage = '';

  String get _myLeadName {
    final header = widget.simulationLog.length > 1 ? widget.simulationLog[1] : '';
    final parts = header.split('  vs  ');
    return parts.isNotEmpty ? parts[0].trim() : _nameFor(widget.myTeam, 0);
  }

  String get _opLeadName {
    final header = widget.simulationLog.length > 1 ? widget.simulationLog[1] : '';
    final parts = header.split('  vs  ');
    return parts.length > 1 ? parts[1].trim() : _nameFor(widget.opponentTeam, 0);
  }

  String _nameFor(List<PokemonForm> team, int idx) {
    if (idx >= team.length) return '';
    final p = team[idx];
    return p.pokemonName ?? p.pokemonId;
  }

  PokemonForm? get _myActive =>
      _myActiveIdx < widget.myTeam.length ? widget.myTeam[_myActiveIdx] : null;

  PokemonForm? get _opActive =>
      _opActiveIdx < widget.opponentTeam.length ? widget.opponentTeam[_opActiveIdx] : null;

  @override
  void initState() {
    super.initState();
    _turns = parseTurns(widget.simulationLog, _myLeadName, _opLeadName);

    _userController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _opController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _flashController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _userSlide = Tween<double>(begin: 0, end: 0).animate(_userController);
    _opSlide = Tween<double>(begin: 0, end: 0).animate(_opController);
    _flash = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _opController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  Color _hpColor(double hp) {
    if (hp > 50) return Colors.greenAccent;
    if (hp > 25) return Colors.yellowAccent;
    return Colors.redAccent;
  }

  Future<void> _playTurn(BattleTurn turn) async {
    if (!mounted) return;

    // Handle team switches before animating
    if (turn.myTeamIndex != _myActiveIdx || turn.opTeamIndex != _opActiveIdx) {
      setState(() {
        if (turn.myTeamIndex != _myActiveIdx) {
          _myActiveIdx = turn.myTeamIndex.clamp(0, widget.myTeam.length - 1);
          _myHp = 100.0;
        }
        if (turn.opTeamIndex != _opActiveIdx) {
          _opActiveIdx = turn.opTeamIndex.clamp(0, widget.opponentTeam.length - 1);
          _opHp = 100.0;
        }
        _battleEnded = false;
        _koMessage = '';
      });
      // Brief pause so the new Pokémon is visible before attacking
      await Future.delayed(const Duration(milliseconds: 400));
    }

    final isUserAttacking = turn.attackerIsUser;

    if (isUserAttacking) {
      _userSlide = Tween<double>(begin: 0, end: 0.6).animate(
        CurvedAnimation(parent: _userController, curve: Curves.easeInBack),
      );
      _opSlide = Tween<double>(begin: 0, end: -0.15).animate(
        CurvedAnimation(parent: _opController, curve: Curves.elasticOut),
      );
    } else {
      _opSlide = Tween<double>(begin: 0, end: -0.6).animate(
        CurvedAnimation(parent: _opController, curve: Curves.easeInBack),
      );
      _userSlide = Tween<double>(begin: 0, end: 0.15).animate(
        CurvedAnimation(parent: _userController, curve: Curves.elasticOut),
      );
    }

    setState(() {});
    await (isUserAttacking ? _userController : _opController).forward(from: 0);

    _flashController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 100));
    _flashController.reverse();

    await (isUserAttacking ? _opController : _userController).forward(from: 0);

    // Apply HP damage after impact
    setState(() {
      if (isUserAttacking) {
        _opHp = (_opHp - turn.damagePct).clamp(0.0, 100.0);
        if (_opHp <= 0) {
          _battleEnded = true;
          _koMessage = '${turn.defenderName} was KNOCKED OUT!';
        }
      } else {
        _myHp = (_myHp - turn.damagePct).clamp(0.0, 100.0);
        if (_myHp <= 0) {
          _battleEnded = true;
          _koMessage = '${turn.defenderName} was KNOCKED OUT!';
        }
      }
    });

    await Future.delayed(const Duration(milliseconds: 200));
    await Future.wait([_userController.reverse(), _opController.reverse()]);

    // Handle faint animation delay if KO happened
    if (_battleEnded) {
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  bool _isFainted(String name) {
    if (name == _myLeadName || widget.myTeam.any((p) => p.pokemonName == name)) return _myHp <= 0;
    if (name == _opLeadName || widget.opponentTeam.any((p) => p.pokemonName == name)) return _opHp <= 0;
    return false;
  }

  Future<void> _startReplay() async {
    if (_turns.isEmpty || _isPlaying) return;
    setState(() {
      _isPlaying = true;
      _currentTurnIdx = 0;
      _myActiveIdx = 0;
      _opActiveIdx = 0;
      _myHp = 100.0;
      _opHp = 100.0;
      _battleEnded = false;
      _koMessage = '';
    });

    for (int i = 0; i < _turns.length; i++) {
      if (!mounted) return;
      final turn = _turns[i];
      
      // Skip turn if attacker is fainted
      if (_isFainted(turn.attackerName) || _isFainted(turn.defenderName)) {
        continue;
      }

      setState(() => _currentTurnIdx = i);

      // If a KO just happened, show it briefly before continuing
      if (_battleEnded) await Future.delayed(const Duration(milliseconds: 700));

      await _playTurn(turn);
      if (!_battleEnded) await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _currentTurnIdx = -1;
      });
    }
  }

  Widget _buildHpBar(String name, double hp, bool isUser) {
    final color = _hpColor(hp);
    final isKo = hp <= 0;
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser && isKo) _koChip(),
            if (!isUser && !isKo)
              Text('${hp.toInt()}%',
                  style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(name,
                style: AppTypography.labelSmall.copyWith(
                    color: isUser ? AppColors.primary : Colors.redAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            if (isUser && !isKo)
              Text('${hp.toInt()}%',
                  style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            if (isUser && isKo) _koChip(),
          ],
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 110,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (hp / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white12,
              valueColor:
                  AlwaysStoppedAnimation(isKo ? Colors.grey : color),
              minHeight: 7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _koChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(4)),
        child: const Text('KO',
            style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold)),
      );

  Widget _buildPartyDots(int total, int activeIdx, bool isUser) {
    if (total <= 1) return const SizedBox.shrink();
    final dotColor = isUser ? AppColors.primary : Colors.redAccent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final fainted = i < activeIdx;
        final active = i == activeIdx;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fainted
                ? Colors.grey.withOpacity(0.3)
                : active
                    ? dotColor
                    : dotColor.withOpacity(0.45),
            border: Border.all(
              color: fainted ? Colors.grey.withOpacity(0.2) : dotColor,
              width: 1,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTurn = _currentTurnIdx >= 0 && _currentTurnIdx < _turns.length
        ? _turns[_currentTurnIdx]
        : null;

    final myActive = _myActive;
    final opActive = _opActive;
    final myName = myActive?.pokemonName ?? myActive?.pokemonId ?? widget.myTeam.first.pokemonId;
    final opName = opActive?.pokemonName ?? opActive?.pokemonId ?? widget.opponentTeam.first.pokemonId;

    return Column(
      children: [
        // Battle Arena
        Container(
          height: 230,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: CustomPaint(painter: _SubtleGridPainter())),

              // HP bars + party dots row
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHpBar(myName, _myHp, true),
                        const SizedBox(height: 4),
                        _buildPartyDots(widget.myTeam.length, _myActiveIdx, true),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildHpBar(opName, _opHp, false),
                        const SizedBox(height: 4),
                        _buildPartyDots(widget.opponentTeam.length, _opActiveIdx, false),
                      ],
                    ),
                  ],
                ),
              ),

              // Flash overlay
              if (_isPlaying)
                AnimatedBuilder(
                  animation: _flash,
                  builder: (_, __) => Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(_flash.value * 0.5),
                    ),
                  ),
                ),

              // User Pokémon (left)
              if (myActive != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInBack,
                  bottom: _myHp <= 0 ? -120 : 30,
                  left: 24,
                  child: AnimatedBuilder(
                    animation: _userController,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_userSlide.value * 200, 0),
                      child: child!,
                    ),
                    child: Column(
                      children: [
                        PokemonSprite(
                            pokemonId: myActive.pokemonId,
                            width: 80,
                            height: 80),
                        const SizedBox(height: 4),
                        Text(myName,
                            style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary, fontSize: 10)),
                      ],
                    ),
                  ),
                ),

              // VS divider (idle only)
              if (!_isPlaying && activeTurn == null && !_battleEnded)
                Center(
                  child: Text('VS',
                      style: AppTypography.labelLarge.copyWith(
                          color: AppColors.outline.withOpacity(0.4),
                          fontSize: 20)),
                ),

              // Opponent Pokémon (right)
              if (opActive != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInBack,
                  top: _opHp <= 0 ? 300 : 72,
                  right: 24,
                  child: AnimatedBuilder(
                    animation: _opController,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(-(_opSlide.value * 200).abs(), 0),
                      child: child!,
                    ),
                    child: Column(
                      children: [
                        PokemonSprite(
                            pokemonId: opActive.pokemonId,
                            width: 80,
                            height: 80),
                        const SizedBox(height: 4),
                        Text(opName,
                            style: AppTypography.labelSmall.copyWith(
                                color: Colors.redAccent, fontSize: 10)),
                      ],
                    ),
                  ),
                ),

              // KO banner or active move label
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: _battleEnded
                      ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_koMessage,
                                style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.8, 0.8))
                      : activeTurn != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: activeTurn.attackerIsUser
                                    ? AppColors.primary.withOpacity(0.85)
                                    : Colors.redAccent.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                  '${activeTurn.attackerName} used ${activeTurn.moveName}!',
                                  style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white, fontSize: 11),
                                  textAlign: TextAlign.center),
                            ).animate().fadeIn(duration: 200.ms)
                          : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Replay and Battle buttons
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                    _isPlaying ? Icons.hourglass_empty : Icons.replay,
                    size: 18),
                label: Text(
                  _isPlaying
                      ? 'REPLAYING BATTLE...'
                      : _turns.isEmpty
                          ? 'NO TURNS TO REPLAY'
                          : 'REPLAY BATTLE',
                  style: AppTypography.labelMedium?.copyWith(color: Colors.white) ??
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isPlaying ? AppColors.outline : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isPlaying || _turns.isEmpty ? null : _startReplay,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.flash_on, size: 18, color: Colors.white),
                label: const Text(
                  'MANUAL BATTLE',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isPlaying 
                    ? null 
                    : () {
                        if (myActive != null && opActive != null) {
                          context.push('/battle/${myActive.pokemonId}/${opActive.pokemonId}');
                        }
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    for (double i = 0; i <= size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
