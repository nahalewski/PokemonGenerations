import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/pokemon.dart';
import '../../../domain/models/battle_state.dart';


class BattleHpBar extends StatelessWidget {
  final String name;
  final int currentHp;
  final int maxHp;
  final int level;
  final bool isPlayer;
  final bool isConnected;
  final String? trainerName;

  const BattleHpBar({
    super.key,
    required this.name,
    required this.currentHp,
    required this.maxHp,
    required this.level,
    required this.isPlayer,
    this.isConnected = true,
    this.trainerName,
    this.status = 'none',
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final hpPercent = (currentHp / maxHp).clamp(0.0, 1.0);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8D8).withOpacity(0.9),
        borderRadius: BorderRadius.only(
          topLeft: isPlayer ? const Radius.circular(16) : Radius.zero,
          bottomRight: isPlayer ? Radius.zero : const Radius.circular(16),
          topRight: isPlayer ? Radius.zero : const Radius.circular(4),
          bottomLeft: isPlayer ? const Radius.circular(4) : Radius.zero,
        ),
        border: Border.all(color: const Color(0xFF505050), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trainerName != null && trainerName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 24),
              child: Text(
                'Trainer: $trainerName'.toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isConnected)
                          BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF404040),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text('Lv$level',
                  style: const TextStyle(color: Color(0xFF404040), fontSize: 12)),
            ],
          ),
          if (status != 'none')
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black26),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('HP',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 10)),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: hpPercent, end: hpPercent),
                      builder: (context, value, _) {
                        final color = value > 0.5
                            ? Colors.greenAccent
                            : value > 0.2
                                ? Colors.yellowAccent
                                : Colors.redAccent;
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(color),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isPlayer)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('$currentHp/$maxHp',
                    style: const TextStyle(
                        color: Color(0xFF404040),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'brn':
      case 'burn':
        return const Color(0xFFFF4422);
      case 'par':
      case 'paralysis':
        return const Color(0xFFFFAA11);
      case 'slp':
      case 'sleep':
        return const Color(0xFF888888);
      case 'frz':
      case 'freeze':
        return const Color(0xFF66CCFF);
      case 'psn':
      case 'poison':
        return const Color(0xFFAA5599);
      case 'tox':
      case 'toxic':
        return const Color(0xFFFF00FF);
      default:
        return Colors.blueGrey;
    }
  }
}

class BattleMessageBox extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;
  final bool compact;

  const BattleMessageBox({
    super.key,
    required this.message,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: compact ? 60 : 100,
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 8 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border.all(color: const Color(0xFF333333), width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 12 : 16,
            fontFamily: 'monospace',
            height: 1.2,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class BattleActionMenu extends StatelessWidget {
  final VoidCallback onFight;
  final VoidCallback onBag;
  final VoidCallback onPokemon;
  final VoidCallback onRun;
  final int selectedIndex;
  final bool compact;
  final bool showControllerIcons;

  const BattleActionMenu({
    super.key,
    required this.onFight,
    required this.onBag,
    required this.onPokemon,
    required this.onRun,
    this.selectedIndex = -1,
    this.compact = false,
    this.showControllerIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('FIGHT', onFight, Icons.local_fire_department, 'assets/inputsprites/a_button.png'),
      ('BAG', onBag, Icons.backpack, 'assets/inputsprites/x_button.png'),
      ('POKEMON', onPokemon, Icons.catching_pokemon, 'assets/inputsprites/y_button.png'),
      ('RUN', onRun, Icons.logout, 'assets/inputsprites/b_button.png'),
    ];

    Widget buildButton(int i) {
      final (label, cb, icon, spritePath) = actions[i];
      final isSelected = selectedIndex == i;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            onTap: cb,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: compact ? 42 : 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.8) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white12,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showControllerIcons)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Image.asset(spritePath, width: compact ? 16 : 22, height: compact ? 16 : 22),
                    )
                  else
                    Icon(icon, size: compact ? 14 : 18, color: isSelected ? Colors.white : Colors.white38),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 11 : 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [buildButton(0), buildButton(1)]),
              Row(children: [buildButton(2), buildButton(3)]),
            ],
          ),
        ),
      ),
    );
  }
}

class BattleMoveMenu extends StatelessWidget {
  final List<PokemonMove> moves;
  final Function(PokemonMove) onMoveSelected;
  final VoidCallback onCancel;
  final int selectedIndex;
  final bool compact;

  const BattleMoveMenu({
    super.key,
    required this.moves,
    required this.onMoveSelected,
    required this.onCancel,
    this.selectedIndex = -1,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayMoves = moves.take(4).toList();

    Widget buildMoveButton(int i) {
      final hasMove = i < displayMoves.length;
      final move = hasMove ? displayMoves[i] : null;
      final isSelected = selectedIndex == i;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            onTap: hasMove ? () => onMoveSelected(move!) : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: compact ? 42 : 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.8)
                    : (hasMove ? Colors.white.withOpacity(0.05) : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white12,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
                ] : null,
              ),
              child: hasMove
                  ? Center(
                      child: Text(
                        move!.name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 11 : 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [buildMoveButton(0), buildMoveButton(1)]),
              Row(children: [buildMoveButton(2), buildMoveButton(3)]),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: InkWell(
                  onTap: onCancel,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 36,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: selectedIndex == 4 ? Colors.white10 : Colors.transparent,
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'BACK TO SELECTION',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... (BattleHpBar remains same)

class BattleLog extends StatefulWidget {
  final List<BattleLogEntry> entries;
  final bool compact;

  const BattleLog({super.key, required this.entries, this.compact = false});

  @override
  State<BattleLog> createState() => _BattleLogState();
}

class _BattleLogState extends State<BattleLog> {
  bool _expanded = true;
  final ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(BattleLog old) {
    super.didUpdateWidget(old);
    if (widget.entries.length != old.entries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0F).withOpacity(0.98),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.analytics_rounded, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BATTLE TELEMETRY',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            'AUDIT LOG / VER 2.4',
                            style: TextStyle(
                              color: AppColors.primary.withOpacity(0.5),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _expanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_expanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: widget.compact ? 160 : 300,
              child: widget.entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.monitor_heart_outlined, color: Colors.white.withOpacity(0.05), size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'STANDBY: NO DATA',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.15),
                              fontSize: 10,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      child: ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: widget.entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final entry = widget.entries[i];
                          return _buildLogEntry(entry);
                        },
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(BattleLogEntry entry) {
    final bool hasSprite = entry.pokemonSprites.isNotEmpty;
    final bool hasItem = entry.itemId != null;
    
    // Theme colors based on action type
    Color accentColor;
    IconData typeIcon;
    String typeLabel = entry.type.toUpperCase();

    switch (entry.type) {
      case 'attack':
        accentColor = entry.isPlayer ? const Color(0xFF64FFDA) : const Color(0xFFFF5252);
        typeIcon = Icons.bolt_rounded;
        break;
      case 'item':
        accentColor = Colors.orangeAccent;
        typeIcon = Icons.inventory_2_outlined;
        break;
      case 'switch':
        accentColor = Colors.cyanAccent;
        typeIcon = Icons.swap_horiz_rounded;
        break;
      case 'faint':
        accentColor = Colors.deepPurpleAccent;
        typeIcon = Icons.heart_broken_rounded;
        break;
      case 'run':
        accentColor = Colors.grey;
        typeIcon = Icons.directions_run_rounded;
        break;
      case 'status':
        accentColor = Colors.amberAccent;
        typeIcon = Icons.priority_high_rounded;
        break;
      default:
        accentColor = Colors.blueGrey;
        typeIcon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.15), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Icon Column
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: accentColor, size: 16),
          ),
          const SizedBox(width: 16),
          
          // Main Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '[$typeLabel] — ${entry.isPlayer ? "USER" : "CPU"}',
                      style: TextStyle(
                        color: accentColor.withOpacity(0.8),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    if (entry.timestamp != null)
                      Text(
                        '${entry.timestamp!.hour}:${entry.timestamp!.minute.toString().padLeft(2, '0')}:${entry.timestamp!.second.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 8, fontFamily: 'monospace'),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  entry.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.4,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Sprite Slot
          if (hasSprite || hasItem)
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (hasSprite)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor.withOpacity(0.2)),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: entry.pokemonSprites.first,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1))),
                          errorWidget: (_, __, ___) => const Icon(Icons.catching_pokemon, size: 14, color: Colors.white10),
                        ),
                      ),
                    ),
                  if (hasItem)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                        ),
                        child: Image.asset(
                          'assets/items/item_${entry.itemId}.png',
                          width: 14,
                          height: 14,
                          errorBuilder: (_, __, ___) => Image.asset('assets/items/${entry.itemId}.png', width: 14, height: 14, errorBuilder: (c, e, s) => const Icon(Icons.inventory_2, size: 10, color: Colors.orangeAccent)),
                        ),
                      ).animate().scale(),
                    ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideX(begin: 0.05);
  }
}


class ControllerIndicator extends StatelessWidget {
  const ControllerIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_esports, color: Colors.greenAccent, size: 14),
          const SizedBox(width: 4),
          Text(
            'CONTROLLER',
            style: TextStyle(
                color: Colors.greenAccent.withOpacity(0.9),
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
