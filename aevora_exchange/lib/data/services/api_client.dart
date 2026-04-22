import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Session Provider ───────────────────────────────────────────────────────────

final sessionProvider = StateNotifierProvider<SessionNotifier, String?>((ref) {
  return SessionNotifier();
});

class SessionNotifier extends StateNotifier<String?> {
  SessionNotifier() : super(null) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('session_username');
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> login(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_username', username);
    state = username;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_username');
    state = null;
  }
}

// ── API Client ─────────────────────────────────────────────────────────────────

final apiClientProvider = Provider((ref) => ApiClient());

class ApiClient {
  static const String _baseUrl = 'https://poke.orosapp.us';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // ── Auth ────────────────────────────────────────────────────────────────────

  /// Logs in with username + passcodeHash. Returns the full user map on success.
  Future<Map<String, dynamic>> login(String username, String passcodeHash) async {
    final response = await _dio.post('/login', data: {
      'username': username,
      'passcodeHash': passcodeHash,
    });
    return Map<String, dynamic>.from(response.data);
  }

  // ── User / Bank (two JSON files per user) ───────────────────────────────────

  /// Returns merged data from both user.json and {username}_bank.json.
  /// Shape:
  ///   { username, displayName, pokedollars, job,   ← from user.json
  ///     bank: { balance, savings, retirement, portfolio, transactions },
  ///     bank_history: [...transactions] }
  Future<Map<String, dynamic>> getBankData(String username) async {
    try {
      // Fetch bank JSON  (GET /economy/bank/:username)
      final bankResp = await _dio.get('/economy/bank/$username');
      final raw = Map<String, dynamic>.from(bankResp.data);

      // The endpoint returns: username, displayName, pokedollars, job + all bank fields
      // We nest the bank-specific fields under 'bank' to match bank_screen expectations.
      final bank = {
        'balance': raw['balance'] ?? 0,
        'savings': raw['savings'] ?? 0,
        'retirement': raw['retirement'] ?? {'roth': 0, 'k401': 0},
        'portfolio': raw['portfolio'] ?? [],
        'transactions': raw['transactions'] ?? [],
      };

      return {
        'username': raw['username'],
        'displayName': raw['displayName'],
        'pokedollars': raw['pokedollars'] ?? 0,
        'job': raw['job'],
        'bank': bank,
        'bank_history': List<dynamic>.from(raw['transactions'] ?? []),
      };
    } catch (_) {
      return {};
    }
  }

  // ── Market ──────────────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchMarketData({String region = 'AEVORA'}) async {
    try {
      final response = await _dio.get('/economy/market',
          queryParameters: {'region': region});
      return List<dynamic>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> fetchDimensions() async {
    try {
      final response = await _dio.get('/economy/market/dimensions');
      return List<dynamic>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> fetchMarketHistory(String assetId) async {
    try {
      final response = await _dio.get('/economy/market/history',
          queryParameters: {'assetId': assetId});
      return List<dynamic>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  // ── News ────────────────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchNewsData() async {
    try {
      final response = await _dio.get('/economy/news');
      return List<dynamic>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  // ── Social / Inbox ──────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchInbox(String username) async {
    try {
      final response = await _dio.get('/social/inbox',
          queryParameters: {'username': username});
      return List<dynamic>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await _dio.get('/social/users');
      return List<dynamic>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  /// Finds a single user from the /social/users list by username.
  Future<Map<String, dynamic>> fetchUserPortfolio(String username) async {
    try {
      final users = await fetchUsers();
      return Map<String, dynamic>.from(
        users.firstWhere(
          (u) => u['username'] == username,
          orElse: () => <String, dynamic>{},
        ),
      );
    } catch (_) {
      return {};
    }
  }

  // ── Bank Transactions ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> transferFunds(
      String username, double amount, String direction) async {
    try {
      final response = await _dio.post('/economy/bank/transfer', data: {
        'username': username,
        'amount': amount,
        'direction': direction,
      });
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> contributeRetirement(
      String username, double amount, String type) async {
    try {
      final response =
          await _dio.post('/economy/bank/retirement/contribute', data: {
        'username': username,
        'amount': amount,
        'type': type,
      });
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ── Generic POST ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ── Stock Trading ───────────────────────────────────────────────────────────

  Future<bool> buyStock({
    required String username,
    required String assetId,
    required int shares,
    required double price,
    required String dimension,
  }) async {
    try {
      final response = await _dio.post('/economy/market/buy', data: {
        'username': username,
        'assetId': assetId,
        'shares': shares,
        'priceAtTrade': price,
        'dimension': dimension,
      });
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Mail ────────────────────────────────────────────────────────────────────

  Future<bool> markAsRead(String username, String messageId) async {
    try {
      final response = await _dio.post('/social/read',
          data: {'username': username, 'messageId': messageId});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> claimAttachment(
      String username, String messageId) async {
    try {
      final response = await _dio.post('/social/claim',
          data: {'username': username, 'messageId': messageId});
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<bool> archiveMessage(String username, String messageId) async {
    try {
      final response = await _dio.post('/social/archive',
          data: {'username': username, 'messageId': messageId});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// ── Connectivity ───────────────────────────────────────────────────────────────

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => results.first);
});

class FailSafeService {
  static bool isOffline(ConnectivityResult? result) {
    return result == ConnectivityResult.none;
  }
}
