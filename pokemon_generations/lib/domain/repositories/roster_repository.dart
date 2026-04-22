import '../models/pokemon.dart';
import '../models/pokemon_form.dart';
import '../models/team.dart';

abstract class RosterRepository {
  Future<List<PokemonForm>> getRosterPokemon();
  Future<void> addPokemonToRoster(PokemonForm pokemon);
  Future<void> updateRosterPokemon(PokemonForm pokemon);
  Future<void> removePokemonFromRoster(String id);
  
  // PC System
  Future<List<PokemonForm>> getPCStorage();
  Future<void> updatePCStorage(List<PokemonForm> pcPokemon);

  Future<List<Team>> getTeamPresets();
  Future<void> saveTeamPreset(Team team);
  Future<void> deleteTeamPreset(String id);
  
  /// Forces a full synchronization with the server.
  Future<void> syncWithCloud({String? username});

  /// Deletes all local roster and team data.
  Future<void> clearLocalData();
}
