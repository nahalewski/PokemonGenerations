import 'package:freezed_annotation/freezed_annotation.dart';
import 'pokemon_form.dart';

part 'social.freezed.dart';
part 'social.g.dart';

@freezed
class SocialUser with _$SocialUser {
  const factory SocialUser({
    required String username,
    required String displayName,
    @Default([]) List<Map<String, dynamic>> roster,
    @Default('offline') String status, // 'online', 'battling', 'offline'
    String? currentBattleId,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(false) bool forcePasscodeChange,
    String? profileImageUrl,
    @Default({}) Map<String, dynamic> cardCustomization,
    @Default([]) List<Map<String, dynamic>> recentReplays,
  }) = _SocialUser;

  factory SocialUser.fromJson(Map<String, dynamic> json) => _$SocialUserFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String sender,
    required String text,
    required DateTime timestamp,
    String? recipient, // For @Admin private messages
    @Default('regular') String type, // 'regular', 'admin_reset', 'broadcast'
    String? profileImageUrl,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}

@freezed
class BattleSession with _$BattleSession {
  const factory BattleSession({
    required String id,
    required String player1, // Username
    required String player2, // Username
    required String status, // 'pending', 'active', 'finished'
    String? currentTurn, // Username of whose turn it is
    @Default(0) int turnCount,
    @Default([]) List<Map<String, dynamic>> history,
    Map<String, dynamic>? lastMove,
    @Default({}) Map<String, dynamic> hpState,
    @Default({}) Map<String, List<Map<String, dynamic>>> rosters,
    DateTime? lastUpdate,
  }) = _BattleSession;

  factory BattleSession.fromJson(Map<String, dynamic> json) => _$BattleSessionFromJson(json);
}
