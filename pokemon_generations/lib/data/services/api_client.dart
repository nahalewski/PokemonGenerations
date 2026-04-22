import 'dart:convert';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/networking/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/analysis.dart';
import '../../domain/models/pokemon.dart';
import '../../domain/models/pokemon_form.dart';
import '../../domain/models/move_detail.dart';
import '../../domain/models/app_update_info.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/team.dart';
import '../../domain/models/social.dart';
import '../../domain/models/gift.dart';
import '../../core/utils/type_chart.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../core/settings/app_settings_controller.dart';

part 'api_client.g.dart';

@riverpod
class ApiClient extends _$ApiClient {
  final Map<String, MoveDetail> _moveCache = {};
  List<dynamic>? _cachedPokemonList;

  @override
  void build() {}

  Future<MoveDetail?> getMoveDetail(String name) async {
    final normalizedName = name.toLowerCase().replaceAll(' ', '-');
    if (_moveCache.containsKey(normalizedName)) {
      return _moveCache[normalizedName];
    }

    try {
      final response = await ref
          .read(dioProvider)
          .get('https://pokeapi.co/api/v2/move/$normalizedName');
      final data = response.data;

      String description = '';
      final entries = data['flavor_text_entries'] as List;
      final enEntry = entries.firstWhere(
        (e) => e['language']['name'] == 'en',
        orElse: () => entries.firstOrNull,
      );
      if (enEntry != null) {
        description = enEntry['flavor_text'].replaceAll('\n', ' ');
      }

      final detail = MoveDetail(
        name: data['name'],
        type: data['type']['name'],
        damageClass: data['damage_class']['name'],
        power: data['power'],
        accuracy: data['accuracy'],
        pp: data['pp'],
        description: description,
      );

      _moveCache[normalizedName] = detail;
      return detail;
    } catch (e) {
      return null;
    }
  }

  Future<MatchupAnalysis> analyzeTeam(
    String baseUrl,
    List<PokemonForm> roster,
    List<dynamic> opponentTeam,
    String format,
  ) async {
    try {
      final response = await ref
          .read(dioProvider)
          .post(
            '$baseUrl/analyze-team',
            data: {
              'roster': roster.map((p) => p.toJson()).toList(),
              'opponentTeam': opponentTeam,
              'format': format,
            },
          );
      return MatchupAnalysis.fromJson(response.data);
    } catch (e) {
      print('ANALYZE ERROR: $e');
      rethrow;
    }
  }

  Future<bool> checkHealth(String baseUrl) async {
    try {
      final response = await ref.read(dioProvider).get('$baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchDailyLoginBriefing(
    String baseUrl,
    String username, {
    bool deliverToInbox = true,
  }) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            '$baseUrl/ai/daily-login-briefing',
            queryParameters: {
              'username': username,
              'deliverToInbox': deliverToInbox.toString(),
            },
          );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<List<Pokemon>> searchPokemon(String query) async {
    try {
      if (_cachedPokemonList == null) {
        try {
          final String jsonString = await rootBundle.loadString(
            'assets/pokemon_database.json',
          );
          final data = jsonDecode(jsonString);
          if (data is Map && data.containsKey('results')) {
            _cachedPokemonList = data['results'] as List;
          }
        } catch (e) {
          print('LOCAL ASSET ERROR: $e. Falling back to PokeAPI.');
        }

        if (_cachedPokemonList == null) {
          final response = await ref
              .read(dioProvider)
              .get('https://pokeapi.co/api/v2/pokemon?limit=1200');
          dynamic data = response.data;
          if (data is String) data = jsonDecode(data);
          if (data is Map && data.containsKey('results')) {
            _cachedPokemonList = data['results'] as List;
          }
        }

        if (_cachedPokemonList == null) {
          throw Exception('Failed to load Pokémon database from any source');
        }
      }

      final queryLower = query.toLowerCase();
      return _cachedPokemonList!
          .where(
            (e) =>
                (e['name'] as String?)?.toLowerCase().contains(queryLower) ??
                false,
          )
          .map((e) {
            final url = e['url'] as String;
            final cleanUrl = url.endsWith('/')
                ? url.substring(0, url.length - 1)
                : url;
            final id = cleanUrl.split('/').last;
            return Pokemon(
              id: id,
              name: _capitalize(e['name'] as String? ?? 'Unknown'),
              types: [],
              baseStats: {},
              abilities: [],
            );
          })
          .toList();
    } catch (e) {
      print('SEARCH ERROR: $e');
      return [];
    }
  }

  Future<Pokemon?> getPokemonDetail(String id, {String? versionGroupId}) async {
    final baseUrl = ref.read(backendBaseUrlProvider);

    // Normalize ID for server (remove dashes for cache/lookup compatibility)
    final normalizedId = id.toString().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9-]'),
      '',
    );

    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      attempts++;
      try {
        // 1. Primary: Use Backend Proxy
        final response = await ref
            .read(dioProvider)
            .get(
              '$baseUrl/pokemon/$normalizedId',
              options: Options(
                receiveTimeout: const Duration(seconds: 8),
                sendTimeout: const Duration(seconds: 8),
              ),
            );

        final data = response.data;
        if (data == null || data['stats'] == null) {
          throw Exception('Invalid data structure from proxy');
        }

        final bool hideAbilities =
            versionGroupId == 'red-blue' ||
            versionGroupId == 'yellow' ||
            versionGroupId == 'gold-silver' ||
            versionGroupId == 'crystal';

        final types = (data['types'] as List)
            .map((t) => _capitalize(t['type']['name'] as String))
            .toList();
        return Pokemon(
          id: id,
          name: _capitalize(data['name']),
          types: types,
          baseStats: {
            for (var s in data['stats'] as List)
              _mapStatName(s['stat']['name']): s['base_stat'] as int,
          },
          abilities: hideAbilities
              ? []
              : (data['abilities'] as List)
                    .map((a) => _capitalize(a['ability']['name']))
                    .toList(),
          availableMoves: _parseMoves(
            data['moves'] as List,
            types,
            versionGroupId,
          ),
          description: await _fetchFlavorText(id),
          latestCryUrl: data['cries']?['latest'],
          legacyCryUrl: data['cries']?['legacy'],
        );
      } catch (e) {
        print('[API] Attempt $attempts failed for Pokemon $id: $e');
        if (attempts == maxAttempts) {
          print(
            '[API] Max attempts reached for Pokemon $id. Falling back to direct PokeAPI.',
          );
        } else {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
        }
      }
    }

    try {
      // 2. Fallback: Direct PokeAPI
      final response = await ref
          .read(dioProvider)
          .get(
            'https://pokeapi.co/api/v2/pokemon/$id',
            options: Options(
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
          );
      final data = response.data;
      final bool hideAbilities =
          versionGroupId == 'red-blue' ||
          versionGroupId == 'yellow' ||
          versionGroupId == 'gold-silver' ||
          versionGroupId == 'crystal';
      final types = (data['types'] as List)
          .map((t) => _capitalize(t['type']['name'] as String))
          .toList();
      return Pokemon(
        id: id,
        name: _capitalize(data['name']),
        types: types,
        baseStats: {
          for (var s in data['stats'] as List)
            _mapStatName(s['stat']['name']): s['base_stat'] as int,
        },
        abilities: hideAbilities
            ? []
            : (data['abilities'] as List)
                  .map((a) => _capitalize(a['ability']['name']))
                  .toList(),
        availableMoves: _parseMoves(
          data['moves'] as List,
          types,
          versionGroupId,
        ),
        description: await _fetchFlavorText(id),
        latestCryUrl: data['cries']?['latest'],
        legacyCryUrl: data['cries']?['legacy'],
      );
    } catch (fallbackError) {
      print('DEBUG: PokeAPI fallback also failed: $fallbackError');
      return null;
    }
  }

  Future<String?> _fetchFlavorText(String id) async {
    // Mega/form variants share a species entry with their base form
    final speciesId = _extractSpeciesId(id);
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            'https://pokeapi.co/api/v2/pokemon-species/$speciesId',
            options: Options(
              receiveTimeout: const Duration(seconds: 5),
              sendTimeout: const Duration(seconds: 5),
            ),
          );
      final data = response.data;
      final entries = (data['flavor_text_entries'] as List)
          .where((e) => e['language']['name'] == 'en')
          .toList();
      if (entries.isEmpty) return null;
      return (entries.last['flavor_text'] as String)
          .replaceAll('\n', ' ')
          .replaceAll('\f', ' ');
    } catch (e) {
      print('[API] Failed to fetch flavor text for $speciesId: $e');
      return null;
    }
  }

  String _extractSpeciesId(String id) {
    final lower = id.toLowerCase();
    for (final suffix in [
      '-mega',
      '-primal',
      '-gmax',
      '-eternamax',
      '-totem',
    ]) {
      if (lower.contains(suffix)) return lower.split(suffix).first;
    }
    return id;
  }

  Future<List<Map<String, dynamic>>> getTcgCards(String pokemonName) async {
    // Strip form suffixes so megas/regionals search by base Pokémon name
    final searchName = _extractTcgSearchName(pokemonName);
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            'https://api.pokemontcg.io/v2/cards',
            queryParameters: {
              'q': 'name:$searchName',
              'orderBy': '-set.releaseDate',
              'pageSize': '60',
            },
            options: Options(
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
          );
      final data = response.data;
      if (data == null || data['data'] == null) return [];
      return List<Map<String, dynamic>>.from(data['data'] as List);
    } catch (e) {
      print('[TCG] Failed to fetch cards for $searchName: $e');
      return [];
    }
  }

  String _extractTcgSearchName(String pokemonName) {
    final lower = pokemonName.toLowerCase();
    for (final suffix in [
      '-mega',
      '-primal',
      '-gmax',
      '-eternamax',
      '-alola',
      '-galar',
      '-hisui',
      '-paldea',
    ]) {
      if (lower.contains(suffix)) return pokemonName.split(suffix).first;
    }
    return pokemonName;
  }

  List<Map<String, dynamic>>? _cachedItemList;

  Future<List<Map<String, dynamic>>> fetchItems() async {
    if (_cachedItemList != null) return _cachedItemList!;
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            '${ApiConstants.baseUrl}/items',
            options: Options(
              receiveTimeout: const Duration(seconds: 5),
              sendTimeout: const Duration(seconds: 5),
            ),
          );
      final List<dynamic> data = response.data;
      _cachedItemList = data.map((i) => i as Map<String, dynamic>).toList();
      return _cachedItemList!;
    } catch (e) {
      print(
        '[API] Failed to fetch items from backend, falling back to PokeAPI: $e',
      );
      try {
        final response = await ref
            .read(dioProvider)
            .get('https://pokeapi.co/api/v2/item?limit=1000');
        final dynamic data = response.data;
        if (data is Map && data.containsKey('results')) {
          final results = data['results'] as List;
          _cachedItemList = results
              .map(
                (e) => {
                  'id': e['name'],
                  'name': _capitalize(e['name'] as String),
                  'description': '',
                },
              )
              .toList();
          return _cachedItemList!;
        }
      } catch (fallbackError) {
        print('[API] PokeAPI item fallback failed: $fallbackError');
      }
      return [
        {'id': 'none', 'name': 'None', 'description': ''},
        {'id': 'focus-sash', 'name': 'Focus Sash', 'description': ''},
        {'id': 'life-orb', 'name': 'Life Orb', 'description': ''},
      ];
    }
  }

  Future<UserProfile?> registerRemote(
    String baseUrl,
    UserProfile profile,
  ) async {
    try {
      final response = await ref
          .read(dioProvider)
          .post('$baseUrl/register', data: profile.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('[API] Register Failed: $e');
      return null;
    }
  }

  Future<String?> uploadProfilePicture(
    String baseUrl,
    String username,
    XFile imageFile,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'username': username,
        'image': MultipartFile.fromBytes(bytes, filename: imageFile.name),
      });

      final response = await ref
          .read(dioProvider)
          .post('$baseUrl/auth/profile-picture', data: formData);

      if (response.statusCode == 200) {
        return response.data['profileImageUrl'] as String;
      }
      return null;
    } catch (e) {
      print('[API] Upload Profile Picture Failed: $e');
      return null;
    }
  }

  Future<bool> requestPasscodeReset(String baseUrl, String username) async {
    try {
      final response = await ref
          .read(dioProvider)
          .post('$baseUrl/auth/request-reset', data: {'username': username});
      return response.statusCode == 200;
    } catch (e) {
      print('[API] Request Reset Failed: $e');
      return false;
    }
  }

  Future<UserProfile?> loginRemote(
    String baseUrl,
    String username,
    String passcodeHash,
  ) async {
    try {
      final response = await ref
          .read(dioProvider)
          .post(
            '$baseUrl/login',
            data: {'username': username, 'passcodeHash': passcodeHash},
          );
      if (response.statusCode == 200) {
        final profile = UserProfile.fromJson(
          response.data as Map<String, dynamic>,
        );
        // Ensure local sync happens after successful login
        return profile;
      }
      return null;
    } catch (e) {
      print('[API] Login Failed: $e');
      return null;
    }
  }

  Future<List<PokemonForm>> fetchRoster(String baseUrl, String username) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/roster', queryParameters: {'username': username});
      final list = response.data as List;
      return list.map((e) => PokemonForm.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveRoster(
    String baseUrl,
    String username,
    List<PokemonForm> roster, {
    String? updatedAt,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/roster',
            data: {
              'username': username,
              'roster': roster.map((e) => e.toJson()).toList(),
              if (updatedAt != null) 'updatedAt': updatedAt,
            },
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PokemonForm>> fetchPC(String baseUrl, String username) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/pc', queryParameters: {'username': username});
      final list = response.data as List;
      return list.map((e) => PokemonForm.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> savePC(
    String baseUrl,
    String username,
    List<PokemonForm> pc, {
    String? updatedAt,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/pc',
            data: {
              'username': username,
              'pc': pc.map((e) => e.toJson()).toList(),
              if (updatedAt != null) 'updatedAt': updatedAt,
            },
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Team>> fetchTeamPresets(String baseUrl, String username) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/presets', queryParameters: {'username': username});
      final list = response.data as List;
      return list.map((e) => Team.fromJson(e)).toList();
    } catch (e) {
      print('[API] Fetch Presets Failed: $e');
      return [];
    }
  }

  Future<void> saveTeamPresets(
    String baseUrl,
    String username,
    List<Team> presets, {
    String? updatedAt,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/presets',
            data: {
              'username': username,
              'presets': presets.map((e) => e.toJson()).toList(),
              if (updatedAt != null) 'updatedAt': updatedAt,
            },
          );
    } catch (e) {
      print('[API] Save Presets Failed: $e');
    }
  }

  // --- ECONOMY & MARKETPLACE ---

  Future<List<dynamic>> fetchMarketAssets(String baseUrl) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/economy/market');
      return List<dynamic>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> fetchFortune500(String baseUrl) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/economy/fortune-500');
      return List<dynamic>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchEconomyStatus(String baseUrl) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/economy/status');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<bool> buyMarketItem({
    required String baseUrl,
    required String buyerUsername,
    required String sellerUsername,
    required String itemId,
    required int price,
  }) async {
    try {
      final response = await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/marketplace/buy',
            data: {
              'buyerUsername': buyerUsername,
              'sellerUsername': sellerUsername,
              'itemId': itemId,
              'price': price,
            },
          );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncOnlineTime({
    required String baseUrl,
    required String username,
    required int minutes,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/career/sync-time',
            data: {'username': username, 'minutes': minutes},
          );
    } catch (_) {}
  }

  Future<AppUpdateInfo?> fetchLatestAppUpdate({
    required String baseUrl,
    required String currentVersion,
    required String currentBuildNumber,
  }) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            '$baseUrl/app-update',
            queryParameters: {
              'version': currentVersion,
              'build': currentBuildNumber,
            },
            options: Options(
              receiveTimeout: const Duration(seconds: 5),
              sendTimeout: const Duration(seconds: 5),
            ),
          );
      if (response.data is Map<String, dynamic>) {
        return AppUpdateInfo.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  String _mapStatName(String raw) {
    switch (raw) {
      case 'hp':
        return 'hp';
      case 'attack':
        return 'atk';
      case 'defense':
        return 'def';
      case 'special-attack':
        return 'spa';
      case 'special-defense':
        return 'spd';
      case 'speed':
        return 'spe';
      default:
        return raw;
    }
  }

  // ─── Move type lookup (lowercase PokeAPI move name → type) ──────────────────
  static const Map<String, String> _moveTypes = {
    'tackle': 'normal',
    'scratch': 'normal',
    'pound': 'normal',
    'quick-attack': 'normal',
    'hyper-beam': 'normal',
    'body-slam': 'normal',
    'double-edge': 'normal',
    'return': 'normal',
    'swift': 'normal',
    'facade': 'normal',
    'slash': 'normal',
    'cut': 'normal',
    'last-resort': 'normal',
    'extreme-speed': 'normal',
    'stomp': 'normal',
    'hyper-fang': 'normal',
    'mega-punch': 'normal',
    'skull-bash': 'normal',
    'take-down': 'normal',
    'tri-attack': 'normal',
    'dizzy-punch': 'normal',
    'wrap': 'normal',
    'rage': 'normal',
    'comet-punch': 'normal',
    'ember': 'fire',
    'flamethrower': 'fire',
    'fire-blast': 'fire',
    'fire-spin': 'fire',
    'flame-wheel': 'fire',
    'heat-wave': 'fire',
    'overheat': 'fire',
    'fire-punch': 'fire',
    'blaze-kick': 'fire',
    'sacred-fire': 'fire',
    'water-gun': 'water',
    'surf': 'water',
    'hydro-pump': 'water',
    'waterfall': 'water',
    'bubble': 'water',
    'bubble-beam': 'water',
    'aqua-tail': 'water',
    'scald': 'water',
    'water-pulse': 'water',
    'aqua-jet': 'water',
    'liquidation': 'water',
    'origin-pulse': 'water',
    'flip-turn': 'water',
    'thunder': 'electric',
    'thunderbolt': 'electric',
    'thunder-shock': 'electric',
    'spark': 'electric',
    'thunder-punch': 'electric',
    'volt-tackle': 'electric',
    'discharge': 'electric',
    'wild-charge': 'electric',
    'electro-ball': 'electric',
    'zap-cannon': 'electric',
    'rising-voltage': 'electric',
    'volt-switch': 'electric',
    'vine-whip': 'grass',
    'razor-leaf': 'grass',
    'solar-beam': 'grass',
    'petal-dance': 'grass',
    'leaf-blade': 'grass',
    'energy-ball': 'grass',
    'giga-drain': 'grass',
    'mega-drain': 'grass',
    'absorb': 'grass',
    'seed-bomb': 'grass',
    'power-whip': 'grass',
    'wood-hammer': 'grass',
    'ice-beam': 'ice',
    'blizzard': 'ice',
    'ice-punch': 'ice',
    'aurora-beam': 'ice',
    'icicle-crash': 'ice',
    'freeze-dry': 'ice',
    'powder-snow': 'ice',
    'icicle-spear': 'ice',
    'glaciate': 'ice',
    'karate-chop': 'fighting',
    'cross-chop': 'fighting',
    'close-combat': 'fighting',
    'brick-break': 'fighting',
    'focus-blast': 'fighting',
    'superpower': 'fighting',
    'low-kick': 'fighting',
    'mach-punch': 'fighting',
    'sky-uppercut': 'fighting',
    'drain-punch': 'fighting',
    'dynamic-punch': 'fighting',
    'aura-sphere': 'fighting',
    'poison-sting': 'poison',
    'sludge': 'poison',
    'sludge-bomb': 'poison',
    'acid': 'poison',
    'gunk-shot': 'poison',
    'cross-poison': 'poison',
    'poison-jab': 'poison',
    'venoshock': 'poison',
    'sludge-wave': 'poison',
    'earthquake': 'ground',
    'earth-power': 'ground',
    'dig': 'ground',
    'mud-shot': 'ground',
    'bone-club': 'ground',
    'bonemerang': 'ground',
    'precipice-blades': 'ground',
    'high-horsepower': 'ground',
    'gust': 'flying',
    'wing-attack': 'flying',
    'aerial-ace': 'flying',
    'fly': 'flying',
    'air-slash': 'flying',
    'brave-bird': 'flying',
    'hurricane': 'flying',
    'bounce': 'flying',
    'acrobatics': 'flying',
    'confusion': 'psychic',
    'psychic': 'psychic',
    'psybeam': 'psychic',
    'psyshock': 'psychic',
    'future-sight': 'psychic',
    'zen-headbutt': 'psychic',
    'extrasensory': 'psychic',
    'luster-purge': 'psychic',
    'mist-ball': 'psychic',
    'signal-beam': 'bug',
    'bug-buzz': 'bug',
    'x-scissor': 'bug',
    'bug-bite': 'bug',
    'megahorn': 'bug',
    'leech-life': 'bug',
    'u-turn': 'bug',
    'attack-order': 'bug',
    'rock-throw': 'rock',
    'rock-slide': 'rock',
    'stone-edge': 'rock',
    'rock-blast': 'rock',
    'ancient-power': 'rock',
    'power-gem': 'rock',
    'head-smash': 'rock',
    'accelerock': 'rock',
    'shadow-ball': 'ghost',
    'shadow-claw': 'ghost',
    'hex': 'ghost',
    'shadow-punch': 'ghost',
    'phantom-force': 'ghost',
    'night-shade': 'ghost',
    'shadow-force': 'ghost',
    'spectral-thief': 'ghost',
    'dragon-rage': 'dragon',
    'twister': 'dragon',
    'draco-meteor': 'dragon',
    'dragon-claw': 'dragon',
    'outrage': 'dragon',
    'dragon-pulse': 'dragon',
    'dragon-rush': 'dragon',
    'spacial-rend': 'dragon',
    'dragon-breath': 'dragon',
    'dragon-tail': 'dragon',
    'bite': 'dark',
    'crunch': 'dark',
    'dark-pulse': 'dark',
    'foul-play': 'dark',
    'knock-off': 'dark',
    'sucker-punch': 'dark',
    'night-slash': 'dark',
    'throat-chop': 'dark',
    'wicked-blow': 'dark',
    'metal-claw': 'steel',
    'iron-tail': 'steel',
    'flash-cannon': 'steel',
    'iron-head': 'steel',
    'meteor-mash': 'steel',
    'bullet-punch': 'steel',
    'gyro-ball': 'steel',
    'steel-wing': 'steel',
    'sunsteel-strike': 'steel',
    'moonblast': 'fairy',
    'dazzling-gleam': 'fairy',
    'play-rough': 'fairy',
    'fairy-wind': 'fairy',
    'disarming-voice': 'fairy',
    'draining-kiss': 'fairy',
    'spirit-break': 'fairy',
    'moongeist-beam': 'fairy',
  };

  static const Map<String, int> _movePowers = {
    'tackle': 40,
    'scratch': 40,
    'pound': 40,
    'quick-attack': 40,
    'hyper-beam': 150,
    'body-slam': 85,
    'double-edge': 120,
    'return': 102,
    'swift': 60,
    'facade': 70,
    'slash': 70,
    'cut': 50,
    'last-resort': 140,
    'extreme-speed': 80,
    'stomp': 65,
    'hyper-fang': 80,
    'mega-punch': 80,
    'skull-bash': 130,
    'take-down': 90,
    'tri-attack': 80,
    'dizzy-punch': 70,
    'wrap': 15,
    'rage': 20,
    'comet-punch': 18,
    'ember': 40,
    'flamethrower': 90,
    'fire-blast': 110,
    'fire-spin': 35,
    'flame-wheel': 60,
    'heat-wave': 95,
    'overheat': 130,
    'fire-punch': 75,
    'blaze-kick': 85,
    'sacred-fire': 100,
    'water-gun': 40,
    'surf': 90,
    'hydro-pump': 110,
    'waterfall': 80,
    'bubble': 40,
    'bubble-beam': 65,
    'aqua-tail': 90,
    'scald': 80,
    'water-pulse': 60,
    'aqua-jet': 40,
    'liquidation': 85,
    'origin-pulse': 110,
    'flip-turn': 60,
    'thunder': 110,
    'thunderbolt': 90,
    'thunder-shock': 40,
    'spark': 65,
    'thunder-punch': 75,
    'volt-tackle': 120,
    'discharge': 80,
    'wild-charge': 90,
    'electro-ball': 80,
    'zap-cannon': 120,
    'rising-voltage': 70,
    'volt-switch': 70,
    'vine-whip': 45,
    'razor-leaf': 55,
    'solar-beam': 120,
    'petal-dance': 120,
    'leaf-blade': 90,
    'energy-ball': 90,
    'giga-drain': 75,
    'mega-drain': 40,
    'absorb': 20,
    'seed-bomb': 80,
    'power-whip': 120,
    'wood-hammer': 120,
    'ice-beam': 90,
    'blizzard': 110,
    'ice-punch': 75,
    'aurora-beam': 65,
    'icicle-crash': 85,
    'freeze-dry': 70,
    'powder-snow': 40,
    'icicle-spear': 25,
    'glaciate': 65,
    'karate-chop': 50,
    'cross-chop': 100,
    'close-combat': 120,
    'brick-break': 75,
    'focus-blast': 120,
    'superpower': 120,
    'low-kick': 50,
    'mach-punch': 40,
    'sky-uppercut': 85,
    'drain-punch': 75,
    'dynamic-punch': 100,
    'aura-sphere': 80,
    'poison-sting': 15,
    'sludge': 65,
    'sludge-bomb': 90,
    'acid': 40,
    'gunk-shot': 120,
    'cross-poison': 70,
    'poison-jab': 80,
    'venoshock': 65,
    'sludge-wave': 95,
    'earthquake': 100,
    'earth-power': 90,
    'dig': 80,
    'mud-shot': 55,
    'bone-club': 65,
    'bonemerang': 50,
    'precipice-blades': 120,
    'high-horsepower': 95,
    'gust': 40,
    'wing-attack': 60,
    'aerial-ace': 60,
    'fly': 90,
    'air-slash': 75,
    'brave-bird': 120,
    'hurricane': 110,
    'bounce': 85,
    'acrobatics': 55,
    'confusion': 50,
    'psychic': 90,
    'psybeam': 65,
    'psyshock': 80,
    'future-sight': 120,
    'zen-headbutt': 80,
    'extrasensory': 80,
    'luster-purge': 70,
    'mist-ball': 70,
    'signal-beam': 75,
    'bug-buzz': 90,
    'x-scissor': 80,
    'bug-bite': 60,
    'megahorn': 120,
    'leech-life': 80,
    'u-turn': 70,
    'attack-order': 90,
    'rock-throw': 50,
    'rock-slide': 75,
    'stone-edge': 100,
    'rock-blast': 25,
    'ancient-power': 60,
    'power-gem': 80,
    'head-smash': 150,
    'accelerock': 40,
    'shadow-ball': 80,
    'shadow-claw': 70,
    'hex': 65,
    'shadow-punch': 60,
    'phantom-force': 90,
    'night-shade': 60,
    'shadow-force': 120,
    'spectral-thief': 90,
    'dragon-rage': 40,
    'twister': 40,
    'draco-meteor': 130,
    'dragon-claw': 80,
    'outrage': 120,
    'dragon-pulse': 85,
    'dragon-rush': 100,
    'spacial-rend': 100,
    'dragon-breath': 60,
    'dragon-tail': 60,
    'bite': 60,
    'crunch': 80,
    'dark-pulse': 80,
    'foul-play': 95,
    'knock-off': 65,
    'sucker-punch': 70,
    'night-slash': 70,
    'throat-chop': 80,
    'wicked-blow': 80,
    'metal-claw': 50,
    'iron-tail': 100,
    'flash-cannon': 80,
    'iron-head': 80,
    'meteor-mash': 90,
    'bullet-punch': 40,
    'gyro-ball': 80,
    'steel-wing': 70,
    'sunsteel-strike': 100,
    'moonblast': 95,
    'dazzling-gleam': 80,
    'play-rough': 90,
    'fairy-wind': 40,
    'disarming-voice': 40,
    'draining-kiss': 50,
    'spirit-break': 75,
    'moongeist-beam': 100,
  };

  static const Map<String, String> _moveDamageClasses = {
    'tackle': 'physical',
    'scratch': 'physical',
    'pound': 'physical',
    'quick-attack': 'physical',
    'hyper-beam': 'special',
    'body-slam': 'physical',
    'double-edge': 'physical',
    'return': 'physical',
    'swift': 'special',
    'facade': 'physical',
    'slash': 'physical',
    'cut': 'physical',
    'last-resort': 'physical',
    'extreme-speed': 'physical',
    'stomp': 'physical',
    'ember': 'special',
    'flamethrower': 'special',
    'fire-blast': 'special',
    'fire-punch': 'physical',
    'flare-blitz': 'physical',
    'heat-wave': 'special',
    'overheat': 'special',
    'sacred-fire': 'physical',
    'water-gun': 'special',
    'surf': 'special',
    'hydro-pump': 'special',
    'waterfall': 'physical',
    'aqua-jet': 'physical',
    'liquidation': 'physical',
    'scald': 'special',
    'bubble-beam': 'special',
    'thunder': 'special',
    'thunderbolt': 'special',
    'thunder-punch': 'physical',
    'volt-tackle': 'physical',
    'wild-charge': 'physical',
    'discharge': 'special',
    'volt-switch': 'special',
    'thunder-shock': 'special',
    'vine-whip': 'physical',
    'razor-leaf': 'physical',
    'solar-beam': 'special',
    'leaf-blade': 'physical',
    'energy-ball': 'special',
    'giga-drain': 'special',
    'power-whip': 'physical',
    'wood-hammer': 'physical',
    'ice-beam': 'special',
    'blizzard': 'special',
    'ice-punch': 'physical',
    'icicle-crash': 'physical',
    'freeze-dry': 'special',
    'icicle-spear': 'physical',
    'close-combat': 'physical',
    'drain-punch': 'physical',
    'mach-punch': 'physical',
    'focus-blast': 'special',
    'brick-break': 'physical',
    'superpower': 'physical',
    'aura-sphere': 'special',
    'dynamic-punch': 'physical',
    'sludge-bomb': 'special',
    'poison-jab': 'physical',
    'gunk-shot': 'physical',
    'sludge-wave': 'special',
    'earthquake': 'physical',
    'earth-power': 'special',
    'dig': 'physical',
    'high-horsepower': 'physical',
    'brave-bird': 'physical',
    'hurricane': 'special',
    'air-slash': 'special',
    'aerial-ace': 'physical',
    'fly': 'physical',
    'acrobatics': 'physical',
    'dual-wingbeat': 'physical',
    'psychic': 'special',
    'psyshock': 'special',
    'zen-headbutt': 'physical',
    'future-sight': 'special',
    'bug-buzz': 'special',
    'u-turn': 'physical',
    'x-scissor': 'physical',
    'megahorn': 'physical',
    'stone-edge': 'physical',
    'rock-slide': 'physical',
    'power-gem': 'special',
    'rock-blast': 'physical',
    'shadow-ball': 'special',
    'shadow-claw': 'physical',
    'phantom-force': 'physical',
    'hex': 'special',
    'draco-meteor': 'special',
    'dragon-pulse': 'special',
    'dragon-claw': 'physical',
    'outrage': 'physical',
    'dark-pulse': 'special',
    'crunch': 'physical',
    'knock-off': 'physical',
    'sucker-punch': 'physical',
    'iron-head': 'physical',
    'flash-cannon': 'special',
    'bullet-punch': 'physical',
    'meteor-mash': 'physical',
    'moonblast': 'special',
    'dazzling-gleam': 'special',
    'play-rough': 'physical',
    'spirit-break': 'physical',
  };

  List<PokemonMove> _parseMoves(
    List movesData,
    List<String> pokemonTypes,
    String? versionGroupId,
  ) {
    final primaryType = pokemonTypes.isNotEmpty
        ? pokemonTypes[0].toLowerCase()
        : 'normal';

    final filtered = movesData.where((m) {
      final details = m['version_group_details'] as List;
      if (versionGroupId != null) {
        return details.any((d) => d['version_group']['name'] == versionGroupId);
      }
      // Priority 1: Level-up moves
      return details.any((d) => d['move_learn_method']['name'] == 'level-up');
    }).toList();

    // If we have fewer than 10 moves (very few), include machine and tutor moves as fallback
    if (filtered.length < 10) {
      final fallbackMoves = movesData.where((m) {
        final details = m['version_group_details'] as List;
        return details.any(
          (d) =>
              d['move_learn_method']['name'] == 'machine' ||
              d['move_learn_method']['name'] == 'tutor' ||
              d['move_learn_method']['name'] == 'egg',
        );
      }).toList();

      for (final fm in fallbackMoves) {
        if (!filtered.any((ex) => ex['move']['name'] == fm['move']['name'])) {
          filtered.add(fm);
        }
      }
    }

    final moves = filtered.map((m) {
      final details = m['version_group_details'] as List;
      dynamic detail;
      if (versionGroupId != null) {
        detail = details.firstWhere(
          (d) => d['version_group']['name'] == versionGroupId,
          orElse: () => details.first,
        );
      } else {
        dynamic best;
        for (final d in details) {
          if (d['move_learn_method']['name'] == 'level-up') {
            if (best == null ||
                (d['level_learned_at'] as int) >
                    (best['level_learned_at'] as int)) {
              best = d;
            }
          }
        }
        detail = best ?? details.first;
      }

      final moveName = (m['move']['name'] as String).toLowerCase();
      final moveType = _moveTypes[moveName] ?? primaryType;

      // Modern Gen 9 logic: Use mapping, status fallback, or type-based rule
      String category = _moveDamageClasses[moveName] ?? 'physical';
      if (!_moveDamageClasses.containsKey(moveName)) {
        if (_movePowers[moveName] == 0) {
          category = 'status';
        } else {
          final isSpec = const {
            'fire',
            'water',
            'electric',
            'grass',
            'ice',
            'psychic',
            'dragon',
            'ghost',
            'dark',
            'fairy',
          }.contains(moveType.toLowerCase());
          category = isSpec ? 'special' : 'physical';
        }
      }

      return PokemonMove(
        name: _capitalize(m['move']['name']),
        learnLevel: detail['level_learned_at'] as int,
        learnMethod: detail['move_learn_method']['name'] as String,
        type: moveType,
        power: _movePowers[moveName] ?? 60,
        damageClass: category,
      );
    }).toList();

    moves.sort((a, b) => b.learnLevel.compareTo(a.learnLevel));
    return moves;
  }

  // ─── Battle simulation helpers ────────────────────────────────────────────

  /// Gen 9 damage formula → % of defender's max HP.
  double _calcDamagePercent({
    required int atkStat,
    required int defStat,
    required int power,
    required int defMaxHp,
    required double typeEff,
    required double stab,
    bool burned = false,
    bool isCrit = false,
    double roll = 1.0,
  }) {
    if (power <= 0 || typeEff == 0.0 || defMaxHp == 0) return 0.0;

    // Base damage: trunc(trunc(trunc(2 * Level / 5 + 2) * Power * A / D) / 50) + 2
    // We assume Level 100 for simulation stats comparison unless specified
    int base = (((2 * 100) ~/ 5) + 2);
    base = (base * power * atkStat) ~/ defStat;
    base = (base ~/ 50) + 2;

    double dmg = base.toDouble();
    if (burned) dmg *= 0.5;
    dmg *= (isCrit ? 1.5 : 1.0);
    dmg *= stab;
    dmg *= typeEff;
    dmg *= roll;

    return (dmg / defMaxHp * 100).clamp(0.1, 1000.0);
  }

  /// Returns (statusName, probability) for a move's status effect.
  (String, double) _moveStatusEffect(String moveName, String moveType) {
    final n = moveName.toLowerCase().replaceAll(' ', '-');
    const dedicated = <String, (String, double)>{
      'will-o-wisp': ('burn', 1.00),
      'thunder-wave': ('paralysis', 1.00),
      'thunderwave': ('paralysis', 1.00),
      'glare': ('paralysis', 1.00),
      'nuzzle': ('paralysis', 1.00),
      'stun-spore': ('paralysis', 1.00),
      'toxic': ('toxic', 1.00),
      'poison-powder': ('poison', 1.00),
      'sleep-powder': ('sleep', 1.00),
      'spore': ('sleep', 1.00),
      'hypnosis': ('sleep', 0.60),
      'sing': ('sleep', 0.55),
      'lovely-kiss': ('sleep', 0.75),
      'yawn': ('sleep', 0.85),
      'dark-void': ('sleep', 0.80),
    };
    const sideEffect = <String, (String, double)>{
      'scald': ('burn', 0.30),
      'lava-plume': ('burn', 0.30),
      'fire-blast': ('burn', 0.10),
      'flamethrower': ('burn', 0.10),
      'flame-wheel': ('burn', 0.10),
      'body-slam': ('paralysis', 0.30),
      'discharge': ('paralysis', 0.30),
      'thunder': ('paralysis', 0.30),
      'bolt-strike': ('paralysis', 0.20),
      'ice-beam': ('freeze', 0.10),
      'ice-punch': ('freeze', 0.10),
      'blizzard': ('freeze', 0.10),
      'powder-snow': ('freeze', 0.10),
      'poison-jab': ('poison', 0.30),
      'sludge-bomb': ('poison', 0.30),
      'sludge-wave': ('poison', 0.10),
      'cross-poison': ('poison', 0.10),
    };
    if (dedicated.containsKey(n)) return dedicated[n]!;
    if (sideEffect.containsKey(n)) return sideEffect[n]!;
    const typeRate = <String, (String, double)>{
      'fire': ('burn', 0.10),
      'electric': ('paralysis', 0.10),
      'ice': ('freeze', 0.10),
      'poison': ('poison', 0.20),
    };
    final t = moveType.toLowerCase();
    if (typeRate.containsKey(t)) return typeRate[t]!;
    return ('', 0.0);
  }

  /// Returns stat boost map for setup moves, or null if not a setup move.
  Map<String, int>? _getBoostMove(String moveName) {
    final n = moveName.toLowerCase().replaceAll(' ', '-');
    const boostMoves = <String, Map<String, int>>{
      'swords-dance': {'atk': 2},
      'nasty-plot': {'spa': 2},
      'calm-mind': {'spa': 1, 'spd': 1},
      'bulk-up': {'atk': 1, 'def': 1},
      'dragon-dance': {'atk': 1, 'spe': 1},
      'quiver-dance': {'spa': 1, 'spd': 1, 'spe': 1},
      'agility': {'spe': 2},
      'shell-smash': {'atk': 2, 'spa': 2, 'spe': 2},
      'growth': {'atk': 1, 'spa': 1},
      'iron-defense': {'def': 2},
      'amnesia': {'spd': 2},
      'coil': {'atk': 1, 'def': 1},
      'work-up': {'atk': 1, 'spa': 1},
      'geomancy': {'spa': 2, 'spd': 2, 'spe': 2},
      'cotton-guard': {'def': 3},
      'stockpile': {'def': 1, 'spd': 1},
      'clangorous-soul': {'atk': 1, 'def': 1, 'spa': 1, 'spd': 1, 'spe': 1},
      'victory-dance': {'atk': 1, 'def': 1, 'spe': 1},
    };
    return boostMoves[n];
  }

  bool _isRecoilMove(String moveName) {
    const recoilMoves = {
      'brave-bird',
      'wild-charge',
      'double-edge',
      'head-smash',
      'flare-blitz',
      'volt-tackle',
      'take-down',
      'submission',
      'high-jump-kick',
      'jump-kick',
      'wood-hammer',
      'head-charge',
      'chloroblast',
      'steel-beam',
    };
    return recoilMoves.contains(moveName.toLowerCase().replaceAll(' ', '-'));
  }

  double _getRecoilFraction(String moveName) {
    final n = moveName.toLowerCase().replaceAll(' ', '-');
    const fractions = <String, double>{
      'brave-bird': 0.33,
      'wood-hammer': 0.33,
      'double-edge': 0.33,
      'flare-blitz': 0.33,
      'volt-tackle': 0.33,
      'head-charge': 0.33,
      'wild-charge': 0.25,
      'head-smash': 0.50,
      'take-down': 0.25,
      'submission': 0.25,
    };
    return fractions[n] ?? 0.33;
  }

  bool _isDrainMove(String moveName) {
    const drainMoves = {
      'giga-drain',
      'mega-drain',
      'absorb',
      'drain-punch',
      'horn-leech',
      'leech-life',
      'oblivion-wing',
      'draining-kiss',
      'parabolic-charge',
    };
    return drainMoves.contains(moveName.toLowerCase().replaceAll(' ', '-'));
  }

  bool _isPunchMove(String moveName) {
    const punchMoves = {
      'fire-punch',
      'ice-punch',
      'thunder-punch',
      'drain-punch',
      'mach-punch',
      'bullet-punch',
      'shadow-punch',
      'focus-punch',
      'hammer-arm',
      'sky-uppercut',
      'meteor-mash',
      'comet-punch',
    };
    return punchMoves.contains(moveName.toLowerCase().replaceAll(' ', '-'));
  }

  bool _isBiteMove(String moveName) {
    const biteMoves = {
      'bite',
      'crunch',
      'fire-fang',
      'ice-fang',
      'thunder-fang',
      'poison-fang',
      'psychic-fangs',
      'hyper-fang',
      'fishious-rend',
      'jaw-lock',
      'bug-bite',
    };
    return biteMoves.contains(moveName.toLowerCase().replaceAll(' ', '-'));
  }

  /// Type-matchup score (positive = I have advantage).
  double _typeMatchupScore(
    List<PokemonType> myOffTypes,
    List<PokemonType> opDefTypes,
    List<PokemonType> opOffTypes,
    List<PokemonType> myDefTypes,
  ) {
    double myBest = myOffTypes.fold(0.0, (best, t) {
      final e = TypeChart.getEffectiveness(t, opDefTypes) * 1.5;
      return e > best ? e : best;
    });
    double opBest = opOffTypes.fold(0.0, (best, t) {
      final e = TypeChart.getEffectiveness(t, myDefTypes) * 1.5;
      return e > best ? e : best;
    });
    return myBest - opBest;
  }

  /// Reorders queue[fromIdx+1..] so best type counter goes next.
  void _sortRemainingByMatchup(
    List<PokemonForm> queue,
    int fromIdx,
    List<PokemonType> opTypes,
    Map<String, List<PokemonType>> myTypesMap,
    Map<String, Map<String, int>> myStatsMap,
  ) {
    if (fromIdx + 1 >= queue.length) return;
    final remaining = queue.sublist(fromIdx + 1);
    remaining.sort((a, b) {
      final aTypes = myTypesMap[a.id] ?? [PokemonType.normal];
      final bTypes = myTypesMap[b.id] ?? [PokemonType.normal];
      final scoreA =
          _typeMatchupScore(aTypes, opTypes, opTypes, aTypes) +
          (myStatsMap[a.id]?['hp'] ?? 200) / 400.0;
      final scoreB =
          _typeMatchupScore(bTypes, opTypes, opTypes, bTypes) +
          (myStatsMap[b.id]?['hp'] ?? 200) / 400.0;
      return scoreB.compareTo(scoreA);
    });
    for (int i = 0; i < remaining.length; i++) {
      queue[fromIdx + 1 + i] = remaining[i];
    }
  }

  // --- SOCIAL & ONLINE BATTLES ---

  Future<List<SocialUser>> fetchGlobalUsers(String baseUrl) async {
    try {
      final response = await ref.read(dioProvider).get('$baseUrl/social/users');
      final list = response.data as List;
      return list.map((e) => SocialUser.fromJson(e)).toList();
    } catch (e) {
      print('[API] Fetch Global Users Failed: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchBroadcast(String baseUrl) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/social/broadcast');
      return response.data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<List<ChatMessage>> fetchGlobalChat(String baseUrl) async {
    try {
      final response = await ref.read(dioProvider).get('$baseUrl/social/chat');
      final list = response.data as List;
      return list.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (e) {
      print('[API] Fetch Global Chat Failed: $e');
      return [];
    }
  }

  Future<bool> sendChatMessage(
    String baseUrl,
    String sender,
    String text, {
    String? recipient,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/chat',
            data: {
              'sender': sender,
              'text': text,
              if (recipient != null) 'recipient': recipient,
            },
          );
      return true;
    } catch (e) {
      print('[API] Send Chat Failed: $e');
      return false;
    }
  }

  Future<bool> submitReport(
    String baseUrl, {
    required String username,
    required String displayName,
    required String platform,
    required String version,
    required String message,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/report',
            data: {
              'username': username,
              'displayName': displayName,
              'platform': platform,
              'version': version,
              'message': message,
            },
          );
      return true;
    } catch (e) {
      print('[API] Submit Report Failed: $e');
      return false;
    }
  }

  Future<String?> sendBattleChallenge(
    String baseUrl,
    String sender,
    String target,
  ) async {
    try {
      final response = await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/challenge',
            data: {'sender': sender, 'target': target},
          );
      return response.data['battleId'] as String?;
    } catch (e) {
      print('[API] Send Challenge Failed: $e');
      return null;
    }
  }

  Future<BattleSession?> getBattleSession(
    String baseUrl,
    String battleId,
  ) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/battle/$battleId/status');
      return BattleSession.fromJson(response.data);
    } catch (e) {
      print('[API] Get Battle Session Failed: $e');
      return null;
    }
  }

  Future<bool> submitOnlineMove(
    String baseUrl,
    String battleId,
    String username,
    Map<String, dynamic> action, {
    Map<String, dynamic>? results,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/battle/$battleId/move',
            data: {'username': username, 'action': action, 'results': results},
          );
      return true;
    } catch (e) {
      print('[API] Submit Move Failed: $e');
      return false;
    }
  }

  Future<bool> updateOnlineStatus(
    String baseUrl, {
    required String username,
    required String displayName,
    String? status,
    List<Map<String, dynamic>>? roster,
    Map<String, int>? inventory,
    int? wins,
    bool? forcePasscodeChange,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/status',
            data: {
              'username': username,
              'displayName': displayName,
              if (status != null) 'status': status,
              if (roster != null) 'roster': roster,
              if (inventory != null) 'inventory': inventory,
              if (wins != null) 'wins': wins,
              if (forcePasscodeChange != null)
                'forcePasscodeChange': forcePasscodeChange,
            },
          );
      return true;
    } catch (e) {
      print('[API] Update Status Failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchFriends(
    String baseUrl,
    String username,
  ) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            '$baseUrl/social/friends',
            queryParameters: {'username': username},
          );
      final data = response.data as Map<String, dynamic>;

      return {
        'friends': (data['friends'] as List)
            .map((e) => SocialUser.fromJson(e))
            .toList(),
        'pending': (data['pending'] as List)
            .map(
              (e) => {
                'username': e['username'] as String,
                'displayName': e['displayName'] as String,
              },
            )
            .toList(),
      };
    } catch (e) {
      print('[API] Fetch Friends Failed: $e');
      return {'friends': <SocialUser>[], 'pending': []};
    }
  }

  Future<bool> sendFriendRequest(
    String baseUrl,
    String sender,
    String target,
  ) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/friend-request',
            data: {'sender': sender, 'target': target},
          );
      return true;
    } catch (e) {
      print('[API] Friend Request Failed: $e');
      return false;
    }
  }

  Future<bool> acceptFriendRequest(
    String baseUrl,
    String username,
    String friendUsername,
  ) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/friend-accept',
            data: {'username': username, 'friendUsername': friendUsername},
          );
      return true;
    } catch (e) {
      print('[API] Accept Friend Failed: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPendingChallenges(
    String baseUrl,
    String username,
  ) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            '$baseUrl/social/challenges/pending',
            queryParameters: {'username': username},
          );

      if (response.data == null) return [];

      final list = response.data as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('[API] Fetch Pending Challenges Failed: $e');
      return [];
    }
  }

  Future<void> acceptBattleChallenge(
    String baseUrl,
    String username,
    String battleId,
  ) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/challenges/accept',
            data: {'username': username, 'battleId': battleId},
          );
    } catch (e) {
      print('[API] Accept Challenge Failed: $e');
    }
  }

  Future<bool> sendGift(
    String baseUrl, {
    required String senderUsername,
    required String senderDisplayName,
    required String recipientUsername,
    required String itemId,
    required int quantity,
    required String message,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/gift/send',
            data: {
              'senderUsername': senderUsername,
              'senderDisplayName': senderDisplayName,
              'recipientUsername': recipientUsername,
              'itemId': itemId,
              'quantity': quantity,
              'message': message,
            },
          );
      return true;
    } catch (e) {
      print('[API] Send Gift Failed: $e');
      return false;
    }
  }

  Future<List<Gift>> fetchPendingGifts(String baseUrl, String username) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            '$baseUrl/social/gifts/pending',
            queryParameters: {'username': username},
          );
      final List data = response.data as List? ?? [];
      return data.map((j) => Gift.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      print('[API] Fetch Gifts Failed: $e');
      return [];
    }
  }

  Future<bool> acceptGift(
    String baseUrl,
    String username,
    String giftId,
  ) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/social/gifts/accept',
            data: {'username': username, 'giftId': giftId},
          );
      return true;
    } catch (e) {
      print('[API] Accept Gift Failed: $e');
      return false;
    }
  }

  Future<Map<String, List<dynamic>>> fetchOstLibrary(String baseUrl) async {
    try {
      final response = await ref
          .read(dioProvider)
          .get('$baseUrl/api/ost-library');
      return Map<String, List<dynamic>>.from(response.data as Map? ?? {});
    } catch (e) {
      print('[API] Fetch OST Library Failed: $e');
      return {};
    }
  }

  Future<void> updateMusicStatus({
    required String baseUrl,
    required String username,
    required String song,
    required String album,
    required bool isPlaying,
  }) async {
    try {
      await ref
          .read(dioProvider)
          .post(
            '$baseUrl/api/music/status',
            data: {
              'username': username,
              'song': song,
              'album': album,
              'isPlaying': isPlaying,
            },
          );
    } catch (e) {
      print('[API] Update Music Status Failed: $e');
    }
  }

  Future<Map<String, dynamic>> claimBattleReward(String username) async {
    final baseUrl = ref.read(backendBaseUrlProvider);
    try {
      final response = await ref
          .read(dioProvider)
          .post(
            '$baseUrl/economy/claim-battle-reward',
            data: {'username': username},
          );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      rethrow;
    }
  }
}
