import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/services/app_update_service.dart';
import '../../core/services/battle_reconnect_service.dart';
import '../../core/services/changelog_service.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/services/api_client.dart';
import '../../data/providers.dart';
import '../auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../social/social_controller.dart';
import '../../domain/models/app_update_info.dart';
import '../../domain/models/history.dart';
import '../../domain/models/social.dart';
import '../analysis/matchup_provider.dart';
import '../settings/update_download_controller.dart';
import 'changelog_dialog.dart';
import '../settings/update_prompt.dart';
import 'news_section.dart';
import '../../core/services/global_audio_controller.dart';
import 'widgets/news_broadcast_overlay.dart';
import 'widgets/home_sidebar.dart';
import '../../core/widgets/currency_indicator.dart';
import 'tabs/bank_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _didRunUpdateCheck = false;
  bool _didRunChangelogCheck = false;
  bool _didCheckReconnect = false;
  bool _didRequestDailyBriefing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didRunUpdateCheck) {
      _didRunUpdateCheck = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybePromptForUpdate(),
      );
    }

    if (!_didRunChangelogCheck) {
      _didRunChangelogCheck = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeShowChangelog(),
      );
    }

    if (!_didCheckReconnect) {
      _didCheckReconnect = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeReconnectBattle();
        ref.read(globalAudioControllerProvider).playMenuMusic();
        _listenForNewsBroadcasts();
        _maybeShowDailyBriefing();
      });
    }
  }

  void _listenForNewsBroadcasts() {
    // Listen to social state for news broadcasts
    ref.listenManual(
      socialControllerProvider.select((s) => s.globalBroadcast),
      (prev, next) {
        if (next != null &&
            next['type'] == 'news' &&
            next['sentAt'] != prev?['sentAt']) {
          _showNewsBroadcast(next['text'] ?? '');
        }
      },
    );
  }

  void _showNewsBroadcast(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (context) => NewsBroadcastOverlay(
        message: message,
        onClose: () {
          Navigator.of(context).pop();
          ref.read(socialControllerProvider.notifier).dismissBroadcast();
        },
      ),
    );
  }

  Future<void> _maybeShowDailyBriefing() async {
    if (_didRequestDailyBriefing || !mounted) return;

    final authState = ref.read(authControllerProvider);
    final baseUrl = ref.read(appSettingsProvider).resolvedBackendUrl;
    final username = authState.profile?.username;
    if (!authState.isAuthenticated || username == null || baseUrl.isEmpty) {
      return;
    }

    _didRequestDailyBriefing = true;
    final activeBroadcast = ref.read(
      socialControllerProvider.select((state) => state.globalBroadcast),
    );
    if (activeBroadcast != null) {
      return;
    }

    final briefing = await ref
        .read(apiClientProvider.notifier)
        .fetchDailyLoginBriefing(baseUrl, username);
    if (!mounted || briefing == null) return;

    final preview = briefing['preview']?.toString().trim();
    if (preview == null || preview.isEmpty) return;
    _showNewsBroadcast(preview);
  }

  Future<void> _maybePromptForUpdate() async {
    final settings = ref.read(appSettingsProvider);
    if (!settings.autoCheckForUpdates) {
      return;
    }

    final updateInfo = await ref
        .read(appUpdateServiceProvider)
        .checkForUpdates(baseUrl: settings.resolvedBackendUrl);

    if (!mounted || updateInfo == null || !updateInfo.updateAvailable) {
      return;
    }

    await showAppUpdateDialog(
      context,
      updateInfo: updateInfo,
      manualCheck: false,
      onInstallPressed: () => _downloadUpdateInBackground(updateInfo),
    );
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

  Future<void> _maybeReconnectBattle() async {
    final savedId = await BattleReconnectService.getSavedBattleId();
    if (savedId == null || !mounted) return;

    final baseUrl = ref.read(appSettingsProvider).resolvedBackendUrl;
    if (baseUrl.isEmpty) return;

    try {
      final session = await ref
          .read(apiClientProvider.notifier)
          .getBattleSession(baseUrl, savedId);
      if (!mounted) return;
      if (session != null && session.status == 'active') {
        context.push('/battle/online/$savedId');
      } else {
        await BattleReconnectService.clearBattleId();
      }
    } catch (_) {
      await BattleReconnectService.clearBattleId();
    }
  }

  Future<void> _maybeShowChangelog() async {
    final changelog = await ref
        .read(changelogServiceProvider)
        .getPendingChangelog();
    if (!mounted || changelog == null) {
      return;
    }

    await showChangelogDialog(context, changelog: changelog);

    await ref.read(changelogServiceProvider).markSeen(changelog.versionLabel);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[HOME] Building HomeScreen...');
    final historyAsync = ref.watch(analysisHistoryNotifierProvider);

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // Centered layout
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [CurrencyIndicator()],
                            ),
                            const SizedBox(height: 20),

                            // Top Logo (App Icon)
                            Center(
                              child:
                                  const Icon(
                                    Icons.catching_pokemon,
                                    color: AppColors.primary,
                                    size: 80,
                                  ).animate().scale(
                                    duration: 600.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                            ),
                            const SizedBox(height: 40),

                            // Header
                            Column(
                              children: [
                                Text(
                                  'POKEMON',
                                  style: AppTypography.displayLarge.copyWith(
                                    height: 0.8,
                                  ),
                                ),
                                Text(
                                  'GENERATIONS',
                                  style: AppTypography.displayLarge.copyWith(
                                    color: AppColors.primary,
                                    height: 0.8,
                                    fontSize: 32, // Adjusted for longer word
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),
                            _buildUserProfileCard(),
                            const SizedBox(height: 32),
                            _buildFeatureCard(
                              context,
                              title: 'POKEMON BANK',
                              subtitle: 'Wall Street Trading Floor',
                              icon: Icons.account_balance,
                              color: Colors.amber,
                              onTap: () => _showBankingSheet(),
                            ),
                            const SizedBox(height: 40),

                            const SizedBox(height: 48),
                            _buildHistoryCard(context, historyAsync),
                            const SizedBox(height: 48),
                            const HomeNewsSection(),
                            const SizedBox(height: 48),
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

  Widget _buildHistoryCard(
    BuildContext context,
    AsyncValue<List<AnalysisHistory>> historyAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RECENT ANALYTICS', style: AppTypography.headlineSmall),
            TextButton(
              onPressed: () => context.push('/history'),
              child: Text(
                'SEE ALL',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        historyAsync.when(
          data: (history) {
            if (history.isEmpty) {
              return const GlassCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No recent reports. Start an analysis to see results.',
                    ),
                  ),
                ),
              );
            }

            final recent = history.take(3).toList();
            return Column(
              children: recent
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHistoryItem(context, ref, item),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned(bottom: -20, right: -20, child: const SizedBox.shrink()),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: AppTypography.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 300.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildUserProfileCard() {
    final authState = ref.watch(authControllerProvider);
    final socialState = ref.watch(socialControllerProvider);

    if (authState.profile == null) {
      return InkWell(
        onTap: () => context.push('/auth'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOT LOGGED IN',
                      style: AppTypography.labelLarge.copyWith(
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tap here to sign in and sync data',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    final profile = authState.profile!;
    // Find wins from social state if available, otherwise 0
    final socialUser = socialState.users.firstWhere(
      (u) => u.username == profile.username,
      orElse: () => SocialUser(
        username: profile.username,
        displayName: profile.displayName,
      ),
    );

    return GlassCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.push('/profile'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: profile.profileImageUrl != null
                ? CachedNetworkImageProvider(profile.profileImageUrl!)
                : null,
            child: profile.profileImageUrl == null
                ? Text(
                    profile.displayName[0].toUpperCase(),
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName.toUpperCase(),
                  style: AppTypography.labelLarge.copyWith(letterSpacing: 1),
                ),
                Text(
                  '@${profile.username}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${socialUser.wins} WINS',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ONLINE',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    ).animate().fade(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    AnalysisHistory item,
  ) {
    return GlassCard(
      onTap: () {
        ref.read(matchupProvider.notifier).loadHistoryResult(item);
        context.push('/analysis');
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${item.result.matchupScore.toInt()}%',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.opponentTeam.take(3).map((p) => p.pokemonName ?? 'Unknown').join(', ')}...',
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM dd, HH:mm').format(item.timestamp),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }

  void _showBankingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const BankTab(),
        ),
      ),
    );
  }
}
