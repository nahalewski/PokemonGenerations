import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/emoji_service.dart';

class EmojiLookupOverlay extends StatelessWidget {
  final String query;
  final Function(String) onEmojiSelected;

  const EmojiLookupOverlay({
    super.key,
    required this.query,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = EmojiService.searchEmojis(query);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 250),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final emoji = suggestions[index];
              final assetPath = EmojiService.getAssetPath(emoji);

              return ListTile(
                dense: true,
                leading: assetPath != null 
                    ? Image.asset(assetPath, width: 24, height: 24)
                    : const Icon(Icons.help_outline, size: 20),
                title: Text(
                  emoji.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(color: Colors.white),
                ),
                onTap: () => onEmojiSelected(emoji),
                hoverColor: AppColors.primary.withOpacity(0.2),
              );
            },
          ),
        ),
      ),
    );
  }
}
