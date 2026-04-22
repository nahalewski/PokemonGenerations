import '../models/analysis.dart';
import '../models/pokemon.dart';
import '../models/team.dart';
import '../models/pokemon_form.dart';

abstract class AnalysisService {
  Future<MatchupAnalysis> analyzeMatchup({
    required List<PokemonForm> roster,
    required List<PokemonForm> opponentTeam,
    required String format,
  });

  Future<LeadRecommendation> getBestLead({
    required List<PokemonForm> roster,
    required List<PokemonForm> opponentTeam,
    required String format,
  });

  Future<List<DamageResult>> calculateDamageRanges({
    required PokemonForm attacker,
    required List<PokemonForm> defenders,
  });
}

class LeadRecommendation {
  final List<String> primaryLeads; // IDs
  final List<String> backupLeads;
  final String reasoning;

  LeadRecommendation({
    required this.primaryLeads,
    required this.backupLeads,
    required this.reasoning,
  });
}
