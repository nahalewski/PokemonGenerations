import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/analysis.dart';
import '../../domain/models/pokemon_form.dart';
import '../../core/settings/app_settings_controller.dart';
import 'matchup_provider.dart';
import 'opponent_selection_modal.dart';
import '../roster/roster_provider.dart';
import 'widgets/type_coverage_matrix.dart';
import 'widgets/battle_clash_scene.dart';
import 'widgets/battle_replay_widget.dart';
import '../../core/widgets/pokemon_sprite.dart';
import '../../core/widgets/stat_radar_chart.dart';
import '../roster/add_pokemon_screen.dart';
import '../../data/services/api_client.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchupProvider);
    final rosterAsync = ref.watch(rosterProvider);
    final hasRoster = rosterAsync.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              )
            : null,
        title: Text('BATTLE ANALYTICS', style: AppTypography.headlineSmall),
        actions: [
          if (state.analysisResult != null)
            IconButton(
              onPressed: () => ref.read(matchupProvider.notifier).reset(),
              icon: const Icon(Icons.refresh, color: AppColors.outline),
            ),
        ],
      ),
      body: state.isAnalyzing
          ? BattleClashScene(
              roster: rosterAsync.value ?? [],
              opponentTeam: state.opponentTeam,
            )
          : state.analysisResult != null
          ? _buildResults(context, ref, state.analysisResult!)
          : _buildInput(context, ref, state, hasRoster),
    );
  }

  Widget _buildInput(
    BuildContext context,
    WidgetRef ref,
    MatchupState state,
    bool hasRoster,
  ) {
    final roster = ref.watch(rosterProvider).value ?? [];
    final backendUrl = ref.watch(backendBaseUrlProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasRoster) ...[
              TypeCoverageMatrix(team: roster),
              const SizedBox(height: 48),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('OPPONENT SQUAD'),
                TextButton.icon(
                  onPressed: state.isAnalyzing 
                    ? null 
                    : () => ref.read(matchupProvider.notifier).autoGenerateOpponents(),
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('AUTO GENERATE'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    textStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOpponentGrid(context, ref, state.opponentTeam),
            const SizedBox(height: 24),
            // Opponent Defensive Coverage
            TypeCoverageMatrix(
              team: state.opponentTeam,
              title: 'OPPONENT DEFENSIVE COVERAGE',
            ),
            const SizedBox(height: 48),
            _buildSectionHeader('BATTLE FORMAT'),
            const SizedBox(height: 16),
            Row(
              children: [
                _FormatToggle(
                  label: 'SINGLES',
                  isSelected: state.format == 'Singles',
                  onTap: () =>
                      ref.read(matchupProvider.notifier).setFormat('Singles'),
                ),
                const SizedBox(width: 8),
                _FormatToggle(
                  label: 'VGC',
                  isSelected: state.format == 'VGC',
                  onTap: () =>
                      ref.read(matchupProvider.notifier).setFormat('VGC'),
                ),
                const SizedBox(width: 8),
                _FormatToggle(
                  label: 'REG G',
                  isSelected: state.format == 'Reg G',
                  onTap: () =>
                      ref.read(matchupProvider.notifier).setFormat('Reg G'),
                ),
              ],
            ),
            const SizedBox(height: 40), // Spacing before button
            if (!hasRoster)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: GlassCard(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderColor: AppColors.primary.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'No Pokémon found in your Roster. Please add some Pokémon to your Roster before starting analysis.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _buildAnalyzeButton(context, ref, state, hasRoster),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: GlassCard(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderColor: AppColors.error.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'CONNECTION ERROR: Ensure your backend is running at $backendUrl',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentGrid(
    BuildContext context,
    WidgetRef ref,
    List<PokemonForm> team,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 110, // Fixed height to prevent shrinking
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        if (index < team.length) {
          final p = team[index];
          return _buildSelectedSlot(
            p,
            () =>
                ref.read(matchupProvider.notifier).removeOpponentPokemon(p.id),
            onTap: () async {
              // Fetch pokemon details first for editing
              final pokemon = await ref
                  .read(apiClientProvider.notifier)
                  .getPokemonDetail(p.pokemonId);
              if (pokemon != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPokemonScreen(
                      isOpponent: true,
                      initialForm: p,
                      initialPokemon: pokemon,
                    ),
                  ),
                );
              }
            },
          );
        }
        return _buildEmptySlot(() => _showAddPokemonModal(context));
      },
    );
  }

  Widget _buildSelectedSlot(
    PokemonForm p,
    VoidCallback onRemove, {
    VoidCallback? onTap,
  }) {
    return Stack(
      children: [
        GlassCard(
          onTap: onTap,
          padding: EdgeInsets.zero,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PokemonSprite(pokemonId: p.pokemonId, width: 60, height: 60),
                const SizedBox(height: 4),
                Text(
                  p.pokemonName ?? 'Unknown',
                  style: AppTypography.labelSmall.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlot(VoidCallback onTap) {
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: const Center(
        child: Icon(Icons.add, color: AppColors.secondary, size: 28),
      ),
    );
  }

  Widget _buildAnalyzeButton(
    BuildContext context,
    WidgetRef ref,
    MatchupState state,
    bool hasRoster,
  ) {
    bool canAnalyze =
        state.opponentTeam.isNotEmpty && hasRoster && !state.isAnalyzing;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canAnalyze
              ? AppColors.primary
              : AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: canAnalyze
            ? () => ref.read(matchupProvider.notifier).runTelemetryAnalysis()
            : null,
        child: state.isAnalyzing
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'START TELEMETRY ANALYSIS',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    WidgetRef ref,
    MatchupAnalysis results,
  ) {
    final rosterAsync = ref.read(rosterProvider);
    final roster = rosterAsync.value ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreHeader(results),
            const SizedBox(height: 32),

            _buildSectionHeader('RECOMMENDED LEAD LINEUP'),
            const SizedBox(height: 16),
            _buildLeadSection(results.recommendedLeads),

            const SizedBox(height: 32),
            _buildSectionHeader('PLAY-BY-PLAY TELEMETRY'),
            const SizedBox(height: 16),
            _buildPlayByPlay(results.simulationLog),

            Builder(
              builder: (ctx) {
                final state = ref.read(matchupProvider);
                if (roster.isEmpty || state.opponentTeam.isEmpty)
                  return const SizedBox.shrink();
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    BattleReplayWidget(
                      simulationLog: results.simulationLog,
                      myTeam: roster,
                      opponentTeam: state.opponentTeam,
                    ),
                  ],
                );
              },
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('DEFENSIVE COVERAGE'),
                      const SizedBox(height: 16),
                      TypeCoverageMatrix(team: roster),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('TEAM UTILITY MATRIX'),
                      const SizedBox(height: 16),
                      ref.watch(rosterStatsProvider).when(
                        data: (stats) => Center(
                          child: Container(
                            height: 250,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: StatRadarChart(
                              stats: stats,
                              maxValue: 180, // Average peak for team stats
                              size: 220,
                              showLabels: true,
                            ),
                          ),
                        ),
                        loading: () => const Center(
                          child: SizedBox(
                            height: 250,
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                        error: (err, stack) => const Center(
                          child: Text('Failed to load team stats' , style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),
            _buildSectionHeader('TEAM OFFENSIVE COVERAGE'),
            const SizedBox(height: 16),
            TypeCoverageMatrix(
              team: roster,
              title: 'Offensive Presence',
              isOffensive: true,
            ),

            const SizedBox(height: 48),
            _buildSectionHeader('TACTICAL BUILD INSIGHTS'),
            const SizedBox(height: 16),
            ...results.moveRecommendations.map(
              (m) => _MoveItem(recommendation: m),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('OPPONENT THREAT MATRIX'),
            const SizedBox(height: 16),
            ...results.threats.map((t) => _ThreatItem(report: t)),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }


  Widget _buildScoreHeader(MatchupAnalysis results) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          results.matchupScore.toInt().toString(),
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.primary,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '%',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.primary,
            height: 2,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WIN PROBABILITY',
                style: AppTypography.labelSmall.copyWith(letterSpacing: 2),
              ),
              Text(
                results.reasoning,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.outline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ).animate().fade().slideX();
  }

  Widget _buildLeadSection(List<String> leads) {
    return Row(
      children: leads
          .map(
            (id) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GlassCard(
                  child: Column(
                    children: [
                      PokemonSprite(pokemonId: id, height: 60),
                      Text(
                        'PRIMARY LEAD',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _showAddPokemonModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OpponentSelectionModal(),
    );
  }

  Widget _buildPlayByPlay(List<String> log) {
    if (log.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      color: Colors.black.withOpacity(0.4),
      borderColor: AppColors.primary.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: log.map((line) {
          bool isHeader =
              line.contains('TURN') ||
              line.contains('INITIATING') ||
              line.contains('MATCHUP:') ||
              line.contains('TEAM OVERVIEW') ||
              line.contains('SPEED TIER');
          bool isPriority = line.contains('>>');

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              line,
              style: GoogleFonts.firaCode(
                fontSize: isHeader ? 12 : 11,
                color: isHeader
                    ? AppColors.primary
                    : isPriority
                    ? Colors.cyanAccent
                    : AppColors.outline,
                fontWeight: isHeader || isPriority
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 600.ms).slide(begin: const Offset(0, 0.1));
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2),
        ),
      ],
    );
  }
}

class _FormatToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondary
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreatItem extends StatelessWidget {
  final ThreatReport report;

  const _ThreatItem({required this.report});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(report.pokemonName, style: AppTypography.headlineSmall),
              Text(
                '${(report.threatLevel * 100).toInt()}% RISK',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: report.threatLevel,
            backgroundColor: AppColors.surfaceContainerHighest,
            color: AppColors.primary,
            minHeight: 2,
          ),
          const SizedBox(height: 12),
          Text(
            report.description,
            style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}

class _MoveItem extends StatelessWidget {
  final MoveRecommendation recommendation;

  const _MoveItem({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(width: 4, height: 40, color: AppColors.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${recommendation.sourcePokemonName} → ${recommendation.targetPokemonName}',
                  style: AppTypography.labelSmall,
                ),
                Text(
                  recommendation.moveName,
                  style: AppTypography.headlineSmall.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                recommendation.damageRange,
                style: AppTypography.labelLarge.copyWith(
                  color: recommendation.isKoChance
                      ? AppColors.primary
                      : AppColors.outline,
                ),
              ),
              Text(
                'EST. DAMAGE',
                style: AppTypography.labelSmall.copyWith(fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
