import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'database/app_database.dart';
import 'repositories/roster_repository_impl.dart';
import 'repositories/history_repository_impl.dart';
import '../domain/repositories/roster_repository.dart';
import '../domain/repositories/history_repository.dart';
import '../domain/models/history.dart';
import '../core/settings/app_settings_controller.dart';
import 'services/api_client.dart';
import '../features/auth/auth_controller.dart';

part 'providers.g.dart';

@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@riverpod
RosterRepository rosterRepository(RosterRepositoryRef ref) {
  return RosterRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(apiClientProvider.notifier),
    () => ref.read(backendBaseUrlProvider),
    () => ref.read(authControllerProvider).profile?.username,
  );
}

@riverpod
HistoryRepository historyRepository(HistoryRepositoryRef ref) {
  return HistoryRepositoryImpl(ref.watch(appDatabaseProvider));
}

@riverpod
class AnalysisHistoryNotifier extends _$AnalysisHistoryNotifier {
  @override
  FutureOr<List<AnalysisHistory>> build() {
    return ref.watch(historyRepositoryProvider).getHistory();
  }

  Future<void> addHistory(AnalysisHistory history) async {
    await ref.read(historyRepositoryProvider).saveHistory(history);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    await ref.read(historyRepositoryProvider).clearHistory();
    ref.invalidateSelf();
  }
}

@riverpod
Future<String> pokemonName(PokemonNameRef ref, String pokemonId) async {
  final pokemon = await ref
      .read(apiClientProvider.notifier)
      .getPokemonDetail(pokemonId);
  return pokemon?.name.toUpperCase() ?? 'UNKNOWN POKÉMON';
}
