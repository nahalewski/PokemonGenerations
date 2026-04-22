import 'package:freezed_annotation/freezed_annotation.dart';
import 'pokemon.dart';
import 'move.dart';

part 'analysis.freezed.dart';
part 'analysis.g.dart';

@freezed
class MatchupAnalysis with _$MatchupAnalysis {
  const factory MatchupAnalysis({
    required String id,
    required DateTime timestamp,
    required List<String> recommendedPicks,
    required List<String> recommendedLeads,
    required List<ThreatReport> threats,
    required List<MoveRecommendation> moveRecommendations,
    @Default([]) List<String> simulationLog,
    required double matchupScore,
    required String reasoning,
    required String format,
  }) = _MatchupAnalysis;

  factory MatchupAnalysis.fromJson(Map<String, dynamic> json) => _$MatchupAnalysisFromJson(json);
}

@freezed
class ThreatReport with _$ThreatReport {
  const factory ThreatReport({
    required String pokemonName,
    required double threatLevel, // 0.0 to 1.0
    required String description,
    required List<String> countersFromRoster,
  }) = _ThreatReport;

  factory ThreatReport.fromJson(Map<String, dynamic> json) => _$ThreatReportFromJson(json);
}

@freezed
class MoveRecommendation with _$MoveRecommendation {
  const factory MoveRecommendation({
    required String sourcePokemonName,
    required String targetPokemonName,
    required String moveName,
    required String damageRange,
    required String reasoning,
    @Default(false) bool isKoChance,
  }) = _MoveRecommendation;

  factory MoveRecommendation.fromJson(Map<String, dynamic> json) => _$MoveRecommendationFromJson(json);
}

@freezed
class DamageResult with _$DamageResult {
  const factory DamageResult({
    required String attackerName,
    required String defenderName,
    required String moveName,
    required List<int> damageRolls,
    required String percentageRange,
    required int minDamage,
    required int maxDamage,
  }) = _DamageResult;

  factory DamageResult.fromJson(Map<String, dynamic> json) => _$DamageResultFromJson(json);
}
