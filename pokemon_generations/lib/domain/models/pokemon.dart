import 'package:freezed_annotation/freezed_annotation.dart';

part 'pokemon.freezed.dart';
part 'pokemon.g.dart';

@freezed
class PokemonMove with _$PokemonMove {
  const factory PokemonMove({
    required String name,
    required int learnLevel,
    required String learnMethod,
    @Default('normal') String type,
    @Default(60) int power,
    @Default('physical') String damageClass, // physical, special, status
    @Default('none') String statusEffect, // brn, psn, tox, par, slp, frb, none
    @Default(0) int statusChance, // 0-100
  }) = _PokemonMove;

  factory PokemonMove.fromJson(Map<String, dynamic> json) => _$PokemonMoveFromJson(json);
}

@freezed
class Pokemon with _$Pokemon {
  const Pokemon._();

  const factory Pokemon({
    required String id,
    required String name,
    required List<String> types,
    required Map<String, int> baseStats,
    required List<String> abilities,
    @Default([]) List<PokemonMove> availableMoves,
    @JsonKey(includeFromJson: false, includeToJson: false) String? spriteUrl,
    @Default(false) bool isCustom,
    String? description,
    String? latestCryUrl,
    String? legacyCryUrl,
  }) = _Pokemon;

  factory Pokemon.fromJson(Map<String, dynamic> json) => _$PokemonFromJson(json);

  String get officialArtworkUrl => 
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get frontSpriteUrl => 
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  String get backSpriteUrl => 
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/$id.png';

  /// Returns a prioritized list of sprites for the player's view (prefers back).
  List<String> get backSpriteUrls => [
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/$id.png',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png', // Fallback to front
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png',
  ];

  /// Returns a prioritized list of sprites for the opponent's view (prefers front).
  List<String> get frontSpriteUrls => [
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/$id.png',
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/$id.png', // Last resort fallback
  ];

  String? get bestCryUrl => latestCryUrl ?? legacyCryUrl;
}
