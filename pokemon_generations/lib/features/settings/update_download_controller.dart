import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/apk_install_service.dart';
import '../../domain/models/app_update_info.dart';

final updateDownloadControllerProvider =
    NotifierProvider<UpdateDownloadController, UpdateDownloadState>(
      UpdateDownloadController.new,
    );

class UpdateDownloadController extends Notifier<UpdateDownloadState> {
  CancelToken? _cancelToken;

  @override
  UpdateDownloadState build() {
    ref.onDispose(() {
      _cancelToken?.cancel();
    });
    return const UpdateDownloadState.idle();
  }

  Future<DownloadPreparationResult> startBackgroundDownload(
    AppUpdateInfo updateInfo,
  ) async {
    final service = ref.read(apkInstallServiceProvider);
    final prep = await service.prepareDownload(updateInfo);

    if (!prep.success) {
      state = UpdateDownloadState.failed(
        message: prep.message,
        updateInfo: updateInfo,
        requiresPermission: prep.requiresPermission,
      );
      return prep;
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    state = UpdateDownloadState.downloading(
      updateInfo: updateInfo,
      progress: 0,
    );

    try {
      final result = await service.downloadUpdate(
        updateInfo,
        cancelToken: _cancelToken,
        onProgress: (progress) {
          state = UpdateDownloadState.downloading(
            updateInfo: updateInfo,
            progress: progress,
          );
        },
      );

      if (!result.success || result.downloadedFilePath == null) {
        state = UpdateDownloadState.failed(
          message: result.message,
          updateInfo: updateInfo,
        );
        return prep;
      }

      state = UpdateDownloadState.ready(
        updateInfo: updateInfo,
        downloadedFilePath: result.downloadedFilePath!,
      );
    } on DioException catch (_) {
      state = UpdateDownloadState.failed(
        message: 'Update download failed. Please try again.',
        updateInfo: updateInfo,
      );
    } catch (_) {
      state = UpdateDownloadState.failed(
        message: 'Update download failed. Please try again.',
        updateInfo: updateInfo,
      );
    }

    return prep;
  }

  Future<ApkInstallResult?> installReadyUpdate() async {
    final current = state;
    if (current.status != UpdateDownloadStatus.ready ||
        current.downloadedFilePath == null) {
      return null;
    }

    state = UpdateDownloadState.installing(
      updateInfo: current.updateInfo!,
      downloadedFilePath: current.downloadedFilePath!,
    );

    final result = await ref
        .read(apkInstallServiceProvider)
        .installDownloadedApk(current.downloadedFilePath!);

    if (result.success) {
      state = UpdateDownloadState.installerOpened(
        updateInfo: current.updateInfo!,
        downloadedFilePath: current.downloadedFilePath!,
      );
    } else {
      state = UpdateDownloadState.failed(
        message: result.message,
        updateInfo: current.updateInfo,
      );
    }

    return result;
  }

  void clearReadyPrompt() {
    final current = state;
    if (current.updateInfo == null) {
      state = const UpdateDownloadState.idle();
      return;
    }

    state = UpdateDownloadState.downloaded(
      updateInfo: current.updateInfo!,
      downloadedFilePath: current.downloadedFilePath,
    );
  }

  Future<void> openUnknownSourcesSettings() async {
    await ref.read(apkInstallServiceProvider).openUnknownSourcesSettings();
  }
}

enum UpdateDownloadStatus {
  idle,
  downloading,
  ready,
  downloaded,
  installing,
  installerOpened,
  failed,
}

class UpdateDownloadState {
  const UpdateDownloadState({
    required this.status,
    this.progress = 0,
    this.updateInfo,
    this.downloadedFilePath,
    this.message,
    this.requiresPermission = false,
  });

  const UpdateDownloadState.idle() : this(status: UpdateDownloadStatus.idle);

  const UpdateDownloadState.downloading({
    required AppUpdateInfo updateInfo,
    required double progress,
  }) : this(
         status: UpdateDownloadStatus.downloading,
         updateInfo: updateInfo,
         progress: progress,
       );

  const UpdateDownloadState.ready({
    required AppUpdateInfo updateInfo,
    required String downloadedFilePath,
  }) : this(
         status: UpdateDownloadStatus.ready,
         updateInfo: updateInfo,
         downloadedFilePath: downloadedFilePath,
         progress: 1,
       );

  const UpdateDownloadState.downloaded({
    required AppUpdateInfo updateInfo,
    String? downloadedFilePath,
  }) : this(
         status: UpdateDownloadStatus.downloaded,
         updateInfo: updateInfo,
         downloadedFilePath: downloadedFilePath,
         progress: 1,
       );

  const UpdateDownloadState.installing({
    required AppUpdateInfo updateInfo,
    required String downloadedFilePath,
  }) : this(
         status: UpdateDownloadStatus.installing,
         updateInfo: updateInfo,
         downloadedFilePath: downloadedFilePath,
         progress: 1,
       );

  const UpdateDownloadState.installerOpened({
    required AppUpdateInfo updateInfo,
    required String downloadedFilePath,
  }) : this(
         status: UpdateDownloadStatus.installerOpened,
         updateInfo: updateInfo,
         downloadedFilePath: downloadedFilePath,
         progress: 1,
       );

  const UpdateDownloadState.failed({
    required String message,
    AppUpdateInfo? updateInfo,
    bool requiresPermission = false,
  }) : this(
         status: UpdateDownloadStatus.failed,
         message: message,
         updateInfo: updateInfo,
         requiresPermission: requiresPermission,
       );

  final UpdateDownloadStatus status;
  final double progress;
  final AppUpdateInfo? updateInfo;
  final String? downloadedFilePath;
  final String? message;
  final bool requiresPermission;
}
