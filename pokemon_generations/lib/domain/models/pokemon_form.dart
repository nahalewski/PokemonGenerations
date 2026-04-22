import 'package:freezed_annotation/freezed_annotation.dart';

part 'pokemon_form.freezed.dart';
part 'pokemon_form.g.dart';

@freezed
class PokemonForm with _$PokemonForm {
  const factory PokemonForm({
    @Default('') String id,
    @Default('') String pokemonId,
    String? pokemonName,
    @Default('Unknown') String ability,
    @Default('None') String item,
    @Default('Neutral') String nature,
    @Default({'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0}) Map<String, int> evs,
    @Default({'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31}) Map<String, int> ivs,
    @Default([]) List<String> moves,
    @Default(50) int level,
    @Default('Normal') String teraType,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int boxIndex,
    @Default(-1) int slotIndex, // -1 means in active roster
  }) = _PokemonForm;


  factory PokemonForm.fromJson(Map<String, dynamic> json) => _$PokemonFormFromJson(json);
}
