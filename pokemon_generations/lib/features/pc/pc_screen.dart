import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/pokemon_form.dart';
import '../roster/roster_provider.dart';
import '../auth/auth_controller.dart';
import '../../data/providers.dart';
import '../../core/widgets/pokemon_sprite.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_radar_chart.dart';
import '../../core/utils/stat_calculator.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/pokemon.dart';
import '../roster/add_pokemon_screen.dart';

class PCScreen extends ConsumerStatefulWidget {
  const PCScreen({super.key});

  @override
  ConsumerState<PCScreen> createState() => _PCScreenState();
}

class _PCScreenState extends ConsumerState<PCScreen> {
  int _currentBoxIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioPlayed = false;

  @override
  void initState() {
    super.initState();
    _playBootupSound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playBootupSound() async {
    if (_audioPlayed) return;
    try {
      await _audioPlayer.play(AssetSource('pcbootup.wav'));
      _audioPlayed = true;
    } catch (e) {
      debugPrint('Error playing PC bootup sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(authControllerProvider).profile;
    final username = userProfile?.username ?? 'TRAINER';

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${username.toUpperCase()}\'S PC',
          style: AppTypography.headlineMedium.copyWith(
            letterSpacing: 3,
            color: AppTheme.neonBlue,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Row(
        children: [
          // Left Side: Active Roster (6 slots)
          _buildActiveRosterSection(),

          // Divider
          Container(
            width: 1,
            color: Colors.white10,
            margin: const EdgeInsets.symmetric(vertical: 20),
          ),

          // Right Side: Box Storage (Grid)
          Expanded(child: _buildBoxStorageSection()),
        ],
      ),
    );
  }

  Widget _buildActiveRosterSection() {
    final rosterAsync = ref.watch(rosterProvider);

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: rosterAsync.when(
        data: (roster) => ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) {
            final mon = index < roster.length ? roster[index] : null;
            return DragTarget<PokemonForm>(
              onAcceptWithDetails: (details) =>
                  _movePokemonToRoster(details.data, index),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? AppTheme.neonBlue.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? AppTheme.neonBlue
                          : Colors.white10,
                      width: 1,
                    ),
                  ),
                  child: mon != null
                      ? Draggable<PokemonForm>(
                          data: mon,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Transform.scale(
                              scale: 1.2,
                              child: _buildCompactSprite(mon),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildCompactSprite(mon),
                          ),
                          child: GestureDetector(
                            onTap: () => _showPokemonMenu(mon),
                            child: _buildCompactSprite(mon),
                          ),
                        )
                      : GestureDetector(
                          onTap: () => _addNewPokemonToRoster(index),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white10,
                              size: 20,
                            ),
                          ),
                        ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildPanelError(
          'Roster failed to load',
          onRetry: () => ref.invalidate(rosterProvider),
        ),
      ),
    );
  }

  Widget _buildBoxStorageSection() {
    return Column(
      children: [
        // Box Tabs
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              final isSelected = _currentBoxIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _currentBoxIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.neonBlue
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.neonBlue.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'BOX ${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Storage Grid
        Expanded(child: _buildBoxGrid()),
      ],
    );
  }

  Widget _buildBoxGrid() {
    final pcAsync = ref.watch(pCStorageProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: pcAsync.when(
        data: (allPC) {
          final boxMons = allPC
              .where((p) => p.boxIndex == _currentBoxIndex)
              .toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 12, // Doubled from 6
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75, // Adjusted for tighter grid
            ),
            itemCount: 72, // Doubled from 36
            itemBuilder: (context, index) {
              final mon = boxMons.firstWhere(
                (p) => p.slotIndex == index,
                orElse: () => const PokemonForm(id: 'EMPTY'),
              );
              final isEmpty = mon.id == 'EMPTY';

              return DragTarget<PokemonForm>(
                onAcceptWithDetails: (details) =>
                    _movePokemonToPC(details.data, _currentBoxIndex, index),
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    decoration: BoxDecoration(
                      color: candidateData.isNotEmpty
                          ? AppTheme.neonBlue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: candidateData.isNotEmpty
                            ? AppTheme.neonBlue
                            : Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: !isEmpty
                        ? Draggable<PokemonForm>(
                            data: mon,
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Transform.scale(
                                scale: 1.2,
                                child: _buildCompactSprite(mon, isMini: true),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildCompactSprite(mon, isMini: true),
                            ),
                            child: GestureDetector(
                              onTap: () => _showPokemonMenu(mon),
                              child: _buildCompactSprite(mon, isMini: true),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _addNewPokemonToPC(index),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildPanelError(
          'PC storage failed to load',
          onRetry: () => ref.invalidate(pCStorageProvider),
        ),
      ),
    );
  }

  Widget _buildPanelError(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactSprite(PokemonForm mon, {bool isMini = false}) {
    final scale = isMini ? 0.8 : 1.0;
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          PokemonSprite(pokemonId: mon.pokemonId, width: (isMini ? 32 : 45)),
          if (!isMini) ...[
            const SizedBox(height: 4),
            Text(
              mon.pokemonName?.toUpperCase() ?? '???',
              style: TextStyle(
                fontSize: 9,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${mon.wins}W-${mon.losses}L',
              style: const TextStyle(fontSize: 7, color: Colors.white24),
            ),
          ],
        ],
      ),
    );
  }

  void _showPokemonMenu(PokemonForm mon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  PokemonSprite(pokemonId: mon.pokemonId, width: 40),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mon.pokemonName?.toUpperCase() ?? 'UNKNOWN',
                        style: AppTypography.headlineSmall.copyWith(fontSize: 18),
                      ),
                      Text(
                        'LV. ${mon.level} • ${mon.nature.toUpperCase()}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.analytics_outlined, color: AppTheme.neonBlue),
              title: const Text('VIEW FULL STATS'),
              onTap: () {
                Navigator.pop(context);
                _showStatsPopup(mon);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.white),
              title: const Text('EDIT POKEMON'),
              onTap: () {
                Navigator.pop(context);
                _editPokemon(mon);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('RELEASE POKEMON', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmRelease(mon);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showStatsPopup(PokemonForm mon) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mon.pokemonName?.toUpperCase() ?? 'POKEMON',
                        style: AppTypography.headlineSmall,
                      ),
                      Text(
                        'LV. ${mon.level} • ${mon.nature.toUpperCase()}',
                        style: TextStyle(color: AppTheme.neonBlue.withValues(alpha: 0.7), letterSpacing: 1),
                      ),
                    ],
                  ),
                  PokemonSprite(pokemonId: mon.pokemonId, width: 60),
                ],
              ),
              const SizedBox(height: 32),
              FutureBuilder<Pokemon?>(
                future: ref.read(apiClientProvider.notifier).getPokemonDetail(mon.pokemonId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final pokemon = snapshot.data;
                  if (pokemon == null) return const Text('Error loading stats');

                  // Calculate actual stats for display
                  final actualStats = StatCalculator.calculateStats(
                    baseStats: pokemon.baseStats,
                    level: mon.level,
                    ivs: mon.ivs,
                    evs: mon.evs,
                    nature: mon.nature,
                  );

                  return Column(
                    children: [
                      StatRadarChart(
                        stats: actualStats,
                        maxValue: 500, // Reasonable max for current level
                        size: 200,
                      ),
                      const SizedBox(height: 24),
                      _buildStatRow('HP', actualStats['hp'] ?? 0, mon.evs['hp'] ?? 0),
                      _buildStatRow('ATK', actualStats['atk'] ?? 0, mon.evs['atk'] ?? 0),
                      _buildStatRow('DEF', actualStats['def'] ?? 0, mon.evs['def'] ?? 0),
                      _buildStatRow('SPA', actualStats['spa'] ?? 0, mon.evs['spa'] ?? 0),
                      _buildStatRow('SPD', actualStats['spd'] ?? 0, mon.evs['spd'] ?? 0),
                      _buildStatRow('SPE', actualStats['spe'] ?? 0, mon.evs['spe'] ?? 0),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE', style: TextStyle(color: Colors.white54, letterSpacing: 2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, int ev) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
                ),
                FractionallySizedBox(
                  widthFactor: (value / 500).clamp(0, 1),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(color: AppTheme.neonBlue, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(value.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          if (ev > 0)
            Text(' (+$ev)', style: const TextStyle(color: Colors.greenAccent, fontSize: 9)),
        ],
      ),
    );
  }

  void _editPokemon(PokemonForm mon) async {
    final pokemon = await ref.read(apiClientProvider.notifier).getPokemonDetail(mon.pokemonId);
    if (pokemon == null) return;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPokemonScreen(
          initialForm: mon,
          initialPokemon: pokemon,
        ),
      ),
    );
  }

  void _confirmRelease(PokemonForm mon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Release Pokemon?'),
        content: Text('Are you sure you want to release ${mon.pokemonName ?? "this Pokemon"} forever? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('RELEASE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mon.slotIndex == -1) {
        await ref.read(rosterProvider.notifier).removePokemon(mon.id);
      } else {
        final pc = ref.read(pCStorageProvider).value ?? [];
        final updatedPC = pc.where((p) => p.id != mon.id).toList();
        await ref.read(pCStorageProvider.notifier).updatePC(updatedPC);
      }
    }
  }

  void _addNewPokemonToRoster(int index) {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPokemonScreen()),
    );
  }

  void _addNewPokemonToPC(int index) {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPokemonScreen()),
    );
  }

  Future<void> _movePokemonToRoster(PokemonForm pokemon, int rosterSlot) async {
    final roster = ref.read(rosterProvider).value ?? [];
    final pc = ref.read(pCStorageProvider).value ?? [];

    // 1. Remove from PC if there
    final updatedPC = pc.where((p) => p.id != pokemon.id).toList();

    // 2. If slot already has someone, move them to PC
    if (rosterSlot < roster.length) {
      final existing = roster[rosterSlot];
      updatedPC.add(
        existing.copyWith(boxIndex: _currentBoxIndex, slotIndex: 0),
      ); // simple slot choice for now
      await ref.read(rosterProvider.notifier).removePokemon(existing.id);
    }

    // 3. Add to roster
    final updatedMon = pokemon.copyWith(slotIndex: -1);
    await ref.read(rosterProvider.notifier).addPokemon(updatedMon);
    await ref.read(pCStorageProvider.notifier).updatePC(updatedPC);
  }

  Future<void> _movePokemonToPC(
    PokemonForm pokemon,
    int boxIndex,
    int slotIndex,
  ) async {
    final pc = ref.read(pCStorageProvider).value ?? [];

    // 1. If coming from roster, remove
    if (pokemon.slotIndex == -1) {
      await ref.read(rosterProvider.notifier).removePokemon(pokemon.id);
    }

    // 2. Add/Update in PC
    final updatedMon = pokemon.copyWith(
      boxIndex: boxIndex,
      slotIndex: slotIndex,
    );
    final updatedPC = [...pc.where((p) => p.id != pokemon.id), updatedMon];
    await ref.read(pCStorageProvider.notifier).updatePC(updatedPC);
  }
}
