import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/providers.dart';
import '../../domain/models/history.dart';
import 'matchup_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(analysisHistoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text('ANALYSIS HISTORY', style: AppTypography.headlineSmall),
        actions: [
          IconButton(
            onPressed: () => _showClearConfirmation(context, ref),
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 64, color: AppColors.outline.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('NO HISTORY YET', style: AppTypography.labelLarge.copyWith(color: AppColors.outline)),
                  const SizedBox(height: 8),
                  Text('Run a telemetry analysis to start your log.', style: AppTypography.bodyMedium.copyWith(color: AppColors.outline.withValues(alpha: 0.5))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildHistoryCard(context, ref, item),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading history: $e')),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WidgetRef ref, AnalysisHistory item) {
    return GlassCard(
      onTap: () {
        ref.read(matchupProvider.notifier).loadHistoryResult(item);
        context.push('/analysis');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(item.timestamp),
                style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.format,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${item.result.matchupScore.toInt()}%',
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OPPONENT SQUAD',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.outline, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.opponentTeam.map((p) => p.pokemonName ?? 'Unknown').join(', '),
                      style: AppTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear History?'),
        content: const Text('This will permanently delete all saved battle analyses.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ref.read(analysisHistoryNotifierProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('CLEAR ALL', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
