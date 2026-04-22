const fs = require('fs');
const path = require('path');

const USERS_DB_DIR = path.join(__dirname, '../data/users');

if (!fs.existsSync(USERS_DB_DIR)) {
  console.error('Users DB directory not found:', USERS_DB_DIR);
  process.exit(1);
}

const files = fs.readdirSync(USERS_DB_DIR).filter(f => f.endsWith('.json'));

let totalMigrated = 0;

files.forEach(file => {
  const filePath = path.join(USERS_DB_DIR, file);
  try {
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    let changed = false;

    if (Array.isArray(data.pendingGifts) && data.pendingGifts.length > 0) {
      if (!data.inbox) data.inbox = [];
      
      data.pendingGifts.forEach(gift => {
        const mail = {
          id: `reclaim_${gift.id}`,
          from: gift.senderUsername,
          fromDisplay: gift.senderDisplayName || gift.senderUsername,
          subject: `[LOGISTICS_RECLAIM] Legacy Gift`,
          body: gift.message || "Logistics Reclaim: This item was recovered from the legacy gift system and is now available for terminal claiming.",
          sentAt: gift.timestamp || new Date().toISOString(),
          read: false,
          type: "official",
          attachment: {
            type: "item",
            value: gift.itemId,
            quantity: gift.quantity || 1,
            claimed: false
          }
        };
        data.inbox.unshift(mail);
        totalMigrated++;
        changed = true;
      });

      // Cleanup
      delete data.pendingGifts;
    }

    if (changed) {
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
      console.log(`[MIGRATION] Migrated ${file}`);
    }
  } catch (e) {
    console.error(`[MIGRATION] Error processing ${file}:`, e.message);
  }
});

console.log(`[MIGRATION] Global Gift Migration Complete. Total items moved: ${totalMigrated}`);
