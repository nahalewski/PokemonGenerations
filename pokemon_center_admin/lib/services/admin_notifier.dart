import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_models.dart';
import 'admin_service.dart';
import 'admin_tab_logger.dart';

class AdminState {
  final List<AdminUser> users;
  final List<AdminChatMessage> chat;
  final AdminBroadcast? activeBroadcast;
  final List<dynamic> inbox;
  final bool isLoading;
  final String? error;

  AdminState({
    this.users = const [],
    this.chat = const [],
    this.inbox = const [],
    this.activeBroadcast,
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<AdminUser>? users,
    List<AdminChatMessage>? chat,
    List<dynamic>? inbox,
    AdminBroadcast? activeBroadcast,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      users: users ?? this.users,
      chat: chat ?? this.chat,
      inbox: inbox ?? this.inbox,
      activeBroadcast: activeBroadcast ?? this.activeBroadcast,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminService _service;
  Timer? _refreshTimer;

  AdminNotifier(this._service) : super(AdminState()) {
    refresh();
    _startPolling();
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true);
    await AdminTabLogger.log(
      'social_dashboard',
      'refresh_started',
      details: {'silent': silent},
    );
    
    try {
      final users = await _service.fetchUsers();
      final chat = await _service.fetchChat();
      final broadcast = await _service.fetchBroadcast();
      final inbox = await _service.fetchInbox('bn200n');
      
      state = state.copyWith(
        users: users,
        chat: chat,
        inbox: inbox,
        activeBroadcast: broadcast,
        isLoading: false,
        error: null,
      );
      await AdminTabLogger.log(
        'social_dashboard',
        'refresh_completed',
        details: {
          'users': users.length,
          'chatMessages': chat.length,
          'inboxMessages': inbox.length,
          'hasBroadcast': broadcast != null,
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      await AdminTabLogger.log(
        'social_dashboard',
        'refresh_failed',
        error: e,
      );
    }
  }

  Future<void> sendBroadcast(String text) async {
    await AdminTabLogger.log(
      'social_dashboard',
      'broadcast_requested',
      details: {'length': text.length},
    );
    await _service.sendBroadcast(text);
    await refresh(silent: true);
  }

  Future<void> clearBroadcast() async {
    await AdminTabLogger.log('social_dashboard', 'broadcast_cleared');
    await _service.clearBroadcast();
    await refresh(silent: true);
  }

  Future<void> suspendUser(String username, bool suspended) async {
    await AdminTabLogger.log(
      'social_dashboard',
      'suspend_user_requested',
      details: {'username': username, 'suspended': suspended},
    );
    await _service.suspendUser(username, suspended);
    await refresh(silent: true);
  }

  Future<void> banUser(String username) async {
    await AdminTabLogger.log(
      'social_dashboard',
      'ban_user_requested',
      details: {'username': username},
    );
    await _service.banUser(username);
    await refresh(silent: true);
  }

  Future<void> deleteUser(String username) async {
    await AdminTabLogger.log(
      'social_dashboard',
      'delete_user_requested',
      details: {'username': username},
    );
    await _service.deleteUser(username);
    await refresh(silent: true);
  }

  Future<void> resetUserPasscode(String username) async {
    await AdminTabLogger.log(
      'social_dashboard',
      'reset_passcode_requested',
      details: {'username': username},
    );
    await _service.resetPasscode(username);
    await refresh(silent: true);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final adminServiceProvider = Provider((ref) => AdminService());

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final service = ref.watch(adminServiceProvider);
  return AdminNotifier(service);
});
