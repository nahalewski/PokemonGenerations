import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/roster/roster_provider.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../data/services/api_client.dart';

final presenceServiceProvider = Provider<void>((ref) {
  final auth = ref.watch(authControllerProvider);

  if (!auth.isAuthenticated || auth.profile == null) return;

  final profile = auth.profile!;
  final baseUrl = ref.read(backendBaseUrlProvider);
  if (baseUrl.isEmpty) return;

  List<Map<String, dynamic>> _buildRosterPayload() {
    final roster = ref.read(rosterProvider).value ?? [];
    return roster.map((f) => {'pokemonId': f.pokemonId}).toList();
  }

  Future<void> postOnline() async {
    final api = ref.read(apiClientProvider.notifier);
    await api.updateOnlineStatus(
      baseUrl,
      username: profile.username,
      displayName: '${profile.firstName} ${profile.lastName}'.trim(),
      status: 'online',
      roster: _buildRosterPayload(),
    );
  }

  Future<void> pushFullRoster() async {
    final roster = ref.read(rosterProvider).value;
    if (roster == null || roster.isEmpty) return;
    try {
      final api = ref.read(apiClientProvider.notifier);
      await api.saveRoster(baseUrl, profile.username, roster);
      print('[SYNC] Periodic roster push: ${roster.length} pokemon');
    } catch (e) {
      print('[SYNC] Periodic roster push failed: $e');
    }
  }

  // Post presence immediately on auth, then every 30 seconds
  postOnline();
  final presenceTimer = Timer.periodic(const Duration(seconds: 30), (_) => postOnline());

  // Push full roster to cloud immediately, then every 5 minutes
  pushFullRoster();
  final rosterTimer = Timer.periodic(const Duration(minutes: 5), (_) => pushFullRoster());

  ref.onDispose(() {
    presenceTimer.cancel();
    rosterTimer.cancel();
    try {
      final api = ref.read(apiClientProvider.notifier);
      api.updateOnlineStatus(
        baseUrl,
        username: profile.username,
        displayName: '${profile.firstName} ${profile.lastName}'.trim(),
        status: 'offline',
        roster: [],
      );
    } catch (_) {}
  });
});
