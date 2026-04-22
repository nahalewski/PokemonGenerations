const fs = require('fs');
const path = require('path');

const USERS_DB_DIR = path.join(__dirname, '../data/users');

if (!fs.existsSync(USERS_DB_DIR)) {
  console.error('Users DB directory not found:', USERS_DB_DIR);
  process.exit(1);
}

const files = fs.readdirSync(USERS_DB_DIR).filter(f => f.endsWith('.json'));

let totalPurged = 0;
let usersAffected = 0;

const resetNotice = {
  id: `reset_${Date.now()}`,
  from: "Executive Board",
  subject: "🚀 Logistics Reset: Regional Infrastructure Upgrade",
  body: "Attention Trainer,\n\nAs part of our commitment to the absolute stability of the Aevora ecosystem, we have successfully deployed the **Box Code 2.0 Protocol**. \n\nDue to the structural overhaul required for this upgrade, we have performed a **Full Storage Reset**. Your high-security PC storage and legacy Presets have been cleared to ensure compatibility with our new regional synchronization standards.\n\n**Note**: Your active Party of 6 has been preserved and sanitized. All financial assets (Bank) and inventories remain untouched.\n\nWe thank you for your cooperation as we build a state-of-the-art financial multiverse.\n\n— Silph-Gold Executive Board",
  sentAt: new Date().toISOString(),
  read: false,
  type: "official"
};

files.forEach(file => {
  const filePath = path.join(USERS_DB_DIR, file);
  try {
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    let changed = false;
    usersAffected++;

    // 1. Wipe PC (DANGEROUS / USER REQUESTED)
    if (data.pc && data.pc.length > 0) {
      totalPurged += data.pc.length;
      data.pc = [];
      changed = true;
    } else {
      data.pc = []; // Ensure it exists as empty array
    }

    // 2. Wipe Presets (DANGEROUS / USER REQUESTED)
    if (data.presets && data.presets.length > 0) {
      totalPurged += data.presets.length; 
      data.presets = [];
      changed = true;
    } else {
      data.presets = []; // Ensure it exists as empty array
    }

    // 3. Sanitize and Trim Roster (Max 6)
    if (Array.isArray(data.roster)) {
      const originalCount = data.roster.length;
      
      // Filter malformed first
      data.roster = data.roster.filter(p => {
        return p.id && p.id.trim() !== '' && p.pokemonName !== null;
      });

      // Trim to 6
      if (data.roster.length > 6) {
        data.roster = data.roster.slice(0, 6);
      }

      if (data.roster.length !== originalCount) changed = true;
    } else {
      data.roster = [];
      changed = true;
    }

    // 4. Add Notification
    if (!data.inbox) data.inbox = [];
    data.inbox.unshift(resetNotice);
    changed = true;

    if (changed) {
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
      console.log(`[RESET] Sanitized and Reset storage for ${file}`);
    }
  } catch (e) {
    console.error(`[RESET] Error processing ${file}:`, e.message);
  }
});

console.log(`[RESET] Global Structural Purge Complete.`);
console.log(`[RESET] Users Affected: ${usersAffected}`);
console.log(`[RESET] Legacy Pokémon Purged: ${totalPurged}`);
