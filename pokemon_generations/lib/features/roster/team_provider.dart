import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/team.dart';
import '../../data/providers.dart';
import 'roster_provider.dart';

part 'team_provider.g.dart';

@riverpod
class TeamList extends _$TeamList {
  @override
  FutureOr<List<Team>> build() async {
    return _fetchTeams();
  }

  Future<List<Team>> _fetchTeams() async {
    final repository = ref.read(rosterRepositoryProvider);
    return repository.getTeamPresets();
  }

  Future<void> saveTeam(Team team) async {
    if (state.hasValue) {
      final currentList = state.value!;
      final exists = currentList.any((t) => t.id == team.id);
      if (exists) {
        state = AsyncValue.data([
          for (final t in currentList)
            if (t.id == team.id) team else t
        ]);
      } else {
        state = AsyncValue.data([...currentList, team]);
      }
    }

    await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).saveTeamPreset(team);
      return _fetchTeams();
    });
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

    await saveTeam(team);
  }

  Future<void> deleteTeam(String id) async {
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncValue.data(currentList.where((t) => t.id != id).toList());
    }

    await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).deleteTeamPreset(id);
      return _fetchTeams();
    });
  }
}

@riverpod
FutureOr<Team?> teamById(TeamByIdRef ref, String id) async {
  final teams = await ref.watch(teamListProvider.future);
  try {
    return teams.firstWhere((t) => t.id == id);
  } catch (e) {
    return null;
  }
}
