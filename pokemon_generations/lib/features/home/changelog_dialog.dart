import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/changelog_service.dart';

Future<void> showChangelogDialog(
  BuildContext context, {
  required ChangelogInfo changelog,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        'Pokemon Generations ${changelog.versionLabel}',
        style: AppTypography.headlineSmall,
      ),
      content: GlassCard(
        color: AppColors.surfaceContainerHighest,
        borderColor: AppColors.primary.withValues(alpha: 0.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              changelog.title,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(changelog.message, style: AppTypography.bodyMedium),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Let’s Battle'),
        ),
      ],
    ),
  );
}
