import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/assets/dynamic_resource_service.dart';
import '../screens/dynamic_downloader_screen.dart';

final dynamicResourceServiceProvider = Provider((ref) => DynamicResourceService());

class InitializationGate extends ConsumerStatefulWidget {
  final Widget child;

  const InitializationGate({super.key, required this.child});

  @override
  ConsumerState<InitializationGate> createState() => _InitializationGateState();
}

class _InitializationGateState extends ConsumerState<InitializationGate> {
  bool _needsSync = false;
  bool _initializing = true;
  Map<String, dynamic>? _manifest;

  @override
  void initState() {
    super.initState();
    _checkSyncStatus();
  }

  Future<void> _checkSyncStatus() async {
    final service = ref.read(dynamicResourceServiceProvider);
    
    // 1. Check if we have assets locally
    final status = await service.needsInitialSync();
    if (!status) {
      if (mounted) setState(() => _initializing = false);
      return;
    }

    // 2. If sync needed, fetch manifest
    final manifest = await service.checkUpdates();
    if (mounted) {
      setState(() {
        _needsSync = manifest != null;
        _manifest = manifest;
        _initializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        backgroundColor: Color(0xFF080808),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_needsSync && _manifest != null) {
      return DynamicDownloaderScreen(
        manifest: _manifest!,
        onComplete: () {
          setState(() => _needsSync = false);
        },
      );
    }

    return widget.child;
  }
}
