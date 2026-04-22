// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamImpl _$$TeamImplFromJson(Map<String, dynamic> json) => _$TeamImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  slots: (json['slots'] as List<dynamic>)
      .map((e) => PokemonForm.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String? ?? '',
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  winCount: (json['winCount'] as num?)?.toInt() ?? 0,
  lossCount: (json['lossCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$TeamImplToJson(_$TeamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slots': instance.slots,
      'notes': instance.notes,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'winCount': instance.winCount,
      'lossCount': instance.lossCount,
    };

_$RosterImpl _$$RosterImplFromJson(Map<String, dynamic> json) => _$RosterImpl(
  id: json['id'] as String,
  pokemon:
      (json['pokemon'] as List<dynamic>?)
          ?.map((e) => PokemonForm.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  presets:
      (json['presets'] as List<dynamic>?)
          ?.map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$RosterImplToJson(_$RosterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pokemon': instance.pokemon,
      'presets': instance.presets,
    };
