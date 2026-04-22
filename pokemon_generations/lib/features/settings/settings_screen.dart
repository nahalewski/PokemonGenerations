import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/api_constants.dart';
import '../../core/services/app_update_service.dart';
import '../../core/services/logging_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/utils/platform_utils.dart';
import '../../core/widgets/futuristic_ui_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/graphics_service.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/app_update_info.dart';
import '../../domain/models/game.dart';
import '../auth/auth_controller.dart';
import '../game_selection/game_provider.dart';
import '../roster/roster_provider.dart';
import '../roster/teams_provider.dart';
import '../../data/providers.dart';
import 'update_download_controller.dart';
import 'update_prompt.dart';
import '../inventory/inventory_provider.dart';
import '../home/widgets/home_sidebar.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  bool _isSavingUrl = false;
  bool _isCheckingUpdates = false;
  String _cacheSize = 'Calculating...';
  bool _isClearing = false;
  bool _isSyncing = false;
  bool _isUploadingPhoto = false;
  Future<PackageInfo>? _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _packageInfoFuture = PackageInfo.fromPlatform();
    _calculateCacheSize();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _calculateCacheSize() async {
    final size = await ref.read(storageServiceProvider).getStorageUsage();
    if (mounted) {
      setState(() {
        _cacheSize = size;
      });
    }
  }


  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will delete all local data, including your roster, teams, and settings. You will need to log in again to sync from the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isClearing = true);
    try {
      // 1. Clear Databases
      await ref.read(rosterRepositoryProvider).clearLocalData();
      
      // 2. Sign Out & Clear Preferences
      await ref.read(authControllerProvider.notifier).signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Clear temp files
      await ref.read(storageServiceProvider).clearCache();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared. Restarting...')),
      );
      
      // Wait a bit for the snackbar and then reload/restart
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      // Return to login screen
      context.go('/auth');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing cache: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  Future<void> _saveBackendUrl() async {
    setState(() => _isSavingUrl = true);
    try {
      await ref
          .read(appSettingsProvider.notifier)
          .saveBackendUrl(_urlController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Backend URL saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingUrl = false);
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    await ref
        .read(appSettingsProvider.notifier)
        .saveBackendUrl(_urlController.text);
    final success = await ref
        .read(apiClientProvider.notifier)
        .checkHealth(_urlController.text);

    if (mounted) {
      setState(() => _isTesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Connection successful.'
                : 'Connection failed. Check the backend URL and make sure the server is running.',
          ),
          backgroundColor: success ? Colors.green : AppColors.error,
        ),
      );
    }
  }

  Future<void> _checkForUpdate() async {
    setState(() => _isCheckingUpdates = true);
    await ref
        .read(appSettingsProvider.notifier)
        .saveBackendUrl(_urlController.text);

    try {
      final updateInfo = await ref
          .read(appUpdateServiceProvider)
          .checkForUpdates(baseUrl: _urlController.text);

      if (!mounted) {
        return;
      }

      if (updateInfo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Update check failed. Make sure the backend exposes /app-update.',
            ),
          ),
        );
        return;
      }

      await showAppUpdateDialog(
        context,
        updateInfo: updateInfo,
        manualCheck: true,
        onInstallPressed: () => _downloadUpdateInBackground(updateInfo),
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdates = false);
      }
    }
  }

  Future<void> _downloadUpdateInBackground(AppUpdateInfo updateInfo) async {
    Navigator.of(context).pop();
    final prep = await ref
        .read(updateDownloadControllerProvider.notifier)
        .startBackgroundDownload(updateInfo);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          prep.success
              ? 'Downloading update in the background. You can keep using the app.'
              : prep.message,
        ),
        action: prep.requiresPermission
            ? SnackBarAction(
                label: 'Allow',
                onPressed: () {
                  ref
                      .read(updateDownloadControllerProvider.notifier)
                      .openUnknownSourcesSettings();
                },
              )
            : null,
      ),
    );
  }

  Future<void> _reportBugDialog() {
    String reportType = 'Bug';
    final controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('SUBMIT REPORT', style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('REPORT TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TypeOption(label: 'Bug', isSelected: reportType == 'Bug', onSelect: () => setDialogState(() => reportType = 'Bug')),
                  _TypeOption(label: 'Feature', isSelected: reportType == 'Feature', onSelect: () => setDialogState(() => reportType = 'Feature')),
                  _TypeOption(label: 'Feedback', isSelected: reportType == 'Feedback', onSelect: () => setDialogState(() => reportType = 'Feedback')),
                ],
              ),
              const SizedBox(height: 16),
              Text('Describe the ${reportType.toLowerCase()} below.', style: AppTypography.bodySmall),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What happened?',
                  filled: true,
                  fillColor: AppColors.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                final message = '[$reportType] ${controller.text.trim()}';
                
                final packageInfo = await _packageInfoFuture;
                final version = packageInfo == null ? 'Unknown' : '${packageInfo.version}+${packageInfo.buildNumber}';
                final platform = kIsWeb ? 'Web' : (defaultTargetPlatform == TargetPlatform.android ? 'Android' : 'Desktop');

                final success = await ref.read(apiClientProvider.notifier).submitReport(
                  ref.read(appSettingsProvider).backendUrl,
                  username: ref.read(authControllerProvider).profile?.username ?? 'Anonymous',
                  displayName: ref.read(authControllerProvider).profile?.displayName ?? 'Anonymous User',
                  platform: platform,
                  version: version,
                  message: message,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent!'), backgroundColor: Colors.green));
                    }
                  } else {
                    await _writeBugToLog(message);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to local log (offline).')));
                    }
                  }
                }
              },
              child: const Text('Send Report'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _writeBugToLog(String message) async {
    try {
      final packageInfo = await _packageInfoFuture;
      final version = packageInfo == null
          ? 'Unknown'
          : '${packageInfo.version}+${packageInfo.buildNumber}';

      final authState = ref.read(authControllerProvider);
      final userId = authState.profile?.username;

      await ref.read(loggingServiceProvider).writeBugToLog(message, version, userId);
    } catch (_) {
      // Best effort
    }
  }


  Future<void> _showCreditsDialog() {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: FuturisticGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CREDITS & SOURCES', style: AppTypography.headlineSmall.copyWith(color: AppColors.primary)),
              const SizedBox(height: 16),
              const Text(
                'Pokémon Generations is a community effort. We leverage incredible assets from these creators:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildCreditItem('Smogon / pokemon-showdown', 'Battle Sprites, Move & Item Data', AppColors.primary),
              _buildCreditItem('Cobblemon', '3D Textures, Models & Move Sounds', AppColors.secondary),
              _buildCreditItem('Pokémon 3D API', 'Optimized GLB Battle Models', AppColors.tertiary),
              _buildCreditItem('PokeMiners', 'Pokémon GO Staged Assets', AppColors.primary),
              _buildCreditItem('TCGDex', 'Global TCG Card Database', AppColors.secondary),
              _buildCreditItem('Poke-Types', 'Type Icons & Effectiveness Charts', AppColors.tertiary),
              _buildCreditItem('Kotlin-Pokedex', 'UI Assets & Components', Colors.deepPurpleAccent),
              _buildCreditItem('GraphQL-Pokemon', 'Structured Data Staging', Colors.blue),
              _buildCreditItem('Trainer Central', 'Futuristic UI Concepts', Colors.deepPurpleAccent),
              _buildCreditItem('Templarian / slack-emoji-pokemon', '252 Pokemon Icon Set', AppColors.primary),
              _buildCreditItem('fraserxu / slack-pokemon-emoji', '151 Gen-1 Retro Icons', AppColors.secondary),
              _buildCreditItem('maierfelix / PokeMMO', 'Web Battle Sprites & Tilesets', AppColors.tertiary),
              _buildCreditItem('serena2341 / whos-that-pokemon', 'Who\'s That Pokemon Silhouettes', Colors.deepPurpleAccent),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('DISMISS', style: TextStyle(color: AppColors.outline, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditItem(String name, String detail, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.toUpperCase(), style: AppTypography.labelLarge.copyWith(height: 1)),
              Text(detail, style: const TextStyle(color: AppColors.outline, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  void _showGraphicsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: FuturisticGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GRAPHICS PROFILE', style: AppTypography.headlineSmall.copyWith(color: AppColors.primary)),
              const SizedBox(height: 16),
              const Text(
                'High-fidelity 3D and animated modes require significant GPU resources and local asset streaming.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildGraphicsOption(GraphicsProfile.static, 'STATIC (PERFORMANCE)', 'Optimum stability and speed.', AppColors.primary),
              _buildGraphicsOption(GraphicsProfile.animated, 'ANIMATED (EXPRESSIVE)', 'Living Smogon battlefield sprites.', AppColors.secondary),
              _buildGraphicsOption(GraphicsProfile.highFidelity3D, 'MODERN 3D (ULTRA)', 'Native GLB rendering (Experimental).', AppColors.tertiary),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('DISMISS', style: TextStyle(color: AppColors.outline, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraphicsOption(GraphicsProfile profile, String title, String subtitle, Color color) {
    final current = ref.watch(graphicsSettingsProvider);
    final isSelected = current.profile == profile;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.labelLarge.copyWith(color: isSelected ? color : Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
      onTap: () {
        ref.read(graphicsSettingsProvider.notifier).setProfile(profile);
        Navigator.pop(context);
      },
      trailing: isSelected ? Icon(Icons.check_circle, color: color, size: 20) : null,
    );
  }

  Future<void> _manualSync() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(rosterRepositoryProvider).syncWithCloud();
      
      // Force refresh of all local data providers
      ref.invalidate(rosterProvider);
      ref.invalidate(teamsNotifierProvider);
      ref.invalidate(inventoryProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data synchronized with cloud.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfilePhoto(image);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeGame = ref.watch(gameProviderProvider);
    final settings = ref.watch(appSettingsProvider);
    final authState = ref.watch(authControllerProvider);
    final updateDownload = ref.watch(updateDownloadControllerProvider);
    final graphics = ref.watch(graphicsSettingsProvider);

    if (_urlController.text != settings.backendUrl) {
      _urlController.value = TextEditingValue(
        text: settings.backendUrl,
        selection: TextSelection.collapsed(offset: settings.backendUrl.length),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const HomeSidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                image: const DecorationImage(
                  image: AssetImage('assets/home_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.4,
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            const Icon(
                              Icons.settings_outlined,
                              color: AppColors.primary,
                              size: 60,
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 16),
                            Text(
                              'APP SETTINGS',
                              style: AppTypography.displayLarge.copyWith(
                                color: AppColors.primary,
                                fontSize: 32,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 48),

                            _buildSectionHeader('COMMUNITY & ADMIN COMMANDS'),
                            const SizedBox(height: 16),
                            _buildSettingsCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('ADMIN COMMANDS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Use these tags in Global Chat to contact an administrator privately.',
                                    style: TextStyle(fontSize: 12, color: AppColors.outline),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildAdminCodeRow('@AdminPasscodeReset', 'Request a passcode reset.'),
                                  _buildAdminCodeRow('@AdminBug', 'Report a critical issue.'),
                                  _buildAdminCodeRow('@AdminFeedback', 'Suggest new features.'),
                                  const Divider(color: AppColors.outlineVariant, height: 32),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Report a Bug', style: TextStyle(color: Colors.white)),
                                    subtitle: const Text('Send a diagnostic report directly to dev.', style: TextStyle(color: AppColors.outline, fontSize: 11)),
                                    trailing: const Icon(Icons.bug_report_outlined, color: AppColors.primary),
                                    onTap: _reportBugDialog,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            _buildSectionHeader('ACCOUNT'),
                            const SizedBox(height: 16),
                            _buildSettingsCard(
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      backgroundImage: authState.profile?.profileImageUrl != null
                                          ? CachedNetworkImageProvider(authState.profile!.profileImageUrl!)
                                          : null,
                                      child: authState.profile?.profileImageUrl == null
                                          ? Text(
                                              (authState.profile?.displayName[0] ?? '?').toUpperCase(),
                                              style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                                            )
                                          : null,
                                    ),
                                    title: Text(authState.profile?.displayName ?? 'No active profile', style: AppTypography.bodyLarge),
                                    subtitle: Text(authState.profile == null ? 'Local login not configured' : '@${authState.profile!.username}', style: AppTypography.bodySmall),
                                    trailing: _isUploadingPhoto
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : IconButton(
                                            icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                                            onPressed: authState.isAuthenticated ? _pickAndUploadPhoto : null,
                                          ),
                                  ),
                                  const Divider(color: AppColors.outlineVariant, height: 32),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('Sign Out', style: AppTypography.bodyLarge),
                                    trailing: const Icon(Icons.logout, color: AppColors.secondary),
                                    onTap: () => ref.read(authControllerProvider.notifier).signOut(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            if (!kReleaseMode) ...[
                              _buildSectionHeader('BACKEND CONFIGURATION'),
                              const SizedBox(height: 16),
                              _buildSettingsCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('SERVER URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white70)),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _urlController,
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'http://localhost:3000',
                                        filled: true,
                                        fillColor: Colors.black26,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isTesting ? null : _testConnection,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.secondary,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: _isTesting 
                                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                            : const Text('TEST CONNECTION'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            _buildSectionHeader('ACTIVE GAME'),
                            const SizedBox(height: 16),
                            _buildSettingsCard(
                              child: ListTile(
                                title: Text(activeGame.valueOrNull?.name ?? 'No Game Selected', style: AppTypography.bodyLarge),
                                subtitle: Text('Gen ${activeGame.valueOrNull?.generation ?? '—'} • ${activeGame.valueOrNull?.regions.join(', ') ?? '—'}', style: AppTypography.bodySmall),
                                trailing: const Icon(Icons.swap_horiz, color: AppColors.primary),
                                onTap: _showGameSelectionSheet,
                              ),
                            ),
                            const SizedBox(height: 32),

                            _buildSectionHeader('BATTLE VISUALS'),
                            const SizedBox(height: 16),
                            _buildSettingsCard(
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: const Text('High Resolution Sprites'),
                                    value: graphics.useHighResSprites,
                                    onChanged: (val) => ref.read(graphicsSettingsProvider.notifier).setUseHighResSprites(val),
                                    activeColor: AppColors.primary,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  const Divider(color: AppColors.outlineVariant),
                                  SwitchListTile(
                                    title: const Text('Animated Sprites (.gif)'),
                                    value: graphics.useAnimatedGifs,
                                    onChanged: (val) => ref.read(graphicsSettingsProvider.notifier).setUseAnimatedGifs(val),
                                    activeColor: AppColors.primary,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  const Divider(color: AppColors.outlineVariant),
                                  SwitchListTile(
                                    title: const Text('3D Battle Models'),
                                    value: graphics.use3DModels,
                                    onChanged: (val) => ref.read(graphicsSettingsProvider.notifier).setUse3DModels(val),
                                    activeColor: AppColors.primary,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  const Divider(color: AppColors.outlineVariant),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Graphics Profile'),
                                    subtitle: Text(graphics.profile.name.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                    trailing: const Icon(Icons.tune, color: AppColors.primary),
                                    onTap: _showGraphicsDialog,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            _buildSectionHeader('SYSTEM SETTINGS'),
                            const SizedBox(height: 16),
                            _buildSettingsCard(
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('Auto-check on launch', style: AppTypography.bodyLarge),
                                    value: settings.autoCheckForUpdates,
                                    onChanged: (value) => ref.read(appSettingsProvider.notifier).setAutoCheckForUpdates(value),
                                    activeColor: AppColors.primary,
                                  ),
                                  const Divider(color: AppColors.outlineVariant, height: 32),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('Manual update check', style: AppTypography.bodyLarge),
                                    trailing: _isCheckingUpdates 
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.system_update_alt, color: AppColors.primary),
                                    onTap: _isCheckingUpdates ? null : _checkForUpdate,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            _buildSectionHeader('DATA MANAGEMENT'),
                            const SizedBox(height: 16),
                            _buildSettingsCard(
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('Offline Fallback Mode', style: AppTypography.bodyLarge),
                                    value: settings.offlineModeEnabled,
                                    onChanged: (value) => ref.read(appSettingsProvider.notifier).setOfflineMode(value),
                                    activeColor: AppColors.primary,
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('Sync User Data', style: AppTypography.bodyLarge),
                                    trailing: _isSyncing 
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Icon(Icons.sync, color: authState.isAuthenticated ? AppColors.primary : AppColors.outline),
                                    onTap: (_isSyncing || !authState.isAuthenticated) ? null : _manualSync,
                                  ),
                                  const Divider(color: AppColors.outlineVariant, height: 32),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Clear Local Cache', style: TextStyle(color: Colors.redAccent)),
                                    subtitle: const Text('Wipe local database and temp files.', style: TextStyle(fontSize: 10)),
                                    trailing: _isClearing 
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                                    onTap: _isClearing ? null : _clearCache,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),

                            FutureBuilder<PackageInfo>(
                              future: _packageInfoFuture,
                              builder: (context, snapshot) {
                                final packageInfo = snapshot.data;
                                final versionLabel = packageInfo == null
                                    ? 'Pokemon Generations'
                                    : 'Pokemon Generations v${packageInfo.version}+${packageInfo.buildNumber}';

                                return Column(
                                  children: [
                                    Center(
                                      child: Text(
                                        versionLabel,
                                        style: AppTypography.labelSmall.copyWith(color: AppColors.outline),
                                      ),
                                    ),
                                    Center(
                                      child: TextButton(
                                        onPressed: _showCreditsDialog,
                                        child: Text(
                                          'CREDITS & LEGAL',
                                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary, letterSpacing: 1),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onLongPress: () {
                                        HapticFeedback.heavyImpact();
                                        context.push('/music-player');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.music_note, color: AppColors.outline, size: 24),
                                      ),
                                    ),
                                    const SizedBox(height: 48),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameSelectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CHOOSE ACTIVE GAME',
                  style: AppTypography.labelLarge.copyWith(letterSpacing: 2),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: PokemonGame.allGames.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.outlineVariant, height: 1),
                itemBuilder: (context, index) {
                  final game = PokemonGame.allGames[index];
                  final isSelected =
                      ref.read(gameProviderProvider).valueOrNull?.id == game.id;

                  return ListTile(
                    title: Text(
                      game.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Gen ${game.generation} • ${game.regions.join(', ')}',
                      style: AppTypography.bodySmall,
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      ref.read(gameProviderProvider.notifier).selectGame(game);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 2,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildAdminCodeRow(String code, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Courier',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelect;

  const _TypeOption({
    required this.label,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        )),
      ),
    );
  }
}
