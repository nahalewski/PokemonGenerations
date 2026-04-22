const fs = require('fs');
const path = require('path');

const USERS_DB_DIR = path.join(__dirname, '../data/users');

if (!fs.existsSync(USERS_DB_DIR)) {
  console.error('Users DB directory not found:', USERS_DB_DIR);
  process.exit(1);
}

const files = fs.readdirSync(USERS_DB_DIR).filter(f => f.endsWith('.json'));

const BANK_NAME = 'The Silph-Gold Trust & Global Reserve';
const MESSAGE_BODY = `Warm greetings, Trainer.

As a valued pioneer of the Aevora financial multiverse, we are thrilled to welcome you to the newly established **Silph-Gold Trust & Global Reserve**—the premier sanctuary for regional wealth.

To thank you for your commitment to testing our multi-dimensional market infrastructure, we have deposited a one-time 'Pioneer Stimulus' of **20,000 Poké Dollars** into your Vault balance.

Our new terminal now features 1-minute high-fidelity trading and high-volatility Gym Leader assets. Please visit the Bank to initialize your vault and begin dominating the regional markets.

Invest with honor.
— Silph-Gold Executive Board`;

files.forEach(file => {
  const filePath = path.join(USERS_DB_DIR, file);
  try {
    const user = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    
    // 1. Credit 20,000 PD to Vault (Bank Balance)
    if (!user.bank) {
      user.bank = { balance: 0, investments: [], portfolio: [], retirement: { roth: 0, k401: 0 } };
    }
    user.bank.balance = (user.bank.balance || 0) + 20000;
    
    // 2. Initialize Inbox and Send Welcome Message
    if (!user.inbox) {
      user.inbox = [];
    }
    
    const message = {
      id: `system_${Date.now()}`,
      from: 'Executive Board',
      subject: '🏛️ Pioneer Award: Silph-Gold Trust Launch',
      body: MESSAGE_BODY,
      sentAt: new Date().toISOString(),
      read: false,
      type: 'official'
    };
    
    user.inbox.unshift(message);
    
    // 3. Save
    fs.writeFileSync(filePath, JSON.stringify(user, null, 2));
    console.log(`[MIGRATION] Processed ${user.username}: +20,000 Vault PD, Inbox Dispatched.`);
  } catch (e) {
    console.error(`[MIGRATION] Error processing ${file}:`, e.message);
  }
});

console.log('[MIGRATION] Complete. Economy Stimulus Dispatched.');
