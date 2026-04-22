import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import '../features/settings/update_download_controller.dart';
import '../features/settings/update_prompt.dart';

class UpdateDownloadListener extends ConsumerStatefulWidget {
  const UpdateDownloadListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateDownloadListener> createState() =>
      _UpdateDownloadListenerState();
}

class _UpdateDownloadListenerState
    extends ConsumerState<UpdateDownloadListener> {
  bool _showingReadyPrompt = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<UpdateDownloadState>(updateDownloadControllerProvider, (
      previous,
      next,
    ) async {
      // Use the global navigator context to ensure we can show a dialog
      // regardless of where the builder context is in the tree.
      final navigatorContext = rootNavigatorKey.currentContext;
      if (navigatorContext == null) return;

      if (next.status == UpdateDownloadStatus.failed && next.message != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }

      if (next.status == UpdateDownloadStatus.ready &&
          !_showingReadyPrompt &&
          next.updateInfo != null) {
        _showingReadyPrompt = true;
        
        final messenger = ScaffoldMessenger.of(navigatorContext);
        final navigator = Navigator.of(navigatorContext);

        await showAppUpdateDialog(
          navigatorContext,
          updateInfo: next.updateInfo!,
          manualCheck: true,
          isReadyToInstall: true,
          onInstallPressed: () async {
            navigator.pop();
            final result = await ref
                .read(updateDownloadControllerProvider.notifier)
                .installReadyUpdate();
            
            if (result != null) {
              messenger.showSnackBar(SnackBar(content: Text(result.message)));
            }
          },
        );
        
        ref.read(updateDownloadControllerProvider.notifier).clearReadyPrompt();
        _showingReadyPrompt = false;
      }
    });

    return widget.child;
  }
}
