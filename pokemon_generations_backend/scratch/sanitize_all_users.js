const fs = require('fs');
const path = require('path');

const USERS_DB_DIR = path.join(__dirname, '../data/users');

if (!fs.existsSync(USERS_DB_DIR)) {
  console.error('Users DB directory not found:', USERS_DB_DIR);
  process.exit(1);
}

const files = fs.readdirSync(USERS_DB_DIR).filter(f => f.endsWith('.json'));

let totalPurged = 0;

files.forEach(file => {
  const filePath = path.join(USERS_DB_DIR, file);
  try {
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    let changed = false;

    // 1. Sanitize Roster
    if (Array.isArray(data.roster)) {
      const originalCount = data.roster.length;
      data.roster = data.roster.filter(p => {
        const isValid = p.id && p.id.trim() !== '' && p.pokemonName !== null;
        if (!isValid) totalPurged++;
        return isValid;
      });
      if (data.roster.length !== originalCount) changed = true;
    }

    // 2. Sanitize PC
    if (Array.isArray(data.pc)) {
      const originalCount = data.pc.length;
      data.pc = data.pc.filter(p => {
        const isValid = p.id && p.id.trim() !== '' && p.pokemonName !== null;
        if (!isValid) totalPurged++;
        return isValid;
      });
      if (data.pc.length !== originalCount) changed = true;
    }

    // 3. Sanitize Presets
    if (Array.isArray(data.presets)) {
      data.presets.forEach(preset => {
        if (Array.isArray(preset.slots)) {
          const originalCount = preset.slots.length;
          preset.slots = preset.slots.filter(p => {
            const isValid = p.id && p.id.trim() !== '' && p.pokemonName !== null;
            if (!isValid) totalPurged++;
            return isValid;
          });
          if (preset.slots.length !== originalCount) changed = true;
        }
      });
    }

    if (changed) {
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
      console.log(`[CLEANSE] Sanitized ${file}`);
    }
  } catch (e) {
    console.error(`[CLEANSE] Error processing ${file}:`, e.message);
  }
});

console.log(`[CLEANSE] Global Sanitization Complete. Total malformed entries purged: ${totalPurged}`);
