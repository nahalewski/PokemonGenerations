import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text('CHANGE LOG', style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/CHANGELOG.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error loading changelog: ${snapshot.error}'));
          }

          final content = snapshot.data ?? 'No changelog found.';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VERSION HISTORY',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      content,
                      style: AppTypography.bodySmall.copyWith(
                        fontFamily: 'Courier',
                        height: 1.6,
                        color: AppColors.onSurface.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
