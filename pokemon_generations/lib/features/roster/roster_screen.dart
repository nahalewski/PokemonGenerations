import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/team.dart';
import '../../domain/models/pokemon_form.dart';
import 'team_provider.dart';
import 'roster_provider.dart';
import '../../core/widgets/pokemon_sprite.dart';
import '../../core/widgets/glass_card.dart';

class RosterScreen extends ConsumerStatefulWidget {
  const RosterScreen({super.key});

  @override
  ConsumerState<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends ConsumerState<RosterScreen> {
  bool _isVerticalView = true;
  int _selectedIndex = 0; // 0: My Collections, 1: Roster Builder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_selectedIndex == 0 ? 'MY COLLECTIONS' : 'ROSTER BUILDER', 
          style: AppTypography.headlineMedium.copyWith(letterSpacing: 2)),
        actions: [
          IconButton(
            icon: Icon(_isVerticalView ? Icons.grid_view_rounded : Icons.view_list_rounded, color: AppTheme.neonBlue),
            onPressed: () => setState(() => _isVerticalView = !_isVerticalView),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: AppTheme.neonBlue,
        unselectedItemColor: Colors.white24,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark_rounded), label: 'Collections'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_fix_high_rounded), label: 'Builder'),
        ],
      ),
      body: _selectedIndex == 0 ? _buildCollectionsView() : _buildBuilderView(),
      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton.extended(
        onPressed: () => _showSaveDialog(),
        backgroundColor: AppTheme.neonBlue,
        label: const Text('SAVE ROSTER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.save_rounded, color: Colors.black),
      ) : FloatingActionButton(
        onPressed: () => setState(() => _selectedIndex = 1),
        backgroundColor: AppTheme.neonBlue,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCollectionsView() {
    final teamsAsync = ref.watch(teamListProvider);

    return teamsAsync.when(
      data: (teams) {
        if (teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_edu_rounded, size: 64, color: Colors.white10),
                const SizedBox(height: 16),
                Text('NO ROSTERS SAVED', style: AppTypography.bodyLarge.copyWith(color: Colors.white24)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonBlue, foregroundColor: Colors.black),
                  child: const Text('CREATE FIRST ROSTER'),
                ),
              ],
            ),
          );
        }

        return _isVerticalView 
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teams.length,
              itemBuilder: (context, index) => _buildTeamCard(teams[index]),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: teams.length,
              itemBuilder: (context, index) => _buildTeamCard(teams[index]),
            );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTeamCard(Team team) {
    return GestureDetector(
      onTap: () => context.push('/roster/detail/${team.id}'),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(team.name.toUpperCase(), 
                    style: AppTypography.titleLarge.copyWith(color: AppTheme.neonBlue, letterSpacing: 1)),
                ),
                Text('${team.winCount}W - ${team.lossCount}L', 
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () => _confirmDelete(team),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, i) {
                  final pokemon = i < team.slots.length ? team.slots[i] : null;
                  return Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: pokemon != null 
                      ? PokemonSprite(pokemonId: pokemon.pokemonId, width: 30)
                      : const Icon(Icons.add, size: 12, color: Colors.white10),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuilderView() {
    final rosterAsync = ref.watch(rosterProvider);

    return rosterAsync.when(
      data: (pokemonList) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('ASSEMBLE YOUR DROUGHT/RAIN SQUAD (MAX 6)', 
                style: AppTypography.bodySmall.copyWith(color: Colors.white38, letterSpacing: 1.5)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final pokemon = index < pokemonList.length ? pokemonList[index] : null;
                  return _buildBuilderSlot(pokemon, index);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildBuilderSlot(PokemonForm? pokemon, int index) {
    return GestureDetector(
      onTap: () {
        if (pokemon != null) {
          context.push('/roster/add-pokemon', extra: pokemon);
        } else {
          context.push('/roster/add-pokemon');
        }
      },
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: pokemon != null ? Stack(
          children: [
            Center(child: PokemonSprite(pokemonId: pokemon.pokemonId, width: 80)),
            Positioned(
              top: 4, right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.white38),
                onPressed: () => ref.read(rosterProvider.notifier).removePokemon(pokemon.id),
              ),
            ),
            Positioned(
              bottom: 8, left: 8,
              child: Text(pokemon.pokemonId.toUpperCase(), style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ) : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: AppTheme.neonBlue, size: 32),
              SizedBox(height: 8),
              Text('ADD SLOT', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('NAME YOUR ROSTER', style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Competitive VGC S1',
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonBlue.withOpacity(0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonBlue)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(teamListProvider.notifier).saveCurrentAsTeam(controller.text);
                Navigator.pop(context);
                setState(() => _selectedIndex = 0); // Back to collections
              }
            },
            child: const Text('SAVE', style: TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('DELETE ${team.name.toUpperCase()}?', style: const TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to remove this roster permanently?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () {
              ref.read(teamListProvider.notifier).deleteTeam(team.id);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
