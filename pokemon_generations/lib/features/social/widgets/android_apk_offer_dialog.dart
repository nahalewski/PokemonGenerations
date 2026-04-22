import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';

class AndroidApkOfferDialog extends StatelessWidget {
  const AndroidApkOfferDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AndroidApkOfferDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.android,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'NATIVE EXPERIENCE',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We detected you are on Android. For the best experience, including background music, haptics, and smoother animations, download our native app.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                   _FeatureItem(icon: Icons.music_note, text: 'Enable Battle Music'),
                   _FeatureItem(icon: Icons.vibration, text: 'Full Haptic Feedback'),
                   _FeatureItem(icon: Icons.bolt, text: 'Faster Animations'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final url = Uri.parse('https://github.com/nahalewski/PokemonGenerations/releases/latest/download/app-release.apk');
                    launchUrl(url, mode: LaunchMode.externalApplication);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('DOWNLOAD APK'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'MAYBE LATER',
                  style: TextStyle(color: AppColors.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.labelMedium.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
