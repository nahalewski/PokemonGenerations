import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A reusable glassmorphic card with a subtle scanline overlay and backdrop blur.
class FuturisticGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? borderColor;
  final bool showScanlines;

  const FuturisticGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16.0,
    this.borderColor,
    this.showScanlines = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              if (showScanlines)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const AssetImage('assets/battle/battle_bg.png'), // Using bg as pattern
                            repeat: ImageRepeat.repeat,
                            fit: BoxFit.none,
                            opacity: 0.5,
                            colorFilter: ColorFilter.mode(
                              AppColors.primary.withValues(alpha: 0.1),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A technical progress bar with an asymmetric 'diagnostic' look.
class DiagnosticGauge extends StatelessWidget {
  final String label;
  final double value; // 0.0 to 1.0
  final Color color;
  final String? secondaryLabel;

  const DiagnosticGauge({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (secondaryLabel != null)
              Text(
                secondaryLabel!,
                style: AppTypography.headlineSmall.copyWith(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * value,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A bento-style tile for modern grids.
class BentoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const BentoTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FuturisticGlassCard(
        padding: const EdgeInsets.all(20),
        borderColor: color.withValues(alpha: 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.headlineSmall.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
