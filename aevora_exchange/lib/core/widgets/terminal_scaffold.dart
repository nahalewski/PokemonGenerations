import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/theme_provider.dart';
import 'scanline_overlay.dart';

class TerminalScaffold extends ConsumerWidget {
  final Widget body;
  final String title;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TerminalScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final accentColor =
        isDark ? AppColors.primary : AppColors.primaryDim;

    return Scaffold(
      appBar: _buildAppBar(context, ref, isDark, accentColor),
      body: Stack(
        children: [
          body
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.04, curve: Curves.easeOut),
          if (isDark) const ScanlineOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark, accentColor),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, bool isDark, Color accentColor) {
    return AppBar(
      backgroundColor:
          isDark ? Colors.black.withOpacity(0.9) : Colors.white,
      elevation: isDark ? 0 : 1,
      title: Text(
        title.toUpperCase(),
        style: AppTypography.textTheme.headlineSmall?.copyWith(
          color: accentColor,
          letterSpacing: -0.5,
          fontSize: 15,
        ),
      ),
      actions: [
        // Light / dark toggle
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: accentColor,
            size: 20,
          ),
          tooltip: isDark ? 'Light mode' : 'Dark mode',
          onPressed: () =>
              ref.read(themeModeProvider.notifier).toggle(),
        ),
        _buildSyncChip(isDark, accentColor),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildSyncChip(bool isDark, Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: accentColor),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                  begin: 0.6,
                  end: 1.4,
                  duration: 900.ms,
                  curve: Curves.easeInOut)
              .then()
              .scaleXY(begin: 1.4, end: 0.6),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: TextStyle(
              color: accentColor,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.surfaceContainerHighest : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTabSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: accentColor,
        unselectedItemColor: isDark ? Colors.white24 : Colors.black38,
        selectedLabelStyle: const TextStyle(
            fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 9),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart, size: 22), label: 'MARKET'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet, size: 22),
              label: 'BANK'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart, size: 22), label: 'PORTFOLIO'),
          BottomNavigationBarItem(
              icon: Icon(Icons.badge_outlined, size: 22),
              label: 'CLASSIFIED'),
          BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline, size: 22), label: 'MAILBOX'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined, size: 22),
              label: 'PROFILE'),
        ],
      ),
    );
  }
}
