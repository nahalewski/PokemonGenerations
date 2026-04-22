import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/models/battle_state.dart';
import '../../../domain/models/pokemon.dart';

class TelemetryService {
  final String _baseUrl = 'http://localhost:8191'; // Fallback for local testing

  Future<void> sendBattleUpdate({
    required String battleId,
    required Pokemon playerPokemon,
    required Pokemon opponentPokemon,
    required int playerHp,
    required int playerMaxHp,
    required int opponentHp,
    required int opponentMaxHp,
    required List<String> log,
    required String status,
  }) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/admin/telemetry/battle'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'battleId': battleId,
          'playerInfo': {
            'name': playerPokemon.name,
            'hp': playerHp,
            'maxHp': playerMaxHp,
            'id': playerPokemon.id,
          },
          'opponentInfo': {
            'name': opponentPokemon.name,
            'hp': opponentHp,
            'maxHp': opponentMaxHp,
            'id': opponentPokemon.id,
          },
          'log': log,
          'status': status,
        }),
      );
    } catch (_) {
      // Fail silently for telemetry
    }
  }
}
