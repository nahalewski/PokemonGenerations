import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pokemon_sprite.dart';
import '../auth/auth_controller.dart';
import '../roster/roster_provider.dart';
import '../inventory/inventory_provider.dart';
import '../social/social_controller.dart';
import '../social/social_state.dart';
import '../../domain/models/social.dart';
import '../../core/constants/item_registry.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/currency_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final rosterAsync = ref.watch(rosterProvider);
    final inventory = ref.watch(inventoryProvider);
    final socialState = ref.watch(socialControllerProvider);
    final profile = authState.profile;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PROFILE')),
        body: const Center(child: Text('No active profile found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text('PLAYER PROFILE', style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identity Section
              _buildHeader(
                profile.firstName,
                profile.lastName,
                profile.username,
                profile.profileImageUrl,
                profile.pokedollars,
                profile.createdAt,
              ),
              const SizedBox(height: 32),

              // Inventory Section
              _buildSectionHeader('BAG INVENTORY', Icons.inventory_2_outlined),
              const SizedBox(height: 16),
              _buildInventoryPreview(context, inventory),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/gift'),
                  icon: const Icon(Icons.card_giftcard, size: 18),
                  label: const Text('OPEN GIFT CENTER'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Roster Section
              _buildSectionHeader(
                'ACTIVE SQUAD',
                Icons.catching_pokemon_outlined,
              ),
              const SizedBox(height: 16),
              _buildRosterList(rosterAsync),

              const SizedBox(height: 32),
              _buildSectionHeader('ACHIEVEMENTS', Icons.emoji_events_outlined),
              const SizedBox(height: 16),
              _buildAchievementGrid(profile.achievements),

              const SizedBox(height: 32),
              _buildSectionHeader('FOR SALE BASKET', Icons.shopping_basket_outlined),
              const SizedBox(height: 16),
              _buildMarketplaceBasket(profile.forSaleItems),

              const SizedBox(height: 48),
              _buildStatsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String first, String last, String username, String? profileImageUrl, int pokedollars, DateTime? createdAt) {
    final isCEO = username.toLowerCase() == 'bn200n';
    
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: isCEO ? Colors.amber.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                    backgroundImage: profileImageUrl != null 
                      ? CachedNetworkImageProvider(profileImageUrl) 
                      : null,
                    child: profileImageUrl == null ? Text(
                      first.isNotEmpty ? first[0].toUpperCase() : '?',
                      style: AppTypography.displaySmall.copyWith(
                        color: isCEO ? Colors.amber : AppColors.primary,
                      ),
                    ) : null,
                  ),
                  if (isCEO)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars, color: Colors.black, size: 16),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$first $last'.toUpperCase(),
                          style: AppTypography.headlineMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isCEO) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: AppColors.primary, size: 20),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildAnniversaryTag(createdAt),
                  ],
                ),
              ),
              _buildBalanceIndicator(pokedollars),
            ],
          ),
          if (isCEO) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.withOpacity(0.2), Colors.transparent],
                ),
                border: const Border(left: BorderSide(color: Colors.amber, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CEO of Silph Co.',
                    style: AppTypography.labelLarge.copyWith(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '"Engineering the Future of Every Generation."',
                    style: TextStyle(fontSize: 10, color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceIndicator(int pokedollars) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
          const SizedBox(height: 4),
          Text(
            'PD ${pokedollars.toLocaleString()}',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildAnniversaryTag(DateTime? createdAt) {
    if (createdAt == null) return const SizedBox.shrink();
    
    final diff = DateTime.now().difference(createdAt);
    String age = '';
    if (diff.inDays >= 365) {
      age = '${(diff.inDays / 365).floor()}Y ';
    }
    if ((diff.inDays % 365) >= 30) {
      age += '${((diff.inDays % 365) / 30).floor()}M ';
    }
    age += '${diff.inDays % 30}D ON SITE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        age.toUpperCase(),
        style: const TextStyle(fontSize: 8, color: Colors.white60, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.outline,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryPreview(BuildContext context, Map<String, int> inventory) {
    final ownedItems = inventory.entries.where((e) => e.value > 0).take(4).toList();

    return GestureDetector(
      onTap: () => context.push('/profile/inventory'),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (ownedItems.isEmpty)
              const Center(child: Text('Your bag is empty.', style: TextStyle(color: AppColors.outline)))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ownedItems.map((e) {
                  final item = pokemonItemRegistry.firstWhere(
                    (i) => i.id == e.key,
                    orElse: () => MasterItem(
                      id: e.key,
                      name: e.key,
                      description: '',
                      category: 'Other',
                      icon: Icons.help_outline,
                      color: Colors.grey,
                    ),
                  );
                  return Column(
                    children: [
                      Icon(item.icon, color: item.color, size: 24),
                      const SizedBox(height: 4),
                      Text('x${e.value}', style: AppTypography.labelSmall),
                    ],
                  );
                }).toList(),
              ),
            const Divider(height: 32, color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('VIEW FULL INVENTORY', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList(List<SocialUser> friends) {
    if (friends.isEmpty) {
      return const Text('No friends added yet. Visit the Social tab to find trainers!', style: TextStyle(fontSize: 12, color: AppColors.outline));
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: friend.displayName,
              child: Badge(
                backgroundColor: friend.status == 'online' ? Colors.green : Colors.grey,
                child: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(friend.username[0].toUpperCase()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRosterList(AsyncValue rosterAsync) {
    return rosterAsync.when(
      data: (roster) => Column(
        children: roster
            .map<Widget>(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: PokemonSprite(
                            pokemonId: p.pokemonId,
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (p.pokemonName ?? p.pokemonId).toUpperCase(),
                              style: AppTypography.bodyLarge,
                            ),
                            Text(
                              'Lv. ${p.level} • ${p.ability}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.outlineVariant,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading squad'),
    );
  }

  Widget _buildStatsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      color: AppColors.secondary.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('BATLES', '12'),
          _buildStatItem('WIN RATE', '75%'),
          _buildStatItem('TOP PIK', 'Pikachu'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.outline),
        ),
      ],
    );
  }

  Widget _buildAchievementGrid(List<String> achievements) {
    // Mapping of Achievement Slugs to Visual Meta
    final Map<String, dynamic> milestoneMeta = {
      'silph-visionary': {'icon': Icons.account_balance, 'color': Colors.amber, 'label': 'Silph Visionary'},
      'diamond-hands': {'icon': Icons.diamond, 'color': Colors.cyan, 'label': 'Diamond Hands'},
      'market-maker': {'icon': Icons.storefront, 'color': Colors.orange, 'label': 'Market Maker'},
      'roster-legend': {'icon': Icons.military_tech, 'color': Colors.purple, 'label': 'Roster Legend'},
      'cpu-slayer': {'icon': Icons.bolt, 'color': Colors.red, 'label': 'CPU Slayer'},
      'archaeologist': {'icon': Icons.bug_report, 'color': Colors.green, 'label': 'Archaeologist'},
      'founder': {'icon': Icons.history_edu, 'color': Colors.blue, 'label': 'Aevora Veteran'},
      'crypto-king': {'icon': Icons.currency_bitcoin, 'color': Colors.orange, 'label': 'Crypto King'},
      'senior-debugger': {'icon': Icons.terminal, 'color': Colors.teal, 'label': 'Senior Debugger'},
      'aevora-tycoon': {'icon': Icons.emoji_events, 'color': Colors.amberAccent, 'label': 'Aevora Tycoon'},
      'disciplined-saver': {'icon': Icons.savings, 'color': Colors.pinkAccent, 'label': 'Disciplined Saver'},
      'clutch-victory': {'icon': Icons.heart_broken, 'color': Colors.redAccent, 'label': 'Clutch Victory'},
    };

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 54, // Expanded to 54 slots (9x6) for the 50-item roadmap
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final slug = index < achievements.length ? achievements[index] : null;
          final meta = milestoneMeta[slug];
          final isUnlocked = meta != null;

          return Tooltip(
            message: isUnlocked ? meta['label'] : 'HIDDEN_MILESTONE',
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked ? (meta['color'] as Color).withOpacity(0.1) : Colors.white10,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? (meta['color'] as Color).withOpacity(0.3) : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Icon(
                isUnlocked ? meta['icon'] : Icons.lock_outline,
                size: 16,
                color: isUnlocked ? meta['color'] : Colors.white24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketplaceBasket(List<dynamic> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No items listed for sale.', style: TextStyle(color: Colors.white24))),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Icon(Icons.inventory_2, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(item['name'] ?? 'ITEM', style: AppTypography.labelSmall),
                  Text('${item['price']} PD', style: const TextStyle(fontSize: 10, color: Colors.amber)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
