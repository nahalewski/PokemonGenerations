import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'dart:math';
import '../../domain/models/pokemon_form.dart';
import '../../domain/models/analysis.dart';
import '../../data/services/api_client.dart';
import '../roster/roster_provider.dart';
import '../../core/utils/type_chart.dart';
import '../../domain/models/history.dart';
import '../../data/providers.dart';
import '../../core/settings/app_settings_controller.dart';

final matchupProvider = NotifierProvider<Matchup, MatchupState>(Matchup.new);

class Matchup extends Notifier<MatchupState> {
  @override
  MatchupState build() {
    return const MatchupState(opponentTeam: [], format: 'VGC');
  }

  void addOpponentPokemon(PokemonForm pokemon) {
    if (state.opponentTeam.length < 6) {
      state = state.copyWith(opponentTeam: [...state.opponentTeam, pokemon]);
    }
  }

  void removeOpponentPokemon(String id) {
    state = state.copyWith(
      opponentTeam: state.opponentTeam.where((p) => p.id != id).toList(),
    );
  }

  Future<void> autoGenerateOpponents() async {
    state = state.copyWith(isAnalyzing: true);
    final api = ref.read(apiClientProvider.notifier);
    
    try {
      // Get full list of pokemon
      final allPokemon = await api.searchPokemon('');
      if (allPokemon.isEmpty) {
        state = state.copyWith(isAnalyzing: false, error: 'Could not fetch Pokemon list');
        return;
      }

      final random = Random();
      final List<PokemonForm> newTeam = [];
      
      // Select 6 unique random pokemon
      final selectedIndices = <int>{};
      while (selectedIndices.length < 6 && selectedIndices.length < allPokemon.length) {
        selectedIndices.add(random.nextInt(allPokemon.length));
      }

      for (final index in selectedIndices) {
        final base = allPokemon[index];
        final detail = await api.getPokemonDetail(base.id);
        if (detail != null) {
          // Create a standard competitive form
          newTeam.add(PokemonForm(
            id: DateTime.now().millisecondsSinceEpoch.toString() + index.toString(),
            pokemonId: detail.id,
            pokemonName: detail.name,
            ability: detail.abilities.isNotEmpty ? detail.abilities.first : 'None',
            item: 'Life Orb',
            nature: 'Jolly',
            evs: {'hp': 4, 'atk': 252, 'spe': 252},
            ivs: {'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31},
            moves: detail.availableMoves.take(4).map((m) => m.name).toList(),
            level: 50,
            teraType: detail.types.first,
          ));
        }
      }

      state = state.copyWith(opponentTeam: newTeam, isAnalyzing: false);
    } catch (e) {
      state = state.copyWith(isAnalyzing: false, error: 'Auto-generation failed: $e');
    }
  }

  void setFormat(String format) {
    state = state.copyWith(format: format);
  }

  Future<void> runTelemetryAnalysis() async {
    final rosterAsync = ref.read(rosterProvider);
    final roster = rosterAsync.value ?? [];

    if (roster.isEmpty || state.opponentTeam.isEmpty) return;

    state = state.copyWith(
      isAnalyzing: true,
      analysisResult: null,
      error: null,
    );

    try {
      final result = await ref
          .read(apiClientProvider.notifier)
          .analyzeTeam(
            ref.read(backendBaseUrlProvider),
            roster,
            state.opponentTeam,
            state.format,
          );
      state = state.copyWith(isAnalyzing: false, analysisResult: result);

      // Save to history
      final historyEntry = AnalysisHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        opponentTeam: List.from(state.opponentTeam),
        result: result,
        format: state.format,
      );
      ref
          .read(analysisHistoryNotifierProvider.notifier)
          .addHistory(historyEntry);
    } catch (e) {
      state = state.copyWith(isAnalyzing: false, error: e.toString());
    }
  }

  void reset() {
    state = const MatchupState(opponentTeam: [], format: 'VGC');
  }

  void loadHistoryResult(AnalysisHistory history) {
    state = MatchupState(
      opponentTeam: history.opponentTeam,
      format: history.format,
      analysisResult: history.result,
    );
  }
}

class MatchupState {
  final List<PokemonForm> opponentTeam;
  final String format;
  final bool isAnalyzing;
  final MatchupAnalysis? analysisResult;
  final String? error;

  const MatchupState({
    required this.opponentTeam,
    required this.format,
    this.isAnalyzing = false,
    this.analysisResult,
    this.error,
  });

  MatchupState copyWith({
    List<PokemonForm>? opponentTeam,
    String? format,
    bool? isAnalyzing,
    MatchupAnalysis? analysisResult,
    String? error,
  }) {
    return MatchupState(
      opponentTeam: opponentTeam ?? this.opponentTeam,
      format: format ?? this.format,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      analysisResult: analysisResult ?? this.analysisResult,
      error: error ?? this.error,
    );
  }
}

final rosterTypesProvider = FutureProvider.autoDispose<List<List<PokemonType>>>(
  (ref) async {
    final rosterAsync = ref.watch(rosterProvider);
    final roster = rosterAsync.value ?? [];
    final api = ref.read(apiClientProvider.notifier);

    if (roster.isEmpty) return [];

    final List<List<PokemonType>> allTypes = [];
    for (final form in roster) {
      final detail = await api.getPokemonDetail(form.pokemonId);
      if (detail != null) {
        allTypes.add(
          detail.types.map((t) => TypeChart.stringToType(t)).toList(),
        );
      }
    }
    return allTypes;
  },
);

final opponentTypesProvider =
    FutureProvider.autoDispose<List<List<PokemonType>>>((ref) async {
      final matchup = ref.watch(matchupProvider);
      final team = matchup.opponentTeam;
      final api = ref.read(apiClientProvider.notifier);

      if (team.isEmpty) return [];

      final List<List<PokemonType>> allTypes = [];
      for (final form in team) {
        final detail = await api.getPokemonDetail(form.pokemonId);
        if (detail != null) {
          allTypes.add(
            detail.types.map((t) => TypeChart.stringToType(t)).toList(),
          );
        }
      }
      return allTypes;
    });
final rosterStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final rosterAsync = ref.watch(rosterProvider);
  final roster = rosterAsync.value ?? [];
  final api = ref.read(apiClientProvider.notifier);

  if (roster.isEmpty) {
    return {'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0};
  }

  final totals = {'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0};
  int count = 0;

  for (final form in roster) {
    final detail = await api.getPokemonDetail(form.pokemonId);
    if (detail != null) {
      count++;
      totals['hp'] = totals['hp']! + (detail.baseStats['hp'] ?? 0);
      totals['atk'] = totals['atk']! + (detail.baseStats['atk'] ?? 0);
      totals['def'] = totals['def']! + (detail.baseStats['def'] ?? 0);
      totals['spa'] = totals['spa']! + (detail.baseStats['spa'] ?? 0);
      totals['spd'] = totals['spd']! + (detail.baseStats['spd'] ?? 0);
      totals['spe'] = totals['spe']! + (detail.baseStats['spe'] ?? 0);
    }
  }

  if (count == 0) {
    return {'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0};
  }

  return totals.map((key, value) => MapEntry(key, (value / count).round()));
});
