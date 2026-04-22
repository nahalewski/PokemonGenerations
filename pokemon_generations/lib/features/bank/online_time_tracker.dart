import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_client.dart';
import '../auth/auth_controller.dart';
import '../../core/settings/app_settings_controller.dart';

final onlineTimeTrackerProvider = Provider((ref) => OnlineTimeTracker(ref));

class OnlineTimeTracker {
  final Ref _ref;
  Timer? _timer;
  DateTime? _sessionStart;

  OnlineTimeTracker(this._ref);

  void startTracking() {
    _sessionStart = DateTime.now();
    _timer?.cancel();
    
    // Sync every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _syncTime());
  }

  void stopTracking() {
    _syncTime();
    _timer?.cancel();
  }

  Future<void> _syncTime() async {
    if (_sessionStart == null) return;
    
    final now = DateTime.now();
    final minutes = now.difference(_sessionStart!).inMinutes;
    if (minutes <= 0) return;

    final profile = _ref.read(authControllerProvider).profile;
    if (profile == null) return;

    final baseUrl = _ref.read(appSettingsProvider).resolvedBackendUrl;
    
    try {
      await _ref.read(apiClientProvider.notifier).syncOnlineTime(
        baseUrl: baseUrl,
        username: profile.username,
        minutes: minutes,
      );
      _sessionStart = now; // Reset session start for next sync chunk
    } catch (_) {}
  }
}
