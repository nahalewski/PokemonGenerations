import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.borderRadius,
    this.onTap,
    this.margin,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              child: Container(
                width: width,
                height: height,
                alignment: alignment,
                padding: padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color ?? AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                  borderRadius: borderRadius ?? BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor ?? AppColors.outlineVariant.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
