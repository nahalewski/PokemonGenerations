import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/passcode_change_screen.dart';
import '../features/home/home_screen.dart';
import '../features/pc/pc_screen.dart';
import '../features/roster/add_pokemon_screen.dart';
import '../features/roster/roster_detail_screen.dart';
import '../features/analysis/analysis_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/analysis/history_screen.dart';
import '../features/battle/battle_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/changelog_screen.dart';
import '../features/social/social_screen.dart';
import '../features/battle/online_battle_screen.dart';
import '../features/onboarding/hybrid_splash_screen.dart';
import '../domain/models/pokemon_form.dart';
import '../features/gifts/gift_screen.dart';
import '../features/home/placeholder_screens.dart';
import '../features/story_mode/story_mode_screen.dart';
import '../features/onboarding/asset_download_screen.dart';
import '../core/services/asset_package_service.dart';

import '../features/game_selection/game_selection_screen.dart';
import '../features/game_selection/game_provider.dart';
import '../features/music/music_player_screen.dart';
import '../features/pokedex/pokedex_screen.dart';
import '../features/pokedex/pokedex_detail_screen.dart';
import '../features/pokemon_center/pokemon_center_screen.dart';
import 'package:pokemon_generations/features/inventory/inventory_screen.dart';
import '../features/battle_tower/battle_tower_screen.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  // Only watch the initialization and authentication status for the top-level router.
  // Minor profile updates (inventory, photo) shouldn't re-instantiate the GoRouter.
  final isInitialized = ref.watch(authControllerProvider.select((s) => s.isInitialized));
  final isAuthenticated = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));
  final hasProfile = ref.watch(authControllerProvider.select((s) => s.hasProfile));
  
  final listenable = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: listenable,
    // listen to nothing specifically, or use a refreshListenable if needed
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToAuth = state.matchedLocation == '/auth';
      final isGoingToSelection = state.matchedLocation == '/game-selection';
      final isGoingToAssetDownload = state.matchedLocation == '/asset-download';
      
      // Use AsyncValue states for cleaner logic
      final gameAsync = ref.read(gameProviderProvider);
      final hasSelected = gameAsync.valueOrNull != null;
      final isInitializing = gameAsync.isLoading;

      if (isGoingToSplash) return null;
      if (isInitializing) return null;

      if (!isInitialized) {
        return isGoingToAuth ? null : '/auth';
      }

      if (!hasProfile || !isAuthenticated) {
        return isGoingToAuth ? null : '/auth';
      }

      if (isGoingToAuth) {
        final selectedGame = ref.read(gameProviderProvider).valueOrNull;
        return selectedGame == null ? '/game-selection' : '/';
      }

      if (!hasSelected && !isGoingToSelection) {
        return '/game-selection';
      }

      if (hasSelected && !kIsWeb && !isGoingToAssetDownload) {
        final firstLaunch = ref.read(isFirstAssetLaunchProvider).valueOrNull;
        if (firstLaunch == true) return '/asset-download';
      }

      if (hasSelected && authState.mustChangePasscode && state.matchedLocation != '/auth/reset') {
        return '/auth/reset';
      }

      if (hasSelected && isGoingToSelection) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const HybridSplashScreen()),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: 'reset',
            builder: (context, state) => const PasscodeChangeScreen(),
          ),
        ],
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/game-selection',
        builder: (context, state) => const GameSelectionScreen(),
      ),
      GoRoute(
        path: '/asset-download',
        builder: (context, state) => const AssetDownloadScreen(),
      ),
      GoRoute(
        path: '/roster',
        builder: (context, state) => const PCScreen(),
        routes: [
          GoRoute(
            path: 'add-pokemon',
            builder: (context, state) {
              final form = state.extra as PokemonForm?;
              return AddPokemonScreen(initialForm: form);
            },
          ),
          GoRoute(
            path: 'detail/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return RosterDetailScreen(teamId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) => const AnalysisScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'changelog',
            builder: (context, state) => const ChangelogScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/battle/:playerId/:opponentId',
        builder: (context, state) {
          final playerId = state.pathParameters['playerId']!;
          final opponentId = state.pathParameters['opponentId']!;
          return BattleScreen(
            playerPokemonId: playerId,
            opponentPokemonId: opponentId,
            isCPUBattle: false,
          );
        },
      ),
      GoRoute(
        path: '/battle/cpu',
        builder: (context, state) {
          return const BattleScreen(
            playerPokemonId: 'ROSTER_LEAD',
            opponentPokemonId: 'RANDOM_CPU',
            isCPUBattle: true,
          );
        },
      ),
      GoRoute(
        path: '/social',
        builder: (context, state) => const SocialScreen(),
      ),
      GoRoute(
        path: '/battle/online/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OnlineBattleScreen(battleId: id);
        },
      ),
      GoRoute(
        path: '/gift',
        builder: (context, state) => const GiftScreen(),
      ),
      GoRoute(
        path: '/music-player',
        builder: (context, state) => const MusicPlayerScreen(),
      ),
      GoRoute(
        path: '/center',
        builder: (context, state) => const PokemonCenterScreen(),
      ),
      GoRoute(
        path: '/mart',
        builder: (context, state) => const MartComingSoonScreen(),
      ),
      GoRoute(
        path: '/pokedex',
        builder: (context, state) => const PokedexScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PokedexDetailScreen(pokemonId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/story-mode',
        builder: (context, state) => const StoryModeScreen(),
      ),
      GoRoute(
        path: '/battle-tower',
        builder: (context, state) => const BattleTowerScreen(),
      ),
    ],
  );
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Only notify listeners when core auth status changes.
    // Small profile updates (inventory, photo, wins) shouldn't reset the router.
    _ref.listen(authControllerProvider.select((s) => s.isInitialized), (_, __) => notifyListeners());
    _ref.listen(authControllerProvider.select((s) => s.isAuthenticated), (_, __) => notifyListeners());
    _ref.listen(authControllerProvider.select((s) => s.hasProfile), (_, __) => notifyListeners());
  }
}
