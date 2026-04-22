import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_client.dart';
import '../../core/settings/app_settings_controller.dart';

final broadcastMessageProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final broadcastPollerProvider = Provider<void>((ref) {
  Timer? timer;

  void poll() async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    if (baseUrl.isEmpty) return;
    try {
      final api = ref.read(apiClientProvider.notifier);
      final msg = await api.fetchBroadcast(baseUrl);
      ref.read(broadcastMessageProvider.notifier).state = msg;
    } catch (_) {}
  }

  poll();
  timer = Timer.periodic(const Duration(seconds: 20), (_) => poll());
  ref.onDispose(() => timer?.cancel());
});
