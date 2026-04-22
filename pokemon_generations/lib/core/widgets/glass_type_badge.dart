import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/type_chart.dart';

class GlassTypeBadge extends StatelessWidget {
  final String type;
  final double fontSize;

  const GlassTypeBadge({
    super.key,
    required this.type,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        type.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire': return const Color(0xFFFF4422);
      case 'water': return const Color(0xFF3399FF);
      case 'grass': return const Color(0xFF77CC55);
      case 'electric': return const Color(0xFFFFCC33);
      case 'ice': return const Color(0xFF66CCFF);
      case 'fighting': return const Color(0xFFBB5544);
      case 'poison': return const Color(0xFFAA5599);
      case 'ground': return const Color(0xFFDDBB55);
      case 'flying': return const Color(0xFF8899FF);
      case 'psychic': return const Color(0xFFFF5599);
      case 'bug': return const Color(0xFFAABB22);
      case 'rock': return const Color(0xFFBBAA66);
      case 'ghost': return const Color(0xFF6666BB);
      case 'dragon': return const Color(0xFF7766EE);
      case 'dark': return const Color(0xFF775544);
      case 'steel': return const Color(0xFFAAAABB);
      case 'fairy': return const Color(0xFFEE99EE);
      default: return AppColors.outline;
    }
  }
}
