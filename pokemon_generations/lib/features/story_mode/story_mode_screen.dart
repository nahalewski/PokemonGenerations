import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/networking/dio_client.dart';
import '../../core/settings/app_settings_controller.dart';
import '../auth/auth_controller.dart';

final _storyModeVoteProvider = StateNotifierProvider<_VoteNotifier, _VoteState>(
  (ref) => _VoteNotifier(ref),
);

class _VoteState {
  const _VoteState({this.hasVoted = false, this.votedFor, this.coopCount = 0, this.mmoCount = 0, this.loading = false, this.error});
  final bool hasVoted;
  final String? votedFor;
  final int coopCount;
  final int mmoCount;
  final bool loading;
  final String? error;

  _VoteState copyWith({bool? hasVoted, String? votedFor, int? coopCount, int? mmoCount, bool? loading, String? error}) {
    return _VoteState(
      hasVoted: hasVoted ?? this.hasVoted,
      votedFor: votedFor ?? this.votedFor,
      coopCount: coopCount ?? this.coopCount,
      mmoCount: mmoCount ?? this.mmoCount,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class _VoteNotifier extends StateNotifier<_VoteState> {
  _VoteNotifier(this._ref) : super(const _VoteState()) {
    _loadVotes();
  }

  final Ref _ref;

  Future<void> _loadVotes() async {
    final baseUrl = _ref.read(appSettingsProvider).resolvedBackendUrl;
    if (baseUrl.isEmpty) return;
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.get('$baseUrl/story-mode/votes');
      final data = response.data as Map<String, dynamic>?;
      if (data != null) {
        state = state.copyWith(
          coopCount: (data['coop'] as num?)?.toInt() ?? 0,
          mmoCount: (data['mmo'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (_) {}
  }

  Future<void> castVote(String vote) async {
    if (state.hasVoted || state.loading) return;
    state = state.copyWith(loading: true, error: null);

    final baseUrl = _ref.read(appSettingsProvider).resolvedBackendUrl;
    final username = _ref.read(authControllerProvider).profile?.username ?? 'anonymous';

    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post('$baseUrl/story-mode/vote', data: {'vote': vote, 'username': username});
      final data = response.data as Map<String, dynamic>?;
      if (data != null) {
        state = state.copyWith(
          hasVoted: true,
          votedFor: vote,
          coopCount: (data['coop'] as num?)?.toInt() ?? state.coopCount,
          mmoCount: (data['mmo'] as num?)?.toInt() ?? state.mmoCount,
          loading: false,
        );
      } else {
        state = state.copyWith(loading: false, error: 'Vote failed. Try again.');
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Could not reach server.');
    }
  }
}

class StoryModeScreen extends ConsumerWidget {
  const StoryModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voteState = ref.watch(_storyModeVoteProvider);
    final total = voteState.coopCount + voteState.mmoCount;
    final coopPct = total > 0 ? voteState.coopCount / total : 0.5;
    final mmoPct = total > 0 ? voteState.mmoCount / total : 0.5;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset('assets/battle/battle_bg.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text('STORY MODE', style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Coming Soon Banner
                  Center(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      color: AppColors.tertiary.withValues(alpha: 0.08),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_clock_outlined, size: 16, color: AppColors.tertiary),
                          const SizedBox(width: 8),
                          Text(
                            'COMING SOON',
                            style: AppTypography.labelLarge.copyWith(color: AppColors.tertiary, letterSpacing: 3),
                          ),
                        ],
                      ),
                    ).animate().shimmer(duration: 2.seconds, color: AppColors.tertiary.withValues(alpha: 0.3)),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'STORY\nMODE',
                    style: AppTypography.displayLarge.copyWith(height: 0.9),
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text(
                    'CAMPAIGN // WORLD MAP // MISSION SYSTEM',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.tertiary, letterSpacing: 2),
                  ),
                  const SizedBox(height: 32),

                  // Godot Launcher (WIP)
                  if (!kIsWeb) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            if (Platform.isMacOS) {
                              await Process.start(
                                '/Applications/Godot.app/Contents/MacOS/Godot',
                                ['--path', '/Users/bennahalewski/Documents/PokeRoster/StoryG'],
                              );
                            } else if (Platform.isAndroid) {
                              await LaunchApp.openApp(
                                androidPackageName: 'com.pokemon.generations.story',
                                openStore: false,
                              );
                            } else {
                              throw 'Platform not supported';
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to launch Godot: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.rocket_launch_outlined, color: AppColors.tertiary),
                        label: Text('LAUNCH STORYG (DEBUG)', style: AppTypography.labelLarge.copyWith(color: AppColors.tertiary)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.tertiary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Description
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THE PLAN', style: AppTypography.headlineSmall),
                        const SizedBox(height: 16),
                        _buildPlanItem(
                          Icons.public_outlined,
                          'World Map',
                          'Navigate a living region map with towns, routes, wild encounters, and trainer battles.',
                          AppColors.primary,
                        ),
                        _buildPlanItem(
                          Icons.flag_outlined,
                          'Campaign Missions',
                          'Progress through gym challenges, story arcs, and rival encounters from all generations.',
                          AppColors.secondary,
                        ),
                        _buildPlanItem(
                          Icons.emoji_events_outlined,
                          'Elite Four & Champion',
                          'Build toward the final league gauntlet with your trained roster.',
                          AppColors.tertiary,
                        ),
                        _buildPlanItem(
                          Icons.catching_pokemon_outlined,
                          'Wild Encounters',
                          'Encounter Pokémon in the field — capture, battle, and expand your roster.',
                          Colors.deepPurpleAccent,
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms),
                  const SizedBox(height: 32),

                  // Multiplayer Mode Choice
                  Text('MULTIPLAYER FORMAT', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Help shape the direction — how should Story Mode handle multiplayer?',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.outline),
                  ),
                  const SizedBox(height: 24),

                  // Mode cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 480;
                      return isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildModeCard(context, ref, voteState, 'coop', coopPct)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildModeCard(context, ref, voteState, 'mmo', mmoPct)),
                              ],
                            )
                          : Column(
                              children: [
                                _buildModeCard(context, ref, voteState, 'coop', coopPct),
                                const SizedBox(height: 16),
                                _buildModeCard(context, ref, voteState, 'mmo', mmoPct),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 16),

                  if (voteState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(voteState.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ),

                  if (voteState.hasVoted)
                    Center(
                      child: Text(
                        'VOTE RECORDED — THANKS TRAINER!',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.tertiary, letterSpacing: 2),
                      ).animate().fade().scale(),
                    ),

                  if (total > 0) ...[
                    const SizedBox(height: 24),
                    Text(
                      'TOTAL VOTES: $total',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.outline, letterSpacing: 1),
                    ),
                  ],

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem(IconData icon, String title, String body, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(body, style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, WidgetRef ref, _VoteState voteState, String mode, double pct) {
    final isCoop = mode == 'coop';
    final color = isCoop ? AppColors.secondary : AppColors.tertiary;
    final title = isCoop ? 'CO-OP MODE' : 'MMO MODE';
    final subtitle = isCoop ? 'Team up with 1–4 friends' : 'Shared persistent world';
    final description = isCoop
        ? 'Play through the story campaign side-by-side with friends. Share battles, trade Pokémon, and tackle gym leaders together in a private session.'
        : 'Enter a persistent online world alongside all trainers. Roam shared routes, compete for gym standings, and build your reputation on a live server.';
    final icon = isCoop ? Icons.group_outlined : Icons.public_outlined;

    final isSelected = voteState.votedFor == mode;
    final hasVoted = voteState.hasVoted;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: isSelected ? color.withValues(alpha: 0.08) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.labelLarge.copyWith(color: color)),
                    Text(subtitle, style: AppTypography.labelSmall.copyWith(color: AppColors.outline, fontSize: 10)),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
          const SizedBox(height: 16),

          // Vote bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(pct * 100).toInt()}%',
            style: AppTypography.labelSmall.copyWith(color: color, fontSize: 10),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasVoted
                  ? null
                  : voteState.loading
                      ? null
                      : () => ref.read(_storyModeVoteProvider.notifier).castVote(mode),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: isSelected ? color.withValues(alpha: 0.3) : AppColors.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isSelected ? 'VOTED' : hasVoted ? 'VOTE CAST' : 'VOTE',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
