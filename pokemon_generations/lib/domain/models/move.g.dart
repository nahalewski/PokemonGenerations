// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MoveImpl _$$MoveImplFromJson(Map<String, dynamic> json) => _$MoveImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  category: json['category'] as String,
  power: (json['power'] as num?)?.toInt(),
  accuracy: (json['accuracy'] as num?)?.toInt(),
  pp: (json['pp'] as num).toInt(),
  priority: (json['priority'] as num).toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$$MoveImplToJson(_$MoveImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'category': instance.category,
      'power': instance.power,
      'accuracy': instance.accuracy,
      'pp': instance.pp,
      'priority': instance.priority,
      'description': instance.description,
    };

_$AbilityImpl _$$AbilityImplFromJson(Map<String, dynamic> json) =>
    _$AbilityImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$AbilityImplToJson(_$AbilityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  spriteUrl: json['spriteUrl'] as String?,
);

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'spriteUrl': instance.spriteUrl,
    };
