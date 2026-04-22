import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/type_chart.dart';
import '../../../domain/models/pokemon_form.dart';
import '../../../data/services/api_client.dart';

class TypeCoverageMatrix extends ConsumerWidget {
  final List<PokemonForm> team;
  final String title;
  final bool isOffensive;

  const TypeCoverageMatrix({
    super.key,
    required this.team,
    this.title = 'DEFENSIVE COVERAGE',
    this.isOffensive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (team.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<PokemonType, int>>(
      future: _calculateCoverage(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final coverage = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2)),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: PokemonType.values.length,
              itemBuilder: (context, index) {
                final type = PokemonType.values[index];
                final score = coverage[type] ?? 0;
                return _buildTypeCell(type, score);
              },
            ),
          ],
        );
      }
    );
  }

  Future<Map<PokemonType, int>> _calculateCoverage(WidgetRef ref) async {
    final Map<PokemonType, int> coverage = {};
    final apiClient = ref.read(apiClientProvider.notifier);
    
    // 1. Fetch Types/Moves for all members
    final List<List<PokemonType>> teamTypeData = [];
    final List<List<PokemonType>> teamMoveTypes = [];

    for (final p in team) {
      final detail = await apiClient.getPokemonDetail(p.pokemonId);
      if (detail != null) {
        final types = detail.types.map((t) => TypeChart.stringToType(t)).toList();
        teamTypeData.add(types);
        
        if (isOffensive) {
          final moveTypes = <PokemonType>{};
          // Add STAB
          moveTypes.addAll(types);
          // Add Actual Moves
          for (final moveName in p.moves) {
            if (moveName == 'None' || moveName.isEmpty) continue;
            final mDetail = await apiClient.getMoveDetail(moveName);
            if (mDetail != null) moveTypes.add(TypeChart.stringToType(mDetail.type));
          }
          teamMoveTypes.add(moveTypes.toList());
        }
      }
    }

    // 2. Calculate based on mode
    for (final type in PokemonType.values) {
      int score = 0;
      
      if (isOffensive) {
        // How many members can hit this type super effectively?
        for (final moves in teamMoveTypes) {
          bool canBreak = false;
          for (final mType in moves) {
            if (TypeChart.getEffectiveness(mType, [type]) > 1.0) {
              canBreak = true;
              break;
            }
          }
          if (canBreak) score += 1;
        }
      } else {
        // Defensive: Sum of resistances/weaknesses
        for (final tData in teamTypeData) {
          final eff = TypeChart.getEffectiveness(type, tData);
          if (eff > 1.0) score -= 1;
          if (eff < 1.0) score += 1;
          if (eff == 0.0) score += 1;
        }
      }
      coverage[type] = score;
    }
    
    return coverage;
  }

  Widget _buildTypeCell(PokemonType type, int score) {
    Color statusColor;
    String statusText;
    
    if (isOffensive) {
      if (score > 2) {
        statusColor = Colors.cyanAccent;
        statusText = 'ADAPT';
      } else if (score > 0) {
        statusColor = Colors.greenAccent;
        statusText = 'BREAK';
      } else {
        statusColor = AppColors.error;
        statusText = 'WALL';
      }
    } else {
      if (score < 0) {
        statusColor = AppColors.error;
        statusText = 'WEAK';
      } else if (score > 1) {
        statusColor = Colors.cyanAccent;
        statusText = 'STRONG';
      } else if (score > 0) {
        statusColor = Colors.greenAccent;
        statusText = 'COVRD';
      } else {
        statusColor = AppColors.outline;
        statusText = 'NEUTR';
      }
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderColor: statusColor.withValues(alpha: 0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type.toString().split('.').last.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.outline,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: AppTypography.labelMedium.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              Text(
                score > 0 ? '+$score' : '$score',
                style: AppTypography.labelMedium.copyWith(
                  color: statusColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return isOffensive 
      ? Row(
          children: [
            _legendItem('Break', Colors.greenAccent),
            const SizedBox(width: 8),
            _legendItem('Wall', AppColors.error),
          ],
        )
      : Row(
          children: [
            _legendItem('Weak', AppColors.error),
            const SizedBox(width: 8),
            _legendItem('Resistance', Colors.greenAccent),
          ],
        );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
      ],
    );
  }
}
