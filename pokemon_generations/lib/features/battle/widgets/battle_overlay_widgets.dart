import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../domain/models/pokemon.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';

import '../../../core/constants/item_registry.dart';

class BagSelectionModal extends StatelessWidget {
  final Map<String, int> inventory;
  final Function(String) onItemSelected;

  const BagSelectionModal({
    super.key,
    required this.inventory,
    required this.onItemSelected,
  });

  MasterItem? _findItem(String id) {
    try {
      return pokemonItemRegistry.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = inventory.entries.where((e) => e.value > 0).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BAG', style: AppTypography.displaySmall.copyWith(color: AppColors.primary)),
          const SizedBox(height: 24),
          if (items.isEmpty)
            const Center(child: Text('Your bag is empty!'))
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final itemEntry = items[index];
                  final itemMeta = _findItem(itemEntry.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      onTap: () => onItemSelected(itemEntry.key),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset(
                              itemMeta?.spritePath ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (context, _, __) => Icon(
                                itemMeta?.icon ?? Icons.auto_awesome,
                                color: itemMeta?.color ?? Colors.purpleAccent,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              itemMeta?.name.toUpperCase() ?? itemEntry.key.toUpperCase(),
                              style: AppTypography.headlineSmall,
                            ),
                          ),
                          Text('x${itemEntry.value}', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class PokemonSelectionModal extends StatelessWidget {
  final List<Pokemon> team;
  final Pokemon activePokemon;
  final Map<String, int> hpMap;
  final Map<String, int> maxHpMap;
  final Function(Pokemon) onPokemonSelected;
  final bool allowActive;
  final bool allowFainted;
  final String? title;

  const PokemonSelectionModal({
    super.key,
    required this.team,
    required this.activePokemon,
    required this.hpMap,
    required this.maxHpMap,
    required this.onPokemonSelected,
    this.allowActive = false,
    this.allowFainted = false,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title ?? 'POKEMON', style: AppTypography.displaySmall.copyWith(color: AppColors.secondary)),
          const SizedBox(height: 24),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: team.length,
              itemBuilder: (context, index) {
                final pokemon = team[index];
                final isActive = pokemon.id == activePokemon.id;
                final currentHp = hpMap[pokemon.id] ?? 0;
                final maxHp = maxHpMap[pokemon.id] ?? 1;
                final isFainted = currentHp <= 0;
                final hpPercent = (currentHp / maxHp).clamp(0.0, 1.0);
                final hpColor = hpPercent > 0.5
                    ? Colors.greenAccent
                    : hpPercent > 0.2
                        ? Colors.yellowAccent
                        : Colors.redAccent;

                final canSelect = (allowActive || !isActive) && (allowFainted || !isFainted);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: (isFainted && !allowFainted) ? 0.45 : 1.0,
                    child: GlassCard(
                      onTap: !canSelect ? null : () => onPokemonSelected(pokemon),
                      padding: const EdgeInsets.all(12),
                      color: isActive ? Colors.white10 : null,
                      child: Row(
                        children: [
                          // Sprite
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CachedNetworkImage(
                              imageUrl: pokemon.frontSpriteUrl,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                              placeholder: (_, __) => const Center(
                                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Text(
                                  pokemon.name[0].toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(pokemon.name.toUpperCase(), style: AppTypography.headlineSmall),
                                    if (isFainted) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('FAINTED', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text('HP', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: hpPercent,
                                          backgroundColor: Colors.grey[800],
                                          valueColor: AlwaysStoppedAnimation(hpColor),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$currentHp/$maxHp',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.catching_pokemon, color: AppColors.secondary, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
