import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/services/asset_package_service.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/asset_package.dart';

class AssetDownloadScreen extends ConsumerStatefulWidget {
  const AssetDownloadScreen({super.key});

  @override
  ConsumerState<AssetDownloadScreen> createState() =>
      _AssetDownloadScreenState();
}

class _AssetDownloadScreenState extends ConsumerState<AssetDownloadScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  AssetManifestResponse? _manifest;
  bool _loading = true;
  bool _done = false;
  String _statusMessage = 'Checking for asset packages…';

  // packageId → 0.0–1.0 progress
  final Map<String, double> _progress = {};
  // packageId → error string
  final Map<String, String> _errors = {};

  int _totalBytes = 0;
  int _receivedBytes = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final service = ref.read(assetPackageServiceProvider);
    final settings = ref.read(appSettingsProvider);
    final baseUrl =
        settings.backendUrl.isNotEmpty ? settings.backendUrl : ApiConstants.baseUrl;

    final manifest = await service.fetchManifest(baseUrl);

    if (!mounted) return;

    if (manifest == null || manifest.packages.isEmpty) {
      // Server unreachable or no packages — skip straight through.
      await _markDone();
      return;
    }

    // Filter to packages that are outdated or not yet installed.
    final toDownload = <AssetPackageInfo>[];
    for (final pkg in manifest.packages) {
      if (!await service.isPackageUpToDate(pkg)) {
        toDownload.add(pkg);
      }
    }

    if (toDownload.isEmpty) {
      await _markDone();
      return;
    }

    setState(() {
      _manifest = manifest;
      _loading = false;
      _totalBytes = toDownload.fold(0, (sum, p) => sum + p.sizeBytes);
      _statusMessage = 'Downloading assets…';
      for (final p in toDownload) {
        _progress[p.id] = 0;
      }
    });

    await _downloadAll(toDownload, service, baseUrl);
  }

  Future<void> _downloadAll(
    List<AssetPackageInfo> packages,
    AssetPackageService service,
    String baseUrl,
  ) async {
    int cumulativeBytes = 0;

    for (final pkg in packages) {
      if (!mounted) return;

      setState(() => _statusMessage = 'Downloading ${pkg.name}…');

      await for (final progress
          in service.downloadPackage(pkg, baseUrl)) {
        if (!mounted) return;

        if (progress.error != null) {
          setState(() => _errors[pkg.id] = progress.error!);
          break;
        }

        final delta = progress.received - (_progress[pkg.id]! * pkg.sizeBytes).round().clamp(0, pkg.sizeBytes);
        setState(() {
          _progress[pkg.id] = progress.fraction;
          _receivedBytes = (cumulativeBytes + progress.received)
              .clamp(0, _totalBytes) as int;
        });

        if (progress.done) {
          cumulativeBytes += pkg.sizeBytes;
          break;
        }
      }
    }

    if (!mounted) return;
    await _markDone();
  }

  Future<void> _markDone() async {
    await ref.read(assetPackageServiceProvider).markInitialized();
    // Invalidate so the router redirect stops triggering.
    ref.invalidate(isFirstAssetLaunchProvider);
    if (!mounted) return;
    setState(() {
      _done = true;
      _statusMessage = 'Ready!';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) context.go('/');
  }

  Future<void> _skip() async {
    await ref.read(assetPackageServiceProvider).markInitialized();
    ref.invalidate(isFirstAssetLaunchProvider);
    if (!mounted) return;
    context.go('/');
  }

  double get _overallFraction =>
      _totalBytes > 0 ? _receivedBytes / _totalBytes : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: 40),
                if (_loading) _buildInitialLoader(),
                if (!_loading && !_done) ...[
                  _buildOverallProgress(),
                  const SizedBox(height: 24),
                  ..._buildPackageRows(),
                ],
                if (_done) _buildDoneIndicator(),
                const SizedBox(height: 48),
                if (!_done && !_loading) _buildSkipButton(),
                if (_loading || _done) _buildSkipButton(subtle: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withOpacity(0.3 + 0.2 * _pulseController.value),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.6 + 0.4 * _pulseController.value),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.catching_pokemon, color: AppColors.primary, size: 40),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'POKEMON GENERATIONS',
      style: AppTypography.headlineSmall.copyWith(
        color: AppColors.primary,
        letterSpacing: 4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      _statusMessage,
      style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInitialLoader() {
    return Column(
      children: [
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Connecting to server…',
          style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
        ),
      ],
    );
  }

  Widget _buildOverallProgress() {
    final pct = (_overallFraction * 100).toStringAsFixed(0);
    final recMb = (_receivedBytes / (1024 * 1024)).toStringAsFixed(1);
    final totMb = (_totalBytes / (1024 * 1024)).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TOTAL', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
            Text('$recMb / $totMb MB  ($pct%)', style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _overallFraction,
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPackageRows() {
    if (_manifest == null) return [];
    return _manifest!.packages
        .where((pkg) => _progress.containsKey(pkg.id))
        .map((pkg) {
      final frac = _progress[pkg.id] ?? 0.0;
      final err = _errors[pkg.id];
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    pkg.name.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: err != null ? AppColors.error : AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  err != null
                      ? 'ERROR'
                      : frac >= 1.0
                          ? 'DONE'
                          : '${pkg.sizeMb.toStringAsFixed(0)} MB',
                  style: AppTypography.labelSmall.copyWith(
                    color: err != null
                        ? AppColors.error
                        : frac >= 1.0
                            ? Colors.green
                            : AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: frac,
                minHeight: 4,
                backgroundColor: AppColors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  err != null ? AppColors.error : AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDoneIndicator() {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
        const SizedBox(height: 12),
        Text(
          'Assets installed',
          style: AppTypography.bodyMedium.copyWith(color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildSkipButton({bool subtle = false}) {
    return TextButton(
      onPressed: _skip,
      child: Text(
        subtle ? 'Skip' : 'Skip for now  →',
        style: AppTypography.bodySmall.copyWith(
          color: subtle ? AppColors.outline.withOpacity(0.5) : AppColors.outline,
        ),
      ),
    );
  }
}
