import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/game.dart';

part 'game_provider.g.dart';

@riverpod
class GameProvider extends _$GameProvider {
  static const String _storageKey = 'selected_game_id';
  SharedPreferences? _prefs;

  @override
  FutureOr<PokemonGame?> build() async {
    _prefs = await SharedPreferences.getInstance();
    final id = _prefs?.getString(_storageKey);
    if (id != null) {
      return PokemonGame.allGames.firstWhere(
        (g) => g.id == id,
        orElse: () => PokemonGame.allGames.first,
      );
    }
    return null;
  }

  Future<void> selectGame(PokemonGame game) async {
    await _prefs?.setString(_storageKey, game.id);
    state = AsyncData(game);
  }

  bool get hasSelectedGame => state.valueOrNull != null;
}
