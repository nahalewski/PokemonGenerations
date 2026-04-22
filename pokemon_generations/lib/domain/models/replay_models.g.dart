// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BattleReplayImpl _$$BattleReplayImplFromJson(Map<String, dynamic> json) =>
    _$BattleReplayImpl(
      version: (json['version'] as num).toInt(),
      battleId: json['battleId'] as String,
      ruleset: json['ruleset'] as String,
      startTimestampMs: (json['startTimestampMs'] as num).toInt(),
      rngSeed: (json['rngSeed'] as num).toInt(),
      p1: ReplayPlayer.fromJson(json['p1'] as Map<String, dynamic>),
      p2: ReplayPlayer.fromJson(json['p2'] as Map<String, dynamic>),
      turns: (json['turns'] as List<dynamic>)
          .map((e) => ReplayTurn.fromJson(e as Map<String, dynamic>))
          .toList(),
      winner: json['winner'] as String,
      endReason: json['endReason'] as String?,
    );

Map<String, dynamic> _$$BattleReplayImplToJson(_$BattleReplayImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'battleId': instance.battleId,
      'ruleset': instance.ruleset,
      'startTimestampMs': instance.startTimestampMs,
      'rngSeed': instance.rngSeed,
      'p1': instance.p1,
      'p2': instance.p2,
      'turns': instance.turns,
      'winner': instance.winner,
      'endReason': instance.endReason,
    };

_$ReplayPlayerImpl _$$ReplayPlayerImplFromJson(Map<String, dynamic> json) =>
    _$ReplayPlayerImpl(
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      team: (json['team'] as List<dynamic>)
          .map((e) => ReplayPokemonState.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ReplayPlayerImplToJson(_$ReplayPlayerImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'displayName': instance.displayName,
      'team': instance.team,
    };

_$ReplayPokemonStateImpl _$$ReplayPokemonStateImplFromJson(
  Map<String, dynamic> json,
) => _$ReplayPokemonStateImpl(
  pokemonId: json['pokemonId'] as String,
  nickname: json['nickname'] as String,
  level: (json['level'] as num).toInt(),
  maxHp: (json['maxHp'] as num).toInt(),
  currentHp: (json['currentHp'] as num).toInt(),
  moveIds: (json['moveIds'] as List<dynamic>).map((e) => e as String).toList(),
  abilityId: json['abilityId'] as String?,
  itemId: json['itemId'] as String?,
  gender: json['gender'] as String?,
  isShiny: json['isShiny'] as bool? ?? false,
);

Map<String, dynamic> _$$ReplayPokemonStateImplToJson(
  _$ReplayPokemonStateImpl instance,
) => <String, dynamic>{
  'pokemonId': instance.pokemonId,
  'nickname': instance.nickname,
  'level': instance.level,
  'maxHp': instance.maxHp,
  'currentHp': instance.currentHp,
  'moveIds': instance.moveIds,
  'abilityId': instance.abilityId,
  'itemId': instance.itemId,
  'gender': instance.gender,
  'isShiny': instance.isShiny,
};

_$ReplayTurnImpl _$$ReplayTurnImplFromJson(Map<String, dynamic> json) =>
    _$ReplayTurnImpl(
      turnIndex: (json['turnIndex'] as num).toInt(),
      events: (json['events'] as List<dynamic>)
          .map((e) => ReplayEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ReplayTurnImplToJson(_$ReplayTurnImpl instance) =>
    <String, dynamic>{
      'turnIndex': instance.turnIndex,
      'events': instance.events,
    };

_$ReplayEventImpl _$$ReplayEventImplFromJson(Map<String, dynamic> json) =>
    _$ReplayEventImpl(
      timestampMs: (json['timestampMs'] as num).toInt(),
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ReplayEventImplToJson(_$ReplayEventImpl instance) =>
    <String, dynamic>{
      'timestampMs': instance.timestampMs,
      'type': instance.type,
      'data': instance.data,
    };
