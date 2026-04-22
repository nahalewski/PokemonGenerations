// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchupAnalysisImpl _$$MatchupAnalysisImplFromJson(
  Map<String, dynamic> json,
) => _$MatchupAnalysisImpl(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  recommendedPicks: (json['recommendedPicks'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendedLeads: (json['recommendedLeads'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  threats: (json['threats'] as List<dynamic>)
      .map((e) => ThreatReport.fromJson(e as Map<String, dynamic>))
      .toList(),
  moveRecommendations: (json['moveRecommendations'] as List<dynamic>)
      .map((e) => MoveRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  simulationLog:
      (json['simulationLog'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  matchupScore: (json['matchupScore'] as num).toDouble(),
  reasoning: json['reasoning'] as String,
  format: json['format'] as String,
);

Map<String, dynamic> _$$MatchupAnalysisImplToJson(
  _$MatchupAnalysisImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'recommendedPicks': instance.recommendedPicks,
  'recommendedLeads': instance.recommendedLeads,
  'threats': instance.threats,
  'moveRecommendations': instance.moveRecommendations,
  'simulationLog': instance.simulationLog,
  'matchupScore': instance.matchupScore,
  'reasoning': instance.reasoning,
  'format': instance.format,
};

_$ThreatReportImpl _$$ThreatReportImplFromJson(Map<String, dynamic> json) =>
    _$ThreatReportImpl(
      pokemonName: json['pokemonName'] as String,
      threatLevel: (json['threatLevel'] as num).toDouble(),
      description: json['description'] as String,
      countersFromRoster: (json['countersFromRoster'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$ThreatReportImplToJson(_$ThreatReportImpl instance) =>
    <String, dynamic>{
      'pokemonName': instance.pokemonName,
      'threatLevel': instance.threatLevel,
      'description': instance.description,
      'countersFromRoster': instance.countersFromRoster,
    };

_$MoveRecommendationImpl _$$MoveRecommendationImplFromJson(
  Map<String, dynamic> json,
) => _$MoveRecommendationImpl(
  sourcePokemonName: json['sourcePokemonName'] as String,
  targetPokemonName: json['targetPokemonName'] as String,
  moveName: json['moveName'] as String,
  damageRange: json['damageRange'] as String,
  reasoning: json['reasoning'] as String,
  isKoChance: json['isKoChance'] as bool? ?? false,
);

Map<String, dynamic> _$$MoveRecommendationImplToJson(
  _$MoveRecommendationImpl instance,
) => <String, dynamic>{
  'sourcePokemonName': instance.sourcePokemonName,
  'targetPokemonName': instance.targetPokemonName,
  'moveName': instance.moveName,
  'damageRange': instance.damageRange,
  'reasoning': instance.reasoning,
  'isKoChance': instance.isKoChance,
};

_$DamageResultImpl _$$DamageResultImplFromJson(Map<String, dynamic> json) =>
    _$DamageResultImpl(
      attackerName: json['attackerName'] as String,
      defenderName: json['defenderName'] as String,
      moveName: json['moveName'] as String,
      damageRolls: (json['damageRolls'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      percentageRange: json['percentageRange'] as String,
      minDamage: (json['minDamage'] as num).toInt(),
      maxDamage: (json['maxDamage'] as num).toInt(),
    );

Map<String, dynamic> _$$DamageResultImplToJson(_$DamageResultImpl instance) =>
    <String, dynamic>{
      'attackerName': instance.attackerName,
      'defenderName': instance.defenderName,
      'moveName': instance.moveName,
      'damageRolls': instance.damageRolls,
      'percentageRange': instance.percentageRange,
      'minDamage': instance.minDamage,
      'maxDamage': instance.maxDamage,
    };
