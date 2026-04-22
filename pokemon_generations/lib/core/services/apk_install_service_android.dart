import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import '../../domain/models/app_update_info.dart';

final apkInstallServiceProvider = Provider<ApkInstallService>(
  (ref) => ApkInstallService(),
);

class ApkInstallService {
  static const _channel = MethodChannel('com.pokemon.generations/apk_installer');
  final Dio _dio = Dio();

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<DownloadPreparationResult> prepareDownload(
    AppUpdateInfo updateInfo,
  ) async {
    if (!_isAndroid) {
      return const DownloadPreparationResult(
        success: false,
        message: 'In-app APK installation is only supported on Android.',
      );
    }

    final canInstall = await _canRequestPackageInstalls();
    if (!canInstall) {
      return const DownloadPreparationResult(
        success: false,
        requiresPermission: true,
        message:
            'Allow Pokemon Generations to install unknown apps, then try the update again.',
      );
    }

    return const DownloadPreparationResult(
      success: true,
      message: 'Ready to download update in the background.',
    );
  }

  Future<ApkDownloadResult> downloadUpdate(
    AppUpdateInfo updateInfo, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (!_isAndroid) {
      return const ApkDownloadResult(
        success: false,
        message: 'In-app APK installation is only supported on Android.',
      );
    }

    final apkFile = await _downloadApk(
      updateInfo,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    return ApkDownloadResult(
      success: true,
      message: 'Update downloaded and ready to install.',
      downloadedFilePath: apkFile.path,
    );
  }

  Future<ApkInstallResult> installDownloadedApk(String apkPath) async {
    if (!_isAndroid) {
      return const ApkInstallResult(
        success: false,
        message: 'In-app APK installation is only supported on Android.',
      );
    }

    final installed =
        await _channel.invokeMethod<bool>('installApk', {'path': apkPath}) ??
        false;

    return ApkInstallResult(
      success: installed,
      message: installed
          ? 'Installer opened. Follow the Android prompts to finish updating.'
          : 'Unable to open the Android package installer.',
      downloadedFilePath: apkPath,
    );
  }

  Future<void> openUnknownSourcesSettings() async {
    if (!_isAndroid) {
      return;
    }
    await _channel.invokeMethod('openUnknownSourcesSettings');
  }

  Future<bool> _canRequestPackageInstalls() async {
    return await _channel.invokeMethod<bool>('canRequestPackageInstalls') ??
        false;
  }

  Future<File> _downloadApk(
    AppUpdateInfo updateInfo, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final updatesDir = await _ensureUpdatesDir();
    final file = File(p.join(updatesDir.path, updateInfo.fileName));

    await _dio.download(
      updateInfo.downloadUrl,
      file.path,
      deleteOnError: true,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress?.call(received / total);
        }
      },
    );

    return file;
  }

  Future<Directory> _ensureUpdatesDir() async {
    final baseDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(baseDir.path, 'updates'));
    if (!kIsWeb && !await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}

class DownloadPreparationResult {
  const DownloadPreparationResult({
    required this.success,
    required this.message,
    this.requiresPermission = false,
  });

  final bool success;
  final bool requiresPermission;
  final String message;
}

class ApkDownloadResult {
  const ApkDownloadResult({
    required this.success,
    required this.message,
    this.downloadedFilePath,
  });

  final bool success;
  final String message;
  final String? downloadedFilePath;
}

class ApkInstallResult {
  const ApkInstallResult({
    required this.success,
    required this.message,
    this.requiresPermission = false,
    this.downloadedFilePath,
  });

  final bool success;
  final bool requiresPermission;
  final String message;
  final String? downloadedFilePath;
}
