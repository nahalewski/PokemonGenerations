import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/models/replay_models.dart';
import '../../battle/widgets/visual_spectate_renderer.dart';
import '../../../core/theme/app_colors.dart';

class ReplayPlayerScreen extends StatefulWidget {
  final BattleReplay replay;

  const ReplayPlayerScreen({super.key, required this.replay});

  @override
  State<ReplayPlayerScreen> createState() => _ReplayPlayerScreenState();
}

class _ReplayPlayerScreenState extends State<ReplayPlayerScreen> {
  final StreamController<ReplayEvent> _eventController = StreamController<ReplayEvent>.broadcast();
  bool _isPlaying = true;
  double _speed = 1.0;
  int _currentTurnIndex = 0;
  bool _recapMode = false;
  
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  void _startPlayback() {
    _playNextTurn();
  }

  Future<void> _playNextTurn() async {
    if (!_isPlaying || _currentTurnIndex >= widget.replay.turns.length) return;

    final turn = widget.replay.turns[_currentTurnIndex];
    
    // If in recap mode, we only play highlighted turns
    if (_recapMode && !_isHighlightTurn(turn)) {
       _currentTurnIndex++;
       _playNextTurn();
       return;
    }

    for (final event in turn.events) {
      if (!mounted) return;
      _eventController.add(event);
      // Wait for event to "play" based on type
      await Future.delayed(Duration(milliseconds: (1000 / _speed).round()));
    }

    _currentTurnIndex++;
    if (_currentTurnIndex < widget.replay.turns.length) {
      _playbackTimer = Timer(const Duration(milliseconds: 500), _playNextTurn);
    }
  }

  bool _isHighlightTurn(ReplayTurn turn) {
    return turn.events.any((e) {
      if (e.type == 'faint') return true;
      if (e.type == 'damage') {
        final damage = e.data?['hp_delta'] as int? ?? 0;
        final maxHp = e.data?['max_hp'] as int? ?? 100;
        if (damage.abs() > (maxHp * 0.3)) return true; // >30% damage
      }
      return false;
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) _playNextTurn();
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _eventController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REPLAY: ${widget.replay.battleId.toUpperCase()}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${widget.replay.p1.username} vs ${widget.replay.p2.username}',
                          style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                  const Spacer(),
                  _buildRecapToggle(),
                ],
              ),
            ),

            // Main Renderer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: VisualSpectateRenderer(
                  eventStream: _eventController.stream,
                  initialData: widget.replay,
                  playbackSpeed: _speed,
                ),
              ),
            ),

            // Control Bar
            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapToggle() {
    return InkWell(
      onTap: () => setState(() {
        _recapMode = !_recapMode;
        // Logic to jump to nearest highlight could be added
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _recapMode ? AppColors.primary : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _recapMode ? Colors.white24 : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(Icons.video_collection, size: 14, color: _recapMode ? Colors.white : Colors.white54),
            const SizedBox(width: 6),
            Text('RECAP', style: TextStyle(color: _recapMode ? Colors.white : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSpeedButton(1.0),
          _buildSpeedButton(2.0),
          _buildSpeedButton(4.0),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 48, color: AppColors.primary),
            onPressed: _togglePlay,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white54),
            onPressed: () {
               // Logic to skip turn
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(double s) {
    final active = _speed == s;
    return InkWell(
      onTap: () => setState(() => _speed = s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('${s.toInt()}X',
            style: TextStyle(
                color: active ? AppColors.primary : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }
}
