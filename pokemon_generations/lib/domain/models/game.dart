import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';
part 'game.g.dart';

@freezed
class PokemonGame with _$PokemonGame {
  const factory PokemonGame({
    required String id,
    required String name,
    required String versionGroupId,
    required int generation,
    required List<String> regions,
    @Default(true) bool hasAbilities,
    @Default(true) bool hasNatures,
    @Default(true) bool hasHeldItems,
  }) = _PokemonGame;

  factory PokemonGame.fromJson(Map<String, dynamic> json) => _$PokemonGameFromJson(json);

  static List<PokemonGame> get allGames => [
    const PokemonGame(id: 'red', name: 'Pokémon Red', versionGroupId: 'red-blue', generation: 1, regions: ['Kanto'], hasAbilities: false, hasNatures: false, hasHeldItems: false),
    const PokemonGame(id: 'blue', name: 'Pokémon Blue', versionGroupId: 'red-blue', generation: 1, regions: ['Kanto'], hasAbilities: false, hasNatures: false, hasHeldItems: false),
    const PokemonGame(id: 'yellow', name: 'Pokémon Yellow', versionGroupId: 'yellow', generation: 1, regions: ['Kanto'], hasAbilities: false, hasNatures: false, hasHeldItems: false),
    
    const PokemonGame(id: 'gold', name: 'Pokémon Gold', versionGroupId: 'gold-silver', generation: 2, regions: ['Johto', 'Kanto'], hasAbilities: false, hasNatures: false, hasHeldItems: true),
    const PokemonGame(id: 'silver', name: 'Pokémon Silver', versionGroupId: 'gold-silver', generation: 2, regions: ['Johto', 'Kanto'], hasAbilities: false, hasNatures: false, hasHeldItems: true),
    const PokemonGame(id: 'crystal', name: 'Pokémon Crystal', versionGroupId: 'crystal', generation: 2, regions: ['Johto', 'Kanto'], hasAbilities: false, hasNatures: false, hasHeldItems: true),
    
    const PokemonGame(id: 'ruby', name: 'Pokémon Ruby', versionGroupId: 'ruby-sapphire', generation: 3, regions: ['Hoenn']),
    const PokemonGame(id: 'sapphire', name: 'Pokémon Sapphire', versionGroupId: 'ruby-sapphire', generation: 3, regions: ['Hoenn']),
    const PokemonGame(id: 'emerald', name: 'Pokémon Emerald', versionGroupId: 'emerald', generation: 3, regions: ['Hoenn']),
    const PokemonGame(id: 'firered', name: 'Pokémon FireRed', versionGroupId: 'firered-leafgreen', generation: 3, regions: ['Kanto']),
    const PokemonGame(id: 'leafgreen', name: 'Pokémon LeafGreen', versionGroupId: 'firered-leafgreen', generation: 3, regions: ['Kanto']),
    
    const PokemonGame(id: 'diamond', name: 'Pokémon Diamond', versionGroupId: 'diamond-pearl', generation: 4, regions: ['Sinnoh']),
    const PokemonGame(id: 'pearl', name: 'Pokémon Pearl', versionGroupId: 'diamond-pearl', generation: 4, regions: ['Sinnoh']),
    const PokemonGame(id: 'platinum', name: 'Pokémon Platinum', versionGroupId: 'platinum', generation: 4, regions: ['Sinnoh']),
    const PokemonGame(id: 'heartgold', name: 'Pokémon HeartGold', versionGroupId: 'heartgold-soulsilver', generation: 4, regions: ['Johto', 'Kanto']),
    const PokemonGame(id: 'soulsilver', name: 'Pokémon SoulSilver', versionGroupId: 'heartgold-soulsilver', generation: 4, regions: ['Johto', 'Kanto']),
    
    const PokemonGame(id: 'black', name: 'Pokémon Black', versionGroupId: 'black-white', generation: 5, regions: ['Unova']),
    const PokemonGame(id: 'white', name: 'Pokémon White', versionGroupId: 'black-white', generation: 5, regions: ['Unova']),
    const PokemonGame(id: 'black-2', name: 'Pokémon Black 2', versionGroupId: 'black-2-white-2', generation: 5, regions: ['Unova']),
    const PokemonGame(id: 'white-2', name: 'Pokémon White 2', versionGroupId: 'black-2-white-2', generation: 5, regions: ['Unova']),
    
    const PokemonGame(id: 'x', name: 'Pokémon X', versionGroupId: 'x-y', generation: 6, regions: ['Kalos']),
    const PokemonGame(id: 'y', name: 'Pokémon Y', versionGroupId: 'x-y', generation: 6, regions: ['Kalos']),
    const PokemonGame(id: 'omega-ruby', name: 'Pokémon Omega Ruby', versionGroupId: 'omega-ruby-alpha-sapphire', generation: 6, regions: ['Hoenn']),
    const PokemonGame(id: 'alpha-sapphire', name: 'Pokémon Alpha Sapphire', versionGroupId: 'omega-ruby-alpha-sapphire', generation: 6, regions: ['Hoenn']),
    
    const PokemonGame(id: 'sun', name: 'Pokémon Sun', versionGroupId: 'sun-moon', generation: 7, regions: ['Alola']),
    const PokemonGame(id: 'moon', name: 'Pokémon Moon', versionGroupId: 'sun-moon', generation: 7, regions: ['Alola']),
    const PokemonGame(id: 'ultra-sun', name: 'Pokémon Ultra Sun', versionGroupId: 'ultra-sun-ultra-moon', generation: 7, regions: ['Alola']),
    const PokemonGame(id: 'ultra-moon', name: 'Pokémon Ultra Moon', versionGroupId: 'ultra-sun-ultra-moon', generation: 7, regions: ['Alola']),
    
    const PokemonGame(id: 'sword', name: 'Pokémon Sword', versionGroupId: 'sword-shield', generation: 8, regions: ['Galar']),
    const PokemonGame(id: 'shield', name: 'Pokémon Shield', versionGroupId: 'sword-shield', generation: 8, regions: ['Galar']),
    const PokemonGame(id: 'legends-arceus', name: 'Pokémon Legends: Arceus', versionGroupId: 'legends-arceus', generation: 8, regions: ['Hisui']),
    
    const PokemonGame(id: 'scarlet', name: 'Pokémon Scarlet', versionGroupId: 'scarlet-violet', generation: 9, regions: ['Paldea']),
    const PokemonGame(id: 'violet', name: 'Pokémon Violet', versionGroupId: 'scarlet-violet', generation: 9, regions: ['Paldea']),
    
    const PokemonGame(id: 'champions', name: 'Pokémon Champions', versionGroupId: 'scarlet-violet', generation: 9, regions: ['Global']),
  ];
}
