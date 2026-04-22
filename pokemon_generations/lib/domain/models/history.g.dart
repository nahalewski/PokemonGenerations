// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalysisHistoryImpl _$$AnalysisHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$AnalysisHistoryImpl(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  opponentTeam: (json['opponentTeam'] as List<dynamic>)
      .map((e) => PokemonForm.fromJson(e as Map<String, dynamic>))
      .toList(),
  result: MatchupAnalysis.fromJson(json['result'] as Map<String, dynamic>),
  format: json['format'] as String,
);

Map<String, dynamic> _$$AnalysisHistoryImplToJson(
  _$AnalysisHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'opponentTeam': instance.opponentTeam,
  'result': instance.result,
  'format': instance.format,
};
