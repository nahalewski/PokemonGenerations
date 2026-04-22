import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_models.dart';
import '../core/constants.dart';
import 'ai_models.dart';

class AdminService {
  final String _baseUrl =
      'http://localhost:${PokemonCenterConstants.backendPort}';

  Future<List<AdminUser>> fetchUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/social/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((u) => AdminUser.fromJson(u)).toList();
    }
    throw Exception('Failed to fetch users');
  }

  Future<List<dynamic>> fetchInbox(String username) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/social/inbox?username=$username'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  Future<bool> sendMail({
    required String from,
    required String to,
    required String subject,
    required String body,
    Map<String, dynamic>? attachment,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/social/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'from': from,
        'to': to,
        'subject': subject,
        'body': body,
        'attachment': attachment,
      }),
    );
    return response.statusCode == 200;
  }

  Future<List<AdminChatMessage>> fetchChat() async {
    final response = await http.get(Uri.parse('$_baseUrl/social/chat'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((m) => AdminChatMessage.fromJson(m)).toList();
    }
    throw Exception('Failed to fetch chat');
  }

  Future<AdminBroadcast?> fetchBroadcast() async {
    final response = await http.get(Uri.parse('$_baseUrl/admin/broadcast'));
    if (response.statusCode == 200) {
      if (response.body == 'null') return null;
      return AdminBroadcast.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<void> sendBroadcast(String text) async {
    await http.post(
      Uri.parse('$_baseUrl/admin/broadcast'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text, 'sentBy': 'admin'}),
    );
  }

  Future<bool> sendGift({
    required String senderUsername,
    required String senderDisplayName,
    required String recipientUsername,
    required String itemId,
    required int quantity,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/social/gift/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'senderUsername': senderUsername,
        'senderDisplayName': senderDisplayName,
        'recipientUsername': recipientUsername,
        'itemId': itemId,
        'quantity': quantity,
        'message': message,
      }),
    );
    return response.statusCode == 200;
  }

  Future<void> clearBroadcast() async {
    await http.delete(Uri.parse('$_baseUrl/admin/broadcast'));
  }

  Future<void> suspendUser(String username, bool suspended) async {
    await http.post(
      Uri.parse('$_baseUrl/admin/suspend'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'suspended': suspended}),
    );
  }

  Future<void> banUser(String username) async {
    await http.post(
      Uri.parse('$_baseUrl/admin/ban'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username}),
    );
  }

  Future<void> deleteUser(String username) async {
    await http.delete(
      Uri.parse('$_baseUrl/admin/user/$username'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'confirmation': 'DELETE'}),
    );
  }

  Future<List<LiveBattle>> fetchLiveBattles() async {
    final response = await http.get(Uri.parse('$_baseUrl/admin/battles/live'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((b) => LiveBattle.fromJson(b)).toList();
    }
    return [];
  }

  Future<String> fetchBattleLog(String battleId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/battle/$battleId/log'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['log'] ?? '';
    }
    return 'Log not available';
  }

  Future<Map<String, dynamic>> fetchFullUser(String username) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/user/$username/full'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch user');
  }

  Future<bool> updatePlayerRoster(String username, List<dynamic> roster) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/user/$username/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userData': {'roster': roster},
      }),
    );
    return response.statusCode == 200;
  }

  Future<List<String>> fetchItems() async {
    final response = await http.get(Uri.parse('$_baseUrl/items'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((i) => i['name'] as String).toList();
    }
    return [];
  }

  Future<List<String>> fetchMoves() async {
    final response = await http.get(Uri.parse('$_baseUrl/moves'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((m) => m['name'] as String).toList();
    }
    return [];
  }

  Future<List<String>> fetchAbilities() async {
    // There isn't a dedicated /abilities endpoint but we can infer from /pokemon?
    // Let's just return a standard list for now or check if there is an endpoint.
    return [
      'Overgrow',
      'Blaze',
      'Torrent',
      'Levitate',
      'Intimidate',
      'Pressure',
      'Sturdy',
    ];
  }

  // --- NEWS & GLOBAL BROADCAST ---

  Future<Map<String, dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse('$_baseUrl/news'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch news');
  }

  Future<bool> updateNews(Map<String, dynamic> news) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/news'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(news),
    );
    return response.statusCode == 200;
  }

  Future<bool> broadcastNews(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/broadcast-news'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message, 'sender': 'POKEMON CENTER'}),
    );
    return response.statusCode == 200;
  }

  Future<List<TelemetryBattle>> fetchTelemetryBattles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/telemetry/battles'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((b) => TelemetryBattle.fromJson(b)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchMusicTelemetry() async {
    final response = await http.get(Uri.parse('$_baseUrl/admin/music/status'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch music telemetry');
  }

  Future<void> resetPasscode(String username) async {
    await http.post(
      Uri.parse('$_baseUrl/social/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'forcePasscodeChange': true}),
    );
  }

  Future<Map<String, dynamic>> fetchAiStatus() async {
    final response = await http.get(Uri.parse('$_baseUrl/ai/status'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch AI status');
  }

  Future<Map<String, dynamic>> installAiModel({required String model}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/install-model'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'model': model}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to install AI model: ${response.body}');
  }

  Future<Map<String, dynamic>> cancelAiModelInstall() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/install-model/cancel'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to cancel AI model install: ${response.body}');
  }

  Future<Map<String, dynamic>> chatWithAi({
    required String message,
    String? sessionId,
    List<Map<String, String>>? messages,
    String? model,
    String? systemPrompt,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': message,
        if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
        if (messages != null) 'messages': messages,
        if (model != null && model.isNotEmpty) 'model': model,
        if (systemPrompt != null && systemPrompt.isNotEmpty)
          'systemPrompt': systemPrompt,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('AI chat failed: ${response.body}');
  }

  Future<Map<String, dynamic>> fetchAiChatState() async {
    final response = await http.get(Uri.parse('$_baseUrl/ai/chat/state'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch AI chat state');
  }

  Future<Map<String, dynamic>> fetchAiQueues() async {
    final response = await http.get(Uri.parse('$_baseUrl/ai/queues'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch AI queues');
  }

  Future<Map<String, dynamic>> updateAiQueueStatus({
    required String queueType,
    required String queueId,
    required String status,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/queues/$queueType/$queueId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'status': status,
        if (note != null && note.isNotEmpty) 'note': note,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update AI queue status: ${response.body}');
  }

  Future<Map<String, dynamic>> fetchAiChatSession(String sessionId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/ai/chat/session/$sessionId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch AI chat session');
  }

  Future<Map<String, dynamic>> startNewAiChat() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/chat/new'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to start a new AI chat');
  }

  Future<Map<String, dynamic>> exportAiChat({String? sessionId}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/chat/export'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to export AI chat');
  }

  Future<AiAutomationActionResult> runAiAutomation({
    required String actionId,
    Map<String, dynamic>? options,
    bool approved = false,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/automation/run'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'actionId': actionId,
        'options': options ?? const {},
        'approved': approved,
      }),
    );
    if (response.statusCode == 200) {
      return AiAutomationActionResult.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Automation failed: ${response.body}');
  }
}
