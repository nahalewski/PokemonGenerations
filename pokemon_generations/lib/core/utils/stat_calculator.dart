import 'dart:math';

class StatCalculator {
  /// Calculates the HP stat for a Pokémon.
  static int calculateHP({
    required int baseHp,
    required int level,
    int iv = 31,
    int ev = 0,
  }) {
    // Shedinja exception (HP is always 1)
    if (baseHp == 1) return 1;

    final value = (0.01 * (2 * baseHp + iv + (ev / 4).floor()) * level).floor() + level + 10;
    return value;
  }

  /// Calculates a non-HP stat for a Pokémon.
  static int calculateStat({
    required int baseStat,
    required int level,
    double natureFactor = 1.0,
    int iv = 31,
    int ev = 0,
  }) {
    final baseCalculated = (0.01 * (2 * baseStat + iv + (ev / 4).floor()) * level).floor() + 5;
    return (baseCalculated * natureFactor).floor();
  }

  /// Maps nature names to their stat modifiers.
  /// Returns a map where key is the stat name (atk, def, spa, spd, spe) and value is the multiplier.
  static Map<String, double> getNatureModifiers(String natureName) {
    const modifiers = {
      'Adamant': {'atk': 1.1, 'spa': 0.9},
      'Bashful': {},
      'Bold': {'def': 1.1, 'atk': 0.9},
      'Brave': {'atk': 1.1, 'spe': 0.9},
      'Calm': {'spd': 1.1, 'atk': 0.9},
      'Careful': {'spd': 1.1, 'spa': 0.9},
      'Docile': {},
      'Gentle': {'spd': 1.1, 'def': 0.9},
      'Hardy': {},
      'Hasty': {'spe': 1.1, 'def': 0.9},
      'Impish': {'def': 1.1, 'spa': 0.9},
      'Jolly': {'spe': 1.1, 'spa': 0.9},
      'Lax': {'def': 1.1, 'spd': 0.9},
      'Lonely': {'atk': 1.1, 'def': 0.9},
      'Mild': {'spa': 1.1, 'def': 0.9},
      'Modest': {'spa': 1.1, 'atk': 0.9},
      'Naive': {'spe': 1.1, 'spd': 0.9},
      'Naughty': {'atk': 1.1, 'spd': 0.9},
      'Quiet': {'spa': 1.1, 'spe': 0.9},
      'Quirky': {},
      'Rash': {'spa': 1.1, 'spd': 0.9},
      'Relaxed': {'def': 1.1, 'spe': 0.9},
      'Sassy': {'spd': 1.1, 'spe': 0.9},
      'Serious': {},
      'Timid': {'spe': 1.1, 'atk': 0.9},
    };

    return (modifiers[natureName] ?? {}).cast<String, double>();
  }

  /// Calculates all stats for a Pokémon.
  static Map<String, int> calculateStats({
    required Map<String, int> baseStats,
    required int level,
    required Map<String, int> ivs,
    required Map<String, int> evs,
    required String nature,
  }) {
    final modifiers = getNatureModifiers(nature);
    final stats = <String, int>{};

    stats['hp'] = calculateHP(
      baseHp: baseStats['hp'] ?? 0,
      level: level,
      iv: ivs['hp'] ?? 31,
      ev: evs['hp'] ?? 0,
    );

    final otherStats = ['atk', 'def', 'spa', 'spd', 'spe'];
    for (final s in otherStats) {
      stats[s] = calculateStat(
        baseStat: baseStats[s] ?? 0,
        level: level,
        iv: ivs[s] ?? 31,
        ev: evs[s] ?? 0,
        natureFactor: modifiers[s] ?? 1.0,
      );
    }

    return stats;
  }
}
