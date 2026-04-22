import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_client.dart';
import '../../core/networking/dio_client.dart';
import '../../core/settings/app_settings_controller.dart';
import '../auth/auth_controller.dart';
import '../../data/providers.dart';
import 'social_state.dart';
import '../../domain/models/social.dart';
import '../../domain/models/gift.dart';
import '../../domain/models/pokemon_form.dart';
import '../inventory/inventory_provider.dart';

final socialControllerProvider = StateNotifierProvider<SocialController, SocialState>((ref) {
  return SocialController(ref);
});

class SocialController extends StateNotifier<SocialState> {
  final Ref ref;
  Timer? _pollingTimer;

  SocialController(this.ref) : super(const SocialState()) {
    startPolling();
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _fetchData(); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchData();
      _syncProfilePeriodic();
    });
  }

  void _syncProfilePeriodic() {
    // Only push occasionally to avoid spamming the server
    final now = DateTime.now();
    _lastSyncTime ??= now.subtract(const Duration(minutes: 1));
    
    if (now.difference(_lastSyncTime!).inSeconds >= 30) {
      updateStatus();
      _lastSyncTime = now;
    }
  }

  DateTime? _lastSyncTime;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty) return;

    try {
      final api = ref.read(apiClientProvider.notifier);
      
      final usersFuture = api.fetchGlobalUsers(baseUrl);
      final chatFuture = api.fetchGlobalChat(baseUrl);
      final friendsFuture = profile != null ? api.fetchFriends(baseUrl, profile.username) : Future.value({'friends': <SocialUser>[], 'pending': []});
      final challengesFuture = profile != null ? api.fetchPendingChallenges(baseUrl, profile.username) : Future.value(<Map<String, dynamic>>[]);
      final giftsFuture = profile != null ? api.fetchPendingGifts(baseUrl, profile.username) : Future.value(<Gift>[]);
      final broadcastFuture = api.fetchBroadcast(baseUrl);

      final results = await Future.wait<dynamic>([usersFuture, chatFuture, friendsFuture, challengesFuture, broadcastFuture, giftsFuture]);
      final chatMessages = (results[1] as List<ChatMessage>?) ?? [];
      final friendsData = (results[2] as Map<String, dynamic>?) ?? {'friends': <SocialUser>[], 'pending': []};
      final pendingGifts = (results[5] as List<Gift>?) ?? [];

      // Identify unread messages - only if profile exists
      List<ChatMessage> newUnreads = [];
      if (profile != null) {
        final lastRead = state.lastReadTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        newUnreads = chatMessages.where((msg) {
          // Rule: Hide private messages unless you are the sender or admin
          final isPrivate = msg.recipient != null && msg.recipient != '';
          if (isPrivate && msg.sender != profile.username && profile.username != 'admin') {
            return false;
          }

          return msg.sender != profile.username && 
                 msg.timestamp.isAfter(lastRead) &&
                 !state.unreadMessages.any((m) => m.id == msg.id);
        }).toList();
      }

      // Filter state messages
      final filteredChat = chatMessages.where((msg) {
        final isPrivate = msg.recipient != null && msg.recipient != '';
        if (isPrivate && profile != null && msg.sender != profile.username && profile.username != 'admin') {
          return false;
        }
        return true;
      }).toList();

      state = state.copyWith(
        users: (results[0] as List<SocialUser>?) ?? <SocialUser>[],
        chatMessages: filteredChat,
        friends: (friendsData['friends'] as List<SocialUser>?) ?? <SocialUser>[],
        pendingRequests: (friendsData['pending'] as List?)?.map((e) => Map<String, String>.from(e as Map)).toList() ?? <Map<String, String>>[],
        incomingChallenges: (results[3] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? <Map<String, dynamic>>[],
        globalBroadcast: (results[4] != null && (results[4] as Map)['sentAt'] != state.dismissedBroadcastAt)
            ? Map<String, dynamic>.from(results[4] as Map)
            : null,
        pendingGifts: pendingGifts,
        unreadMessages: [...state.unreadMessages, ...newUnreads],
        isLoading: false,
        isServerConnected: true,
      );
    } catch (e) {
      print('[SOCIAL] Polling Failed: $e'); // Critical for web debugging
      state = state.copyWith(
        error: e.toString(), 
        isLoading: false,
        isServerConnected: false,
      );
    }
  }

  void dismissMessage(String messageId) {
    state = state.copyWith(
      unreadMessages: state.unreadMessages.where((m) => m.id != messageId).toList(),
      lastReadTime: DateTime.now(), // Softly update so we don't show it again
    );
  }

  void markAllRead() {
    state = state.copyWith(unreadMessages: [], lastReadTime: DateTime.now());
  }

  Future<void> updateTrainerCard(Map<String, dynamic> cardCustomization) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (profile == null) return;

    try {
      await ref.read(dioProvider).post(
        '$baseUrl/api/user/profile/card',
        data: {
          'username': profile.username,
          'cardCustomization': cardCustomization,
        },
      );
      // Logic for local update handled by next polling cycle
    } catch (e) {
      print('[SOCIAL] Error updating trainer card: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserReplays(String username) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    try {
      final res = await ref.read(dioProvider).get('$baseUrl/api/replays/$username');
      return List<Map<String, dynamic>>.from(res.data);
    } catch (e) {
      return [];
    }
  }

  void dismissBroadcast() {
    if (state.globalBroadcast != null) {
      final sentAt = state.globalBroadcast!['sentAt'] as String?;
      state = state.copyWith(
        dismissedBroadcastAt: sentAt,
        globalBroadcast: null,
      );
    }
  }

  void dismissGiftNotification(String giftId) {
    state = state.copyWith(
      dismissedGiftIds: [...state.dismissedGiftIds, giftId],
    );
  }

  Future<void> syncAll() async {
    await _fetchData();
  }

  Future<void> sendMessage(String text) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return;

    final api = ref.read(apiClientProvider.notifier);
    
    // Check for @Admin prefix
    String? recipient;
    if (text.trim().startsWith('@Admin')) {
      recipient = 'admin';
    }

    await api.sendChatMessage(baseUrl, profile.username, text, recipient: recipient);
    await _fetchData(); // Refresh immediately
  }

  Future<Map<String, dynamic>?> fetchBroadcast(String baseUrl) async {
    try {
      final response = await ref.read(dioProvider).get('$baseUrl/social/broadcast');
      return response.data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> challengeUser(String targetUsername) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return null;

    final api = ref.read(apiClientProvider.notifier);
    return await api.sendBattleChallenge(baseUrl, profile.username, targetUsername);
  }

  Future<void> acceptBattleChallenge(String battleId) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return;

    final api = ref.read(apiClientProvider.notifier);
    await api.acceptBattleChallenge(baseUrl, profile.username, battleId);
    await _fetchData(); // Refresh to clear challenge from state
  }

  Future<void> sendFriendRequest(String targetUsername) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return;

    final api = ref.read(apiClientProvider.notifier);
    await api.sendFriendRequest(baseUrl, profile.username, targetUsername);
  }

  Future<void> acceptFriendRequest(String friendUsername) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return;

    final api = ref.read(apiClientProvider.notifier);
    await api.acceptFriendRequest(baseUrl, profile.username, friendUsername);
    await _fetchData(); // Refresh immediately
  }

  Future<bool> sendGift({
    required String recipientUsername,
    required String itemId,
    required int quantity,
    required String message,
  }) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return false;

    // 1. Send via API
    final success = await ref.read(apiClientProvider.notifier).sendGift(
      baseUrl,
      senderUsername: profile.username,
      senderDisplayName: profile.displayName,
      recipientUsername: recipientUsername,
      itemId: itemId,
      quantity: quantity,
      message: message,
    );

    if (success) {
      // 2. Trigger status update to sync inventory
      await updateStatus();
      await _fetchData();
    }
    
    return success;
  }

  Future<bool> acceptGift(String giftId, String itemId, int quantity) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final profile = ref.read(authControllerProvider).profile;
    if (baseUrl.isEmpty || profile == null) return false;

    // 1. Accept via API
    final success = await ref.read(apiClientProvider.notifier).acceptGift(
      baseUrl,
      profile.username,
      giftId,
    );

    if (success) {
      // 2. Add to local inventory
      await ref.read(inventoryProvider.notifier).addItem(itemId, quantity);
      
      // 3. Trigger status update to sync inventory back to cloud
      await updateStatus();
      await _fetchData();
    }
    
    return success;
  }

  Future<void> updateStatus({String? customStatus}) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    final authState = ref.read(authControllerProvider);
    if (baseUrl.isEmpty || !authState.isAuthenticated || authState.profile == null) return;

    final profile = authState.profile!;
    final api = ref.read(apiClientProvider.notifier);

    await api.updateOnlineStatus(
      baseUrl,
      username: profile.username,
      displayName: profile.displayName,
      status: customStatus ?? 'online',
      roster: profile.roster.map((e) => e.toJson()).toList(),
      inventory: profile.inventory,
      wins: profile.wins,
    );
  }
}
