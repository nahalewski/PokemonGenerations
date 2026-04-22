import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/game.dart';
import 'game_provider.dart';

class GameSelectionScreen extends ConsumerWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildWarningBanner(),
            Expanded(
              child: _buildGameGrid(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Text(
            'POKÉMON GENERATIONS',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.primary,
              letterSpacing: 2.0,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'SELECT YOUR ACTIVE GAME',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.outline,
              letterSpacing: 2.0,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your selection determines which items, abilities, and natures are available for your Pokémon builds.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildGameGrid(BuildContext context, WidgetRef ref) {
    final games = PokemonGame.allGames;
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _GameCard(
          game: game,
          onTap: () async {
            await ref.read(gameProviderProvider.notifier).selectGame(game);
            if (context.mounted) {
              context.go('/');
            }
          },
        ).animate().fadeIn(delay: (800 + (index * 50)).ms).scale(begin: const Offset(0.9, 0.9));
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  final PokemonGame game;
  final VoidCallback onTap;

  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _getGenerationColor(game.generation);

    return GlassCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'GEN ${game.generation}',
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              game.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              game.regions.join(', '),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.outline,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGenerationColor(int gen) {
    switch (gen) {
      case 1: return Colors.red;
      case 2: return Colors.amber;
      case 3: return Colors.green;
      case 4: return Colors.blue;
      case 5: return Colors.grey;
      case 6: return Colors.pink;
      case 7: return Colors.orange;
      case 8: return Colors.cyan;
      case 9: return Colors.deepPurple;
      default: return AppColors.primary;
    }
  }
}
