import 'package:freezed_annotation/freezed_annotation.dart';
import 'pokemon_form.dart';
import 'analysis.dart';

part 'history.freezed.dart';
part 'history.g.dart';

@freezed
class AnalysisHistory with _$AnalysisHistory {
  const factory AnalysisHistory({
    required String id,
    required DateTime timestamp,
    required List<PokemonForm> opponentTeam,
    required MatchupAnalysis result,
    required String format,
  }) = _AnalysisHistory;

  factory AnalysisHistory.fromJson(Map<String, dynamic> json) => _$AnalysisHistoryFromJson(json);
}
