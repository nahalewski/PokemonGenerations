import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/social.dart';
import '../../domain/models/gift.dart';

part 'social_state.freezed.dart';

@freezed
class SocialState with _$SocialState {
  const factory SocialState({
    @Default([]) List<SocialUser> users,
    @Default([]) List<SocialUser> friends,
    @Default([]) List<Map<String, String>> pendingRequests,
    @Default([]) List<ChatMessage> chatMessages,
    @Default([]) List<ChatMessage> unreadMessages,
    @Default([]) List<Map<String, dynamic>> incomingChallenges,
    Map<String, dynamic>? globalBroadcast,
    @Default([]) List<Gift> pendingGifts,
    @Default([]) List<String> dismissedGiftIds,
    DateTime? lastReadTime,
    String? dismissedBroadcastAt,
    @Default(false) bool isLoading,
    @Default(true) bool isServerConnected,
    String? error,
  }) = _SocialState;
}
