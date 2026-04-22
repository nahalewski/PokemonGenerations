import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? AppColors.surfaceContainerHigh.withOpacity(0.4),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
