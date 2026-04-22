import 'dart:convert';
import 'package:http/http.dart' as http;

class EconomyService {
  final String _baseUrl = 'http://localhost:8191';

  Future<Map<String, dynamic>> fetchStatus() async {
    final response = await http.get(Uri.parse('$_baseUrl/economy/status'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch economy status');
  }

  Future<List<dynamic>> fetchMarket() async {
    final response = await http.get(Uri.parse('$_baseUrl/economy/market'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to fetch market data');
  }

  Future<bool> updateTax(double rate, bool override) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/economy/tax'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'taxRate': rate, 'manualOverride': override}),
    );
    return response.statusCode == 200;
  }

  Future<void> syncNews() async {
    final response = await http.post(Uri.parse('$_baseUrl/admin/sync-news'));
    if (response.statusCode != 200) {
      throw Exception('News sync failed: ${response.body}');
    }
  }
}
