import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pokemon_sprite.dart';
import '../../../domain/models/pokemon_form.dart';

class BattleClashScene extends StatelessWidget {
  final List<PokemonForm> roster;
  final List<PokemonForm> opponentTeam;

  const BattleClashScene({
    super.key,
    required this.roster,
    required this.opponentTeam,
  });

  @override
  Widget build(BuildContext context) {
    if (roster.isEmpty || opponentTeam.isEmpty) return const SizedBox.shrink();

    final myLead = roster.first;
    final opLead = opponentTeam.first;

    return Container(
      color: AppColors.surface.withOpacity(0.9),
      child: Stack(
        children: [
          // Background "Energy" Grid
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2.seconds, color: AppColors.primary.withOpacity(0.1)),

          // Team Roster (Left)
          Align(
            alignment: const Alignment(-1.5, 0),
            child: _buildTeamColumn(roster, true),
          ).animate()
            .moveX(begin: 0, end: 300, duration: 800.ms, curve: Curves.easeInBack)
            .then()
            .moveX(begin: 0, end: -300, duration: 400.ms, curve: Curves.elasticOut),

          // Opponent Team (Right)
          Align(
            alignment: const Alignment(1.5, 0),
            child: _buildTeamColumn(opponentTeam, false),
          ).animate()
            .moveX(begin: 0, end: -300, duration: 800.ms, curve: Curves.easeInBack)
            .then()
            .moveX(begin: 0, end: 300, duration: 400.ms, curve: Curves.elasticOut),

          // Impact Flash
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ).animate()
            .hide()
            .then(delay: 800.ms)
            .show()
            .scale(begin: const Offset(0, 0), end: const Offset(15, 15), duration: 200.ms, curve: Curves.easeOut)
            .fadeOut(duration: 400.ms),

          // Simulation Text
          Align(
            alignment: const Alignment(0, 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RUNNING TELMETRY SIMULATION',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.primary, letterSpacing: 3),
                ).animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1.5.seconds),
                const SizedBox(height: 8),
                Text(
                  '${myLead.pokemonName} vs ${opLead.pokemonName}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 1.seconds),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(List<PokemonForm> team, bool isLeft) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: team.take(3).map((p) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: PokemonSprite(
          pokemonId: p.pokemonId,
          width: 80,
          height: 80,
        ),
      )).toList(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = 0; i <= size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
