import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/app_update_info.dart';

Future<void> showAppUpdateDialog(
  BuildContext context, {
  required AppUpdateInfo updateInfo,
  required bool manualCheck,
  bool isReadyToInstall = false,
  VoidCallback? onInstallPressed,
  VoidCallback? onOpenExternallyPressed,
}) {
  final publishedLabel = updateInfo.publishedAt == null
      ? 'Unknown build time'
      : DateFormat(
          'MMM d, yyyy • h:mm a',
        ).format(updateInfo.publishedAt!.toLocal());

  final title =
      isReadyToInstall
          ? 'Installation Ready'
          : updateInfo.updateAvailable
          ? 'Update Available'
          : 'App Up To Date';

  final message =
      isReadyToInstall
          ? 'The update for Pokemon Generations ${updateInfo.displayVersion} has been downloaded and is ready to install.'
          : updateInfo.updateAvailable
          ? 'Pokemon Generations ${updateInfo.displayVersion} is available from your Mac mini build folder.'
          : 'No newer APK was found in your configured update folder.';

  final primaryButtonLabel = isReadyToInstall ? 'Install Now' : 'Download & Install';

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: AppTypography.headlineSmall),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTypography.bodyMedium),
          const SizedBox(height: 12),
          Text('APK: ${updateInfo.fileName}', style: AppTypography.bodySmall),
          Text('Built: $publishedLabel', style: AppTypography.bodySmall),
          Text(
            'Size: ${updateInfo.fileSizeMb.toStringAsFixed(1)} MB',
            style: AppTypography.bodySmall,
          ),
          if ((updateInfo.sha1 ?? '').isNotEmpty)
            Text('SHA1: ${updateInfo.sha1}', style: AppTypography.bodySmall),
          if (manualCheck && !updateInfo.updateAvailable && !isReadyToInstall)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Manual check completed successfully.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (updateInfo.updateAvailable && updateInfo.downloadUrl.isNotEmpty)
          TextButton(
            onPressed:
                onOpenExternallyPressed ??
                () async {
                  final uri = Uri.tryParse(updateInfo.downloadUrl);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
            child: const Text('Open in Browser'),
          ),
        if (updateInfo.updateAvailable && updateInfo.downloadUrl.isNotEmpty)
          FilledButton(
            onPressed: onInstallPressed,
            child: Text(primaryButtonLabel),
          ),
      ],
    ),
  );
}
