import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/models/team.dart';
import '../../domain/models/pokemon_form.dart';
import '../../data/providers.dart';
import 'roster_provider.dart';

final teamsNotifierProvider = AsyncNotifierProvider.autoDispose<TeamsNotifier, List<Team>>(TeamsNotifier.new);

class TeamsNotifier extends AutoDisposeAsyncNotifier<List<Team>> {
  @override
  FutureOr<List<Team>> build() async {
    final repository = ref.read(rosterRepositoryProvider);
    return repository.getTeamPresets();
  }

  Future<void> saveCurrentAsTeam(String name) async {
    final rosterData = ref.read(rosterProvider).value ?? [];
    if (rosterData.isEmpty) return;

    final team = Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      slots: rosterData,
      updatedAt: DateTime.now(),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).saveTeamPreset(team);
      return ref.read(rosterRepositoryProvider).getTeamPresets();
    });
  }

  Future<void> loadTeam(Team team) async {
    final rosterNotifier = ref.read(rosterProvider.notifier);
    
    // Clear current roster and load team slots
    await _clearRoster();
    for (final slot in team.slots) {
      await rosterNotifier.addPokemon(slot);
    }
  }

  Future<void> deleteTeam(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).deleteTeamPreset(id);
      return ref.read(rosterRepositoryProvider).getTeamPresets();
    });
  }

  Future<void> _clearRoster() async {
    final roster = ref.read(rosterProvider).value ?? [];
    for (final p in roster) {
      await ref.read(rosterProvider.notifier).removePokemon(p.id);
    }
  }
}
