import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pokemon_sprite.dart';
import '../../core/widgets/futuristic_ui_utils.dart';
import '../../core/widgets/glass_type_badge.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/pokemon.dart';
import 'pokedex_detail_screen.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Pokemon> _allPokemon = [];
  List<Pokemon> _filteredPokemon = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    try {
      final results = await ref.read(apiClientProvider.notifier).searchPokemon('');
      if (mounted) {
        setState(() {
          _allPokemon = results;
          _filteredPokemon = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPokemon = _allPokemon;
      } else {
        final queryLower = query.toLowerCase();
        _filteredPokemon = _allPokemon
            .where((p) =>
                p.name.toLowerCase().contains(queryLower) ||
                p.id.toString() == query)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Technical Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/battle/battle_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildSearchSection(),
                if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                else
                  Expanded(
                    child: _filteredPokemon.isEmpty
                        ? _buildNoResults()
                        : (_isGridView ? _buildPokemonGrid() : _buildPokemonList()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.library_books_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'DEXTEL V1.0 // REGISTRY',
                style: AppTypography.labelLarge.copyWith(letterSpacing: 2),
              ),
            ],
          ),
          Row(
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.view_module),
                    label: Text('GRID'),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.view_list),
                    label: Text('LIST'),
                  ),
                ],
                selected: {_isGridView},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() => _isGridView = newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary.withOpacity(0.2);
                      }
                      return Colors.transparent;
                    },
                  ),
                  side: const WidgetStatePropertyAll(
                    BorderSide(color: AppColors.primary, width: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: AppColors.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'SEARCH NATIONAL DEX...',
          hintStyle: TextStyle(
            color: AppColors.outline.withValues(alpha: 0.5),
            letterSpacing: 1.5,
            fontSize: 12,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'NO MATCHES FOUND',
            style: AppTypography.labelLarge.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1400) {
          crossAxisCount = 8;
        } else if (constraints.maxWidth > 1100) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth > 500) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: _filteredPokemon.length,
          itemBuilder: (context, index) {
            final pokemon = _filteredPokemon[index];
            return _PokemonGridTile(pokemon: pokemon)
                .animate()
                .fade(delay: (index % 10 * 50).ms, duration: 400.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutQuad);
          },
        );
      },
    );
  }

  Widget _buildPokemonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _filteredPokemon.length,
      itemBuilder: (context, index) {
        final pokemon = _filteredPokemon[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PokemonListTile(pokemon: pokemon)
              .animate()
              .fade(delay: (index % 10 * 50).ms, duration: 400.ms)
              .slideX(begin: 0.1, curve: Curves.easeOutQuad),
        );
      },
    );
  }
}

class _PokemonGridTile extends StatelessWidget {
  final Pokemon pokemon;

  const _PokemonGridTile({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return FuturisticGlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      borderColor: AppColors.primary.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Hero(
                  tag: 'pokedex_${pokemon.id}',
                  child: PokemonSprite(
                    pokemonId: pokemon.id,
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#${pokemon.id.padLeft(3, '0')}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pokemon.name.toUpperCase(),
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    context.push('/pokedex/${pokemon.id}');
  }
}

class _PokemonListTile extends StatelessWidget {
  final Pokemon pokemon;

  const _PokemonListTile({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return FuturisticGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 16,
      borderColor: AppColors.primary.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Hero(
              tag: 'pokedex_${pokemon.id}',
              child: PokemonSprite(
                pokemonId: pokemon.id,
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${pokemon.id.padLeft(3, '0')}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    pokemon.name.toUpperCase(),
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              children: pokemon.types
                  .map((type) => GlassTypeBadge(type: type, fontSize: 10))
                  .toList(),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    context.push('/pokedex/${pokemon.id}');
  }
}
