// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PokemonGameImpl _$$PokemonGameImplFromJson(Map<String, dynamic> json) =>
    _$PokemonGameImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      versionGroupId: json['versionGroupId'] as String,
      generation: (json['generation'] as num).toInt(),
      regions: (json['regions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      hasAbilities: json['hasAbilities'] as bool? ?? true,
      hasNatures: json['hasNatures'] as bool? ?? true,
      hasHeldItems: json['hasHeldItems'] as bool? ?? true,
    );

Map<String, dynamic> _$$PokemonGameImplToJson(_$PokemonGameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'versionGroupId': instance.versionGroupId,
      'generation': instance.generation,
      'regions': instance.regions,
      'hasAbilities': instance.hasAbilities,
      'hasNatures': instance.hasNatures,
      'hasHeldItems': instance.hasHeldItems,
    };
