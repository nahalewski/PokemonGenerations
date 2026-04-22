import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class CloudflareService {
  Future<Map<String, String>> _loadProjectEnv() async {
    final candidates = [
      File('${PokemonCenterConstants.rootDir}/pokemon_generations_backend/.env'),
      File('${PokemonCenterConstants.rootDir}/.env'),
      File('${PokemonCenterConstants.rootDir}/.env.local'),
    ];
    for (final file in candidates) {
      if (!file.existsSync()) continue;
      final values = <String, String>{};
      for (final rawLine in await file.readAsLines()) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#') || !line.contains('=')) continue;
        final idx = line.indexOf('=');
        final key = line.substring(0, idx).trim();
        final value = line.substring(idx + 1).trim();
        values[key] = value;
      }
      if (values.isNotEmpty) return values;
    }
    return const {};
  }

  Future<bool?> purgeEverything() async {
    final envFile = await _loadProjectEnv();
    final token = PokemonCenterConstants.cloudflareApiToken.isNotEmpty
        ? PokemonCenterConstants.cloudflareApiToken
        : Platform.environment['CLOUDFLARE_API_TOKEN'] ?? envFile['CLOUDFLARE_API_TOKEN'];
    final zoneId = PokemonCenterConstants.cloudflareZoneId.isNotEmpty
        ? PokemonCenterConstants.cloudflareZoneId
        : Platform.environment['CLOUDFLARE_ZONE_ID'] ?? envFile['CLOUDFLARE_ZONE_ID'];

    if (token == null || token.isEmpty || zoneId == null || zoneId.isEmpty) {
      print(
        'Cloudflare Purge Skipped: missing CLOUDFLARE_API_TOKEN or CLOUDFLARE_ZONE_ID',
      );
      return null;
    }

    final url = Uri.parse(
      'https://api.cloudflare.com/client/v4/zones/$zoneId/purge_cache',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'purge_everything': true}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        print(
          'Cloudflare Purge Failed: ${response.statusCode} ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Cloudflare Purge Error: $e');
      return false;
    }
  }
}
