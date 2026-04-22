import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/pokemon_sprite.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/stat_calculator.dart';
import '../../core/widgets/stat_radar_chart.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/pokemon.dart';
import '../../domain/models/pokemon_form.dart';
import '../../domain/models/move_detail.dart';
import '../analysis/matchup_provider.dart';
import '../game_selection/game_provider.dart';
import 'roster_provider.dart';

class AddPokemonScreen extends ConsumerStatefulWidget {
  final PokemonForm? initialForm;
  final Pokemon? initialPokemon;
  final bool isOpponent;

  const AddPokemonScreen({
    super.key, 
    this.initialForm, 
    this.initialPokemon, 
    this.isOpponent = false
  });

  @override
  ConsumerState<AddPokemonScreen> createState() => _AddPokemonScreenState();
}

class _AddPokemonScreenState extends ConsumerState<AddPokemonScreen> {
  Pokemon? _selectedPokemon;
  final TextEditingController _searchController = TextEditingController();
  List<Pokemon> _searchResults = [];
  bool _isSearching = false;
  bool _isAddingRandom = false;

  static const _kNatures = [
    'Adamant', 'Bashful', 'Bold', 'Brave', 'Calm',
    'Careful', 'Docile', 'Gentle', 'Hardy', 'Hasty',
    'Impish', 'Jolly', 'Lax', 'Lonely', 'Mild',
    'Modest', 'Naive', 'Naughty', 'Quiet', 'Quirky',
    'Rash', 'Relaxed', 'Sassy', 'Serious', 'Timid',
  ];

  static const _kItems = [
    'Choice Band', 'Choice Scarf', 'Choice Specs', 'Life Orb',
    'Leftovers', 'Rocky Helmet', 'Focus Sash', 'Assault Vest',
    'Eviolite', 'Heavy-Duty Boots', 'Black Sludge', 'Lum Berry',
    'Sitrus Berry', 'Weakness Policy', 'Air Balloon', 'Toxic Orb',
    'Flame Orb', 'Expert Belt', 'Scope Lens', 'Wide Lens',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPokemon = widget.initialPokemon;
    if (_selectedPokemon == null && widget.initialForm == null) {
      _performSearch('');
    }
  }

  void _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await ref.read(apiClientProvider.notifier).searchPokemon(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _addRandomPokemon() async {
    if (_isAddingRandom) return;
    setState(() => _isAddingRandom = true);

    try {
      final rng = Random();

      // Use already-loaded search results, fall back to fetching all
      final pool = _searchResults.isNotEmpty
          ? _searchResults
          : await ref.read(apiClientProvider.notifier).searchPokemon('');
      if (pool.isEmpty || !mounted) return;

      final randomBase = pool[rng.nextInt(pool.length)];
      final activeGame = ref.read(gameProviderProvider).valueOrNull;
      final detail = await ref.read(apiClientProvider.notifier)
          .getPokemonDetail(randomBase.id, versionGroupId: activeGame?.versionGroupId);
      if (detail == null || !mounted) return;

      // Random ability
      final ability = detail.abilities.isNotEmpty
          ? detail.abilities[rng.nextInt(detail.abilities.length)]
          : 'Unknown';

      // Random nature
      final nature = _kNatures[rng.nextInt(_kNatures.length)];

      // Random held item
      final item = _kItems[rng.nextInt(_kItems.length)];

      // Random 4 moves from available pool (shuffle + take 4)
      final allMoves = List<String>.from(detail.availableMoves.map((m) => m.name))
        ..shuffle(rng);
      final moves = allMoves.take(4).toList();

      // Random level 50–100
      final level = 50 + rng.nextInt(51);

      // Random EV spread: 252 / 252 / 4 in three random stats
      const statKeys = ['hp', 'atk', 'def', 'spa', 'spd', 'spe'];
      final shuffledStats = List<String>.from(statKeys)..shuffle(rng);
      final evs = {for (final s in statKeys) s: 0};
      evs[shuffledStats[0]] = 252;
      evs[shuffledStats[1]] = 252;
      evs[shuffledStats[2]] = 4;

      // Random IVs 0–31 per stat
      final ivs = {for (final s in statKeys) s: rng.nextInt(32)};

      final teraType = detail.types.isNotEmpty ? detail.types[rng.nextInt(detail.types.length)] : 'Normal';

      final form = PokemonForm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pokemonId: detail.id,
        pokemonName: detail.name,
        ability: ability,
        nature: nature,
        item: item,
        moves: moves,
        level: level,
        evs: evs,
        ivs: ivs,
        teraType: teraType,
      );

      await ref.read(rosterProvider.notifier).addPokemon(form);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Random pick failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingRandom = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPokemon != null || widget.initialForm != null) {
      return Scaffold(
        body: _SetEditor(
          pokemon: _selectedPokemon ?? Pokemon(id: widget.initialForm!.pokemonId, name: '', types: [], baseStats: {}, abilities: []),
          initialForm: widget.initialForm,
          isOpponent: widget.isOpponent,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.isOpponent ? 'ADD OPPONENT' : 'ADD TO COLLECTION', style: AppTypography.headlineSmall),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Random pick button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isAddingRandom ? null : _addRandomPokemon,
                icon: _isAddingRandom
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.shuffle, size: 18),
                label: Text(_isAddingRandom ? 'Picking...' : 'RANDOM'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

          if (_isSearching)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pokemon = _searchResults[index];
                  return GlassCard(
                    onTap: () => setState(() => _selectedPokemon = pokemon),
                    child: Row(
                      children: [
                        PokemonSprite(
                          pokemonId: pokemon.id,
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 16),
                        Text(pokemon.name, style: AppTypography.bodyLarge),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: AppColors.primary),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SetEditor extends ConsumerStatefulWidget {
  final Pokemon pokemon;
  final PokemonForm? initialForm;
  final bool isOpponent;

  const _SetEditor({required this.pokemon, this.initialForm, this.isOpponent = false});

  @override
  ConsumerState<_SetEditor> createState() => _SetEditorState();
}

class _SetEditorState extends ConsumerState<_SetEditor> {
  late String _ability;
  late String _nature;
  late String _item;
  final List<String> _moves = [];
  int _level = 50;
  
  final Map<String, int> _evs = {
    'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0
  };
  final Map<String, int> _ivs = {
    'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31
  };

  List<String> _availableItems = ['None'];
  bool _isLoadingItems = false;
  bool _isFetchingDetails = false;
  late Pokemon _pokemon;

  @override
  void initState() {
    super.initState();
    _pokemon = widget.pokemon;
    _isFetchingDetails = _pokemon.abilities.isEmpty;
    
    _loadItems();
    if (_isFetchingDetails) {
      _fetchDetails();
    } else {
      _initValues();
    }
  }

  Future<void> _fetchDetails() async {
    final activeGame = ref.read(gameProviderProvider).valueOrNull;
    final detail = await ref.read(apiClientProvider.notifier).getPokemonDetail(
      _pokemon.id, 
      versionGroupId: activeGame?.versionGroupId
    );
    if (mounted && detail != null) {
      setState(() {
        _pokemon = detail;
        _isFetchingDetails = false;
        _initValues();
      });
    }
  }

  void _initValues() {
    if (widget.initialForm != null) {
      final form = widget.initialForm!;
      _ability = form.ability;
      _nature = form.nature;
      _item = form.item;
      _level = form.level;
      _moves.clear();
      _moves.addAll(form.moves);
      _evs.clear();
      _evs.addAll(form.evs);
      _ivs.clear();
      _ivs.addAll(form.ivs);
    } else {
      _ability = _pokemon.abilities.firstOrNull ?? 'Unknown';
      _nature = 'Adamant';
      _item = 'None';
    }
  }

  Future<void> _loadItems() async {
    setState(() => _isLoadingItems = true);
    final items = await ref.read(apiClientProvider.notifier).fetchItems();
    if (mounted) {
      setState(() {
        final itemNames = items.map((i) => i['name'] as String).where((n) => n.toLowerCase() != 'none').toList();
        _availableItems = ['None', ...itemNames..sort()];
        
        if (!_availableItems.contains(_item)) {
          _availableItems.add(_item);
        }
        _isLoadingItems = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.outline),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              if (_isFetchingDetails)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                Row(
                  children: [
                    PokemonSprite(
                      pokemonId: _pokemon.id,
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_pokemon.name.toUpperCase(), style: AppTypography.displaySmall),
                        Text(_pokemon.types.join(' / ').toUpperCase(), 
                            style: AppTypography.bodySmall.copyWith(color: AppColors.outline.withValues(alpha: 0.7))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('BASIC CONFIG'),
                Consumer(
                  builder: (context, ref, _) {
                    final game = ref.watch(gameProviderProvider).valueOrNull;
                    return Column(
                      children: [
                        if (game?.hasAbilities ?? true)
                          _buildSelectionTile(
                            label: 'Ability', 
                            value: _ability, 
                            icon: Icons.auto_awesome, 
                            onTap: () => _showAbilitySheet(),
                          ),
                        if (game?.hasNatures ?? true)
                          _buildSelectionTile(
                            label: 'Nature', 
                            value: _nature, 
                            icon: Icons.psychology, 
                            onTap: () => _showNatureSheet(),
                          ),
                        if (game?.hasHeldItems ?? true)
                          _buildSelectionTile(
                            label: 'Held Item', 
                            value: _item, 
                            icon: Icons.inventory_2, 
                            onTap: () => _showItemSheet(),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              _buildSectionHeader('BATTLE READY CONFIG'),
              _buildLevelSlider(),
              const SizedBox(height: 24),
              _buildPresets(),
              const SizedBox(height: 24),
              _buildStatEditor(),
              const SizedBox(height: 16),
              _buildStatGrid(),
              
              const SizedBox(height: 24),
              _buildSectionHeader('MOVES (MAX 4)'),
              _buildMoveGrid(),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Ensure we have at least one type for Tera Type fallback
                    final teraType = _pokemon.types.isNotEmpty ? _pokemon.types.first : 'Normal';
                    
                    final form = PokemonForm(
                      id: widget.initialForm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      pokemonId: _pokemon.id,
                      pokemonName: _pokemon.name,
                      ability: _ability,
                      item: _item,
                      nature: _nature,
                      evs: Map<String, int>.from(_evs),
                      ivs: Map<String, int>.from(_ivs),
                      moves: _moves,
                      level: _level,
                      teraType: teraType,
                    );
                    
                    if (widget.isOpponent) {
                      ref.read(matchupProvider.notifier).addOpponentPokemon(form);
                      context.pop(); // Close Editor
                      context.pop(); // Close Modal
                    } else if (widget.initialForm != null) {
                      ref.read(rosterProvider.notifier).updatePokemon(form);
                      context.pop();
                    } else {
                      ref.read(rosterProvider.notifier).addPokemon(form);
                      context.pop(); 
                    }
                  },
                  child: Text(
                    widget.isOpponent ? 'SAVE TO OPPONENT SQUAD' : 'SAVE TO ROSTER', 
                    style: AppTypography.labelLarge.copyWith(color: Colors.white)
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile({
    required String label, 
    required String value, 
    required IconData icon, 
    required VoidCallback onTap
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
                  Text(value, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbilitySheet() {
    _showSelectionSheet(
      title: 'SELECT ABILITY',
      options: _pokemon.abilities,
      selectedValue: _ability,
      onSelected: (v) => setState(() => _ability = v),
    );
  }

  void _showNatureSheet() {
    final natures = [
      'Adamant', 'Bashful', 'Bold', 'Brave', 'Calm', 
      'Careful', 'Docile', 'Gentle', 'Hardy', 'Hasty', 
      'Impish', 'Jolly', 'Lax', 'Lonely', 'Mild', 
      'Modest', 'Naive', 'Naughty', 'Quiet', 'Quirky', 
      'Rash', 'Relaxed', 'Sassy', 'Serious', 'Timid'
    ];
    _showSelectionSheet(
      title: 'SELECT NATURE',
      options: natures,
      selectedValue: _nature,
      onSelected: (v) => setState(() => _nature = v),
      itemBuilder: (item, isSelected) {
        final mods = StatCalculator.getNatureModifiers(item);
        String sub = 'Neutral';
        if (mods.isNotEmpty) {
          final pos = mods.entries.where((e) => e.value > 1.0).firstOrNull?.key ?? '';
          final neg = mods.entries.where((e) => e.value < 1.0).firstOrNull?.key ?? '';
          if (pos.isNotEmpty) sub = '+${pos.toUpperCase()} / -${neg.toUpperCase()}';
        }
        return ListTile(
          title: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : null, fontWeight: isSelected ? FontWeight.bold : null)),
          subtitle: Text(sub, style: AppTypography.labelSmall),
          trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () => Navigator.pop(context, item),
        );
      },
    );
  }

  void _showItemSheet() {
    _showSelectionSheet(
      title: 'SELECT ITEM',
      options: _availableItems,
      selectedValue: _item,
      searchEnabled: true,
      onSelected: (v) => setState(() => _item = v),
    );
  }

  Widget _buildMoveGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final moveName = index < _moves.length ? _moves[index] : null;
        return InkWell(
          onTap: () => _showMoveSelectionSheet(index),
          onLongPress: moveName != null ? () => _showMoveDetail(moveName) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: moveName != null ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moveName != null) ...[
                  Text(moveName.toUpperCase(), style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.add, size: 16, color: AppColors.outline),
                      const SizedBox(width: 8),
                      Text('ADD MOVE', style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoveSelectionSheet(int moveIndex) {
    // For Opponents, show ALL moves. For Roster, filter by level.
    final availableMoveNames = _pokemon.availableMoves
        .where((m) => widget.isOpponent || m.learnLevel <= _level || m.learnLevel == 0 || _level == 100)
        .map((m) => m.name)
        .toList();

    // Ensure 'None' is available at the top
    final options = ['None', ...availableMoveNames..sort()];

    _showSelectionSheet(
      title: 'SELECT MOVE #${moveIndex + 1}',
      options: options,
      selectedValue: moveIndex < _moves.length ? _moves[moveIndex] : 'None',
      searchEnabled: true,
      onSelected: (v) {
        setState(() {
          if (moveIndex < _moves.length) {
            if (v == 'None' || v.isEmpty) {
              _moves.removeAt(moveIndex);
            } else {
              _moves[moveIndex] = v;
            }
          } else if (v.isNotEmpty && v != 'None') {
            _moves.add(v);
          }
        });
      },
      itemBuilder: (item, isSelected) {
        if (item == 'None') {
          return ListTile(
            title: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : null, fontWeight: isSelected ? FontWeight.bold : null)),
            trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () => Navigator.pop(context, item),
          );
        }
        final moveDetail = _pokemon.availableMoves.firstWhere((m) => m.name == item, orElse: () => _pokemon.availableMoves.first);
        return ListTile(
          title: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : null, fontWeight: isSelected ? FontWeight.bold : null)),
          subtitle: Text('Level ${moveDetail.learnLevel} • ${moveDetail.learnMethod}'),
          trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () => Navigator.pop(context, item),
        );
      },
    );
  }

  void _showSelectionSheet({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
    bool searchEnabled = false,
    Widget Function(String item, bool isSelected)? itemBuilder,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectionSheet(
        title: title,
        options: options,
        selectedValue: selectedValue,
        searchEnabled: searchEnabled,
        itemBuilder: itemBuilder,
      ),
    );
    if (result != null) onSelected(result);
  }

  Widget _buildPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PRESETS', style: AppTypography.labelSmall.copyWith(color: AppColors.secondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PresetChip(label: 'Perfect', color: Colors.amber, onTap: _applyPerfectPreset),
            _PresetChip(label: 'Physical Sweeper', color: Colors.red, onTap: _applyPhysicalSweeper),
            _PresetChip(label: 'Special Sweeper', color: Colors.blue, onTap: _applySpecialSweeper),
            _PresetChip(label: 'Bulky', color: Colors.green, onTap: _applyBulkyPreset),
            _PresetChip(label: 'Trick Room', color: Colors.purple, onTap: _applyTrickRoomPreset),
          ],
        ),
      ],
    );
  }

  void _applyPerfectPreset() {
    final game = ref.read(gameProviderProvider).valueOrNull;
    if (game != null && game.generation <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfect presets are not applicable to Legacy (Gen 1-2) games.')),
      );
      return;
    }
    
    setState(() {
      _ivs.updateAll((k, v) => 31);
      final totalEvs = _evs.values.fold(0, (sum, v) => sum + v);
      if (totalEvs == 0) {
        if ((_pokemon.baseStats['atk'] ?? 0) >= (_pokemon.baseStats['spa'] ?? 0)) {
          _applyPhysicalSweeper();
        } else {
          _applySpecialSweeper();
        }
      }
    });
  }

  void _applyPhysicalSweeper() {
    setState(() {
      _evs.updateAll((k, v) => 0);
      _evs['atk'] = 252;
      _evs['spe'] = 252;
      _evs['hp'] = 4;
      _nature = 'Jolly';
    });
  }

  void _applySpecialSweeper() {
    setState(() {
      _evs.updateAll((k, v) => 0);
      _evs['spa'] = 252;
      _evs['spe'] = 252;
      _evs['hp'] = 4;
      _nature = 'Timid';
    });
  }

  void _applyBulkyPreset() {
    setState(() {
      _evs.updateAll((k, v) => 0);
      _evs['hp'] = 252;
      _evs['def'] = 128;
      _evs['spd'] = 128;
      _nature = 'Relaxed';
    });
  }

  void _applyTrickRoomPreset() {
    setState(() {
      _ivs['spe'] = 0;
      _nature = 'Brave';
    });
  }

  Widget _buildStatEditor() {
    final totalEvs = _evs.values.fold(0, (sum, v) => sum + v);
    final evWarning = totalEvs > 510;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('ADVANCED STATS (EV/IV)', style: AppTypography.labelLarge.copyWith(color: evWarning ? AppColors.error : AppColors.primary)),
        subtitle: Text('Total EVs: $totalEvs / 510', style: AppTypography.labelSmall.copyWith(color: evWarning ? AppColors.error : AppColors.outline)),
        children: [
          _buildStatRow('HP', 'hp'),
          _buildStatRow('ATK', 'atk'),
          _buildStatRow('DEF', 'def'),
          _buildStatRow('SPA', 'spa'),
          _buildStatRow('SPD', 'spd'),
          _buildStatRow('SPE', 'spe'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: AppTypography.labelMedium)),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EV: ${_evs[key]}', style: AppTypography.labelSmall),
                Slider(
                  value: _evs[key]!.toDouble(),
                  min: 0,
                  max: 252,
                  onChanged: (v) => setState(() => _evs[key] = v.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IV: ${_ivs[key]}', style: AppTypography.labelSmall),
                Slider(
                  value: _ivs[key]!.toDouble(),
                  min: 0,
                  max: 31,
                  onChanged: (v) => setState(() => _ivs[key] = v.toInt()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Level', style: AppTypography.bodyMedium),
            Text('$_level', style: AppTypography.headlineSmall.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _level.toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _level = v.toInt()),
        ),
      ],
    );
  }

  Widget _buildStatGrid() {
    final natureMods = StatCalculator.getNatureModifiers(_nature);
    final hp = StatCalculator.calculateHP(
      baseHp: _pokemon.baseStats['hp'] ?? 0,
      level: _level,
      iv: _ivs['hp'] ?? 31,
      ev: _evs['hp'] ?? 0,
    );
    final stats = {
      'ATK': StatCalculator.calculateStat(baseStat: _pokemon.baseStats['atk'] ?? 0, level: _level, natureFactor: natureMods['atk'] ?? 1.0, iv: _ivs['atk'] ?? 31, ev: _evs['atk'] ?? 0),
      'DEF': StatCalculator.calculateStat(baseStat: _pokemon.baseStats['def'] ?? 0, level: _level, natureFactor: natureMods['def'] ?? 1.0, iv: _ivs['def'] ?? 31, ev: _evs['def'] ?? 0),
      'SPA': StatCalculator.calculateStat(baseStat: _pokemon.baseStats['spa'] ?? 0, level: _level, natureFactor: natureMods['spa'] ?? 1.0, iv: _ivs['spa'] ?? 31, ev: _evs['spa'] ?? 0),
      'SPD': StatCalculator.calculateStat(baseStat: _pokemon.baseStats['spd'] ?? 0, level: _level, natureFactor: natureMods['spd'] ?? 1.0, iv: _ivs['spd'] ?? 31, ev: _evs['spd'] ?? 0),
      'SPE': StatCalculator.calculateStat(baseStat: _pokemon.baseStats['spe'] ?? 0, level: _level, natureFactor: natureMods['spe'] ?? 1.0, iv: _ivs['spe'] ?? 31, ev: _evs['spe'] ?? 0),
    };
    final radarStats = {
      'hp':  hp,
      'atk': stats['ATK']!,
      'def': stats['DEF']!,
      'spa': stats['SPA']!,
      'spd': stats['SPD']!,
      'spe': stats['SPE']!,
    };
    return Column(
      children: [
        Center(
          child: StatRadarChart(
            stats: radarStats,
            maxValue: 600,
            size: 200,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildStatItemSummary('HP', hp, Colors.green),
            ...stats.entries.map((e) => _buildStatItemSummary(e.key, e.value, _getStatColor(e.key))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItemSummary(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
          Text('$value', style: AppTypography.headlineSmall),
        ],
      ),
    );
  }

  Color _getStatColor(String stat) {
    switch (stat) {
      case 'ATK': return Colors.red;
      case 'DEF': return Colors.orange;
      case 'SPA': return Colors.lightBlue;
      case 'SPD': return Colors.blue;
      case 'SPE': return Colors.pink;
      default: return Colors.grey;
    }
  }

  void _showMoveDetail(String moveName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoveDetailSheet(moveName: moveName),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTypography.labelMedium.copyWith(color: AppColors.secondary)),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      label: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      onPressed: onTap,
    );
  }
}

class _MoveDetailSheet extends ConsumerStatefulWidget {
  final String moveName;
  const _MoveDetailSheet({required this.moveName});
  @override
  ConsumerState<_MoveDetailSheet> createState() => _MoveDetailSheetState();
}

class _MoveDetailSheetState extends ConsumerState<_MoveDetailSheet> {
  MoveDetail? _detail;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadDetail();
  }
  Future<void> _loadDetail() async {
    final detail = await ref.read(apiClientProvider.notifier).getMoveDetail(widget.moveName);
    if (mounted) setState(() { _detail = detail; _isLoading = false; });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.all(32),
      child: _isLoading ? const Center(child: CircularProgressIndicator()) : _detail == null ? const Center(child: Text('Could not load move details')) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _getTypeColor(_detail!.type).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(_detail!.type.toUpperCase(), style: AppTypography.labelLarge.copyWith(color: _getTypeColor(_detail!.type), letterSpacing: 1.2))),
              const SizedBox(width: 12),
              Text(_detail!.damageClass.toUpperCase(), style: AppTypography.labelMedium.copyWith(color: AppColors.outline)),
            ]),
            const SizedBox(height: 16),
            Text(_detail!.name.toUpperCase().replaceAll('-', ' '), style: AppTypography.displaySmall),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildStatDetailItem('POWER', _detail!.power?.toString() ?? '—'),
              _buildStatDetailItem('ACCURACY', _detail!.accuracy?.toString() ?? '—'),
              _buildStatDetailItem('PP', _detail!.pp.toString()),
            ]),
            const SizedBox(height: 32),
            Text('DESCRIPTION', style: AppTypography.labelSmall.copyWith(color: AppColors.secondary)),
            const SizedBox(height: 12),
            Text(_detail!.description, style: AppTypography.bodyMedium.copyWith(height: 1.5, color: AppColors.onSurface.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
  Widget _buildStatDetailItem(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
      const SizedBox(height: 4),
      Text(value, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire': return Colors.orange;
      case 'water': return Colors.blue;
      case 'grass': return Colors.green;
      case 'electric': return Colors.yellow[700]!;
      case 'ice': return Colors.cyanAccent;
      case 'fighting': return Colors.redAccent;
      case 'poison': return Colors.purple;
      case 'ground': return Colors.brown;
      case 'flying': return Colors.indigoAccent;
      case 'psychic': return Colors.pinkAccent;
      case 'bug': return Colors.lightGreen;
      case 'rock': return Colors.grey;
      case 'ghost': return Colors.deepPurple;
      case 'dragon': return Colors.indigo;
      case 'dark': return Colors.black87;
      case 'steel': return Colors.blueGrey;
      case 'fairy': return Colors.pink[200]!;
      default: return Colors.grey;
    }
  }
}

class _SelectionSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final bool searchEnabled;
  final Widget Function(String item, bool isSelected)? itemBuilder;
  const _SelectionSheet({required this.title, required this.options, required this.selectedValue, this.searchEnabled = false, this.itemBuilder});
  @override
  State<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> {
  late List<String> _filteredOptions;
  final _searchController = TextEditingController();
  @override
  void initState() { super.initState(); _filteredOptions = widget.options; }
  void _onSearch(String query) {
    setState(() { _filteredOptions = widget.options.where((o) => o.toLowerCase().contains(query.toLowerCase())).toList(); });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(24), child: Row(children: [
          Text(widget.title, style: AppTypography.labelLarge.copyWith(letterSpacing: 1.2)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ])),
        if (widget.searchEnabled) Padding(padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16), child: TextField(controller: _searchController, decoration: InputDecoration(hintText: 'Search...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: AppColors.surfaceContainerLow, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), onChanged: _onSearch)),
        Expanded(child: ListView.builder(padding: const EdgeInsets.only(left: 12, right: 12, bottom: 24), itemCount: _filteredOptions.length, itemBuilder: (context, index) {
          final item = _filteredOptions[index];
          final isSelected = item == widget.selectedValue;
          if (widget.itemBuilder != null) return widget.itemBuilder!(item, isSelected);
          return ListTile(title: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : null, fontWeight: isSelected ? FontWeight.bold : null)), trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () => Navigator.pop(context, item));
        })),
      ]),
    );
  }
}
