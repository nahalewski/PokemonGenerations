enum PlayerVisualMode {
  vinyl,
  pokeBallRecord,
  pokeballSynthwave,
}

extension PlayerVisualModeExtension on PlayerVisualMode {
  String get displayName {
    switch (this) {
      case PlayerVisualMode.vinyl:
        return 'Retro Vinyl';
      case PlayerVisualMode.pokeBallRecord:
        return 'PokeBall Record';
      case PlayerVisualMode.pokeballSynthwave:
        return 'Pokeball Synthwave';
    }
  }

  String get id {
    switch (this) {
      case PlayerVisualMode.vinyl:
        return 'vinyl';
      case PlayerVisualMode.pokeBallRecord:
        return 'pokeball_record';
      case PlayerVisualMode.pokeballSynthwave:
        return 'pokeball_synthwave';
    }
  }

  static PlayerVisualMode fromId(String id) {
    return PlayerVisualMode.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PlayerVisualMode.vinyl,
    );
  }
}
