// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocialUserImpl _$$SocialUserImplFromJson(Map<String, dynamic> json) =>
    _$SocialUserImpl(
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      roster:
          (json['roster'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'offline',
      currentBattleId: json['currentBattleId'] as String?,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      forcePasscodeChange: json['forcePasscodeChange'] as bool? ?? false,
      profileImageUrl: json['profileImageUrl'] as String?,
      cardCustomization:
          json['cardCustomization'] as Map<String, dynamic>? ?? const {},
      recentReplays:
          (json['recentReplays'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SocialUserImplToJson(_$SocialUserImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'displayName': instance.displayName,
      'roster': instance.roster,
      'status': instance.status,
      'currentBattleId': instance.currentBattleId,
      'wins': instance.wins,
      'losses': instance.losses,
      'forcePasscodeChange': instance.forcePasscodeChange,
      'profileImageUrl': instance.profileImageUrl,
      'cardCustomization': instance.cardCustomization,
      'recentReplays': instance.recentReplays,
    };

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      sender: json['sender'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recipient: json['recipient'] as String?,
      type: json['type'] as String? ?? 'regular',
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'recipient': instance.recipient,
      'type': instance.type,
      'profileImageUrl': instance.profileImageUrl,
    };

_$BattleSessionImpl _$$BattleSessionImplFromJson(Map<String, dynamic> json) =>
    _$BattleSessionImpl(
      id: json['id'] as String,
      player1: json['player1'] as String,
      player2: json['player2'] as String,
      status: json['status'] as String,
      currentTurn: json['currentTurn'] as String?,
      turnCount: (json['turnCount'] as num?)?.toInt() ?? 0,
      history:
          (json['history'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      lastMove: json['lastMove'] as Map<String, dynamic>?,
      hpState: json['hpState'] as Map<String, dynamic>? ?? const {},
      rosters:
          (json['rosters'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>)
                  .map((e) => e as Map<String, dynamic>)
                  .toList(),
            ),
          ) ??
          const {},
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$$BattleSessionImplToJson(_$BattleSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player1': instance.player1,
      'player2': instance.player2,
      'status': instance.status,
      'currentTurn': instance.currentTurn,
      'turnCount': instance.turnCount,
      'history': instance.history,
      'lastMove': instance.lastMove,
      'hpState': instance.hpState,
      'rosters': instance.rosters,
      'lastUpdate': instance.lastUpdate?.toIso8601String(),
    };
