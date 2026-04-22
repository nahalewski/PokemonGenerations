import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/app_update_info.dart';

final apkInstallServiceProvider = Provider<ApkInstallService>(
  (ref) => ApkInstallService(),
);

class ApkInstallService {
  Future<DownloadPreparationResult> prepareDownload(
    AppUpdateInfo updateInfo,
  ) async {
    return const DownloadPreparationResult(
      success: false,
      message: 'APK installation is only supported on Android.',
    );
  }

  Future<ApkDownloadResult> downloadUpdate(
    AppUpdateInfo updateInfo, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    return const ApkDownloadResult(
      success: false,
      message: 'APK installation is only supported on Android.',
    );
  }

  Future<ApkInstallResult> installDownloadedApk(String apkPath) async {
    return const ApkInstallResult(
      success: false,
      message: 'APK installation is only supported on Android.',
    );
  }

  Future<void> openUnknownSourcesSettings() async {}
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
