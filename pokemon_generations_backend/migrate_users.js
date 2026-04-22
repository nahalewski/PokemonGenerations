const fs = require('fs');
const path = require('path');

const OLD_USERS_FILE = path.join(__dirname, 'data', 'users.json');
const NEW_USERS_DIR = path.join(__dirname, 'data', 'users');

// Ensure directory exists
if (!fs.existsSync(NEW_USERS_DIR)) {
  fs.mkdirSync(NEW_USERS_DIR, { recursive: true });
}

if (!fs.existsSync(OLD_USERS_FILE)) {
  console.log('No users.json found at ' + OLD_USERS_FILE);
  process.exit(0);
}

try {
  const users = JSON.parse(fs.readFileSync(OLD_USERS_FILE, 'utf8'));
  console.log(`Starting migration of ${users.length} users...`);

  users.forEach((user) => {
    if (!user.username) {
      console.warn('Skipping user without username:', user);
      return;
    }
    const userFile = path.join(NEW_USERS_DIR, `${user.username.toLowerCase()}.json`);
    fs.writeFileSync(userFile, JSON.stringify(user, null, 2));
    console.log(`- Migrated: ${user.username}`);
  });

  console.log('Migration complete!');
  
  // Backup the old file just in case
  const backupFile = OLD_USERS_FILE + '.bak.' + Date.now();
  fs.renameSync(OLD_USERS_FILE, backupFile);
  console.log(`Original file backed up to: ${path.basename(backupFile)}`);

} catch (e) {
  console.error('Migration failed:', e);
  process.exit(1);
}
