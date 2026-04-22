import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

class BattleTowerScreen extends StatelessWidget {
  const BattleTowerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/home_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fort_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'BATTLE TOWER',
                    style: AppTypography.displayLarge.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'THE ULTIMATE CHALLENGE',
                    style: AppTypography.labelLarge.copyWith(letterSpacing: 4),
                  ),
                  const SizedBox(height: 48),
                  const GlassCard(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text(
                          'COMING SOON',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 24),
                        _ModeInfo(
                          title: 'ROGUE-LIKE MODE',
                          description: 'Climb the tower with a limited roster. Pick upgrades and heal your team between floors.',
                        ),
                        SizedBox(height: 20),
                        _ModeInfo(
                          title: 'ENDLESS CHALLENGE',
                          description: 'How long can you survive against increasingly difficult CPU teams?',
                        ),
                        SizedBox(height: 20),
                        _ModeInfo(
                          title: 'EXCLUSIVE REWARDS',
                          description: 'Earn rare items and shiny tokens for your victories.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text('BACK TO HOME'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeInfo extends StatelessWidget {
  final String title;
  final String description;

  const _ModeInfo({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
