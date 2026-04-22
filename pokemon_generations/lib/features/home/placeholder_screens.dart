import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/futuristic_ui_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CenterComingSoonScreen extends StatelessWidget {
  const CenterComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Technical Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/battle/battle_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, 'MEDICAL SERVICES', Icons.settings_backup_restore_outlined),
                  const SizedBox(height: 32),
                  
                  // Diagnostic Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MEDICAL DIAGNOSTIC',
                              style: AppTypography.displaySmall.copyWith(fontSize: 32),
                            ),
                            const Text(
                              'REAL-TIME BIOMETRICS // TERMINAL 01',
                              style: TextStyle(letterSpacing: 2, fontSize: 10, color: AppColors.outline),
                            ),
                            const SizedBox(height: 24),
                            FuturisticGlassCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const DiagnosticGauge(
                                    label: 'Party Integrity',
                                    value: 0.94,
                                    secondaryLabel: '94%',
                                  ),
                                  const SizedBox(height: 24),
                                  _buildAlertTile('Arcanine: Paralyzed', AppColors.primary),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 6,
                        child: _buildComingSoonOverlay('Pokemon Center Logic In Development'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Procedures Bento Grid
                  _buildBentoSection(
                    title: 'PROCEDURES & INFUSIONS',
                    tiles: [
                      _buildBentoTile('Full Heal Protocol', 'Restore party integrity', Icons.healing, AppColors.primary),
                      _buildBentoTile('PP Restore', 'Recharge move energy', Icons.bolt, AppColors.secondary),
                      _buildBentoTile('Status Cleanse', 'Remove biological anomalies', Icons.clean_hands, AppColors.tertiary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(title, style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.outline),
        ),
      ],
    );
  }

  Widget _buildAlertTile(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 16),
          const SizedBox(width: 12),
          Text(
            text.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoSection({required String title, required List<Widget> tiles}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headlineSmall),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: tiles,
        ),
      ],
    );
  }

  Widget _buildBentoTile(String title, String subtitle, IconData icon, Color color) {
    return SizedBox(
      width: 200,
      height: 180,
      child: BentoTile(
        title: title,
        subtitle: subtitle,
        icon: icon,
        color: color,
        onTap: () {},
      ),
    );
  }

  Widget _buildComingSoonOverlay(String message) {
    return FuturisticGlassCard(
      padding: const EdgeInsets.all(40),
      borderColor: AppColors.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_clock_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'COMING SOON',
              style: AppTypography.displayLarge.copyWith(color: AppColors.primary, fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              message.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(letterSpacing: 1, fontSize: 10, color: AppColors.outline),
            ),
          ],
        ),
      ),
    ).animate().shake(duration: 500.ms, hz: 4);
  }
}

class MartComingSoonScreen extends StatelessWidget {
  const MartComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.05, child: Image.asset('assets/battle/battle_bg.png', fit: BoxFit.cover))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, 'SUPPLY REQUISITION', Icons.shopping_cart_outlined),
                  const SizedBox(height: 32),
                  Text('LOGISTIC SUPPORT', style: AppTypography.displaySmall.copyWith(fontSize: 48)),
                  const Text('MODULE // TERMINAL 04', style: TextStyle(letterSpacing: 4, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 48),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildItemCard('Ultra Ball', 'Capture Tech', '800 ₽', Icons.catching_pokemon, AppColors.tertiary),
                            _buildItemCard('Max Potion', 'Recovery Core', '2,500 ₽', Icons.vaccines, AppColors.secondary),
                            _buildItemCard('Rare Candy', 'Class-S Tactical', '4,800 ₽', Icons.star, AppColors.primary),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: _buildComingSoonOverlay('Poké Mart System Integration In Progress'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Text(title, style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
          ],
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.outline)),
      ],
    );
  }

  Widget _buildItemCard(String name, String cat, String price, IconData icon, Color color) {
    return SizedBox(
      width: 240,
      child: FuturisticGlassCard(
        borderColor: color.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cat.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Icon(icon, color: color.withValues(alpha: 0.3)),
              ],
            ),
            const SizedBox(height: 12),
            Text(name, style: AppTypography.headlineSmall),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRICE', style: TextStyle(fontSize: 8, color: AppColors.outline)),
                    Text(price, style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                  child: const Text('ADD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonOverlay(String message) {
    return FuturisticGlassCard(
      padding: const EdgeInsets.all(32),
      borderColor: AppColors.secondary,
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.construction, size: 48, color: AppColors.secondary),
            const SizedBox(height: 24),
            Text('COMING SOON', style: AppTypography.headlineSmall.copyWith(color: AppColors.secondary)),
            const SizedBox(height: 12),
            Text(message.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.outline, letterSpacing: 1)),
          ],
        ),
      ),
    ).animate().shimmer(duration: 2.seconds);
  }
}

class PokedexComingSoonScreen extends StatelessWidget {
  const PokedexComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.1, child: Image.asset('assets/battle/battle_bg.png', fit: BoxFit.cover))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, 'DEXTEL V1.0 // REGISTRY', Icons.library_books_outlined),
                  const SizedBox(height: 48),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        flex: 5,
                        child: Center(
                          child: Icon(Icons.catching_pokemon, size: 280, color: AppColors.primary),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('#150', style: AppTypography.labelLarge.copyWith(color: AppColors.primary, letterSpacing: 4)),
                            Text('MEWTWO', style: AppTypography.displayLarge.copyWith(fontSize: 80, height: 1)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildTypeTag('PSYCHIC', AppColors.secondary),
                                const SizedBox(width: 8),
                                _buildTypeTag('ELITE-CLASS', AppColors.primary),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Genetic anomaly detected. Highly unstable synaptic patterns. Neural output exceeds standard analytical capacity.',
                              style: TextStyle(color: AppColors.outline, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 64),
                  Center(child: _buildComingSoonBanner('Pokédex Telemetry Calibration In Progress')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Text(title, style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
          ],
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.outline)),
      ],
    );
  }

  Widget _buildTypeTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildComingSoonBanner(String message) {
    return FuturisticGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      borderColor: AppColors.primary,
      child: Column(
        children: [
          Text('COMING SOON', style: AppTypography.displaySmall.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(message.toUpperCase(), style: const TextStyle(color: AppColors.outline, fontSize: 11, letterSpacing: 2)),
        ],
      ),
    ).animate().fade(duration: 500.ms).slide(begin: const Offset(0, 0.5)).scale();
  }
}
