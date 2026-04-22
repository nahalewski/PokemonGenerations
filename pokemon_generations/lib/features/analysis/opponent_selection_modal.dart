import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/pokemon.dart';
import '../../domain/models/pokemon_form.dart';
import '../roster/add_pokemon_screen.dart';
import 'matchup_provider.dart';
import '../../core/widgets/pokemon_sprite.dart';

import '../../core/utils/region_utils.dart';

class OpponentSelectionModal extends ConsumerStatefulWidget {
  const OpponentSelectionModal({super.key});

  @override
  ConsumerState<OpponentSelectionModal> createState() => _OpponentSelectionModalState();
}

class _OpponentSelectionModalState extends ConsumerState<OpponentSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Pokemon> _searchResults = [];
  Map<String, List<Pokemon>> _groupedResults = {};

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  bool _isSearching = false;

  void _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await ref.read(apiClientProvider.notifier).searchPokemon(query);
      
      // Group results by region
      final grouped = <String, List<Pokemon>>{};
      for (final p in results) {
        final region = RegionUtils.getRegionName(p.id);
        grouped.putIfAbsent(region, () => []).add(p);
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _groupedResults = grouped;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _groupedResults = {};
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the list of regions that actually have results
    final sortedRegions = RegionUtils.regionsOrdered
        .where((r) => _groupedResults.containsKey(r))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search Opponent Pokémon...',
                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          if (_isSearching)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ))
          else if (_searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: AppColors.outline.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty 
                        ? 'Loading Pokémon Database...' 
                        : 'No Pokémon found for "${_searchController.text}"',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: sortedRegions.length,
                itemBuilder: (context, regionIndex) {
                  final region = sortedRegions[regionIndex];
                  final pokemonList = _groupedResults[region]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              region.toUpperCase(),
                              style: AppTypography.labelLarge.copyWith(color: AppColors.secondary, letterSpacing: 2),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Divider(color: AppColors.secondary.withValues(alpha: 0.2))),
                          ],
                        ),
                      ),
                      ...pokemonList.map((pokemon) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          onTap: () => _selectPokemon(pokemon),
                          child: Row(
                            children: [
                              PokemonSprite(
                                pokemonId: pokemon.id,
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 16),
                              Text(pokemon.name, style: AppTypography.bodyLarge),
                              const Spacer(),
                              const Icon(Icons.add, color: AppColors.primary),
                            ],
                          ),
                        ),
                      )).toList(),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  void _selectPokemon(Pokemon pokemon) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPokemonScreen(
          isOpponent: true,
          initialPokemon: pokemon,
        ),
      ),
    );
  }
}
