import 'package:shared_preferences/shared_preferences.dart';

const _kActiveBattleKey = 'active_battle_id';

class BattleReconnectService {
  static Future<void> saveBattleId(String battleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActiveBattleKey, battleId);
  }

  static Future<void> clearBattleId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActiveBattleKey);
  }

  static Future<String?> getSavedBattleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kActiveBattleKey);
  }
}
