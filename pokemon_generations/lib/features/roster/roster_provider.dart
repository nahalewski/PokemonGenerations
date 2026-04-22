import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/pokemon.dart';
import '../../domain/models/pokemon_form.dart';
import '../../data/providers.dart';

part 'roster_provider.g.dart';

@riverpod
class Roster extends _$Roster {
  @override
  FutureOr<List<PokemonForm>> build() async {
    return _fetchRoster();
  }

  Future<List<PokemonForm>> _fetchRoster() async {
    final repository = ref.read(rosterRepositoryProvider);
    return repository.getRosterPokemon();
  }

  Future<void> addPokemon(PokemonForm pokemon) async {
    // Optimistic Update: Add to the local list immediately
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncValue.data([...currentList, pokemon]);
    }

    // Perform actual save
    await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).addPokemonToRoster(pokemon);
      return _fetchRoster(); // Final sync with source of truth
    });
  }

  Future<void> updatePokemon(PokemonForm pokemon) async {
    // Optimistic Update
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncValue.data([
        for (final p in currentList)
          if (p.id == pokemon.id) pokemon else p
      ]);
    }

    await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).updateRosterPokemon(pokemon);
      return _fetchRoster();
    });
  }

  Future<void> removePokemon(String id) async {
    // Optimistic Update
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncValue.data(currentList.where((p) => p.id != id).toList());
    }

    await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).removePokemonFromRoster(id);
      return _fetchRoster();
    });
  }
}

@riverpod
class PCStorage extends _$PCStorage {
  @override
  FutureOr<List<PokemonForm>> build() async {
    return _fetchPC();
  }

  Future<List<PokemonForm>> _fetchPC() async {
    final repository = ref.read(rosterRepositoryProvider);
    return repository.getPCStorage();
  }

  Future<void> updatePC(List<PokemonForm> pcPokemon) async {
    // Optimistic Update
    state = AsyncValue.data(pcPokemon);

    await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).updatePCStorage(pcPokemon);
      return _fetchPC();
    });
  }
}
