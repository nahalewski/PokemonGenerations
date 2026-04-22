import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';

class Fortune500List extends StatelessWidget {
  final List<dynamic> rankings;

  const Fortune500List({super.key, required this.rankings});

  @override
  Widget build(BuildContext context) {
    if (rankings.isEmpty) {
      return const Center(child: Text('COMMUNICATIONS ARCHIVE EMPTY...'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final trainer = rankings[index];
        final isTop3 = index < 3;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  child: Text(
                    '#${index + 1}',
                    style: AppTypography.labelLarge.copyWith(
                      color: isTop3 ? Colors.amber : AppColors.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: trainer['profileImageUrl'] != null 
                    ? NetworkImage(trainer['profileImageUrl']) 
                    : null,
                  child: trainer['profileImageUrl'] == null 
                    ? Text(trainer['username'][0].toUpperCase(), style: const TextStyle(fontSize: 12)) 
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer['username'].toUpperCase(),
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (trainer['job'] != null)
                        Text(
                          trainer['job'].toString().toUpperCase(),
                          style: TextStyle(fontSize: 9, color: AppColors.primary.withOpacity(0.7), letterSpacing: 1),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PD ${trainer['netWorth'].toLocaleString()}',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.secondary),
                    ),
                    const Text('NET WORTH', style: TextStyle(fontSize: 8, color: Colors.white24)),
                  ],
                ),
              ],
            ),
          ).animate().slideX(begin: 0.1, delay: (index * 50).ms).fade(),
        );
      },
    );
  }
}
