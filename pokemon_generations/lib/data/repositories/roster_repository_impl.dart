import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/models/pokemon_form.dart';
import '../../domain/models/team.dart';
import '../../domain/repositories/roster_repository.dart';
import '../database/app_database.dart';
import '../services/api_client.dart';

class RosterRepositoryImpl implements RosterRepository {
  final AppDatabase db;
  final ApiClient apiClient;
  final String Function() getBaseUrl;
  final String? Function() getUsername;

  RosterRepositoryImpl(
    this.db,
    this.apiClient,
    this.getBaseUrl,
    this.getUsername,
  );

  String? _lastUpdatedAt;
  String? _lastRosterHash;
  String? _lastPresetsHash;
  String? _lastPCHash;
  Future<void>? _activeSync;

  Future<void> _enqueueSync() async {
    final completer = Completer<void>();
    final previousSync = _activeSync;
    _activeSync = completer.future;

    if (previousSync != null) {
      try {
        await previousSync;
      } catch (_) {}
    }

    try {
      await _syncToCloud();
    } finally {
      completer.complete();
    }
  }

  Future<List<PokemonForm>> _readLocalRoster() async {
    try {
      final rows = await db.select(db.pokemonFormsTable).get();
      return rows
          .map((row) => PokemonForm.fromJson(json.decode(row.data)))
          .toList();
    } catch (e) {
      print('[SYNC] Local roster read failed: $e');
      return [];
    }
  }

  Future<List<PokemonForm>> _readLocalPC() async {
    try {
      final row = await (db.select(
        db.pCStorageTable,
      )..where((t) => t.id.equals('pc_main'))).getSingleOrNull();
      if (row == null) return [];
      final List decoded = json.decode(row.data);
      return decoded.map((e) => PokemonForm.fromJson(e)).toList();
    } catch (e) {
      print('[SYNC] Local PC read failed: $e');
      return [];
    }
  }

  Future<void> _writeLocalRoster(List<PokemonForm> roster) async {
    try {
      // Filter out invalid/ghost entries (empty IDs or invalid Pokemon IDs)
      final validRoster = roster.where((p) => p.id.isNotEmpty && p.pokemonId.isNotEmpty).toList();

      await db.transaction(() async {
        await db.delete(db.pokemonFormsTable).go();
        for (final pokemon in validRoster) {
          await db
              .into(db.pokemonFormsTable)
              .insert(
                PokemonFormsTableCompanion.insert(
                  id: pokemon.id,
                  pokemonId: pokemon.pokemonId,
                  data: json.encode(pokemon.toJson()),
                ),
                mode: InsertMode.insertOrReplace,
              );
        }
      });
    } catch (e) {
      print('[SYNC] Local roster write skipped: $e');
    }
  }

  Future<void> _writeLocalPC(List<PokemonForm> pcPokemon) async {
    try {
      final validPC = pcPokemon.where((p) => p.id.isNotEmpty && p.pokemonId.isNotEmpty).toList();
      await db
          .into(db.pCStorageTable)
          .insert(
            PCStorageTableCompanion.insert(
              id: 'pc_main',
              data: json.encode(validPC.map((e) => e.toJson()).toList()),
            ),
            mode: InsertMode.insertOrReplace,
          );
    } catch (e) {
      print('[SYNC] Local PC write skipped: $e');
    }
  }

  @override
  Future<List<PokemonForm>> getRosterPokemon() async {
    final localRoster = await _readLocalRoster();

    _reconcileStartupState();

    if (localRoster.isNotEmpty || getUsername() == null) {
      return localRoster;
    }

    try {
      final cloudRoster = await apiClient.fetchRoster(
        getBaseUrl(),
        getUsername()!,
      );
      await _writeLocalRoster(cloudRoster);
      return cloudRoster;
    } catch (e) {
      print('[SYNC] Fallback roster fetch failed: $e');
    }

    return localRoster;
  }

  Future<void> _reconcileStartupState() async {
    final username = getUsername();
    if (username == null) return;

    try {
      final baseUrl = getBaseUrl();

      // Fetch cloud state first (Safe Confirmation)
      final cloudRoster = await apiClient.fetchRoster(baseUrl, username);
      final cloudTeams = await apiClient.fetchTeamPresets(baseUrl, username);
      
      // We don't have the timestamp from standard fetch yet, but server-sent user profile would have it
      // For now, if we successfully fetched, we proceed to update local.

      await db.transaction(() async {
        // Safe Transaction: Only clear and write if fetch was successful (reached this line)
        await db.delete(db.pokemonFormsTable).go();
        await db.delete(db.teamPresetsTable).go();

        for (var p in cloudRoster) {
          await db
              .into(db.pokemonFormsTable)
              .insert(
                PokemonFormsTableCompanion.insert(
                  id: p.id,
                  pokemonId: p.pokemonId,
                  data: json.encode(p.toJson()),
                ),
              );
        }

        for (var t in cloudTeams) {
          await db
              .into(db.teamPresetsTable)
              .insert(
                TeamPresetsTableCompanion.insert(
                  id: t.id,
                  name: t.name,
                  data: json.encode(t.toJson()),
                ),
              );
        }
      });
      print(
        '[SYNC] Startup reconciliation complete. Cloud Source of Truth applied.',
      );
    } catch (e) {
      print('[SYNC] Background reconcile failed: $e');
    }
  }

  Future<void> _syncToCloud() async {
    final username = getUsername();
    if (username == null) {
      return;
    }

    try {
      final baseUrl = getBaseUrl();
      
      // 1. Sync Roster
      final roster = await _readLocalRoster();
      final rosterJson = json.encode(roster.map((e) => e.toJson()).toList());
      final rosterHash = rosterJson.hashCode.toString();
      
      if (rosterHash != _lastRosterHash) {
        print('[SYNC] Pushing Roster (Hash changed: $rosterHash)');
        await apiClient.saveRoster(baseUrl, username, roster, updatedAt: _lastUpdatedAt);
        _lastRosterHash = rosterHash;
      }

      // 2. Sync Presets
      final pRows = await db.select(db.teamPresetsTable).get();
      final presets = pRows
          .map((row) => Team.fromJson(json.decode(row.data)))
          .toList();
      final presetsJson = json.encode(presets.map((e) => e.toJson()).toList());
      final presetsHash = presetsJson.hashCode.toString();

      if (presetsHash != _lastPresetsHash) {
        print('[SYNC] Pushing Presets (Hash changed: $presetsHash)');
        await apiClient.saveTeamPresets(baseUrl, username, presets, updatedAt: _lastUpdatedAt);
        _lastPresetsHash = presetsHash;
      }

      // 3. Sync PC Storage
      final pc = await getPCStorage();
      if (pc.isNotEmpty) {
        final pcJson = json.encode(pc.map((e) => e.toJson()).toList());
        final pcHash = pcJson.hashCode.toString();
        
        if (pcHash != _lastPCHash) {
          print('[SYNC] Pushing PC (Hash changed: $pcHash)');
          await apiClient.savePC(baseUrl, username, pc, updatedAt: _lastUpdatedAt);
          _lastPCHash = pcHash;
        }
      }
    } catch (e, stack) {
      if (e.toString().contains('409') || e.toString().contains('Conflict')) {
        print('[SYNC] Conflict detected. Forcing a refresh on next startup.');
      }
      print('[SYNC] _syncToCloud FAILED: $e');
    }
  }

  @override
  Future<void> addPokemonToRoster(PokemonForm pokemon) async {
    final roster = await _readLocalRoster();
    final updatedRoster = [
      for (final entry in roster)
        if (entry.id == pokemon.id) pokemon else entry,
      if (!roster.any((entry) => entry.id == pokemon.id)) pokemon,
    ];
    await _writeLocalRoster(updatedRoster);
    await _enqueueSync();
  }

  @override
  Future<void> updateRosterPokemon(PokemonForm pokemon) async {
    await addPokemonToRoster(pokemon);
  }

  @override
  Future<void> removePokemonFromRoster(String id) async {
    final roster = await _readLocalRoster();
    await _writeLocalRoster(roster.where((entry) => entry.id != id).toList());
    await _enqueueSync();
  }

  @override
  Future<List<PokemonForm>> getPCStorage() async {
    final localPC = await _readLocalPC();
    if (localPC.isNotEmpty || getUsername() == null) {
      return localPC;
    }

    try {
      final cloudPC = await apiClient.fetchPC(getBaseUrl(), getUsername()!);
      await _writeLocalPC(cloudPC);
      return cloudPC;
    } catch (e) {
      print('[SYNC] Fallback PC fetch failed: $e');
    }

    return localPC;
  }

  @override
  Future<void> updatePCStorage(List<PokemonForm> pcPokemon) async {
    await _writeLocalPC(pcPokemon);
    await _syncToCloud();
  }

  @override
  Future<List<Team>> getTeamPresets() async {
    final rows = await db.select(db.teamPresetsTable).get();
    return rows.map((row) => Team.fromJson(json.decode(row.data))).toList();
  }

  @override
  Future<void> saveTeamPreset(Team team) async {
    await db
        .into(db.teamPresetsTable)
        .insert(
          TeamPresetsTableCompanion.insert(
            id: team.id,
            name: team.name,
            data: json.encode(team.toJson()),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _syncToCloud();
  }

  @override
  Future<void> deleteTeamPreset(String id) async {
    await (db.delete(db.teamPresetsTable)..where((t) => t.id.equals(id))).go();
    await _syncToCloud();
  }

  @override
  Future<void> syncWithCloud({String? username}) async {
    final effectiveUsername = username ?? getUsername();
    print('[SYNC] syncWithCloud called for username: $effectiveUsername');
    if (effectiveUsername == null) {
      print('[SYNC] Aborting - username is null');
      return;
    }

    print(
      '[SYNC] Starting forced cloud sync for $effectiveUsername (OVERWRITE MODE)...',
    );
    try {
      final baseUrl = getBaseUrl();

      // 1. Fetch Remote Data
      final cloudRoster = await apiClient.fetchRoster(
        baseUrl,
        effectiveUsername,
      );
      final cloudPresets = await apiClient.fetchTeamPresets(
        baseUrl,
        effectiveUsername,
      );

      // 2. Clear local and replace with cloud (Source of Truth)
      await db.transaction(() async {
        // Clear Existing
        await db.delete(db.pokemonFormsTable).go();
        await db.delete(db.teamPresetsTable).go();
        await db.delete(db.pCStorageTable).go();

        // Insert Roster
        for (var p in cloudRoster) {
          await db
              .into(db.pokemonFormsTable)
              .insert(
                PokemonFormsTableCompanion.insert(
                  id: p.id,
                  pokemonId: p.pokemonId,
                  data: json.encode(p.toJson()),
                ),
                mode: InsertMode.insertOrReplace,
              );
        }

        // Insert Presets
        for (var t in cloudPresets) {
          await db
              .into(db.teamPresetsTable)
              .insert(
                TeamPresetsTableCompanion.insert(
                  id: t.id,
                  name: t.name,
                  data: json.encode(t.toJson()),
                ),
                mode: InsertMode.insertOrReplace,
              );
        }

        // Try to fetch PC storage from cloud
        try {
          final cloudPC = await apiClient.fetchPC(baseUrl, effectiveUsername);
          if (cloudPC.isNotEmpty) {
            await db
                .into(db.pCStorageTable)
                .insert(
                  PCStorageTableCompanion.insert(
                    id: 'pc_main',
                    data: json.encode(cloudPC.map((e) => e.toJson()).toList()),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
          }
        } catch (_) {}
      });

      print(
        '[SYNC] Forced sync completed. Roster: ${cloudRoster.length}, Presets: ${cloudPresets.length}',
      );
    } catch (e) {
      print('[SYNC] Forced sync failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearLocalData() async {
    await db.clearAllData();
  }
}
