import 'dart:async';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../../core/theme.dart';
import '../../services/admin_service.dart';
import '../../models/admin_models.dart';

class SpectatorWindow extends StatefulWidget {
  final WindowController windowController;
  final Map<String, dynamic> args;

  const SpectatorWindow({
    super.key,
    required this.windowController,
    required this.args,
  });

  @override
  State<SpectatorWindow> createState() => _SpectatorWindowState();
}

class _SpectatorWindowState extends State<SpectatorWindow> {
  bool _isPlayer1View = true;
  bool _isRecording = false;
  bool _isMinimized = false;
  List<String> _battleLogs = [];
  Timer? _pollingTimer;
  LiveBattle? _currentBattle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _fetchUpdate();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchUpdate();
    });
  }

  Future<void> _fetchUpdate() async {
    final battleId = widget.args['battleId'];
    if (battleId == null) return;

    try {
      final service = AdminService();
      final logText = await service.fetchBattleLog(battleId);
      
      final liveBattles = await service.fetchLiveBattles();
      final foundBattle = liveBattles.where((b) => b.id == battleId).firstOrNull;

      if (mounted) {
        setState(() {
          _battleLogs = logText.split('\n').where((l) => l.isNotEmpty).toList().reversed.toList();
          _currentBattle = foundBattle;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final battleId = widget.args['battleId'] ?? 'UNKNOWN';
    final p1 = widget.args['player1'] ?? 'P1';
    final p2 = widget.args['player2'] ?? 'P2';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            flex: _isMinimized ? 1 : 2,
            child: Column(
              children: [
                _buildWindowHeader(battleId),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          _buildVisualArena(p1, p2),
                          _buildFeedControls(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildPlaybackStatus(p1, p2),
              ],
            ),
          ),

          if (!_isMinimized)
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(left: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Column(
                children: [
                  _buildTabs(),
                  Expanded(child: _buildPlayByPlayView()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVisualArena(String p1, String p2) {
    final active1 = _currentBattle?.active1 ?? 'pikachu';
    final active2 = _currentBattle?.active2 ?? 'charizard';
    final hp1 = _currentBattle?.hp1 ?? 100.0;
    final hp2 = _currentBattle?.hp2 ?? 100.0;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Colors.blueGrey.withOpacity(0.2),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('LIVE STADIUM FEED', 
              style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 8, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildParticipant(p1, active1, hp1, true),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                  ),
                  child: const Text('VS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                _buildParticipant(p2, active2, hp2, false),
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam, color: Colors.redAccent, size: 14),
                const SizedBox(width: 8),
                Text('REMOTE AUDIT ACTIVE - TURN ${_currentBattle?.turnCount ?? 0}', 
                  style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipant(String name, String species, double hp, bool isPlayer1) {
    final spriteUrl = 'https://img.pokemondb.net/sprites/home/normal/${species.toLowerCase()}.png';
    final hpColor = hp > 50 ? Colors.greenAccent : (hp > 20 ? Colors.amberAccent : Colors.redAccent);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.02),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            Image.network(
              spriteUrl,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.help_outline, color: Colors.white10, size: 40),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13, letterSpacing: 1.2)),
        Text(species.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Container(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('HP', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                  Text('${hp.toInt()}%', style: TextStyle(color: hpColor, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: hp / 100,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(hpColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWindowHeader(String id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          const Icon(Icons.radar, color: AppColors.primary, size: 16),
          const SizedBox(width: 12),
          Text('BATTLE SECURITY FEED: ${id.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
          const Spacer(),
          _buildHeaderAction(_isRecording ? Icons.stop_circle : Icons.fiber_manual_record, 
            _isRecording ? Colors.red : Colors.white24, () => setState(() => _isRecording = !_isRecording)),
          const SizedBox(width: 8),
          _buildHeaderAction(_isMinimized ? Icons.open_in_full : Icons.close_fullscreen, 
            Colors.white24, () => setState(() => _isMinimized = !_isMinimized)),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildFeedControls() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewToggle('P1 FOCUS', _isPlayer1View, () => setState(() => _isPlayer1View = true)),
              const SizedBox(width: 4),
              _buildViewToggle('P2 FOCUS', !_isPlayer1View, () => setState(() => _isPlayer1View = false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildPlaybackStatus(String p1, String p2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.black,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text('LIVE LINK: $p1 VS $p2', style: const TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const Spacer(),
          Text('POLLING INTERVAL: 2000MS  |  SERVER: OK', style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
     return Container(
       padding: const EdgeInsets.all(20),
       width: double.infinity,
       decoration: BoxDecoration(
         border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('BATTLE CHRONICLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, color: AppColors.primary)),
           const SizedBox(height: 4),
           Text('FULL TELEMETRY LOG', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9)),
         ],
       ),
     );
  }

  Widget _buildPlayByPlayView() {
    if (_battleLogs.isEmpty && _isLoading) return const Center(child: CircularProgressIndicator());
    if (_battleLogs.isEmpty) return const Center(child: Text('WAITING FOR ENCOUNTER DATA...', style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 1)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _battleLogs.length,
      itemBuilder: (context, i) {
        final log = _battleLogs[i];
        final isTurn = log.contains('Turn');
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isTurn ? AppColors.primary.withOpacity(0.05) : Colors.black12,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isTurn ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.02)),
          ),
          child: Text(
            log, 
            style: TextStyle(
              fontSize: 11, 
              color: isTurn ? Colors.white : Colors.white70,
              fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Courier',
            )
          ),
        );
      },
    );
  }
}
