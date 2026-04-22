// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PokemonFormImpl _$$PokemonFormImplFromJson(Map<String, dynamic> json) =>
    _$PokemonFormImpl(
      id: json['id'] as String? ?? '',
      pokemonId: json['pokemonId'] as String? ?? '',
      pokemonName: json['pokemonName'] as String?,
      ability: json['ability'] as String? ?? 'Unknown',
      item: json['item'] as String? ?? 'None',
      nature: json['nature'] as String? ?? 'Neutral',
      evs:
          (json['evs'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
      ivs:
          (json['ivs'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {
            'hp': 31,
            'atk': 31,
            'def': 31,
            'spa': 31,
            'spd': 31,
            'spe': 31,
          },
      moves:
          (json['moves'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      level: (json['level'] as num?)?.toInt() ?? 50,
      teraType: json['teraType'] as String? ?? 'Normal',
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      boxIndex: (json['boxIndex'] as num?)?.toInt() ?? 0,
      slotIndex: (json['slotIndex'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$$PokemonFormImplToJson(_$PokemonFormImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pokemonId': instance.pokemonId,
      'pokemonName': instance.pokemonName,
      'ability': instance.ability,
      'item': instance.item,
      'nature': instance.nature,
      'evs': instance.evs,
      'ivs': instance.ivs,
      'moves': instance.moves,
      'level': instance.level,
      'teraType': instance.teraType,
      'wins': instance.wins,
      'losses': instance.losses,
      'boxIndex': instance.boxIndex,
      'slotIndex': instance.slotIndex,
    };
