import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/admin_tab_logger.dart';

class MusicSTab extends StatefulWidget {
  const MusicSTab({super.key});

  @override
  State<MusicSTab> createState() => _MusicSTabState();
}

class _MusicSTabState extends State<MusicSTab> {
  final AdminService _adminService = AdminService();
  Timer? _pollingTimer;
  Map<String, dynamic>? _telemetry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AdminTabLogger.log('music_telemetry', 'tab_initialized');
    _fetchTelemetry();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchTelemetry());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTelemetry() async {
    try {
      final data = await _adminService.fetchMusicTelemetry();
      if (mounted) {
        setState(() {
          _telemetry = data;
          _isLoading = false;
        });
      }
      await AdminTabLogger.log(
        'music_telemetry',
        'telemetry_refresh_completed',
        details: {
          'listeners': (data['listeners'] as List?)?.length ?? 0,
          'topTracks': (data['topTracks'] as List?)?.length ?? 0,
        },
      );
    } catch (e) {
      debugPrint('TELEMETRY ERROR: $e');
      await AdminTabLogger.log(
        'music_telemetry',
        'telemetry_refresh_failed',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _telemetry == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final listeners = (_telemetry?['listeners'] as List?) ?? [];
    final stats = (_telemetry?['stats'] as Map?) ?? {};
    final topTracks = (_telemetry?['topTracks'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 32),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Active Listeners
              Expanded(
                flex: 3,
                child: _buildActiveListenersList(context, listeners),
              ),
              const SizedBox(width: 32),
              // Right Column: Statistics
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildGlobalStatsCard(context, stats),
                    const SizedBox(height: 32),
                    _buildMostPlayedCard(context, topTracks),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('MusicS TELEMETRY', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.graphic_eq_rounded, color: AppColors.secondary, size: 14),
                  SizedBox(width: 8),
                  Text('LIVE SERVER', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Music Server Monitoring — Real-time playback analytics and user listening habits.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
        ),
      ],
    );
  }

  Widget _buildActiveListenersList(BuildContext context, List<dynamic> listeners) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CURRENTLY LISTENING', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12, color: AppColors.primary)),
          const SizedBox(height: 24),
          if (listeners.isEmpty)
             Expanded(
               child: Center(
                 child: Text('NO ACTIVE SESSIONS', style: TextStyle(color: AppColors.textDim, fontSize: 13, letterSpacing: 1.2)),
               ),
             )
          else
            Expanded(
              child: ListView.builder(
                itemCount: listeners.length,
                itemBuilder: (context, i) {
                  final l = listeners[i];
                  final isListening = l['isPlaying'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isListening ? AppColors.primary.withOpacity(0.1) : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.background,
                          child: Icon(isListening ? Icons.music_note_rounded : Icons.music_off_rounded, color: isListening ? AppColors.primary : AppColors.textDim),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l['user']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(l['song']!, style: TextStyle(color: isListening ? AppColors.accent : AppColors.textDim, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (isListening)
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('LIVE', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('STREAMING', style: TextStyle(color: AppColors.textDim, fontSize: 10)),
                            ],
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (i * 100).ms).slideX(begin: 0.1);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlobalStatsCard(BuildContext context, Map<dynamic, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SERVER STATISTICS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12, color: AppColors.primary)),
          const SizedBox(height: 24),
          _buildStatRow('Active Connections', stats['activeConnections'] ?? '0', Icons.people_outline),
          const SizedBox(height: 16),
          _buildStatRow('Avg Listen Time', stats['avgListenTime'] ?? '---', Icons.timer_outlined),
          const SizedBox(height: 16),
          _buildStatRow('Total Plays (24h)', stats['totalPlays24h'] ?? '0', Icons.play_circle_outline),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textDim, size: 18),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 13)),
        const Spacer(),
        Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
      ],
    );
  }

  Widget _buildMostPlayedCard(BuildContext context, List<dynamic> topSongs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOP TRACKS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12, color: AppColors.accent)),
          const SizedBox(height: 24),
          if (topSongs.isEmpty)
             const Text('NO DATA COLLECTED YET', style: TextStyle(color: AppColors.textDim, fontSize: 11))
          else
            ...topSongs.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: Text(s['title']!.toString(), style: const TextStyle(fontSize: 13))),
                  Text(s['count']!.toString(), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 4),
                  const Text('PLAYS', style: TextStyle(color: Colors.white24, fontSize: 9)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
