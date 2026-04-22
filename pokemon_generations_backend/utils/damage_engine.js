/**
 * Pokemon Generations - Live Damage Engine (Gen 9 Formula)
 */

function calculateDamage(attacker, defender, move, fieldState = {}) {
  const level = attacker.level || 100;
  
  // 1. Initial Damage (Level & Stats)
  // formula: floor(floor(floor(2 * L / 5 + 2) * Power * A / D) / 50) + 2
  let baseDamage = Math.floor(Math.floor(2 * level / 5 + 2) * (move.power || 0) * (attacker.attack || 100) / (defender.defense || 100));
  baseDamage = Math.floor(baseDamage / 50) + 2;

  // 2. Modifiers
  // Multi-target, Weather, Critical, Random, STAB, Type, Burn, Other
  
  // STAB (Same Type Attack Bonus)
  let stab = 1.0;
  if (attacker.types && attacker.types.includes(move.type)) {
    stab = 1.5;
  }

  // Type Effectiveness (Simplified for now, expecting calculated value from client or lookup)
  const typeMod = move.typeEffectiveness || 1.0;

  // Final Rolls (85% to 100%)
  const rolls = [];
  for (let i = 85; i <= 100; i++) {
    let damage = Math.floor(baseDamage * (i / 100));
    damage = Math.floor(damage * stab);
    damage = Math.floor(damage * typeMod);
    rolls.push(Math.max(1, damage));
  }

  return {
    min: rolls[0],
    max: rolls[rolls.length - 1],
    rolls: rolls
  };
}

module.exports = { calculateDamage };
