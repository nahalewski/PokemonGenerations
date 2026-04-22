// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MoveDetailImpl _$$MoveDetailImplFromJson(Map<String, dynamic> json) =>
    _$MoveDetailImpl(
      name: json['name'] as String,
      type: json['type'] as String,
      damageClass: json['damageClass'] as String,
      power: (json['power'] as num?)?.toInt(),
      accuracy: (json['accuracy'] as num?)?.toInt(),
      pp: (json['pp'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$$MoveDetailImplToJson(_$MoveDetailImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'damageClass': instance.damageClass,
      'power': instance.power,
      'accuracy': instance.accuracy,
      'pp': instance.pp,
      'description': instance.description,
    };
