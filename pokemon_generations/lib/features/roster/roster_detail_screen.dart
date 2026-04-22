import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/team.dart';
import '../../domain/models/pokemon_form.dart';
import 'team_provider.dart';
import '../../core/widgets/pokemon_sprite.dart';
import '../../core/utils/type_chart.dart';
import 'package:go_router/go_router.dart';

class RosterDetailScreen extends ConsumerStatefulWidget {
  final String teamId;

  const RosterDetailScreen({super.key, required this.teamId});

  @override
  ConsumerState<RosterDetailScreen> createState() => _RosterDetailScreenState();
}

class _RosterDetailScreenState extends ConsumerState<RosterDetailScreen> {
  bool _showAbstract = false;

  @override
  Widget build(BuildContext context) {
    final teamAsync = ref.watch(teamByIdProvider(widget.teamId));

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: teamAsync.when(
          data: (team) => Text(team?.name.toUpperCase() ?? 'ROSTER DETAIL', style: AppTypography.headlineMedium),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const Text('ERROR'),
        ),
      ),
      body: teamAsync.when(
        data: (team) {
          if (team == null) return const Center(child: Text('Roster not found', style: TextStyle(color: Colors.white)));
          return _buildContent(team);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildContent(Team team) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 900;
      
      if (isWide) {
        return Row(
          children: [
            Expanded(flex: 2, child: _buildPokemonList(team)),
            const VerticalDivider(color: Colors.white12, width: 1),
            Expanded(flex: 3, child: _buildStatsPane(team)),
          ],
        );
      } else {
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildPokemonList(team),
              const Divider(color: Colors.white12),
              _buildStatsPane(team),
            ],
          ),
        );
      }
    });
  }

  Widget _buildPokemonList(Team team) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final pokemon = index < team.slots.length ? team.slots[index] : null;
        return _buildPokemonSlot(pokemon, index);
      },
    );
  }

  Widget _buildPokemonSlot(PokemonForm? pokemon, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white10,
            child: Text('${index + 1}', style: const TextStyle(color: Colors.white38)),
          ),
          const SizedBox(width: 16),
          if (pokemon != null) ...[
             PokemonSprite(
              pokemonId: pokemon.pokemonId,
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pokemon.pokemonId.toUpperCase(), style: AppTypography.titleMedium),
                  Text('Lvl ${pokemon.level} • ${pokemon.item}', style: AppTypography.bodySmall.copyWith(color: Colors.white38)),
                ],
              ),
            ),
          ] else
            const Expanded(child: Text('EMPTY SLOT', style: TextStyle(color: Colors.white24, letterSpacing: 2))),
        ],
      ),
    );
  }

  Widget _buildStatsPane(Team team) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreHeader(team),
          const SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _showAbstract = !_showAbstract),
              child: Column(
                children: [
                  Text(_showAbstract ? 'TEAM PERSONA' : 'TRADITIONAL STATS', 
                    style: const TextStyle(color: AppTheme.neonBlue, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: _buildRadarChart(team),
                  ),
                  const Text('Click chart to toggle view', style: TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildOverallStatBars(team),
          const SizedBox(height: 40),
          _buildOtherData(team),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(Team team) {
    final totalBST = team.slots.fold<int>(0, (sum, p) => sum + 500); // Placeholder — ideally we'd have real BST
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildScoreItem('POWER RATING', '$totalBST'),
        _buildScoreItem('WIN / LOSS', '${team.winCount} - ${team.lossCount}'),
      ],
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
        Text(value, style: AppTypography.headlineMedium.copyWith(color: AppTheme.neonBlue)),
      ],
    );
  }

  Widget _buildRadarChart(Team team) {
    if (team.slots.isEmpty) return const Center(child: Text('No Data'));

    // Normalization logic
    List<double> values;
    List<String> titles;

    if (_showAbstract) {
      titles = ['Power', 'Bulk', 'Speed', 'Synergy', 'Skill'];
      values = [0.8, 0.6, 0.9, 0.7, 0.5]; // Mock abstract logic
    } else {
      titles = ['HP', 'ATK', 'DEF', 'SPA', 'SPD', 'SPE'];
      values = [0.7, 0.8, 0.6, 0.75, 0.65, 0.9]; // Mock stat average
    }

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        dataSets: [
          RadarDataSet(
            fillColor: AppTheme.neonBlue.withOpacity(0.2),
            borderColor: AppTheme.neonBlue,
            entryRadius: 3,
            dataEntries: values.map((e) => RadarEntry(value: e)).toList(),
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.white10),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 10),
        getTitle: (index, angle) => RadarChartTitle(text: titles[index]),
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        gridBorderData: const BorderSide(color: Colors.white10, width: 1),
      ),
    );
  }

  Widget _buildOverallStatBars(Team team) {
     // Mock stats for demonstration
    final stats = {
      'HP': 0.7,
      'ATTACK': 0.85,
      'DEFENSE': 0.6,
      'SP. ATK': 0.75,
      'SP. DEF': 0.65,
      'SPEED': 0.9,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TEAM AVERAGES', style: AppTypography.titleMedium.copyWith(color: Colors.white70)),
        const SizedBox(height: 16),
        ...stats.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  Text('${(e.value * 150).toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: e.value,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildOtherData(Team team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TYPE INTELLIGENCE', style: AppTypography.titleMedium.copyWith(color: Colors.white70)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow('Weaknesses', 'Flying, Ground, Psychic'),
              const Divider(color: Colors.white10),
              _buildInfoRow('Resistances', 'Grass, Fighting, Bug'),
              const Divider(color: Colors.white10),
              _buildInfoRow('Offensive Coverage', '92% of Metagame'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 12))),
        ],
      ),
    );
  }
}
