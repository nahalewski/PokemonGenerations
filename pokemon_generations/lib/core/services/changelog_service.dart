import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final changelogServiceProvider = Provider<ChangelogService>(
  (ref) => ChangelogService(),
);

class ChangelogService {
  static const _lastSeenVersionKey = 'changelog.last_seen_version';

  Future<ChangelogInfo?> getPendingChangelog() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final installedVersion =
        '${packageInfo.version}+${packageInfo.buildNumber}';
    final lastSeenVersion = prefs.getString(_lastSeenVersionKey);

    if (lastSeenVersion == installedVersion) {
      return null;
    }

    // Return the latest version info
    return const ChangelogInfo(
      versionLabel: 'v2.0.1+4',
      title: 'V2.0.1+4: BATTLE STABILITY & SPLASH UPDATE',
      message: '### **What\'s New Today:**\n\n'
          '• **Battle Engine Stability:** Fixed a critical bug where using items could cause a navigation reset; combat sessions are now more resilient to profile updates.\n'
          '• **Premium Launch Sequence:** Implemented a new high-fidelity Hybrid Splash screen with the official Pokémon Generations logo and loading animation.\n'
          '• **Battle Audio Control:** Added a dedicated Mute/Unmute toggle directly in the battle interface.\n'
          '• **Divine Reward Fix:** Redesigned the Arceus Reward notification header for improved visibility and asset rendering.\n'
          '• **Performance Optimization:** Refined the core routing engine to prevent unnecessary re-instantiations during active gameplay.\n\n'
          '--- \n\n'
          '### **PREVIOUSLY (v2.0.1.3):** \n'
          '• **Multi-Roster Management:** Full overhaul of the collection system into a professional multi-team hub.\n'
          '• **Advanced Analytics:** Integrated radar charts and performance tracking for team composition.\n',
    );
  }

  Future<void> markSeen(String versionLabel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenVersionKey, versionLabel);
  }
}

class ChangelogInfo {
  const ChangelogInfo({
    required this.versionLabel,
    required this.title,
    required this.message,
  });

  final String versionLabel;
  final String title;
  final String message;
}
