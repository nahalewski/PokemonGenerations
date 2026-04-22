import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../../../../core/theme.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/admin_tab_logger.dart';
import '../../../../models/admin_models.dart';

class BattleMonitorTab extends StatefulWidget {
  const BattleMonitorTab({super.key});

  @override
  State<BattleMonitorTab> createState() => _BattleMonitorTabState();
}

class _BattleMonitorTabState extends State<BattleMonitorTab> {
  List<LiveBattle> _battles = [];
  List<TelemetryBattle> _telemetryBattles = [];
  bool _isLoading = true;
  Timer? _timer;
  LiveBattle? _spectatingBattle;
  String _battleLog = '';

  @override
  void initState() {
    super.initState();
    AdminTabLogger.log('battle_monitor', 'tab_initialized');
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final battles = await AdminService().fetchLiveBattles();
      final telemetry = await AdminService().fetchTelemetryBattles();
      if (mounted) {
        setState(() {
          _battles = battles;
          _telemetryBattles = telemetry;
          _isLoading = false;
        });
      }
      await AdminTabLogger.log(
        'battle_monitor',
        'refresh_completed',
        details: {
          'liveBattles': battles.length,
          'telemetryBattles': telemetry.length,
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
      await AdminTabLogger.log('battle_monitor', 'refresh_failed');
    }
  }

  Future<void> _updateLog(String battleId) async {
    final log = await AdminService().fetchBattleLog(battleId);
    if (mounted) {
      setState(() => _battleLog = log);
    }
    await AdminTabLogger.log(
      'battle_monitor',
      'battle_log_loaded',
      details: {'battleId': battleId, 'length': log.length},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_spectatingBattle != null) {
      return _buildSpectatorView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('BATTLE MONITOR', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.radio_button_checked, color: Colors.redAccent, size: 14),
                  SizedBox(width: 8),
                  Text('LIVE AUDIT', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Security & Anti-Cheat Hub — Real-time telemetry for active arena matches.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading && _battles.isEmpty && _telemetryBattles.isEmpty) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOnlineSection(),
          const SizedBox(height: 48),
          _buildLocalSection(),
        ],
      ),
    );
  }

  Widget _buildOnlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.wifi, color: Colors.greenAccent, size: 16),
            const SizedBox(width: 8),
            Text('ACTIVE ONLINE MATCHES', style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
            const Spacer(),
            Text('${_battles.length} SESSIONS', style: const TextStyle(color: Colors.white24, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 16),
        if (_battles.isEmpty)
          _buildEmptyState('No active PvP sessions detected.')
        else
          ..._battles.map((b) => _buildBattleCard(b)),
      ],
    );
  }

  Widget _buildLocalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.phonelink_setup, color: Colors.blueAccent, size: 16),
            const SizedBox(width: 8),
            Text('LOCAL SIMULATIONS (TELEMETRY)', style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
            const Spacer(),
            Text('${_telemetryBattles.length} PINGS', style: const TextStyle(color: Colors.white24, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 16),
        if (_telemetryBattles.isEmpty)
          _buildEmptyState('No CPU telemetry reporting currently.')
        else
          ..._telemetryBattles.map((b) => _buildTelemetryCard(b)),
      ],
    );
  }

  Widget _buildBattleCard(LiveBattle battle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(battle.player1, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('VS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
          Expanded(child: Text(battle.player2, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
          const SizedBox(width: 24),
          OutlinedButton(
            onPressed: () async {
              await AdminTabLogger.log(
                'battle_monitor',
                'spectate_window_requested',
                details: {'battleId': battle.id},
              );
              final window = await DesktopMultiWindow.createWindow(jsonEncode({
                'battleId': battle.id,
                'player1': battle.player1,
                'player2': battle.player2,
              }));
              window
                ..setFrame(const Offset(0, 0) & const Size(1280, 800))
                ..center()
                ..setTitle('BATTLE SPECTATE: ${battle.id}')
                ..show();
            },
            child: const Text('SPECTATE'),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(TelemetryBattle battle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildPlayerStats(battle.playerInfo['name'] ?? 'PLAYER', battle.playerInfo['hp'] ?? 0, battle.playerInfo['maxHp'] ?? 100, true),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('VS', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          ),
          _buildPlayerStats(battle.opponentInfo['name'] ?? 'CPU', battle.opponentInfo['hp'] ?? 0, battle.opponentInfo['maxHp'] ?? 100, false),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ID: ${battle.id.toUpperCase()}', style: const TextStyle(color: Colors.white24, fontSize: 9)),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _showTelemetrySpectator(battle),
                style: FilledButton.styleFrom(backgroundColor: Colors.blueAccent.withOpacity(0.1), foregroundColor: Colors.blueAccent),
                icon: const Icon(Icons.analytics, size: 16),
                label: const Text('AUDIT LOG'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStats(String name, int hp, int maxHp, bool isPlayer) {
    final percent = (hp / maxHp).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        crossAxisAlignment: isPlayer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.black26,
            valueColor: AlwaysStoppedAnimation(percent > 0.5 ? Colors.greenAccent : (percent > 0.2 ? Colors.amberAccent : Colors.redAccent)),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text('$hp / $maxHp HP', style: TextStyle(color: AppColors.textDim, fontSize: 10)),
        ],
      ),
    );
  }

  void _showTelemetrySpectator(TelemetryBattle battle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 40, spreadRadius: 5),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: Colors.blueAccent, size: 28),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BATTLE AUDIT LOG', style: Theme.of(context).textTheme.headlineMedium),
                        Text('Session ID: ${battle.id.toUpperCase()}', style: TextStyle(color: AppColors.textDim, fontSize: 10)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Match Summary Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    _buildAuditPlayerCard(battle.playerInfo['name'] ?? 'PLAYER', true),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('VS', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 18)),
                    ),
                    _buildAuditPlayerCard(battle.opponentInfo['name'] ?? 'CPU', false),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Log Timeline
              Expanded(
                child: Container(
                  color: Colors.black12,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: battle.log.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _buildPolishedLogEntry(
                      battle.log[i],
                      playerName: battle.playerInfo['name'] ?? 'PLAYER',
                      opponentName: battle.opponentInfo['name'] ?? 'CPU',
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

  Widget _buildAuditPlayerCard(String name, bool isPlayer) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: isPlayer ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (!isPlayer) const Spacer(),
            Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: isPlayer ? Colors.blueAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
              child: Icon(isPlayer ? Icons.person : Icons.computer, size: 16, color: isPlayer ? Colors.blueAccent : Colors.redAccent),
            ),
            if (isPlayer) const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPolishedLogEntry(String log, {required String playerName, required String opponentName}) {
    // Detect source based on name occurrence in log
    final isPlayerAction = log.contains(playerName);
    final isCPUAction = log.contains(opponentName);
    
    // Fallback to left-aligned if ambiguous, but prioritize threading
    final alignment = isCPUAction ? MainAxisAlignment.end : MainAxisAlignment.start;
    final themeColor = isCPUAction ? Colors.orangeAccent : (isPlayerAction ? Colors.blueAccent : Colors.white24);
    final bubbleColor = themeColor.withOpacity(0.05);

    final pkmRegex = RegExp(r'\b(Pikachu|Charmander|Squirtle|Bulbasaur|Charizard|Blastoise|Venusaur|Mewtwo|Arceus)\b', caseSensitive: false);
    final itemRegex = RegExp(r'\b(Potion|Super-Potion|Hyper-Potion|Revive|Full-Restore|Poke-Ball|Great-Ball|Ultra-Ball|Master-Ball|Leftovers|Life-Orb)\b', caseSensitive: false);

    final pkmMatch = pkmRegex.firstMatch(log);
    final itemMatch = itemRegex.firstMatch(log);

    return Row(
      mainAxisAlignment: alignment,
      children: [
        if (isCPUAction) const Spacer(flex: 2),
        Flexible(
          flex: 8,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCPUAction) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 12, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 12),
                ],
                if (pkmMatch != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      'https://img.pokemondb.net/sprites/home/normal/${pkmMatch.group(0)!.toLowerCase()}.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                Flexible(
                  child: Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                if (isCPUAction) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('CPU', style: TextStyle(color: Colors.orangeAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!isCPUAction) const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: AppColors.textDim, fontSize: 12)),
      ),
    );
  }

  Widget _buildSpectatorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => setState(() {
                _spectatingBattle = null;
                _battleLog = '';
              }),
            ),
            const SizedBox(width: 8),
            Text('SPECTATING: ${_spectatingBattle!.player1} VS ${_spectatingBattle!.player2}',
                style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(),
            Text('LIVE FEED', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('MATCH TELEMETRY LOG', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(DateTime.now().toLocal().toString().split('.')[0], style: const TextStyle(color: Colors.greenAccent, fontSize: 10)),
                  ],
                ),
                const Divider(color: Colors.greenAccent, thickness: 0.5, height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Text(
                      _battleLog.isEmpty ? 'Waiting for match data...' : _battleLog,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ANTI-CHEAT NOTICE: You are in silent spectator mode. Moves and status effects are mirrored from the server authority. Variations in expected damage output are automatically flagged.',
                  style: TextStyle(color: AppColors.textDim, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
