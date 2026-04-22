import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/services/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/networking/dio_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

final newsFutureProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final settings = ref.read(appSettingsProvider);
  final baseUrl = settings.resolvedBackendUrl;
  if (baseUrl.isEmpty) return {};
  
  try {
    final response = await ref.read(dioProvider).get('$baseUrl/news');
    return response.data as Map<String, dynamic>;
  } catch (e) {
    print('Error fetching news: $e');
    return {};
  }
});

class HomeNewsSection extends ConsumerStatefulWidget {
  const HomeNewsSection({super.key});

  @override
  ConsumerState<HomeNewsSection> createState() => _HomeNewsSectionState();
}

class _HomeNewsSectionState extends ConsumerState<HomeNewsSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _NewsPageConfig(
      id: 'changelog',
      label: 'CHANGELOG',
      icon: Icons.update,
      color: AppColors.primary,
    ),
    _NewsPageConfig(
      id: 'upcoming',
      label: 'UPCOMING',
      icon: Icons.rocket_launch_outlined,
      color: AppColors.secondary,
    ),
    _NewsPageConfig(
      id: 'features',
      label: 'FEATURES',
      icon: Icons.star_outline,
      color: AppColors.tertiary,
    ),
    _NewsPageConfig(
      id: 'platforms',
      label: 'PLATFORMS',
      icon: Icons.devices_outlined,
      color: Colors.deepPurpleAccent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsFutureProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('NEWS', style: AppTypography.headlineSmall),
            Row(
              children: List.generate(_pages.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tab strip
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _pages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final page = _pages[i];
              final active = i == _currentPage;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? page.color.withOpacity(0.15)
                        : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? page.color : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(page.icon, size: 14, color: active ? page.color : AppColors.outline),
                      const SizedBox(width: 6),
                      Text(
                        page.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: active ? page.color : AppColors.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Page content
        SizedBox(
          height: 280,
          child: newsAsync.when(
            data: (news) => PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _ChangelogPage(data: news['changelog'] ?? {}),
                _UpcomingPage(items: (news['upcoming'] ?? []) as List),
                _FeaturesPage(items: (news['features'] ?? []) as List),
                _PlatformsPage(items: (news['platforms'] ?? []) as List),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Failed to load news: $e')),
          ),
        ),
      ],
    );
  }
}

class _NewsPageConfig {
  const _NewsPageConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String id;
  final String label;
  final IconData icon;
  final Color color;
}

// ── Page: Changelog ───────────────────────────────────────────────────────────

class _ChangelogPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ChangelogPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${data['version']} — ${data['title']}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Text(data['date'] ?? '', style: AppTypography.labelSmall.copyWith(color: AppColors.outline, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 16),
            ...(data['items'] as List? ?? []).map((text) => _BulletItem(
              icon: Icons.bolt,
              text: text,
              color: AppColors.primary,
            )),
          ],
        ),
      ),
    );
  }
}

// ── Page: Upcoming ────────────────────────────────────────────────────────────

class _UpcomingPage extends StatelessWidget {
  final List items;
  const _UpcomingPage({required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ON THE HORIZON', style: AppTypography.labelLarge.copyWith(color: AppColors.secondary)),
            const SizedBox(height: 16),
            ...items.map((text) => _BulletItem(
              icon: Icons.rocket_launch_outlined,
              text: text,
              color: AppColors.secondary,
            )),
          ],
        ),
      ),
    );
  }
}

// ── Page: Current Features ────────────────────────────────────────────────────

class _FeaturesPage extends StatelessWidget {
  final List items;
  const _FeaturesPage({required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LIVE FEATURES', style: AppTypography.labelLarge.copyWith(color: AppColors.tertiary)),
            const SizedBox(height: 16),
            ...items.map((text) => _BulletItem(
              icon: Icons.star_outline,
              text: text,
              color: AppColors.tertiary,
            )),
          ],
        ),
      ),
    );
  }
}

// ── Page: Platforms ───────────────────────────────────────────────────────────

class _PlatformsPage extends StatelessWidget {
  final List items;
  const _PlatformsPage({required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PLATFORM STATUS', style: AppTypography.labelLarge.copyWith(color: Colors.deepPurpleAccent)),
          const SizedBox(height: 16),
          ...items.map((p) {
            final data = p as Map<String, dynamic>;
            final name = data['name'] as String;
            final icon = name.toLowerCase() == 'web' 
                ? Icons.language 
                : (name.toLowerCase() == 'android' ? Icons.android : (name.toLowerCase() == 'ios' ? Icons.apple : Icons.devices));
            final color = name.toLowerCase() == 'web' 
                ? Colors.blueAccent 
                : (name.toLowerCase() == 'android' ? Colors.greenAccent : (name.toLowerCase() == 'ios' ? Colors.white70 : Colors.grey));
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlatformRow(
                platform: '$name — ${data['status']}',
                icon: icon,
                color: color,
                items: (data['details'] as List).cast<String>(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PlatformRow extends StatelessWidget {
  const _PlatformRow({
    required this.platform,
    required this.icon,
    required this.color,
    required this.items,
  });
  final String platform;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(platform, style: AppTypography.labelSmall.copyWith(color: color)),
              const SizedBox(height: 2),
              ...items.map((t) => Text(
                '• $t',
                style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.outline),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared: Bullet item ───────────────────────────────────────────────────────

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
