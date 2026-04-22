import 'dart:math';
import '../../domain/models/pokemon.dart';
import 'type_chart.dart';

class DamageCalculator {
  static final Random _random = Random();

  /// Calculates damage based on the Gen 9 (Scarlet/Violet) formula.
  /// 
  /// Damage = floor(floor(floor(floor(floor(floor(BaseDamage * Weather) * Critical) * random) * STAB) * Type) * Burn)
  static int calculate({
    required Pokemon attacker,
    required Pokemon defender,
    required PokemonMove move,
    required int attackerLevel,
    required int defenderLevel,
    String weather = 'none',
    String terrain = 'none',
    bool isCrit = false,
    bool isAttackerBurned = false,
  }) {
    if (move.power <= 0 || move.damageClass.toLowerCase() == 'status') return 0;

    final isSpecial = move.damageClass.toLowerCase() == 'special';
    
    // 1. Base Stats
    final double atk = (isSpecial
        ? attacker.baseStats['spa']
        : attacker.baseStats['atk'])?.toDouble() ?? 100.0;
    final double def = (isSpecial
        ? defender.baseStats['spd']
        : defender.baseStats['def'])?.toDouble() ?? 100.0;

    // 2. Base Damage Calculation
    // formula: floor(floor(floor(2 * L / 5 + 2) * Power * A / D) / 50) + 2
    int baseDamage = (((2 * attackerLevel) ~/ 5) + 2);
    baseDamage = (baseDamage * move.power * atk.toInt()) ~/ def.toInt();
    baseDamage = (baseDamage ~/ 50) + 2;

    double finalDamage = baseDamage.toDouble();

    // 3. Weather Modifiers
    if (weather != 'none') {
      final moveType = move.type.toLowerCase();
      if (weather == 'rain') {
        if (moveType == 'water') finalDamage *= 1.5;
        if (moveType == 'fire') finalDamage *= 0.5;
      } else if (weather == 'sun') {
        if (moveType == 'fire') finalDamage *= 1.5;
        if (moveType == 'water') finalDamage *= 0.5;
      }
      finalDamage = finalDamage.floorToDouble();
    }

    // 4. Critical Hit
    if (isCrit) {
      finalDamage *= 1.5;
      finalDamage = finalDamage.floorToDouble();
    }

    // 5. Random Factor (85% to 100%)
    final int randomInt = 85 + _random.nextInt(16); // 85 to 100
    finalDamage = (finalDamage * randomInt) / 100.0;
    finalDamage = finalDamage.floorToDouble();

    // 6. STAB (Same Type Attack Bonus)
    final bool hasStab = attacker.types.map((t) => t.toLowerCase()).contains(move.type.toLowerCase());
    if (hasStab) {
      // Note: Adaptability would make this 2.0, but we'll stick to 1.5 for now
      finalDamage *= 1.5;
      finalDamage = finalDamage.floorToDouble();
    }

    // 7. Type Effectiveness
    final double effectiveness = _getEffectiveness(move, defender);
    finalDamage *= effectiveness;
    finalDamage = finalDamage.floorToDouble();

    // 8. Burn Modifier
    if (isAttackerBurned && !isSpecial) {
      // Guts ability would ignore this, but we'll stick to the base rule
      finalDamage *= 0.5;
      finalDamage = finalDamage.floorToDouble();
    }

    // 9. Terrain Modifiers
    if (terrain != 'none') {
      final moveType = move.type.toLowerCase();
      // Only affects grounded pokemon (we assume all are grounded for now)
      if (terrain == 'electric' && moveType == 'electric') finalDamage *= 1.3;
      if (terrain == 'grassy' && moveType == 'grass') finalDamage *= 1.3;
      if (terrain == 'psychic' && moveType == 'psychic') finalDamage *= 1.3;
      if (terrain == 'misty' && moveType == 'dragon') finalDamage *= 0.5;
      finalDamage = finalDamage.floorToDouble();
    }

    return finalDamage.toInt().clamp(1, 9999);
  }

  static double _getEffectiveness(PokemonMove move, Pokemon defender) {
    final attackType = TypeChart.stringToType(move.type);
    final defenderTypes = defender.types.map((t) => TypeChart.stringToType(t)).toList();
    return TypeChart.getEffectiveness(attackType, defenderTypes);
  }
}
