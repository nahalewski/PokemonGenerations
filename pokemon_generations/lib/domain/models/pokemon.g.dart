// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PokemonMoveImpl _$$PokemonMoveImplFromJson(Map<String, dynamic> json) =>
    _$PokemonMoveImpl(
      name: json['name'] as String,
      learnLevel: (json['learnLevel'] as num).toInt(),
      learnMethod: json['learnMethod'] as String,
      type: json['type'] as String? ?? 'normal',
      power: (json['power'] as num?)?.toInt() ?? 60,
      damageClass: json['damageClass'] as String? ?? 'physical',
      statusEffect: json['statusEffect'] as String? ?? 'none',
      statusChance: (json['statusChance'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PokemonMoveImplToJson(_$PokemonMoveImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'learnLevel': instance.learnLevel,
      'learnMethod': instance.learnMethod,
      'type': instance.type,
      'power': instance.power,
      'damageClass': instance.damageClass,
      'statusEffect': instance.statusEffect,
      'statusChance': instance.statusChance,
    };

_$PokemonImpl _$$PokemonImplFromJson(Map<String, dynamic> json) =>
    _$PokemonImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      baseStats: Map<String, int>.from(json['baseStats'] as Map),
      abilities: (json['abilities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      availableMoves:
          (json['availableMoves'] as List<dynamic>?)
              ?.map((e) => PokemonMove.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCustom: json['isCustom'] as bool? ?? false,
      description: json['description'] as String?,
      latestCryUrl: json['latestCryUrl'] as String?,
      legacyCryUrl: json['legacyCryUrl'] as String?,
    );

Map<String, dynamic> _$$PokemonImplToJson(_$PokemonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'types': instance.types,
      'baseStats': instance.baseStats,
      'abilities': instance.abilities,
      'availableMoves': instance.availableMoves,
      'isCustom': instance.isCustom,
      'description': instance.description,
      'latestCryUrl': instance.latestCryUrl,
      'legacyCryUrl': instance.legacyCryUrl,
    };
