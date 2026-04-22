import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_generations/core/settings/app_settings.dart';
import 'package:pokemon_generations/core/settings/visual_mode.dart';
import 'package:pokemon_generations/domain/models/app_update_info.dart';
import 'package:pokemon_generations/domain/models/user_profile.dart';

void main() {
  test('AppSettings normalizes backend URLs', () {
    const settings = AppSettings(
      backendUrl: 'http://192.168.0.148:8191/',
      offlineModeEnabled: false,
      autoCheckForUpdates: true,
      visualMode: PlayerVisualMode.vinyl,
      showSurfingPikachu: false,
      menuMusicEnabled: true,
    );

    expect(settings.resolvedBackendUrl, 'http://192.168.0.148:8191');
  });

  test('AppUpdateInfo parses backend payloads', () {
    final info = AppUpdateInfo.fromJson({
      'updateAvailable': true,
      'version': '1.0.1',
      'buildNumber': '2',
      'downloadUrl': 'http://192.168.0.148:8191/downloads/apk/app-release.apk',
      'fileName': 'app-release.apk',
      'fileSizeBytes': 1048576,
      'publishedAt': '2026-04-18T06:46:00.000Z',
    });

    expect(info.updateAvailable, isTrue);
    expect(info.displayVersion, '1.0.1+2');
    expect(info.fileSizeMb, 1.0);
    expect(info.publishedAt, isNotNull);
  });

  test('UserProfile encodes and decodes cleanly', () {
    const profile = UserProfile(
      firstName: 'Ash',
      lastName: 'Ketchum',
      username: 'ashk',
      passcodeHash: 'hash123',
    );

    final decoded = UserProfile.decode(profile.encode());

    expect(decoded.displayName, 'Ash Ketchum');
    expect(decoded.username, 'ashk');
    expect(decoded.passcodeHash, 'hash123');
  });
}
