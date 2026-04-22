import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/services/api_client.dart';
import '../../domain/models/app_update_info.dart';
import '../settings/app_settings_controller.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>(
  (ref) => AppUpdateService(ref),
);

class AppUpdateService {
  const AppUpdateService(this.ref);

  final Ref ref;

  Future<AppUpdateInfo?> checkForUpdates({String? baseUrl}) async {
    final packageInfo = await PackageInfo.fromPlatform();

    final update = await ref.read(apiClientProvider.notifier).fetchLatestAppUpdate(
          baseUrl: baseUrl ?? ref.read(backendBaseUrlProvider),
          currentVersion: packageInfo.version,
          currentBuildNumber: packageInfo.buildNumber,
        );

    if (update == null || !update.updateAvailable) return update;

    // Safety check: ensure the returned version is actually newer
    final isNewer = _isNewer(
      currentVersion: packageInfo.version,
      currentBuild: packageInfo.buildNumber,
      newVersion: update.version,
      newBuild: update.buildNumber,
    );

    if (!isNewer) {
      // If server said updateAvailable but client sees it's same/older, override it
      return AppUpdateInfo(
        updateAvailable: false,
        version: update.version,
        buildNumber: update.buildNumber,
        downloadUrl: update.downloadUrl,
        fileName: update.fileName,
        fileSizeBytes: update.fileSizeBytes,
        sha1: update.sha1,
        publishedAt: update.publishedAt,
      );
    }

    return update;
  }

  bool _isNewer({
    required String currentVersion,
    required String currentBuild,
    required String newVersion,
    required String newBuild,
  }) {
    final currentParts = currentVersion.split('.').map(int.tryParse).toList();
    final newParts = newVersion.split('.').map(int.tryParse).toList();

    // Compare semantic version parts
    for (int i = 0; i < 3; i++) {
      final curr = (currentParts.length > i ? currentParts[i] : 0) ?? 0;
      final n = (newParts.length > i ? newParts[i] : 0) ?? 0;
      if (n > curr) return true;
      if (n < curr) return false;
    }

    // Versions equal, compare build number
    final currBuildInt = int.tryParse(currentBuild) ?? 0;
    final newBuildInt = int.tryParse(newBuild) ?? 0;
    return newBuildInt > currBuildInt;
  }
}
