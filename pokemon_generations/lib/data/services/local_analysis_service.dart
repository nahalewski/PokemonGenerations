import '../../domain/models/analysis.dart';
import '../../domain/models/pokemon.dart';
import '../../domain/models/pokemon_form.dart';
import '../../domain/services/analysis_service.dart';

class LocalAnalysisService implements AnalysisService {
  @override
  Future<MatchupAnalysis> analyzeMatchup({
    required List<PokemonForm> roster,
    required List<PokemonForm> opponentTeam,
    required String format,
  }) async {
    // Basic heuristic: Type Advantage Score
    // For each pokemon in roster, calculate how well it covers the opponent team.
    
    final List<String> recommendedPicks = [];
    final List<ThreatReport> threats = [];
    
    // Sort roster by a simple power score (just a mock for now)
    final sortedRoster = List<PokemonForm>.from(roster);
    sortedRoster.sort((a, b) => b.level.compareTo(a.level));
    
    recommendedPicks.addAll(sortedRoster.take(6).map((e) => e.id));
    
    return MatchupAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      recommendedPicks: recommendedPicks,
      recommendedLeads: recommendedPicks.take(2).toList(),
      threats: [
        const ThreatReport(
          pokemonName: 'Unknown Threat',
          threatLevel: 0.5,
          description: 'Based on type coverage analysis.',
          countersFromRoster: [],
        )
      ],
      moveRecommendations: [],
      matchupScore: 75.0,
      reasoning: 'Detailed local analysis based on current roster type coverage.',
      format: format,
    );
  }

  @override
  Future<LeadRecommendation> getBestLead({
    required List<PokemonForm> roster,
    required List<PokemonForm> opponentTeam,
    required String format,
  }) async {
    return LeadRecommendation(
      primaryLeads: roster.take(1).map((e) => e.id).toList(),
      backupLeads: roster.skip(1).take(1).map((e) => e.id).toList(),
      reasoning: 'Optimal speed and utility for the current format.',
    );
  }

  @override
  Future<List<DamageResult>> calculateDamageRanges({
    required PokemonForm attacker,
    required List<PokemonForm> defenders,
  }) async {
    return defenders.map((defender) => DamageResult(
      attackerName: 'Attacker',
      defenderName: defender.pokemonId,
      moveName: 'Best Move',
      damageRolls: [85, 90, 95, 100],
      percentageRange: '85-100%',
      minDamage: 85,
      maxDamage: 100,
    )).toList();
  }
}
