import 'package:freezed_annotation/freezed_annotation.dart';
import 'pokemon_form.dart';

part 'team.freezed.dart';
part 'team.g.dart';

@freezed
class Team with _$Team {
  const factory Team({
    required String id,
    required String name,
    required List<PokemonForm> slots,
    @Default('') String notes,
    required DateTime updatedAt,
    @Default(0) int winCount,
    @Default(0) int lossCount,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

@freezed
class Roster with _$Roster {
  const factory Roster({
    required String id,
    @Default([]) List<PokemonForm> pokemon,
    @Default([]) List<Team> presets,
  }) = _Roster;

  factory Roster.fromJson(Map<String, dynamic> json) => _$RosterFromJson(json);
}
