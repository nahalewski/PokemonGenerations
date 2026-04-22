const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const os = require('os');
const path = require('path');
const fs = require('fs');
const https = require('https');
const { calculateDamage } = require('./utils/damage_engine');
const { getEffectiveness } = require('./utils/type_effectiveness');
const { registerAiFeatures } = require('./ai_features');

// --- LOGGING SYSTEM ---
const LOG_DIR = path.join(__dirname, '.logs');
if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });

const LOG_FILES = {
  system: path.join(LOG_DIR, 'system.log'),
  battle: path.join(LOG_DIR, 'battle.log'),
  error: path.join(LOG_DIR, 'error.log'),
  auth: path.join(LOG_DIR, 'auth.log'),
  sync: path.join(LOG_DIR, 'sync.log'),
  social: path.join(LOG_DIR, 'social.log'),
};

function log(category, message) {
  const timestamp = new Date().toISOString();
  const fileKey = category.toLowerCase();
  const logPath = LOG_FILES[fileKey] || LOG_FILES.system;
  const entry = `[${timestamp}] ${message}\n`;

  // 1. Write to specific file
  fs.appendFileSync(logPath, entry);

  // 2. Tag for Mac App console routing via stdout
  console.log(`[${category.toUpperCase()}] ${message}`);
}

// --- ARCHIVING HELPERS ---
function archiveNews(content) {
  try {
    const now = new Date();
    const dateStr = now.toISOString().split('T')[0]; // YYYY-MM-DD
    const timeStr = now.toTimeString().split(' ')[0].replace(/:/g, '-'); // HH-MM-SS
    const archiveDir = path.join(LOG_DIR, 'news_archive');
    if (!fs.existsSync(archiveDir)) fs.mkdirSync(archiveDir, { recursive: true });

    const archivePath = path.join(archiveDir, `news_${dateStr}_${timeStr}.json`);
    fs.writeFileSync(archivePath, JSON.stringify({ archivedAt: now.toISOString(), ...content }, null, 2));
    log('system', `News archived to news_archive/news_${dateStr}_${timeStr}.json`);
  } catch (e) {
    log('error', `Failed to archive news: ${e.message}`);
  }
}

function logBattleEvent(battleId, event) {
  try {
    const battleLogDir = path.join(LOG_DIR, 'battles');
    if (!fs.existsSync(battleLogDir)) fs.mkdirSync(battleLogDir, { recursive: true });

    const battleLogPath = path.join(battleLogDir, `${battleId}.log`);
    const timestamp = new Date().toISOString();
    const entry = `[${timestamp}] ${JSON.stringify(event)}\n`;
    fs.appendFileSync(battleLogPath, entry);
  } catch (e) {
    log('error', `Failed to log battle event for ${battleId}: ${e.message}`);
  }
}

function fetchFromPokeAPI(id) {
  return new Promise((resolve, reject) => {
    https.get(`https://pokeapi.co/api/v2/pokemon/${id}`, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
}

const POKEMON_CACHE_FILE = path.join(__dirname, 'pokemon_cache.json');
let pokemonCache = {};
if (fs.existsSync(POKEMON_CACHE_FILE)) {
  try { pokemonCache = JSON.parse(fs.readFileSync(POKEMON_CACHE_FILE)); } catch (e) { }
}

const app = express();
const port = 8194;

const APK_OUTPUT_DIR =
  '/Users/bennahalewski/Documents/PokeRoster/pokemon_generations/build/app/outputs/flutter-apk';
const FLUTTER_PUBSPEC_PATH =
  '/Users/bennahalewski/Documents/PokeRoster/pokemon_generations/pubspec.yaml';

app.use(cors({
  origin: [
    'https://generations.orosapp.us',
    'https://exchange.orosapp.us',
    'https://poke.orosapp.us',
    'https://pokeroster.orosapp.us',
    'https://app.orosapp.us',
    'http://localhost:8191',
    'http://127.0.0.1:8191',
    'http://localhost:8192',
    'http://127.0.0.1:8192',
    'http://localhost:8194',
    'http://127.0.0.1:8194'
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept'],
  credentials: true
}));
app.use(bodyParser.json());

app.use('/pokemon-images', express.static(path.join(__dirname, 'assets/pokemon_images')));
app.use('/profile-pics', express.static(path.join(__dirname, 'data/profile_pics')));
app.use('/downloads/apk', express.static(APK_OUTPUT_DIR));

// Community asset directories — served statically for streaming / individual file access.
app.use('/assets/battle-audio', express.static(path.join(__dirname, 'assets/battle_audio'), {
  setHeaders: (res) => res.set('Cache-Control', 'public, max-age=86400'),
}));
app.use('/assets/pokemon-icons/templarian', express.static(path.join(__dirname, 'assets/pokemon_icons/templarian'), {
  setHeaders: (res) => res.set('Cache-Control', 'public, max-age=604800, immutable'),
}));
app.use('/assets/pokemon-icons/fraserxu', express.static(path.join(__dirname, 'assets/pokemon_icons/fraserxu'), {
  setHeaders: (res) => res.set('Cache-Control', 'public, max-age=604800, immutable'),
}));
app.use('/assets/pokemmo-sprites', express.static(path.join(__dirname, 'assets/pokemmo_sprites'), {
  setHeaders: (res) => res.set('Cache-Control', 'public, max-age=604800, immutable'),
}));

// Official SoundTrack Library – streaming enabled
const OST_DIR = '/Users/bennahalewski/Documents/PokeRoster/Pokemon Generations Official SoundTrack';
if (!fs.existsSync(OST_DIR)) fs.mkdirSync(OST_DIR, { recursive: true });
app.use('/assets/ost', express.static(OST_DIR, {
  setHeaders: (res) => res.set('Cache-Control', 'public, max-age=3600'),
}));

// Attack SFX Library – streaming enabled for battles
const SFX_ATTACKS_DIR = '/Users/bennahalewski/Documents/PokeRoster/old assets/Pokemon SFX Attack Moves & Sound Effects Collection/GEN 7 SFX - Attack Moves - SUMO, USUM';
app.use('/assets/sfx/attacks', express.static(SFX_ATTACKS_DIR, {
  setHeaders: (res) => res.set('Cache-Control', 'public, max-age=86400'),
}));

// Pre-built downloadable zip packages (generated by scripts/build_asset_packages.js)
const ASSET_PACKAGES_DIR = path.join(__dirname, 'assets/asset_packages');
if (!fs.existsSync(ASSET_PACKAGES_DIR)) fs.mkdirSync(ASSET_PACKAGES_DIR, { recursive: true });
app.use('/api/asset-packages', express.static(ASSET_PACKAGES_DIR, {
  setHeaders: (res) => res.set('Cache-Control', 'public, max-age=3600'),
}));

const WEB_BUILD_DIR = '/Users/bennahalewski/Documents/PokeRoster/pokemon_generations/build/web';

// Files that must always be fresh — never cached by the browser or CDN
const NO_CACHE_FILES = ['index.html', 'flutter_service_worker.js', 'flutter_bootstrap.js', 'manifest.json'];

app.use('/app', express.static(WEB_BUILD_DIR, {
  setHeaders: (res, filePath) => {
    if (NO_CACHE_FILES.some(f => filePath.endsWith(f))) {
      res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
      res.set('Pragma', 'no-cache');
      res.set('Expires', '0');
    } else {
      // Content-hashed Flutter assets are safe to cache indefinitely
      res.set('Cache-Control', 'public, max-age=31536000, immutable');
    }
  },
}));

app.get('/app/*', (req, res) => {
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
  res.sendFile(path.join(WEB_BUILD_DIR, 'index.html'));
});

function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const devName in interfaces) {
    const iface = interfaces[devName];
    for (let i = 0; i < iface.length; i += 1) {
      const alias = iface[i];
      if (alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal) {
        return alias.address;
      }
    }
  }
  return 'localhost';
}

function parsePubspecVersion() {
  try {
    const pubspec = fs.readFileSync(FLUTTER_PUBSPEC_PATH, 'utf8');
    const match = pubspec.match(/^version:\s*([0-9A-Za-z.+-]+)$/m);
    if (!match) {
      return { version: '0.0.0', buildNumber: '0' };
    }

    const [version, buildNumber = '0'] = match[1].trim().split('+');
    return { version, buildNumber };
  } catch (error) {
    return { version: '0.0.0', buildNumber: '0' };
  }
}

function compareDottedValues(left, right) {
  const leftParts = String(left || '0').split('.').map((part) => Number.parseInt(part, 10) || 0);
  const rightParts = String(right || '0').split('.').map((part) => Number.parseInt(part, 10) || 0);
  const length = Math.max(leftParts.length, rightParts.length);

  for (let index = 0; index < length; index += 1) {
    const a = leftParts[index] || 0;
    const b = rightParts[index] || 0;
    if (a > b) {
      return 1;
    }
    if (a < b) {
      return -1;
    }
  }

  return 0;
}

function isUpdateAvailable(latestVersion, latestBuildNumber, currentVersion, currentBuildNumber) {
  const versionCompare = compareDottedValues(latestVersion, currentVersion);
  if (versionCompare > 0) {
    return true;
  }
  if (versionCompare < 0) {
    return false;
  }
  return (Number.parseInt(latestBuildNumber, 10) || 0) > (Number.parseInt(currentBuildNumber, 10) || 0);
}

function readSha1File(fileName) {
  const sameNameSha1Path = path.join(APK_OUTPUT_DIR, `${fileName}.sha1`);
  if (fs.existsSync(sameNameSha1Path)) {
    return fs.readFileSync(sameNameSha1Path, 'utf8').trim();
  }

  const genericSha1 = fs
    .readdirSync(APK_OUTPUT_DIR)
    .find((entry) => entry.toLowerCase().endsWith('.sha1'));
  if (!genericSha1) {
    return null;
  }
  return fs.readFileSync(path.join(APK_OUTPUT_DIR, genericSha1), 'utf8').trim();
}

function getLatestApkMetadata(req) {
  if (!fs.existsSync(APK_OUTPUT_DIR)) {
    return null;
  }

  const apkFiles = fs
    .readdirSync(APK_OUTPUT_DIR)
    .filter((entry) => entry.toLowerCase().endsWith('.apk'))
    .map((entry) => {
      const absolutePath = path.join(APK_OUTPUT_DIR, entry);
      const stats = fs.statSync(absolutePath);
      return {
        fileName: entry,
        absolutePath,
        size: stats.size,
        modifiedAt: stats.mtime.toISOString(),
        modifiedAtMs: stats.mtimeMs,
      };
    })
    .sort((a, b) => b.modifiedAtMs - a.modifiedAtMs);

  if (apkFiles.length === 0) {
    return null;
  }

  const latestApk = apkFiles[0];
  const { version, buildNumber } = parsePubspecVersion();
  const downloadUrl = `${req.protocol}://${req.get('host')}/downloads/apk/${encodeURIComponent(
    latestApk.fileName,
  )}`;

  return {
    version,
    buildNumber,
    fileName: latestApk.fileName,
    fileSizeBytes: latestApk.size,
    publishedAt: latestApk.modifiedAt,
    downloadUrl,
    sha1: readSha1File(latestApk.fileName),
  };
}

const showdownPokedex = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'assets/showdown_pokedex.json'), 'utf8'),
);
const showdownMoves = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'assets/showdown_moves.json'), 'utf8'),
);
const showdownItems = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'assets/showdown_items.json'), 'utf8'),
);
const showdownLearnsets = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'assets/showdown_learnsets.json'), 'utf8'),
);

const PROFILE_PICS_DIR = path.join(__dirname, 'data/profile_pics');
const REPLAYS_DIR = path.join(__dirname, 'data/replays');
const USERS_DB_DIR = path.join(__dirname, 'data/users');
const BANK_DB_DIR = path.join(__dirname, 'data/bank');

if (!fs.existsSync(PROFILE_PICS_DIR)) fs.mkdirSync(PROFILE_PICS_DIR, { recursive: true });
if (!fs.existsSync(REPLAYS_DIR)) fs.mkdirSync(REPLAYS_DIR, { recursive: true });
if (!fs.existsSync(USERS_DB_DIR)) fs.mkdirSync(USERS_DB_DIR, { recursive: true });
if (!fs.existsSync(BANK_DB_DIR)) fs.mkdirSync(BANK_DB_DIR, { recursive: true });

function getBankPath(username) {
  return path.join(BANK_DB_DIR, `${username.toLowerCase()}_bank.json`);
}

function loadBank(username) {
  const bankPath = path.join(BANK_DB_DIR, `${username}_bank.json`);
  let bank = {
    balance: 0,
    savings: 0,
    retirement: { k401: 0, roth: 0 },
    portfolio: [],
    transactions: [],
    lastInterestDate: new Date().toISOString()
  };

  if (fs.existsSync(bankPath)) {
    try {
      bank = JSON.parse(fs.readFileSync(bankPath, 'utf8'));
    } catch (e) {
      log('error', `Error reading bank for ${username}: ${e.message}`);
    }
  }

  // --- MONTHLY INTEREST ENGINE (4.5% APY) ---
  const now = new Date();
  // Fallback to current date if field is missing to start the clock for new users
  if (!bank.lastInterestDate) bank.lastInterestDate = now.toISOString();
  
  const lastInterest = new Date(bank.lastInterestDate);
  const diffMs = now.getTime() - lastInterest.getTime();
  const monthsElapsed = Math.floor(diffMs / (1000 * 60 * 60 * 24 * 30));

  if (monthsElapsed >= 1 && bank.savings > 0) {
    const monthlyRate = 0.045 / 12;
    const interestEarned = Math.floor(bank.savings * monthlyRate * monthsElapsed);
    
    if (interestEarned > 0) {
      bank.savings += interestEarned;
      bank.lastInterestDate = now.toISOString();
      
      // Update history without saving yet
      if (!bank.transactions) bank.transactions = [];
      bank.transactions.unshift({
        id: `INT-${Date.now()}`,
        timestamp: now.toISOString(),
        type: 'INTEREST',
        description: `Monthly Savings Interest (4.5% APY x ${monthsElapsed})`,
        amount: interestEarned,
        source: 'savings'
      });
      
      // Keep transaction limit
      if (bank.transactions.length > 500) bank.transactions = bank.transactions.slice(0, 500);
      
      // Save the applied interest
      saveBank(username, bank);
      log('system', `[INTEREST] Applied ${interestEarned} PD to ${username}'s savings (${monthsElapsed} months)`);
    }
  }

  return bank;
}

function saveBank(username, bankData) {
  const bankPath = getBankPath(username);
  bankData.updatedAt = new Date().toISOString();
  try {
    fs.writeFileSync(bankPath, JSON.stringify(bankData, null, 2));
  } catch (e) {
    log('error', `Error saving bank for ${username}: ${e.message}`);
  }
}

function appendBankTransaction(bank, type, amount, description, source = 'checking') {
  if (!bank.transactions) bank.transactions = [];
  if (!bank.retirement) bank.retirement = { k401: 0, roth: 0 };

  bank.transactions.unshift({
    id: `TX-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    timestamp: new Date().toISOString(),
    type,
    amount,
    description,
    source
  });

  if (source === 'checking') {
    bank.balance = (bank.balance || 0) + amount;
  } else if (source === 'savings') {
    bank.savings = (bank.savings || 0) + amount;
  } else if (source === 'k401') {
    bank.retirement.k401 = (bank.retirement.k401 || 0) + amount;
  } else if (source === 'roth') {
    bank.retirement.roth = (bank.retirement.roth || 0) + amount;
  }

  if (bank.transactions.length > 500) bank.transactions = bank.transactions.slice(0, 500);
  return bank;
}

function logBankTransaction(username, type, amount, description, source = 'checking') {
  const bank = loadBank(username);
  appendBankTransaction(bank, type, amount, description, source);
  saveBank(username, bank);
  log('social', `[BANK] ${username}: ${type} ${amount} PD (${description}) via ${source}`);
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    if (file.fieldname === 'replay') {
      cb(null, REPLAYS_DIR);
    } else {
      cb(null, PROFILE_PICS_DIR);
    }
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.json';
    const username = (req.body.username || 'unknown').toLowerCase();
    const prefix = file.fieldname === 'replay' ? 'replay' : username;
    cb(null, `${prefix}_${username}_${Date.now()}${ext}`);
  }
});
const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 } // 2MB
});

function getUserPath(username) {
  if (!username) return null;
  return path.join(USERS_DB_DIR, `${username.toLowerCase()}.json`);
}

function migrateBankingData(user) {
  if (user.bank || user.pokedollars !== undefined) {
    const bank = loadBank(user.username);
    let migrated = false;

    // Migrate balance (from pokedollars or existing user.bank.balance)
    if (user.pokedollars !== undefined) {
      bank.balance += user.pokedollars;
      migrated = true;
      delete user.pokedollars;
    }

    if (user.bank) {
      if (typeof user.bank.balance === 'number') {
        bank.balance += user.bank.balance;
        migrated = true;
      }
      if (typeof user.bank.savings === 'number') {
        bank.savings += user.bank.savings;
        migrated = true;
      }
      if (Array.isArray(user.bank.portfolio)) {
        // Merge portfolios, avoiding duplicates
        user.bank.portfolio.forEach(p => {
          const existing = bank.portfolio.find(ep => ep.id === p.id);
          if (existing) {
            existing.shares += p.shares;
          } else {
            bank.portfolio.push(p);
          }
        });
        migrated = true;
      }
      if (user.bank.retirement) {
        bank.retirement.k401 += (user.bank.retirement.k401 || 0);
        bank.retirement.roth += (user.bank.retirement.roth || 0);
        migrated = true;
      }
      delete user.bank;
    }

    if (migrated) {
      saveBank(user.username, bank);
      // We don't call saveUser here to avoid recursion or redundant writes if called from loadUsers
      log('system', `[MIGRATION] Bank data migrated for ${user.username}`);
    }
    return migrated;
  }
  return false;
}

function loadUsers() {
  try {
    if (!fs.existsSync(USERS_DB_DIR)) {
      fs.mkdirSync(USERS_DB_DIR, { recursive: true });
      return [];
    }
    const files = fs.readdirSync(USERS_DB_DIR);
    const users = files
      .filter(f => f.endsWith('.json'))
      .map(f => {
        try {
          const user = JSON.parse(fs.readFileSync(path.join(USERS_DB_DIR, f), 'utf8'));
          if (migrateBankingData(user)) {
            // If migrated, save the cleaned user file back
            const userPath = path.join(USERS_DB_DIR, f);
            fs.writeFileSync(userPath, JSON.stringify(user, null, 2));
          }
          return user;
        } catch (e) {
          return null;
        }
      })
      .filter(u => u !== null);
    return users;
  } catch (e) {
    console.error('[DB] Error loading aggregated users:', e);
    return [];
  }
}

function getUser(username) {
  if (!username) return null;
  const userPath = getUserPath(username);
  try {
    if (fs.existsSync(userPath)) {
      return JSON.parse(fs.readFileSync(userPath, 'utf8'));
    }
  } catch (e) {
    console.error(`[DB] Error loading user ${username}:`, e);
  }
  return null;
}

function saveUser(user, preserveTimestamp = false) {
  if (!user || !user.username) return;
  const userPath = getUserPath(user.username);

  if (!preserveTimestamp) {
    user.updatedAt = new Date().toISOString();
  }

  try {
    fs.writeFileSync(userPath, JSON.stringify(user, null, 2));

    // Optimized cache update: Update the specific user in memory instead of re-loading everything
    const idx = globalUsers.findIndex(u => u.username === user.username);
    if (idx !== -1) {
      globalUsers[idx] = user;
    } else {
      globalUsers.push(user);
    }
  } catch (e) {
    console.error(`[DB] Error saving user ${user.username}:`, e);
  }
}

// Deprecated: for batch operations only
function saveUsers(users) {
  users.forEach(saveUser);
}

let globalUsers = loadUsers();
let globalChat = [];
let globalBroadcast = null; // { text, sentAt, sentBy }
let battleSessions = {};
let pendingChallenges = {}; // { targetUsername: [ { challenger, battleId, expires } ] }
let battleTelemetry = {}; // { battleId: { lastUpdate, log, playerInfo, opponentInfo } }
let bannedIPs = [];

// --- NEWS FEED STORAGE ---
const NEWS_FILE = path.join(__dirname, 'data/news.json');
if (!fs.existsSync(path.join(__dirname, 'data'))) fs.mkdirSync(path.join(__dirname, 'data'), { recursive: true });
if (!fs.existsSync(NEWS_FILE)) fs.writeFileSync(NEWS_FILE, JSON.stringify([], null, 2));

function loadNews() {
  try {
    return JSON.parse(fs.readFileSync(NEWS_FILE, 'utf8'));
  } catch (e) {
    return [];
  }
}

// --- GLOBAL ECONOMY ENGINE ---
let globalEconomy = {
  taxRate: 0.05,
  bitcoinPrice: 65000,
  nasdaqIndex: 16000,
  treasury: 0,
  lastUpdate: new Date().toISOString(),
  manualOverride: false
};

function updateEconomy() {
  // Fetch Bitcoin
  https.get('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd', (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      try {
        const json = JSON.parse(data);
        if (json.bitcoin && json.bitcoin.usd) {
          const oldPrice = globalEconomy.bitcoinPrice;
          globalEconomy.bitcoinPrice = json.bitcoin.usd;

          if (!globalEconomy.manualOverride) {
            // Calculate dynamic tax (2-15%) based on 1% volatility step
            const flux = (globalEconomy.bitcoinPrice - oldPrice) / oldPrice;
            let newTax = globalEconomy.taxRate + (flux * 5); // 5x multiplier for impact
            globalEconomy.taxRate = Math.min(0.15, Math.max(0.02, newTax));

            // Notification for Economy Mac App (via stdout tag)
            if (Math.abs(flux) > 0.05) {
              log('system', `MARKET_VOLATILITY: BTC Flux ${(flux * 100).toFixed(2)}% detected. Tax rate adjusted to ${(globalEconomy.taxRate * 100).toFixed(1)}%`);
            }
          }
        }
      } catch (e) { }
    });
  }).on('error', () => { });

  // Fetch S&P 500 (Simulated via Nasdaq Proxy for theme)
  https.get('https://query1.finance.yahoo.com/v8/finance/chart/^GSPC?interval=1m&range=1d', (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      try {
        const json = JSON.parse(data);
        if (json.chart && json.chart.result && json.chart.result[0].meta.regularMarketPrice) {
          globalEconomy.nasdaqIndex = json.chart.result[0].meta.regularMarketPrice;
        }
      } catch (e) { }
    });
  }).on('error', () => { });

  globalEconomy.lastUpdate = new Date().toISOString();
  log('system', `Economy Sync: BTC $${globalEconomy.bitcoinPrice.toLocaleString()}, Tax: ${(globalEconomy.taxRate * 100).toFixed(1)}%`);
}

const aiRuntime = registerAiFeatures(app, {
  rootDir: '/Users/bennahalewski/Documents/PokeRoster',
  backendDir: __dirname,
  getUsers: () => globalUsers,
  getUser,
  saveUser,
  getGlobalEconomy: () => globalEconomy,
  getGlobalBroadcast: () => globalBroadcast,
  setGlobalBroadcast: (value) => {
    globalBroadcast = value;
  },
  log,
});

// Update every 5 minutes
setInterval(updateEconomy, 300000);
updateEconomy();

function isMarketOpen() {
  const now = new Date();
  // Standard Wall Street Hours: 9:30 AM — 4:00 PM Eastern Time
  // ET is UTC-4 (EDT) or UTC-5 (EST)
  // For simplicity, we'll use a fixed offset of UTC-4 (most of the year)
  const etOffset = -4;
  const utc = now.getTime() + (now.getTimezoneOffset() * 60000);
  const etDate = new Date(utc + (3600000 * etOffset));

  const day = etDate.getDay();
  const hours = etDate.getHours();
  const minutes = etDate.getMinutes();

  // Weekend check (Saturday=6, Sunday=0)
  if (day === 0 || day === 6) return false;

  const timeInMinutes = (hours * 60) + minutes;
  const openTime = (9 * 60) + 30; // 9:30 AM
  const closeTime = (16 * 60);    // 4:00 PM

  return timeInMinutes >= openTime && timeInMinutes <= closeTime;
}

function collectTax(amount) {
  const admin = getUser('bn200n');
  if (admin) {
    admin.pokedollars = (admin.pokedollars || 0) + amount;
    saveUser(admin, true);
    log('social', `Tax Collected: $${amount.toFixed(2)} routed to treasury (bn200n)`);
  }
}

const FORBIDDEN_WORDS = ['fuck', 'shit', 'ass', 'bitch', 'crap', 'damn']; // Simple list for demonstration

function filterCussWords(text) {
  let filtered = text;
  FORBIDDEN_WORDS.forEach(word => {
    const regex = new RegExp(word, 'gi');
    filtered = filtered.replace(regex, '***');
  });
  return filtered;
}


app.post('/auth/profile-picture', upload.single('image'), (req, res) => {
  const { username } = req.body;
  if (!username || !req.file) {
    return res.status(400).json({ success: false, message: 'Missing username or image file.' });
  }

  const user = getUser(username);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found.' });
  }

  const profileImageUrl = `${req.protocol}://${req.get('host')}/profile-pics/${req.file.filename}`;
  user.profileImageUrl = profileImageUrl;
  saveUser(user);

  res.json({ success: true, profileImageUrl });
});

// ── Asset Manifest ────────────────────────────────────────────────────────────
// Describes every downloadable asset package.  The Flutter app fetches this on
// launch to decide what to download on first install and when to update.

const ASSET_PACKAGE_DEFS = [
  {
    id: 'pokemon_icons_templarian',
    name: 'Pokemon Icons (252)',
    description: '252 clean Pokemon PNG icons by Templarian/slack-emoji-pokemon',
    version: '1.0.0',
    required: false,
    sourceDir: path.join(__dirname, 'assets/pokemon_icons/templarian'),
    zipFile: 'pokemon_icons_templarian.zip',
  },
  {
    id: 'pokemon_icons_fraserxu',
    name: 'Pokemon Icons Retro (151)',
    description: '151 classic Gen-1 Pokemon icons by fraserxu',
    version: '1.0.0',
    required: false,
    sourceDir: path.join(__dirname, 'assets/pokemon_icons/fraserxu'),
    zipFile: 'pokemon_icons_fraserxu.zip',
  },
  {
    id: 'pokemmo_sprites',
    name: 'PokeMMO Sprites',
    description: 'Pokemon sprites from PokeMMO by maierfelix',
    version: '1.0.0',
    required: false,
    sourceDir: path.join(__dirname, 'assets/pokemmo_sprites'),
    zipFile: 'pokemmo_sprites.zip',
  },
];

function getAssetManifest(req) {
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const packages = [];

  for (const def of ASSET_PACKAGE_DEFS) {
    const zipPath = path.join(ASSET_PACKAGES_DIR, def.zipFile);
    const hasZip = fs.existsSync(zipPath);

    // Only advertise packages where the zip has been pre-built.
    if (!hasZip) continue;

    const stats = fs.statSync(zipPath);
    packages.push({
      id: def.id,
      name: def.name,
      description: def.description,
      version: def.version,
      required: def.required,
      sizeBytes: stats.size,
      downloadUrl: `${baseUrl}/api/asset-packages/${def.zipFile}`,
    });
  }

  return {
    manifestVersion: '1',
    generatedAt: new Date().toISOString(),
    packages,
  };
}

app.get('/api/asset-manifest', (req, res) => {
  res.json(getAssetManifest(req));
});

// Admin helper: POST /admin/build-asset-packages
// Re-zips each source directory into assets/asset_packages/*.zip.
// Run once after updating source assets.
app.post('/admin/build-asset-packages', (req, res) => {
  const { exec } = require('child_process');
  const results = [];
  let pending = ASSET_PACKAGE_DEFS.length;

  for (const def of ASSET_PACKAGE_DEFS) {
    const zipOut = path.join(ASSET_PACKAGES_DIR, def.zipFile);
    // zip -j = junk (strip) paths so files land at zip root
    const cmd = `zip -j "${zipOut}" "${def.sourceDir}"/*.png "${def.sourceDir}"/*.jpg "${def.sourceDir}"/*.gif 2>/dev/null; zip -j "${zipOut}" "${def.sourceDir}"/* 2>/dev/null; true`;
    exec(`cd "${def.sourceDir}" && zip -r "${zipOut}" .`, (err, stdout, stderr) => {
      results.push({ id: def.id, ok: !err, zipFile: def.zipFile });
      pending--;
      if (pending === 0) {
        res.json({ success: true, results });
      }
    });
  }

  if (ASSET_PACKAGE_DEFS.length === 0) res.json({ success: true, results: [] });
});

app.get('/health', (req, res) => {
  const latestApk = getLatestApkMetadata(req);
  res.json({
    status: 'ok',
    server: 'Pokemon Center Admin Backend',
    ip: getLocalIP(),
    dbSize: Object.keys(showdownPokedex).length,
    updateSource: latestApk
      ? {
        version: latestApk.version,
        buildNumber: latestApk.buildNumber,
        fileName: latestApk.fileName,
        publishedAt: latestApk.publishedAt,
      }
      : null,
    globalEconomy: {
      taxRate: globalEconomy.taxRate,
      bitcoin: globalEconomy.bitcoinPrice,
      nasdaq: globalEconomy.nasdaqIndex
    }
  });
});

app.get('/app-update', (req, res) => {
  const latestApk = getLatestApkMetadata(req);
  if (!latestApk) {
    return res.status(404).json({
      error: 'No APK found in the configured build output directory.',
      apkDirectory: APK_OUTPUT_DIR,
    });
  }

  const currentVersion = String(req.query.currentVersion || '0.0.0');
  const currentBuildNumber = String(req.query.currentBuildNumber || '0');

  return res.json({
    ...latestApk,
    currentVersion,
    currentBuildNumber,
    updateAvailable: isUpdateAvailable(
      latestApk.version,
      latestApk.buildNumber,
      currentVersion,
      currentBuildNumber,
    ),
  });
});

app.get('/pokemon', (req, res) => {
  const list = Object.keys(showdownPokedex).map((id) => ({
    id,
    name: showdownPokedex[id].name,
    types: showdownPokedex[id].types.map((type) => type.toLowerCase()),
  }));
  res.json(list);
});

app.get('/items', (req, res) => {
  const list = Object.entries(showdownItems).map(([id, item]) => ({
    id,
    name: item.name,
    description: item.desc || '',
  }));
  res.json(list);
});

app.get('/moves', (req, res) => {
  const list = Object.entries(showdownMoves).map(([id, move]) => ({
    id,
    name: move.name,
    type: move.type,
    category: move.category,
    power: move.power || 0,
    accuracy: move.accuracy || 0,
    pp: move.pp || 0,
  }));
  res.json(list);
});

const REGIONS = {
  'AEVORA': { name: 'Aevora (Alpha)', id: 'AEVORA', tag: 'AE', isLocal: true, theme: 'standard' },
  'KANTO': { name: 'Kanto (Gen 1)', id: 'KANTO', tag: 'KT', proxy: 'AAPL', description: 'Silicon Valley of the Traditional World.' },
  'JOHTO': { name: 'Johto (Gen 2)', id: 'JOHTO', tag: 'JT', proxy: 'DIS', description: 'Cultural and communications hub.' },
  'HOENN': { name: 'Hoenn (Gen 3)', id: 'HOENN', tag: 'HN', proxy: 'TSLA', description: 'Industrial and energy innovation.' },
  'SINNOH': { name: 'Sinnoh (Gen 4)', id: 'SINNOH', tag: 'SN', proxy: 'GOOGL', description: 'Digital tech and ancient wearables.' },
  'UNOVA_C': { name: 'Unova (Classic)', id: 'UNOVA_C', tag: 'UN', proxy: 'UNP', description: 'Logistics and transport corridor.' },
  'KALOS': { name: 'Kalos (Gen 6)', id: 'KALOS', tag: 'KL', proxy: 'XOM', description: 'Energy and luxury sectors.' },
  'ALOLA': { name: 'Alola (Gen 7)', id: 'ALOLA', tag: 'AL', proxy: 'MRNA', description: 'BioTech and organic sciences.' },
  'GALAR': { name: 'Galar (Gen 8)', id: 'GALAR', tag: 'GL', proxy: '^FTSE', description: 'Heavy industrial conglomerate.' },
  'PALDEA': { name: 'Paldea (Gen 9)', id: 'PALDEA', tag: 'PD', proxy: 'MSFT', description: 'Educational tech and legacy infra.' },
  'HISUI': { name: 'Hisui (Historical)', id: 'HISUI', tag: 'HS', proxy: 'RIO', description: 'Ancient merchant guilds and workshops.', theme: 'sepia' },
  'LUMI_F': { name: 'Lumiose (Future)', id: 'LUMI_F', tag: 'LZ', proxy: 'NVDA', description: 'Future city redevelopment and hologram tech.', theme: 'hologram' },
};

function getMarketAssetsByRegion(region, nasdaq, btcRatio) {
  if (region === 'AEVORA') {
    return [
      { id: 'AEX', name: 'Aevora Index', ticker: '^IXIC', displayTicker: '^AEX', price: nasdaq / 10, sector: 'INDEX', dimension: 'AEVORA' },
      { id: 'SLPH', name: 'Silph Co. (Global)', ticker: 'AAPL', displayTicker: 'SLPH', price: 220.0, sector: 'TECH', dimension: 'AEVORA' },
      { id: 'PLAT', name: 'Plasma Energy', ticker: 'XOM', displayTicker: 'PLTE', price: 115.0, sector: 'ENERGY', dimension: 'AEVORA' },
      { id: 'PRYG', name: 'Porygon Crypto', ticker: 'BTC-USD', displayTicker: 'PRYG', price: btcRatio * 2500, sector: 'CRYPTO', dimension: 'AEVORA' },
      { id: 'ROST', name: 'Roster Analytics', ticker: 'PLTR', displayTicker: 'ROST', price: 42.0, sector: 'SaaS', dimension: 'AEVORA' },
    ];
  }

  const dimensionalAssets = {
    'KANTO': [
      { id: 'KT_SLPH', name: 'Silph Co. (Classic)', ticker: 'MSFT', displayTicker: 'SLPH.K', price: 410.0, sector: 'TECH', dimension: 'KANTO' },
      { id: 'KT_CELA', name: 'Celadon Dept Store', ticker: 'TGT', displayTicker: 'CELA', price: 145.0, sector: 'RETAIL', dimension: 'KANTO' },
      { id: 'KT_ROCK', name: 'Rocket Game Corner', ticker: 'LVS', displayTicker: 'RKTG', price: 52.0, sector: 'GAMING', dimension: 'KANTO' },
      { id: 'KT_RAD0', name: 'Kanto Radio', ticker: 'SIRI', displayTicker: 'KRAD', price: 3.50, sector: 'MEDIA', dimension: 'KANTO' },
      { id: 'KT_BIKE', name: 'Cerulean Bike Shop', ticker: 'HOG', displayTicker: 'CERB', price: 35.0, sector: 'TRANSIT', dimension: 'KANTO' },
      { id: 'KT_PEN_BROCK', name: 'Brock Boulder Ores', ticker: 'DNN', displayTicker: 'BRCK', price: 2.15, sector: 'PENNY', isPenny: true, dimension: 'KANTO', volatility: 3.5 },
      { id: 'KT_PEN_MISTY', name: 'Misty Water Systems', ticker: 'CWCO', displayTicker: 'MSTY', price: 3.40, sector: 'PENNY', isPenny: true, dimension: 'KANTO', volatility: 3.5 },
    ],
    'JOHTO': [
      { id: 'JT_GOLD', name: 'Goldenrod Radio', ticker: 'SIRI', displayTicker: 'GRDO', price: 3.50, sector: 'MEDIA', dimension: 'JOHTO' },
      { id: 'JT_MAGN', name: 'Magnet Train Co.', ticker: 'UNP', displayTicker: 'MGTN', price: 245.0, sector: 'TRANSIT', dimension: 'JOHTO' },
      { id: 'JT_GDEP', name: 'Goldenrod Dept', ticker: 'TGT', displayTicker: 'GDEP', price: 145.0, sector: 'RETAIL', dimension: 'JOHTO' },
      { id: 'JT_PEN_WHIT', name: 'Whitney Normal Cap', ticker: 'WM', displayTicker: 'WHIT', price: 210.0, sector: 'PENNY', isPenny: true, dimension: 'JOHTO' },
    ],
    'HOENN': [
      { id: 'HN_DEVN', name: 'Devon Corp.', ticker: 'TSLA', displayTicker: 'DEVN', price: 250.0, sector: 'TECH', dimension: 'HOENN' },
      { id: 'HN_GMH0', name: 'Greater Mauville Holdings', ticker: 'BRK-B', displayTicker: 'GMVH', price: 450.0, sector: 'CONGLOMERATE', dimension: 'HOENN' },
      { id: 'HN_STRN', name: 'Stern Shipyard', ticker: 'HII', displayTicker: 'STRN', price: 260.0, sector: 'MARINE', dimension: 'HOENN' },
    ],
    'HISUI': [
      { id: 'HS_GINK', name: 'Ginkgo Merchant Guild', ticker: 'RIO', displayTicker: 'GINK', price: 65.0, sector: 'GUILD', dimension: 'HISUI', label: 'Guild Stake' },
      { id: 'HS_GALA', name: 'Galaxy Expedition Stakes', ticker: 'FCX', displayTicker: 'GALX', price: 48.0, sector: 'GUILD', dimension: 'HISUI', label: 'Merchant Token' },
    ],
    'LUMI_F': [
      { id: 'LZ_QUAS', name: 'Quasartico Inc.', ticker: 'NVDA', displayTicker: 'QUAS', price: 125.0, sector: 'FUTURE_REDEV', dimension: 'LUMI_F' },
      { id: 'LZ_HOLO', name: 'Holo Caster Network', ticker: 'META', displayTicker: 'HLOC', price: 495.0, sector: 'FUTURE_TECH', dimension: 'LUMI_F' },
    ]
  };

  return dimensionalAssets[region] || [];
}

// --- REAL-TIME MARKET BUFFER ---
const priceCache = {}; // ticker -> { price, timestamp }

async function fetchYahooPrice(ticker) {
  return new Promise((resolve) => {
    const url = `https://query1.finance.yahoo.com/v8/finance/chart/${ticker}?interval=1m&range=1d`;
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.chart?.result?.[0]) {
            const price = json.chart.result[0].meta.regularMarketPrice;
            if (typeof price === 'number') return resolve(price);
          }
          resolve(null);
        } catch (e) { resolve(null); }
      });
    }).on('error', () => resolve(null));
  });
}

async function fetchAlpacaPrice(ticker) {
  const keyId = process.env.APCA_API_KEY_ID;
  const secretKey = process.env.APCA_API_SECRET_KEY;
  if (!keyId || !secretKey || secretKey === 'MISSING_SECRET_KEY') return null;

  return new Promise((resolve) => {
    const url = `https://data.alpaca.markets/v2/stocks/trades/latest?symbols=${ticker}`;
    const options = {
      headers: {
        'APCA-API-KEY-ID': keyId,
        'APCA-API-SECRET-KEY': secretKey
      }
    };
    https.get(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.trades && json.trades[ticker]) {
            return resolve(json.trades[ticker].p);
          }
          resolve(null);
        } catch (e) { resolve(null); }
      });
    }).on('error', () => resolve(null));
  });
}

async function fetchCoinGeckoPrice(id) {
  // Map PRYG/Bitcoin specifically if needed
  const geckoId = id === 'BTC-USD' || id === 'PRYG' ? 'bitcoin' : id.toLowerCase();
  return new Promise((resolve) => {
    const url = `https://api.coingecko.com/api/v3/simple/price?ids=${geckoId}&vs_currencies=usd`;
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json[geckoId]) return resolve(json[geckoId].usd);
          resolve(null);
        } catch (e) { resolve(null); }
      });
    }).on('error', () => resolve(null));
  });
}

async function fetchYahooHistory(ticker) {
  if (!ticker) return [];
  return new Promise((resolve) => {
    // 1m interval, 1d range gives us enough for a 24h chart sparkline
    const url = `https://query1.finance.yahoo.com/v8/finance/chart/${ticker}?interval=1m&range=1d`;
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.chart?.result?.[0]) {
            const res = json.chart.result[0];
            const timestamps = res.timestamp;
            const quote = res.indicators.quote[0];
            const bars = timestamps.map((t, i) => ({
              t: new Date(t * 1000).toISOString(),
              o: quote.open[i] || quote.close[i],
              h: quote.high[i] || quote.close[i],
              l: quote.low[i] || quote.close[i],
              c: quote.close[i]
            })).filter(b => b.c !== null);
            return resolve(bars);
          }
          resolve([]);
        } catch (e) { resolve([]); }
      });
    }).on('error', () => resolve([]));
  });
}

async function fetchRealPrice(ticker, assetId) {
  if (!ticker && assetId !== 'PRYG') return null;
  
  // Use priceCache to reduce API hits (60s cache)
  const cacheKey = ticker || assetId;
  if (priceCache[cacheKey] && Date.now() - priceCache[cacheKey].timestamp < 60000) {
    return priceCache[cacheKey].price;
  }

  // 1. Try Yahoo Finance
  let price = await fetchYahooPrice(ticker);
  
  // 2. Try Alpaca Fallback
  if (!price && ticker) {
    log('system', `Yahoo failed for ${ticker}. Trying Alpaca...`);
    price = await fetchAlpacaPrice(ticker);
  }

  // 3. Try CoinGecko Fallback (Crypto)
  if (!price && (assetId === 'PRYG' || ticker?.includes('BTC'))) {
    log('system', `Yahoo/Alpaca failed for ${assetId}. Trying CoinGecko...`);
    price = await fetchCoinGeckoPrice(assetId === 'PRYG' ? 'bitcoin' : ticker);
  }

  if (price) {
    priceCache[cacheKey] = { price, timestamp: Date.now() };
    return price;
  }
  
  return null;
}

const PRICE_BUFFER_LIMIT = 1440; // 24 hours (1440 minutes) of 1m data
const marketHistory = {}; // stockId -> [{t, o, h, l, c}]

function getMockOHLC(basePrice, flux) {
  const o = basePrice * (1 + (Math.random() * 0.002 - 0.001));
  const c = basePrice * (1 + flux);
  const h = Math.max(o, c) * (1 + Math.random() * 0.005);
  const l = Math.min(o, c) * (1 - Math.random() * 0.005);
  return { o, h, l, c, t: new Date().toISOString() };
}

async function updateMarketBuffers() {
  const nasdaq = globalEconomy.nasdaqIndex || 16000;
  const btcRatio = (globalEconomy.bitcoinPrice || 60000) / 60000;

  // Update all dimension assets
  for (const regionId of Object.keys(REGIONS)) {
    const assets = getMarketAssetsByRegion(regionId, nasdaq, btcRatio);
    for (const asset of assets) {
      // Seed history if empty using 24h bar fetch
      if (!marketHistory[asset.id] || marketHistory[asset.id].length === 0) {
        log('system', `Seeding 24h Real Data for ${asset.id}...`);
        const history = await fetchYahooHistory(asset.ticker);
        if (history.length > 0) {
          marketHistory[asset.id] = history.slice(-PRICE_BUFFER_LIMIT);
        } else {
          marketHistory[asset.id] = [];
        }
      }
      
      const history = marketHistory[asset.id];
      let currentPrice = history.length > 0 ? history[history.length - 1].c : asset.price;
      
      if (asset.ticker || asset.id === 'PRYG') {
        const realPrice = await fetchRealPrice(asset.ticker, asset.id);
        if (realPrice) currentPrice = realPrice;
      }
      
      const flux = asset.flux || (Math.random() * 0.002 - 0.001); // Reduced flux for real-world parity
      const candle = getMockOHLC(currentPrice, flux);
      
      marketHistory[asset.id].push(candle);
      if (marketHistory[asset.id].length > PRICE_BUFFER_LIMIT) marketHistory[asset.id].shift();
    }
  }
}

// Update buffer every minute
setInterval(updateMarketBuffers, 60000);


// Wealth Ranking Cache
let wealthCache = [];
let lastWealthUpdate = 0;
const WEALTH_CACHE_TTL = 10 * 60 * 1000; // 10 minutes

app.get('/economy/market/dimensions', (req, res) => {
  res.json(Object.values(REGIONS));
});

app.get('/economy/market', (req, res) => {
  const { region = 'AEVORA' } = req.query;
  const nasdaq = globalEconomy.nasdaqIndex || 16000;
  const btcRatio = (globalEconomy.bitcoinPrice || 60000) / 60000;

  const assets = getMarketAssetsByRegion(region, nasdaq, btcRatio);

  // Attach latest candle data for sparklines
  const enrichedAssets = assets.map(asset => {
    const history = marketHistory[asset.id] || [];
    let currentPrice = asset.price;
    
    // PRYG (Bitcoin) Override for real-world direct sync
    if (asset.id === 'PRYG') {
      const btcHistory = marketHistory['PRYG'] || [];
      if (btcHistory.length > 0) {
        currentPrice = btcHistory[btcHistory.length - 1].c;
      }
    } else {
      currentPrice = history.length ? history[history.length - 1].c : asset.price;
    }

    // Strip real-world proxy ticker — send only the Pokémon-themed displayTicker
    const { ticker: _internal, displayTicker, ...publicAsset } = asset;
    return {
      ...publicAsset,
      ticker: displayTicker || asset.id,  // client sees only the fictional ticker
      history,
      currentPrice
    };
  });

  res.json(enrichedAssets);
});

// Return raw candle history for a specific asset (used by hero chart refresh)
app.get('/economy/market/history', (req, res) => {
  const { assetId } = req.query;
  if (!assetId) return res.status(400).json({ error: 'assetId required' });
  const history = marketHistory[assetId] || [];
  res.json(history);
});

app.post('/economy/market/buy', (req, res) => {
  if (!isMarketOpen()) {
    return res.status(403).json({ error: 'MARKET_CLOSED', message: 'Trading is currently restricted to Wall Street hours (9:30 AM - 4:00 PM ET).' });
  }

  const { username, assetId, shares, priceAtTrade, dimension = 'AEVORA' } = req.body;
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const shareCount = Number(shares);
  const tradePrice = Number(priceAtTrade);
  if (!assetId || !Number.isFinite(shareCount) || !Number.isFinite(tradePrice) || shareCount <= 0 || tradePrice <= 0) {
    return res.status(400).json({ error: 'Invalid trade parameters' });
  }

  const bank = loadBank(username);
  
  // Dimensional Link Tax: 5% for non-local trades
  const isForeign = dimension !== 'AEVORA';
  const dimTax = Math.floor(shareCount * tradePrice * 0.05);
  const totalCost = (shareCount * tradePrice) + dimTax;

  if (bank.balance < totalCost) {
    return res.status(400).json({ error: 'Insufficient funds (Base + 5% Link Tax)' });
  }

  // Update Bank Balance & Portfolio
  if (!bank.portfolio) bank.portfolio = [];

  const asset = bank.portfolio.find(a => a.id === assetId);
  if (asset) {
    asset.avgPrice = ((asset.avgPrice * asset.shares) + (shareCount * tradePrice)) / (asset.shares + shareCount);
    asset.shares += shareCount;
  } else {
    bank.portfolio.push({ id: assetId, shares: shareCount, avgPrice: tradePrice, dimension });
  }

  appendBankTransaction(bank, 'WITHDRAW_TRADE', -totalCost, `Bought ${shareCount} shares of ${assetId} ${isForeign ? '(Foreign)' : ''}`, 'checking');
  
  saveBank(username, bank);
  saveUser(user);
  
  log('system', `[TRADE] ${username} bought ${shareCount} shares of ${assetId} in ${dimension}. Cost: ${totalCost} PD.`);
  aiRuntime.onTradeExecuted({ username, action: 'buy', assetId, shares: shareCount, priceAtTrade: tradePrice });
  res.json({ success: true, newBalance: bank.balance, portfolio: bank.portfolio });
});

app.post('/economy/market/sell', (req, res) => {
  if (!isMarketOpen()) {
    return res.status(403).json({ error: 'MARKET_CLOSED', message: 'Trading is currently restricted to Wall Street hours (9:30 AM - 4:00 PM ET).' });
  }

  const { username, assetId, shares, priceAtTrade } = req.body;
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const shareCount = Number(shares);
  const tradePrice = Number(priceAtTrade);
  if (!assetId || !Number.isFinite(shareCount) || !Number.isFinite(tradePrice) || shareCount <= 0 || tradePrice <= 0) {
    return res.status(400).json({ error: 'Invalid trade parameters' });
  }

  const bank = loadBank(username);
  if (!bank.portfolio || bank.portfolio.length === 0) return res.status(400).json({ error: 'Empty portfolio' });

  const asset = bank.portfolio.find(a => a.id === assetId);
  if (!asset || asset.shares < shareCount) {
    return res.status(400).json({ error: 'Insufficient shares' });
  }

  const proceedsRaw = shareCount * tradePrice;
  const brokerageFee = Math.floor(proceedsRaw * 0.001); // 0.1% Brokerage Fee
  const proceeds = proceedsRaw - brokerageFee;

  asset.shares -= shareCount;

  if (asset.shares <= 0) {
    bank.portfolio = bank.portfolio.filter(a => a.id !== assetId);
  }

  appendBankTransaction(bank, 'DEPOSIT_TRADE', proceeds, `Sold ${shareCount} shares of ${assetId} (Fee: ${brokerageFee} PD)`, 'checking');

  saveBank(username, bank);
  saveUser(user);
  
  log('system', `[TRADE] ${username} sold ${shareCount} shares of ${assetId} at ${tradePrice} PD.`);
  aiRuntime.onTradeExecuted({ username, action: 'sell', assetId, shares: shareCount, priceAtTrade: tradePrice });
  res.json({ success: true, newBalance: bank.balance, portfolio: bank.portfolio });
});

app.get('/economy/news', (req, res) => {
  res.json(loadNews());
});

app.post('/admin/sync-news', (req, res) => {
  const { exec } = require('child_process');
  const scriptPath = path.join(__dirname, 'scripts/translate_news.py');

  // Tag for Mac App console routing
  log('system', 'ADMIN: Triggering News Sync Daemon...');

  exec(`python3 "${scriptPath}"`, (error, stdout, stderr) => {
    if (error) {
      log('error', `News Sync Failed: ${error.message}`);
      return res.status(500).json({ success: false, error: error.message });
    }
    log('system', 'News Sync Complete. Broadcasting to terminals.');
    res.json({ success: true, message: 'News synced successfully' });
  });
});

app.post('/social/marketplace/buy', (req, res) => {
  const { buyerUsername, sellerUsername, itemId, price } = req.body;

  const buyer = getUser(buyerUsername);
  const seller = getUser(sellerUsername);

  if (!buyer || !seller) return res.status(404).json({ error: 'User not found' });
  const purchasePrice = Number(price);
  if (!itemId || !Number.isFinite(purchasePrice) || purchasePrice <= 0) {
    return res.status(400).json({ error: 'Invalid marketplace purchase request' });
  }
  if (!seller.inventory || (seller.inventory[itemId] || 0) < 1) {
    return res.status(400).json({ error: 'Seller item unavailable' });
  }
  
  // Refactor: Use loadBank for buyer balance
  const buyerBank = loadBank(buyerUsername);
  if (buyerBank.balance < purchasePrice) return res.status(400).json({ error: 'Insufficient bank balance (Checking)' });

  // Calculate Tax (5%)
  const tax = Math.floor(purchasePrice * 0.05);
  const sellerProceeds = purchasePrice - tax;

  appendBankTransaction(buyerBank, 'MARKET_PURCHASE', -purchasePrice, `Purchased ${itemId} from ${sellerUsername}`, 'checking');
  
  // Note: For simplicity, seller proceeds go to their liquid pokedollars (Pocket Cash)
  // as per standard marketplace behavior unless they deposit it.
  seller.pokedollars += sellerProceeds;
  seller.inventory[itemId]--;
  if (seller.inventory[itemId] <= 0) delete seller.inventory[itemId];
  buyer.inventory = buyer.inventory || {};
  buyer.inventory[itemId] = (buyer.inventory[itemId] || 0) + 1;
  collectTax(tax);

  saveUser(buyer);
  saveUser(seller);
  saveBank(buyerUsername, buyerBank);

  log('social', `MARKETPLACE: ${buyerUsername} bought ${itemId} from ${sellerUsername} for ${purchasePrice} PD (Tax: ${tax})`);
  res.json({ success: true, newBalance: buyerBank.balance });
});

app.get('/economy/fortune-500', (req, res) => {
  const now = Date.now();
  if (now - lastWealthUpdate < WEALTH_CACHE_TTL && wealthCache.length > 0) {
    return res.json(wealthCache);
  }

  const rankings = globalUsers.map(user => {
    const bank = loadBank(user.username);
    const checking = bank.balance || 0;
    const savings = bank.savings || 0;
    const retirement = (bank.retirement?.roth || 0) + (bank.retirement?.k401 || 0);
    
    const portfolioValue = (bank.portfolio || []).reduce((acc, stock) => {
      const history = marketHistory[stock.id] || [];
      const latestPrice = history.length > 0 ? history[history.length - 1].c : 100;
      return acc + (stock.shares * latestPrice);
    }, 0);

    return {
      username: user.username,
      profileImageUrl: user.profileImageUrl,
      netWorth: checking + savings + retirement + portfolioValue,
      job: user.job?.title
    };
  }).sort((a, b) => b.netWorth - a.netWorth).slice(0, 500);

  wealthCache = rankings;
  lastWealthUpdate = now;
  res.json(rankings);
});

app.post('/economy/bank/transfer', (req, res) => {
  const { username, amount, direction } = req.body; // direction: 'vault_to_checking' or 'checking_to_vault'
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const bank = loadBank(username);
  const val = Math.abs(Number(amount));
  if (!Number.isFinite(val) || val <= 0) return res.status(400).json({ error: 'Invalid transfer amount' });

  if (direction === 'checking_to_vault') {
    if (bank.balance < val) return res.status(400).json({ error: 'Insufficient Checking funds' });
    appendBankTransaction(bank, 'TRANSFER', -val, 'Transfer to Savings Vault', 'checking');
    appendBankTransaction(bank, 'TRANSFER', val, 'Transfer from Checking', 'savings');
  } else if (direction === 'vault_to_checking') {
    if (bank.savings < val) return res.status(400).json({ error: 'Insufficient Savings funds' });
    appendBankTransaction(bank, 'TRANSFER', -val, 'Transfer to Checking Account', 'savings');
    appendBankTransaction(bank, 'TRANSFER', val, 'Transfer from Savings Vault', 'checking');
  } else {
    return res.status(400).json({ error: 'Invalid transfer direction' });
  }

  saveBank(username, bank);
  res.json({ success: true, balance: bank.balance, savings: bank.savings });
});

app.post('/economy/bank/retirement/contribute', (req, res) => {
  const { username, amount, type } = req.body; // type: 'k401' or 'roth'
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const bank = loadBank(username);
  const val = Math.abs(Number(amount));
  if (!Number.isFinite(val) || val <= 0) return res.status(400).json({ error: 'Invalid contribution amount' });
  if (bank.balance < val) return res.status(400).json({ error: 'Insufficient Checking funds' });

  const target = (type === 'roth') ? 'roth' : 'k401';
  appendBankTransaction(bank, 'CONTRIBUTION', -val, `Manual Contribution to ${target.toUpperCase()}`, 'checking');
  appendBankTransaction(bank, 'DEPOSIT', val, 'Retirement Contribution', target);
  
  // 6% Employer Match for 401(k)
  if (target === 'k401') {
    const match = Math.floor(val * 0.06);
    if (match > 0) {
      appendBankTransaction(bank, 'CONTRIBUTION', match, 'Employer Match (6%)', 'k401');
    }
  }

  saveBank(username, bank);
  res.json({ success: true, balance: bank.balance, savings: bank.savings, [target]: bank[target] || bank.retirement[target] });
});

app.post('/economy/bank/deposit', (req, res) => {
  const { username, amount } = req.body;
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const depositAmount = Number(amount);
  if (!Number.isFinite(depositAmount) || depositAmount <= 0) {
    return res.status(400).json({ error: 'Invalid deposit amount' });
  }
  
  if ((user.pokedollars || 0) < depositAmount) {
    return res.status(400).json({ error: 'Insufficient pocket cash' });
  }

  const bank = loadBank(username);
  
  // Withdraw from Wallet, Deposit to Checking
  user.pokedollars -= depositAmount;
  appendBankTransaction(bank, 'DEPOSIT', depositAmount, 'ATM Deposit from Wallet', 'checking');
  
  saveUser(user);
  saveBank(username, bank);

  res.json({ success: true, balance: bank.balance, wallet: user.pokedollars });
});

app.post('/economy/bank/withdraw', (req, res) => {
  const { username, amount } = req.body;
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const withdrawalAmount = Number(amount);
  if (!Number.isFinite(withdrawalAmount) || withdrawalAmount <= 0) {
    return res.status(400).json({ error: 'Invalid withdrawal amount' });
  }

  const bank = loadBank(username);
  if (bank.balance < withdrawalAmount) return res.status(400).json({ error: 'Insufficient bank balance' });

  // Move from bank balance (checking) to wallet (user object)
  appendBankTransaction(bank, 'WITHDRAW', -withdrawalAmount, 'ATM Withdrawal to Wallet', 'checking');
  user.pokedollars = (user.pokedollars || 0) + withdrawalAmount;
  
  saveUser(user);
  saveBank(username, bank);

  res.json({ success: true, balance: bank.balance, wallet: user.pokedollars });
});

// --- CAREER & EMPLOYMENT ENGINE ---

const JOBS = {
  'lead-debugger': { 
    id: 'lead-debugger',
    title: 'Lead Debugger', 
    dailySalary: 450, 
    match: 0.06, 
    description: 'Fix Unova Flux distortions and logic errors.',
    requirements: 'Level 5 Coder',
    sprite: 'clerk'
  },
  'lead-programmer': {
    id: 'lead-programmer',
    title: 'Lead Programmer', 
    dailySalary: 1200, 
    match: 0.06,
    description: 'Propose and implement high-fidelity architectural features.',
    requirements: 'Level 25 Coder',
    sprite: 'clerk'
  },
  'data-analyst': {
    id: 'data-analyst',
    title: 'Digital Data Analyst',
    dailySalary: 850,
    match: 0.06,
    description: 'Monitor Unova Flux and manage trade intelligence.',
    requirements: 'Market Tier 2',
    sprite: 'veteran'
  },
  'ceo': { 
    id: 'ceo',
    title: 'CEO of Silph Co.', 
    dailySalary: 2740, 
    match: 0.08, 
    sharesPerWeek: 50,
    description: 'Lead the corporate empire and oversee regional innovation.',
    requirements: 'Exclusive',
    sprite: 'businessman'
  }
};

app.get('/career/white-pages', (req, res) => {
  res.json(Object.values(JOBS));
});

app.post('/career/apply', (req, res) => {
  const { username, jobId } = req.body;
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const job = JOBS[jobId];
  if (!job) return res.status(400).json({ error: 'Invalid Job ID' });

  user.job = {
    title: job.title,
    lastSalaryDate: new Date().toISOString(),
    dailyOnlineTime: 0
  };
  saveUser(user);
  log('social', `CAREER: ${username} joined as ${job.title}`);
  res.json({ success: true, job: user.job });
});

async function processSalary(user) {
  if (!user.job || !user.job.title) return;

  const now = new Date();
  const lastPayoutStr = user.job.lastSalaryDate;
  const lastPayout = lastPayoutStr ? new Date(lastPayoutStr) : null;

  const jobConfig = Object.values(JOBS).find(j => j.title === user.job.title);
  if (!jobConfig) return;

  if (lastPayout) {
    const diffMs = now.getTime() - lastPayout.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    if (diffDays >= 1) {
      const dailySal = jobConfig.dailySalary;
      const totalPayout = diffDays * dailySal;

      // Matching Logic (6% or config)
      const matchRate = jobConfig.match || 0;
      const matchContribution = Math.floor(totalPayout * matchRate);

      // Log salary payment
      logBankTransaction(user.username, 'DEPOSIT', totalPayout, `Salary Payout (${diffDays} days)`, 'checking');

      // Log Match Contribution to 401k
      if (matchContribution > 0) {
        logBankTransaction(user.username, 'CONTRIBUTION', matchContribution, `Employer Match (6%)`, 'k401');
      }

      // CEO Weekly Stock Options
      if (jobConfig.title === 'CEO of Silph Co.' && jobConfig.sharesPerWeek) {
        const weeks = Math.floor(diffDays / 7);
        if (weeks >= 1) {
          const bank = loadBank(user.username);
          if (!bank.portfolio) bank.portfolio = [];
          const silphStock = bank.portfolio.find(s => s.id === 'SLPH');
          const totalShares = weeks * jobConfig.sharesPerWeek;
          if (silphStock) {
            silphStock.shares += totalShares;
          } else {
            bank.portfolio.push({ id: 'SLPH', name: 'Silph Co. (Global)', ticker: 'AAPL', shares: totalShares });
          }
          saveBank(user.username, bank);
          log('system', `[CEO_CATCHUP] Granted ${totalShares} SLPH shares to ${user.username} for ${weeks} weeks.`);
        }
      }

      user.job.lastSalaryDate = new Date(lastPayout.getTime() + (diffDays * 24 * 60 * 60 * 1000)).toISOString();
      saveUser(user, true);
    }
  } else {
    user.job.lastSalaryDate = now.toISOString();
    saveUser(user, true);
  }
}

app.post('/economy/claim-battle-reward', (req, res) => {
  const { username } = req.body;
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const now = new Date().toISOString().split('T')[0];
  if (!user.economy) user.economy = { dailyCPURewards: 0, lastRewardDate: '' };

  if (user.economy.lastRewardDate !== now) {
    user.economy.dailyCPURewards = 0;
    user.economy.lastRewardDate = now;
  }

  if (user.economy.dailyCPURewards >= 2) {
    return res.status(400).json({ error: 'Daily reward limit reached (2/2)' });
  }

  const reward = 200;
  // Use Transaction System
  logBankTransaction(username, 'DEPOSIT', reward, 'Battle Reward: CPU Challenge', 'checking');

  user.economy.dailyCPURewards += 1;
  saveUser(user);

  const bank = loadBank(username);
  res.json({ success: true, newBalance: bank.balance, count: user.economy.dailyCPURewards });
});

app.post('/career/sync-time', (req, res) => {
  const { username, minutes } = req.body;
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  if (!user.job) user.job = { dailyOnlineTime: 0 };
  user.job.dailyOnlineTime = (user.job.dailyOnlineTime || 0) + (minutes * 60 * 1000);

  processSalary(user).then(() => {
    res.json({ success: true, dailyOnlineTime: user.job.dailyOnlineTime });
  });
});

// CPU Battle Rewards Logic
app.post('/battle/cpu/reward', (req, res) => {
  const { username, won } = req.body;
  if (!won) return res.json({ success: true, reward: 0 });

  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const now = new Date().toISOString().split('T')[0];
  if (!user.economy) user.economy = { lastCpuRewardDate: null, dailyCpuRewards: 0 };

  if (user.economy.lastCpuRewardDate !== now) {
    user.economy.lastCpuRewardDate = now;
    user.economy.dailyCpuRewards = 0;
  }

  if (user.economy.dailyCpuRewards < 2) {
    const reward = 250;
    logBankTransaction(username, 'DEPOSIT', reward, 'Pokemon Battle vs CPU Win', 'checking');
    user.economy.dailyCpuRewards++;
    saveUser(user);

    return res.json({ success: true, reward, message: `Excellent battle! You've earned PD ${reward}.` });
  }

  res.json({ success: true, reward: 0, message: "You've reached your daily reward limit for CPU battles." });
});

app.get('/roster', (req, res) => {
  const { username } = req.query;
  const user = getUser(username);
  log('sync', `Roster fetched for ${username}. Count: ${user?.roster?.length || 0}`);
  res.json(user ? (user.roster || []) : []);
});

// Pokémon detail route consolidated below at line 694

app.post('/roster', (req, res) => {
  const { username, roster, updatedAt } = req.body;
  if (!Array.isArray(roster)) {
    return res.status(400).json({ error: 'Roster must be an array' });
  }

  const user = getUser(username);
  if (user) {
    // Sanitization: Purge malformed entries
    user.roster = (roster || []).filter(p => p.id && p.id.trim() !== '' && p.pokemonName !== null);

    // Conflict Detection: Reject if client data is older than server data
    if (updatedAt && user.updatedAt && new Date(updatedAt) < new Date(user.updatedAt)) {
      log('sync', `CONFLICT: ${username} attempted to save stale roster. Server: ${user.updatedAt}, Client: ${updatedAt}`);
      return res.status(409).json({
        error: 'Conflict',
        message: 'A newer version of your roster exists on the server.',
        serverUpdatedAt: user.updatedAt
      });
    }

    if (updatedAt) user.updatedAt = updatedAt; // Sync timestamp if provided
    saveUser(user, !!updatedAt);
    log('sync', `Roster updated for ${username}. Size: ${user.roster.length}`);
    return res.json({ status: 'success', size: user.roster.length, updatedAt: user.updatedAt });
  }

  return res.status(404).json({ error: 'User not found' });
});

app.post('/register', (req, res) => {
  const profile = req.body;

  if (getUser(profile.username)) {
    return res.status(400).json({ error: 'Username already taken' });
  }

  const newUser = {
    ...profile,
    displayName: profile.displayName || `${profile.firstName} ${profile.lastName}`,
    roster: [],
    wins: 0,
    pokedollars: 10000,
    createdAt: new Date().toISOString(),
    achievements: [],
    bank: { balance: 0, investments: [], retirement: { roth: 0, k401: 0 } },
    status: 'online',
    lastSeen: new Date().toISOString()
  };

  saveUser(newUser);

  console.log(`[AUTH] New user registered: ${profile.username}`);
  res.status(201).json(newUser);
});

app.post('/auth/request-reset', (req, res) => {
  const { username } = req.body;
  if (!username) return res.status(400).json({ error: 'Username required' });

  const user = getUser(username);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  // Create a system message for the admin (bn200n)
  const message = {
    id: Date.now().toString(),
    sender: `[GUEST] ${username}`,
    text: `PASSCODE RESET REQUEST: User "${username}" is requesting a passcode reset. Please review their status.`,
    timestamp: new Date().toISOString(),
    recipient: 'bn200n', // Direct to admin
    type: 'admin_reset',
    ip: req.ip || req.connection.remoteAddress
  };

  globalChat.push(message);
  console.log(`[AUTH] Passcode reset request received for: ${username}`);
  res.json({ success: true, message: 'Reset request sent to admin.' });
});

app.post('/login', (req, res) => {
  const { username, passcodeHash } = req.body;
  const user = getUser(username);

  if (user && user.passcodeHash === passcodeHash) {
    user.lastSeen = new Date().toISOString();
    saveUser(user);
    log('auth', `User logged in: ${username}`);
    return res.json(user);
  }

  res.status(401).json({ error: 'Invalid username or passcode' });
});

app.get('/pc', (req, res) => {
  const { username } = req.query;
  const user = getUser(username);
  console.log(`[SYNC] PC fetched for ${username}. Count: ${user?.pc?.length || 0}`);
  res.json(user ? (user.pc || []) : []);
});

app.post('/pc', (req, res) => {
  const { username, pc, updatedAt } = req.body;
  if (!Array.isArray(pc)) {
    return res.status(400).json({ error: 'PC Storage must be an array' });
  }

  const user = getUser(username);
  if (user) {
    // Sanitization: Purge malformed entries
    user.pc = (pc || []).filter(p => p.id && p.id.trim() !== '' && p.pokemonName !== null);

    if (updatedAt && user.updatedAt && new Date(updatedAt) < new Date(user.updatedAt)) {
      return res.status(409).json({ error: 'Conflict', serverUpdatedAt: user.updatedAt });
    }
    if (updatedAt) user.updatedAt = updatedAt;
    saveUser(user, !!updatedAt);
    log('sync', `PC updated for ${username}. Size: ${user.pc.length}`);
    return res.json({ status: 'success', size: user.pc.length, updatedAt: user.updatedAt });
  }

  return res.status(404).json({ error: 'User not found' });
});

app.get('/presets', (req, res) => {
  const { username } = req.query;
  const user = getUser(username);
  log('sync', `Presets fetched for ${username}. Count: ${user?.presets?.length || 0}`);
  res.json(user ? (user.presets || []) : []);
});

app.post('/presets', (req, res) => {
  const { username, presets, updatedAt } = req.body;
  if (!Array.isArray(presets)) {
    return res.status(400).json({ error: 'Presets must be an array' });
  }

  const user = getUser(username);
  if (user) {
    // Sanitization: Purge malformed entries in all slots
    user.presets = (presets || []).map(preset => ({
      ...preset,
      slots: (preset.slots || []).filter(p => p.id && p.id.trim() !== '' && p.pokemonName !== null)
    }));

    if (updatedAt && user.updatedAt && new Date(updatedAt) < new Date(user.updatedAt)) {
      return res.status(409).json({ error: 'Conflict', serverUpdatedAt: user.updatedAt });
    }
    if (updatedAt) user.updatedAt = updatedAt;
    saveUser(user, !!updatedAt);
    log('sync', `Presets updated for ${username}. Size: ${user.presets.length}`);
    return res.json({ status: 'success', size: user.presets.length, updatedAt: user.updatedAt });
  }

  return res.status(404).json({ error: 'User not found' });
});

app.post('/report', (req, res) => {
  const { username, displayName, platform, version, message } = req.body;

  const timestamp = new Date().toISOString();
  const reportPath = path.join(__dirname, 'user_reports.txt');

  const logEntry = `
==================================================
REPORT RECEIVED: ${timestamp}
--------------------------------------------------
USER:    ${displayName || 'Unknown'} (@${username || 'N/A'})
PLATFORM: ${platform || 'Unknown'} (v${version || 'N/A'})
MESSAGE:
${message}
==================================================
`;

  try {
    fs.appendFileSync(reportPath, logEntry);
    console.log(`[REPORT] Logged from ${username} (${platform})`);
    res.json({ status: 'success', message: 'Report saved to backend' });
  } catch (e) {
    console.error('[REPORT] Failed to save report:', e);
    res.status(500).json({ error: 'Failed to save report on server' });
  }
});

app.post('/analyze-team', (req, res) => {
  const { roster, opponentTeam, format = 'singles' } = req.body;

  if (!roster || roster.length === 0) {
    return res.status(400).json({ error: 'Roster is required for analysis' });
  }

  // Real Threat Analysis Logic
  const threats = [];
  const bestLead = roster[0] || { name: 'Starter', id: 'active', moves: ['STAB Move'] };
  const firstOpponent = (opponentTeam && opponentTeam.length > 0) ? opponentTeam[0] : { name: 'Opponent' };

  if (opponentTeam && opponentTeam.length > 0) {
    opponentTeam.forEach(opp => {
      roster.forEach(pos => {
        const eff = getEffectiveness(opp.type || 'normal', pos.types || ['normal']);
        if (eff > 1) {
          threats.push({
            pokemonName: opp.name || opp.pokemonId,
            threatLevel: eff === 4 ? 0.95 : 0.75,
            description: `${opp.name} has a major type advantage (${eff}x) over your ${pos.name}.`,
            countersFromRoster: roster.filter(p => getEffectiveness(p.types?.[0] || 'normal', [opp.type || 'normal']) > 1).map(p => p.id)
          });
        }
      });
    });
  }

  const response = {
    id: Date.now().toString(),
    timestamp: new Date().toISOString(),
    recommendedPicks: roster.slice(0, 6).map((pokemon) => pokemon.id),
    recommendedLeads: [bestLead.id || bestLead.pokemonId].filter(Boolean),
    moveRecommendations: [
      {
        sourcePokemonName: bestLead.name,
        targetPokemonName: firstOpponent.name || 'Opponent',
        moveName: bestLead.moves[0] || 'STAB Move',
        damageRange: '64-78%',
        reasoning: `Primary offensive pressure from ${bestLead.name} is key to winning the early game.`,
        isKoChance: false,
      },
    ],
    threats,
    matchupScore: 75 + Math.random() * 15,
    reasoning: `Analysis complete for ${format}. Your roster featuring ${bestLead.name} has a strong positional advantage. Dynamic lead adjustments recommended.`,
    format,
  };

  return res.json(response);
});

app.post('/best-lead', (req, res) => {
  const { roster } = req.body;
  res.json({
    primaryLeads: [roster[0]?.pokemonId, roster[1]?.pokemonId].filter(Boolean),
    backupLeads: [roster[2]?.pokemonId].filter(Boolean),
    reasoning: 'Optimal speed control and utility for this matchup.',
  });
});

app.post('/damage-range', (req, res) => {
  const { attacker, defender, move } = req.body;
  if (!attacker || !defender || !move) {
    return res.status(400).json({ error: 'Missing calculation parameters' });
  }
  const result = calculateDamage(attacker, defender, move);
  log('battle', `Damage Range Calc: ${attacker.name} vs ${defender.name} with ${move.name} -> ${result.min}-${result.max}`);
  res.json(result.rolls || []);
});

function recordBattleResult(winnerUsername, loserUsername, isTimeout = false) {
  const winner = getUser(winnerUsername);
  const loser = getUser(loserUsername);

  if (winner) {
    winner.wins = (winner.wins || 0) + 1;
    saveUser(winner);
  }
  if (loser) {
    loser.losses = (loser.losses || 0) + 1;
    if (isTimeout) {
      loser.inactiveMatches = (loser.inactiveMatches || 0) + 1;
    }
    saveUser(loser);
  }
  log('battle', `Result: ${winnerUsername} wins, ${loserUsername} loses${isTimeout ? ' (inactive timeout)' : ''}`);
}

// --- SOCIAL & ONLINE BATTLES ---

app.get('/social/users', (req, res) => {
  const now = Date.now();

  // Return all users from in-memory globalUsers cache
  const trainerList = globalUsers.map(u => {
    const isRecentlyActive = u.lastSeen && (now - new Date(u.lastSeen).getTime()) < 60000;

    // Find if user is in an active battle
    let currentBattleId = null;
    let actualStatus = u.status || 'online';

    for (const id in battleSessions) {
      const session = battleSessions[id];
      if (session.status === 'active' && (session.player1 === u.username || session.player2 === u.username)) {
        actualStatus = 'battling';
        currentBattleId = id;
        break;
      }
    }

    return {
      username: u.username,
      displayName: u.displayName,
      status: isRecentlyActive ? actualStatus : 'offline',
      currentBattleId,
      roster: u.roster || [],
      wins: u.wins || 0,
      losses: u.losses || 0,
      suspended: u.suspended || false
    };
  });

  res.json(trainerList);
});

app.get('/social/friends', (req, res) => {
  const { username } = req.query;
  if (!username) return res.status(400).json({ error: 'Username required' });

  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const friends = (user.friends || []).map(fUsername => {
    const fProfile = globalUsers.find(u => u.username === fUsername);
    if (!fProfile) return null;
    return {
      username: fProfile.username,
      displayName: fProfile.displayName,
      status: (Date.now() - new Date(fProfile.lastSeen).getTime() < 60000) ? fProfile.status : 'offline',
      roster: fProfile.roster || []
    };
  }).filter(Boolean);

  const pending = (user.pendingRequests || []).map(fUsername => {
    const fProfile = globalUsers.find(u => u.username === fUsername);
    return fProfile ? { username: fProfile.username, displayName: fProfile.displayName } : null;
  }).filter(Boolean);

  res.json({ friends, pending });
});

app.post('/social/friend-request', (req, res) => {
  const { sender, target } = req.body;
  const targetUser = getUser(target);

  if (!targetUser) return res.status(404).json({ error: 'Target user not found' });
  if (targetUser.username.toLowerCase() === sender.toLowerCase()) return res.status(400).json({ error: 'Cannot friend yourself' });

  targetUser.pendingRequests = targetUser.pendingRequests || [];
  if (!targetUser.pendingRequests.includes(sender)) {
    targetUser.pendingRequests.push(sender);
    saveUser(targetUser);
  }
  log('social', `Friend Request: ${sender} -> ${target}`);
  res.json({ success: true });
});

app.post('/social/friend-accept', (req, res) => {
  const { username, friendUsername } = req.body;
  // ... existing logic ...


  const user = getUser(username);
  const friend = getUser(friendUsername);

  if (!user || !friend) return res.status(404).json({ error: 'User not found' });

  user.pendingRequests = (user.pendingRequests || []).filter(u => u !== friendUsername);
  user.friends = user.friends || [];
  if (!user.friends.includes(friendUsername)) user.friends.push(friendUsername);

  friend.friends = friend.friends || [];
  if (!friend.friends.includes(username)) friend.friends.push(username);

  saveUser(user);
  saveUser(friend);
  res.json({ success: true });
});

app.get('/social/chat', (req, res) => {
  res.json(globalChat.slice(-50)); // Last 50 messages
});

app.post('/social/chat', (req, res) => {
  const ip = req.ip || req.connection.remoteAddress;
  if (bannedIPs.includes(ip)) {
    return res.status(403).json({ error: 'Your IP is banned' });
  }

  const { sender, text } = req.body;

  // Check if sender is suspended
  const user = getUser(sender);
  if (user && user.isSuspended) {
    return res.status(403).json({ error: 'Account suspended' });
  }

  const filteredText = filterCussWords(text);

  const message = {
    id: Date.now().toString(),
    sender,
    text: filteredText,
    timestamp: new Date().toISOString(),
    ip, // Track IP for admin panel
  };
  globalChat.push(message);
  res.json(message);
});

app.get('/social/broadcast', (req, res) => {
  res.json(globalBroadcast);
});

app.post('/social/broadcast', (req, res) => {
  const { text, sentBy } = req.body;
  if (!text) {
    globalBroadcast = null;
  } else {
    globalBroadcast = {
      text,
      sentAt: new Date().toISOString(),
      sentBy: sentBy || 'System'
    };
  }
  console.log(`[SOCIAL] Global Broadcast: ${text || 'CLEARED'}`);
  res.json({ success: true, broadcast: globalBroadcast });
});

// --- ADMIN ENDPOINTS ---

app.post('/admin/suspend', (req, res) => {
  const { username, suspended } = req.body;
  const user = getUser(username);
  if (user) {
    user.suspended = suspended;
    saveUser(user);
    console.log(`[ADMIN] User ${username} suspension set to: ${suspended}`);
    return res.json({ success: true, suspended });
  }
  res.status(404).json({ error: 'User not found' });
});

app.post('/admin/ban-ip', (req, res) => {
  const { ip } = req.body;
  if (ip && !bannedIPs.includes(ip)) {
    bannedIPs.push(ip);
    console.log(`[ADMIN] IP Banned: ${ip}`);
    return res.json({ success: true, bannedIPs });
  }
  res.json({ success: false, message: 'Invalid IP or already banned' });
});

app.delete('/admin/user/:username', (req, res) => {
  const { username } = req.params;
  const { confirmation } = req.body || {};

  const userPath = getUserPath(username);
  if (fs.existsSync(userPath)) {
    fs.unlinkSync(userPath);
    globalUsers = loadUsers(); // Full refresh needed on delete
    console.log(`[ADMIN] User file deleted: ${username}`);
    return res.json({ success: true });
  }
  res.status(404).json({ error: 'User not found' });
});

app.post('/social/challenge', (req, res) => {
  const { sender, target } = req.body;
  const senderUser = getUser(sender);
  const targetUser = getUser(target);

  if (!targetUser) return res.status(404).json({ error: 'Target user not found' });

  const battleId = `battle_${Date.now()}`;
  battleSessions[battleId] = {
    id: battleId,
    player1: sender,
    player2: target,
    status: 'pending',
    currentTurn: sender,
    turnCount: 0,
    history: [],
    hpState: {}, // username -> { pokemonId: currentHp }
    rosters: {
      [sender]: senderUser ? (senderUser.roster || []) : [],
      [target]: targetUser ? (targetUser.roster || []) : []
    },
    lastUpdate: new Date().toISOString(),
    turnStartedAt: new Date().toISOString(),
  };

  const tKey = target.toLowerCase();
  log('battle', `Battle Challenge: ${sender} -> ${target} (ID: ${battleId})`);
  if (!pendingChallenges[tKey]) pendingChallenges[tKey] = [];
  res.json({ battleId });
});

app.get('/social/challenges/pending', (req, res) => {
  const { username } = req.query;
  if (!username) return res.json([]);

  const now = Date.now();
  const uKey = username.toLowerCase();

  if (pendingChallenges[uKey]) {
    pendingChallenges[uKey] = pendingChallenges[uKey].filter(c => c.expires > now);
  }
  res.json(pendingChallenges[uKey] || []);
});

app.post('/social/challenges/accept', (req, res) => {
  const { username, battleId } = req.body;
  const session = battleSessions[battleId];
  if (session) {
    session.status = 'active';
  }

  const uKey = username ? username.toLowerCase() : null;
  if (uKey && pendingChallenges[uKey]) {
    pendingChallenges[uKey] = pendingChallenges[uKey].filter(c => c.battleId !== battleId);
  }
  console.log(`[SOCIAL] Challenge Accepted by ${username} for session ${battleId}`);
  res.json({ success: true });
});



// ── Gift System ───────────────────────────────────────────────────────────────

function generateId() {
  return `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`; // standards-ignore: purely for unique ID generation
}

function handleSocialSend(payload, res) {
  const { from, fromDisplay, to, subject, body, attachment } = payload;
  const sender = getUser(from);
  const recipient = getUser(to);

  if (!sender || !recipient) return res.status(404).json({ error: 'User not found' });

  if (attachment) {
    if (attachment.type === 'pokedollars') {
      const amount = Number(attachment.value);
      if (!Number.isFinite(amount) || amount <= 0) {
        return res.status(400).json({ error: 'Invalid attachment value' });
      }
      if (from !== 'bn200n') {
        return res.status(403).json({ error: 'FORBIDDEN_TRANSACTION', message: 'Corporate Policy: Peer-to-Peer Poké Dollar transfers via mail are restricted to Executive accounts.' });
      }
      if ((sender.pokedollars || 0) < amount) {
        return res.status(400).json({ error: 'Insufficient funds for attachment' });
      }

      sender.pokedollars -= amount;
      const recipientBank = loadBank(to);
      appendBankTransaction(recipientBank, 'MAIL_GRANT', amount, `Mail grant from ${from}`, 'checking');
      saveBank(to, recipientBank);
      log('social', `Admin Grant: ${from} sent ${amount} PD to ${to}`);
    } else if (attachment.type === 'item') {
      const itemKey = attachment.value;
      const qty = Number(attachment.quantity || 1);
      if (!itemKey || !Number.isFinite(qty) || qty <= 0) {
        return res.status(400).json({ error: 'Invalid item attachment' });
      }

      if (!sender.inventory || (sender.inventory[itemKey] || 0) < qty) {
        return res.status(400).json({ error: 'Insufficient items for attachment' });
      }

      const shippingWeights = {
        'potion': 50, 'super-potion': 100, 'hyper-potion': 200, 'max-potion': 350,
        'revive': 500, 'max-revive': 1000,
        'pokeball': 100, 'greatball': 200, 'ultraball': 500, 'masterball': 5000,
        'rare-candy': 1500, 'pp-up': 2000, 'pp-max': 5000,
        'ability-patch': 10000, 'ability-capsule': 5000
      };

      const baseFee = shippingWeights[itemKey] || 250;
      const totalShipping = baseFee * qty;
      const taxRate = globalEconomy.taxRate || 0.05;
      const totalLogisticsCost = totalShipping + (totalShipping * taxRate);

      if (from !== 'bn200n') {
        if ((sender.pokedollars || 0) < totalLogisticsCost) {
          return res.status(400).json({
            error: 'INSUFFICIENT_LOGISTICS_FUNDS',
            message: `Mailing this item requires ${totalLogisticsCost.toFixed(2)} PD for shipping and dimensional tax.`
          });
        }
        sender.pokedollars -= totalLogisticsCost;

        const adminBank = loadBank('bn200n');
        appendBankTransaction(adminBank, 'MAIL_LOGISTICS', totalLogisticsCost, `Logistics revenue from ${from} (${itemKey})`, 'checking');
        saveBank('bn200n', adminBank);
        log('social', `Logistics Revenue: ${totalLogisticsCost.toFixed(2)} PD collected from ${from} for ${itemKey} delivery.`);
      }

      sender.inventory[itemKey] -= qty;
      if (sender.inventory[itemKey] <= 0) delete sender.inventory[itemKey];
      if (!recipient.inventory) recipient.inventory = {};
      recipient.inventory[itemKey] = (recipient.inventory[itemKey] || 0) + qty;
      log('social', `Mail Attachment: ${from} sent ${qty}x ${itemKey} to ${to}`);
    }
  }

  const message = {
    id: `msg_${Date.now()}`,
    from: sender.username,
    fromDisplay: fromDisplay || sender.displayName,
    subject: subject || '(No Subject)',
    body: body || '',
    sentAt: new Date().toISOString(),
    read: false,
    attachment: attachment || null
  };

  if (!recipient.inbox) recipient.inbox = [];
  recipient.inbox.unshift(message);
  if (recipient.inbox.length > 50) recipient.inbox = recipient.inbox.slice(0, 50);

  saveUser(sender);
  saveUser(recipient);
  return res.json({ success: true });
}

app.post('/social/gift/send', (req, res) => {
  const { senderUsername, senderDisplayName, recipientUsername, itemId, quantity, message } = req.body;

  return handleSocialSend({
    from: senderUsername,
    fromDisplay: senderDisplayName || senderUsername,
    to: recipientUsername,
    subject: `GIFT_DELIVERY: ${String(itemId || '').toUpperCase()}`,
    body: message || 'You have received a regional gift grant.',
    attachment: {
      type: 'item',
      value: itemId,
      quantity: parseInt(quantity, 10) || 1
    }
  }, res);
});

app.get('/social/inbox', (req, res) => {
  const { username } = req.query;
  const user = getUser(username);
  if (!user) return res.json([]);
  // Return inbox combined with any unread official messages
  res.json(user.inbox || []);
});

app.post('/social/read', (req, res) => {
  const { username, messageId } = req.body;
  const user = getUser(username);
  if (!user || !user.inbox) return res.status(404).json({ error: 'User or inbox not found' });

  const msg = user.inbox.find(m => m.id === messageId);
  if (msg) {
    msg.read = true;
    saveUser(user);
  }
  res.json({ success: true });
});

app.post('/social/claim', (req, res) => {
  const { username, messageId } = req.body;
  const user = getUser(username);
  if (!user || !user.inbox) return res.status(404).json({ error: 'User not found' });

  const msg = user.inbox.find(m => m.id === messageId);
  if (!msg || !msg.attachment) return res.status(404).json({ error: 'Attachment not found' });
  if (msg.attachment.claimed) return res.status(400).json({ error: 'ALREADY_CLAIMED' });

  // Process Claim
  const att = msg.attachment;
  if (att.type === 'pokedollars') {
    const bank = loadBank(username);
    const amount = Number(att.value || 0);
    appendBankTransaction(bank, 'MAIL_CLAIM', amount, `Claimed ${amount} PD from mail`, 'checking');
    saveBank(username, bank);
  } else if (att.type === 'item') {
    if (!user.inventory) user.inventory = {};
    user.inventory[att.value] = (user.inventory[att.value] || 0) + (att.quantity || 1);
  }

  msg.attachment.claimed = true;
  saveUser(user);

  log('social', `Claim Success: ${username} claimed ${att.type === 'item' ? att.value : att.value + ' PD'}`);
  res.json({ success: true, message: 'CORPORATE_ASSETS_RECOVERED' });
});

app.post('/social/archive', (req, res) => {
  const { username, messageId } = req.body;
  const user = getUser(username);
  if (!user || !user.inbox) return res.status(404).json({ error: 'User not found' });

  const msgIndex = user.inbox.findIndex(m => m.id === messageId);
  if (msgIndex !== -1) {
    if (!user.archive) user.archive = [];
    const [msg] = user.inbox.splice(msgIndex, 1);
    user.archive.unshift(msg);
    saveUser(user);
  }
  res.json({ success: true });
});

app.post('/social/send', (req, res) => {
  return handleSocialSend(req.body, res);
});

app.get('/social/gifts/pending', (req, res) => {
  const { username } = req.query;
  if (!username) return res.status(400).json({ error: 'username required' });

  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const pending = (user.pendingGifts || []).filter(g => g.status === 'pending');
  res.json({ gifts: pending });
});

app.post('/social/gifts/accept', (req, res) => {
  const { username, giftId } = req.body;
  if (!username || !giftId) return res.status(400).json({ error: 'username and giftId required' });

  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  if (!Array.isArray(user.pendingGifts)) return res.status(404).json({ error: 'Gift not found' });

  const idx = user.pendingGifts.findIndex(g => g.id === giftId && g.status === 'pending');
  if (idx === -1) return res.status(404).json({ error: 'Gift not found or already claimed' });

  const gift = user.pendingGifts[idx];
  gift.status = 'accepted';

  // Credit inventory
  if (!user.inventory) user.inventory = {};
  user.inventory[gift.itemId] = (user.inventory[gift.itemId] || 0) + gift.quantity;

  saveUser(user);
  console.log(`[GIFT] ${username} claimed ${gift.quantity}x ${gift.itemId} from ${gift.senderUsername}`);
  res.json({ success: true, itemId: gift.itemId, quantity: gift.quantity });
});

app.get('/pokemon/:id', async (req, res) => {
  const { id } = req.params;
  const normalizedId = id.toString().toLowerCase().replace(/[^a-z0-9-]/g, '');

  // 1. Check Cache
  if (pokemonCache[normalizedId]) {
    return res.json(pokemonCache[normalizedId]);
  }

  // 2. Try Local Showdown Data for speed (if it exists)
  const showdownId = normalizedId.replace(/-/g, '');
  if (showdownPokedex && showdownPokedex[showdownId]) {
    const pokemon = showdownPokedex[showdownId];
    // Map minimal data to PokeAPI format if possible
    // (But PokeAPI is still preferred for full move sets and official stats)
    console.log(`[PROXY] Partial match for ${id} in Showdown data.`);
  }

  // 3. Official PokeAPI Fetch
  console.log(`[PROXY] Fetching Pokemon ${id} from PokeAPI...`);
  try {
    const data = await fetchFromPokeAPI(id);

    // Safety check for critical fields
    if (!data.name || !data.stats) {
      throw new Error('Malformed data from PokeAPI');
    }

    pokemonCache[normalizedId] = data;

    // Async save to file to avoid blocking
    fs.writeFile(POKEMON_CACHE_FILE, JSON.stringify(pokemonCache), (err) => {
      if (err) console.error('[PROXY] Cache save error:', err);
    });

    res.json(data);
  } catch (e) {
    console.error(`[PROXY] Failed to fetch Pokemon ${id}:`, e.message);
    res.status(500).json({ error: 'Failed to fetch Pokemon data', details: e.message });
  }
});

app.get('/battle/:id/status', (req, res) => {
  const session = battleSessions[req.params.id];
  if (!session) return res.status(404).json({ error: 'Battle not found' });
  res.json(session);
});

app.post('/battle/:id/move', (req, res) => {
  const { username, action, results } = req.body;
  const session = battleSessions[req.params.id];
  if (!session) return res.status(404).json({ error: 'Battle not found' });

  session.history.push({
    turn: session.turnCount,
    username,
    action,
    results,
    timestamp: new Date().toISOString(),
  });

  session.turnCount += 1;
  session.currentTurn = (session.player1 === username) ? session.player2 : session.player1;
  session.lastMove = action;
  session.lastUpdate = new Date().toISOString();
  session.turnStartedAt = session.lastUpdate;

  // Persistence Log
  logBattleEvent(req.params.id, {
    turn: session.turnCount,
    username,
    action,
    results,
    hpState: session.hpState
  });

  // Authoritative HP Update
  if (results && results.type === 'attack') {
    const targetUsername = session.player1 === username ? session.player2 : session.player1;
    if (!session.hpState[targetUsername]) session.hpState[targetUsername] = {};

    // We trust the client for now but store it as the 'truth' for the other player's poll
    const pokemonId = results.targetPokemonId || 'active';
    session.hpState[targetUsername][pokemonId] = results.newHp;
  } else if (results && results.type === 'swap') {
    // No HP change on swap usually, but could be used to sync current hp of arriving pokemon
  }

  if (results && results.isFinished) {
    session.status = 'finished';
    const loser = session.player1 === username ? session.player2 : session.player1;
    recordBattleResult(username, loser, false);
  }

  // --- PERSISTENT LOGGING ---
  try {
    const logDir = path.join(__dirname, 'data/logs/battles');
    if (!fs.existsSync(logDir)) fs.mkdirSync(logDir, { recursive: true });

    const logPath = path.join(logDir, `${req.params.id}.log`);
    const logEntry = `[${new Date().toISOString()}] ${username}: ${action.type}${action.move ? ' (' + action.move + ')' : ''}${action.pokemonId ? ' (to #' + action.pokemonId + ')' : ''} | Result: ${JSON.stringify(results)}\n`;
    fs.appendFileSync(logPath, logEntry);
  } catch (e) {
    console.error(`[LOG] Failed to write battle log for ${req.params.id}:`, e);
  }

  res.json({ status: 'success', turnCount: session.turnCount });
});

// Check every 15 s for players who have not moved within 90 seconds
setInterval(() => {
  const now = Date.now();
  for (const id in battleSessions) {
    const s = battleSessions[id];
    if (s.status !== 'active' || !s.turnStartedAt) continue;
    const elapsed = now - new Date(s.turnStartedAt).getTime();
    if (elapsed > 90000) {
      const loser = s.currentTurn;
      const winner = s.player1 === loser ? s.player2 : s.player1;
      s.status = 'finished';
      s.currentTurn = winner;
      s.timedOut = true;
      s.lastUpdate = new Date().toISOString();
      recordBattleResult(winner, loser, true);
      console.log(`[TIMEOUT] ${loser} timed out in battle ${id}. ${winner} wins.`);
    }
  }
}, 15000);

// Update user status & migrate legacy users
app.post('/social/status', (req, res) => {
  const { username, status, displayName, roster, inventory, wins } = req.body;
  const user = getUser(username);

  if (user) {
    // 1. Existing persistent user - Update transient state
    user.status = status;
    user.lastSeen = new Date().toISOString();
    if (displayName) user.displayName = displayName;
    if (roster) user.roster = roster;
    if (inventory) user.inventory = inventory;
    if (wins !== undefined) user.wins = wins;
    if (req.body.forcePasscodeChange !== undefined) user.forcePasscodeChange = req.body.forcePasscodeChange;

    saveUser(user);
  } else {
    // 2. New or Legacy user detected - Auto-migrate to persistent store
    const newUser = {
      username,
      displayName: displayName || username,
      firstName: displayName ? displayName.split(' ')[0] : 'Legendary',
      lastName: displayName && displayName.includes(' ') ? displayName.split(' ').slice(1).join(' ') : 'Trainer',
      passcodeHash: 'legacy_account', // Mark for password setup
      status,
      lastSeen: new Date().toISOString(),
      roster: roster || [],
      wins: 0,
      friends: [],
      pendingRequests: [],
      legacyMigrated: true,
    };
    saveUser(newUser);
    console.log(`[MIGRATE] Auto-migrated active user to persistent store: ${username}`);
  }

  res.json({ success: true });
});

// --- ADMIN ENDPOINTS ---

app.get('/admin/broadcast', (req, res) => {
  res.json(globalBroadcast);
});

app.post('/admin/broadcast', (req, res) => {
  const { text, sentBy } = req.body;
  if (!text || !text.trim()) {
    globalBroadcast = null;
  } else {
    globalBroadcast = { text: text.trim(), sentAt: new Date().toISOString(), sentBy: sentBy || 'admin' };
  }
  res.json(globalBroadcast);
});

app.delete('/admin/broadcast', (req, res) => {
  globalBroadcast = null;
  res.json({ success: true });
});

app.post('/admin/ban', (req, res) => {
  const { username } = req.body;
  const user = getUser(username);
  if (user) {
    user.banned = true;
    saveUser(user);
    console.log(`[ADMIN] User ${username} banned`);
    return res.json({ success: true });
  }
  res.status(404).json({ error: 'User not found' });
});

app.get('/admin/telemetry/battles', (req, res) => {
  res.json(Object.entries(battleTelemetry).map(([id, data]) => ({
    id,
    ...data
  })));
});

app.post('/admin/telemetry/battle', (req, res) => {
  const { battleId, playerInfo, opponentInfo, log, status } = req.body;
  if (!battleId) return res.status(400).json({ error: 'Missing battleId' });
  battleTelemetry[battleId] = {
    lastUpdate: new Date().toISOString(),
    playerInfo,
    opponentInfo,
    log: log || [],
    status: status || 'active'
  };
  const now = Date.now();
  Object.keys(battleTelemetry).forEach(id => {
    if (now - new Date(battleTelemetry[id].lastUpdate).getTime() > 3600000) {
      delete battleTelemetry[id];
    }
  });
  res.json({ success: true });
});

// ── User Profile (read-only, no passcode needed) ─────────────────────────────
app.get('/profile/:username', (req, res) => {
  const user = getUser(req.params.username);
  if (!user) return res.status(404).json({ error: 'User not found' });
  const { passcodeHash, ...safe } = user;
  res.json(safe);
});

// ── Bank Data for a user ──────────────────────────────────────────────────────
app.get('/economy/bank/:username', (req, res) => {
  const user = getUser(req.params.username);
  if (!user) return res.status(404).json({ error: 'User not found' });
  const bank = loadBank(req.params.username);
  res.json({
    username: user.username,
    displayName: user.displayName,
    pokedollars: user.pokedollars || 0,
    job: user.job || null,
    ...bank,
  });
});

app.get('/news', (req, res) => {
  const newsPath = path.join(__dirname, 'data/news.json');
  if (fs.existsSync(newsPath)) {
    try {
      return res.json(JSON.parse(fs.readFileSync(newsPath, 'utf8')));
    } catch (e) {
      console.error('[NEWS] Error parsing news file:', e);
    }
  }
  res.json({
    changelog: { version: 'v1.0.9', title: 'Initial Release', items: ['Stage 1 Testing Complete'], date: 'Apr 2026' },
    upcoming: [],
    features: ['Battle Telemetry', 'Admin News Feed'],
    status: 'Operational'
  });
});

app.post('/news', (req, res) => {
  const newsPath = path.join(__dirname, 'data/news.json');
  if (!fs.existsSync(path.dirname(newsPath))) fs.mkdirSync(path.dirname(newsPath), { recursive: true });

  const newsData = req.body;
  newsData.lastUpdated = new Date().toISOString();

  fs.writeFileSync(newsPath, JSON.stringify(newsData, null, 2));

  // Archive with timestamp
  archiveNews(newsData);

  log('system', 'News updated and archived.');
  res.json({ success: true });
});

app.post('/broadcast-news', (req, res) => {
  const { message, sender } = req.body;
  globalBroadcast = {
    type: 'news',
    text: message,
    sentAt: new Date().toISOString(),
    sentBy: sender || 'ADMIN'
  };
  res.json({ success: true, broadcast: globalBroadcast });
});

// --- OST LIBRARY API ---
app.get('/api/ost-library', (req, res) => {
  const OST_DIR = '/Users/bennahalewski/Documents/PokeRoster/Pokemon Generations Official SoundTrack';
  const library = {};

  if (!fs.existsSync(OST_DIR)) return res.json(library);

  const albums = fs.readdirSync(OST_DIR).filter(f => fs.statSync(path.join(OST_DIR, f)).isDirectory());

  for (const album of albums) {
    const albumPath = path.join(OST_DIR, album);
    const tracks = fs.readdirSync(albumPath)
      .filter(f => f.endsWith('.mp3'))
      .map(f => ({
        title: f.replace(/\.mp3$/, '').replace(/_/g, ' '),
        filename: f,
        url: `/assets/ost/${encodeURIComponent(album)}/${encodeURIComponent(f)}`
      }));
    if (tracks.length > 0) {
      library[album] = tracks;
    }
  }

  res.json(library);
});

app.get('/admin/battles/live', (req, res) => {
  const live = Object.values(battleSessions)
    .filter(s => s.status === 'active')
    .map(s => {
      const p1Active = Object.keys(s.hpState[s.player1] || {}).find(k => k !== 'active') || 'unknown';
      const p2Active = Object.keys(s.hpState[s.player2] || {}).find(k => k !== 'active') || 'unknown';

      return {
        id: s.id,
        player1: s.player1,
        player2: s.player2,
        turnCount: s.turnCount,
        lastUpdate: s.lastUpdate,
        active1: s.active1 || p1Active,
        active2: s.active2 || p2Active,
        hp1: s.hpState[s.player1] ? (s.hpState[s.player1][s.active1 || p1Active] || 100) : 100,
        hp2: s.hpState[s.player2] ? (s.hpState[s.player2][s.active2 || p2Active] || 100) : 100,
      };
    });
  res.json(live);
});

app.get('/admin/battle/:id/log', (req, res) => {
  const logPath = path.join(__dirname, 'data/logs/battles', `${req.params.id}.log`);
  if (fs.existsSync(logPath)) {
    const content = fs.readFileSync(logPath, 'utf8');
    res.json({ log: content });
  } else {
    // If no file yet, return in-memory history
    const session = battleSessions[req.params.id];
    if (session) {
      const historyLog = session.history.map(h =>
        `[${h.timestamp}] ${h.username}: ${h.action.type} | ${JSON.stringify(h.results)}`
      ).join('\n');
      res.json({ log: historyLog });
    } else {
      res.status(404).json({ error: 'Log not found' });
    }
  }
});

app.get('/admin/user/:username/full', (req, res) => {
  const user = getUser(req.params.username);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

app.post('/admin/user/:username/update', (req, res) => {
  const { userData } = req.body;
  const user = getUser(req.params.username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  // Merge or overwrite safe administrative fields
  const updatedUser = { ...user, ...userData, username: user.username };
  saveUser(updatedUser);
  console.log(`[ADMIN] Manually updated player profile: ${user.username}`);
  res.json({ success: true, user: updatedUser });
});

app.post('/api/user/profile/card', (req, res) => {
  const { username, cardCustomization } = req.body;
  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  user.cardCustomization = cardCustomization;
  saveUser(user);
  res.json({ success: true, cardCustomization });
});

// --- REPLAY CLEANUP (7 DAY TTL) ---
function cleanupReplays() {
  const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000;
  const now = Date.now();

  try {
    const files = fs.readdirSync(REPLAYS_DIR);
    let deletedCount = 0;

    files.forEach(file => {
      const filePath = path.join(REPLAYS_DIR, file);
      const stats = fs.statSync(filePath);
      if (now - stats.mtimeMs > SEVEN_DAYS_MS) {
        fs.unlinkSync(filePath);
        deletedCount++;
      }
    });

    if (deletedCount > 0) {
      log('system', `Cleanup: Deleted ${deletedCount} replays older than 7 days.`);
    }
  } catch (e) {
    log('error', `Replay cleanup failed: ${e.message}`);
  }
}

// Run cleanup on startup and every 24 hours
cleanupReplays();
setInterval(cleanupReplays, 24 * 60 * 60 * 1000);

// ── Story Mode Votes ─────────────────────────────────────────────────────────
const VOTES_DIR = path.join(__dirname, 'VOTES');
const STORY_MODE_VOTE_LOG = path.join(VOTES_DIR, 'StoryModeVoteslogfile.txt');
if (!fs.existsSync(VOTES_DIR)) fs.mkdirSync(VOTES_DIR, { recursive: true });

app.get('/story-mode/votes', (req, res) => {
  let coop = 0, mmo = 0;
  if (fs.existsSync(STORY_MODE_VOTE_LOG)) {
    const lines = fs.readFileSync(STORY_MODE_VOTE_LOG, 'utf-8').split('\n').filter(Boolean);
    for (const line of lines) {
      if (line.includes('vote=coop')) coop++;
      else if (line.includes('vote=mmo')) mmo++;
    }
  }
  res.json({ coop, mmo });
});

app.post('/story-mode/vote', (req, res) => {
  const { vote, username } = req.body;
  if (!['coop', 'mmo'].includes(vote)) return res.status(400).json({ error: 'Invalid vote' });

  const timestamp = new Date().toISOString();
  const entry = `[${timestamp}] username=${username || 'anonymous'} vote=${vote}\n`;
  fs.appendFileSync(STORY_MODE_VOTE_LOG, entry);
  console.log(`[STORY-MODE] ${username} voted ${vote}`);

  let coop = 0, mmo = 0;
  const lines = fs.readFileSync(STORY_MODE_VOTE_LOG, 'utf-8').split('\n').filter(Boolean);
  for (const line of lines) {
    if (line.includes('vote=coop')) coop++;
    else if (line.includes('vote=mmo')) mmo++;
  }
  res.json({ success: true, coop, mmo });
});

// ── MusicS Telemetry (Real-time) ─────────────────────────────────────────────
const liveMusicStatus = new Map(); // username -> { song, album, isPlaying, timestamp }
const musicHistory = []; // { song, timestamp } for aggregation

app.post('/api/music/status', (req, res) => {
  const { username, song, album, isPlaying } = req.body;
  if (!username) return res.status(400).json({ error: 'Username required' });

  liveMusicStatus.set(username, {
    song: song || 'Silence',
    album: album || 'Unknown',
    isPlaying: isPlaying ?? false,
    timestamp: new Date().toISOString()
  });

  if (isPlaying && song) {
    musicHistory.push({ song, timestamp: new Date() });
    // Keep history at 1000 items
    if (musicHistory.length > 1000) musicHistory.shift();
  }

  res.json({ success: true });
});

app.get('/admin/music/status', (req, res) => {
  // 1. Current Listeners
  const listeners = [];
  const now = new Date();
  liveMusicStatus.forEach((data, username) => {
    const lastUpdate = new Date(data.timestamp);
    // Only count as active if updated in the last 10 minutes
    if (now - lastUpdate < 10 * 60 * 1000) {
      listeners.push({ user: username, ...data });
    }
  });

  // 2. Global Stats
  const topTracksMap = {};
  musicHistory.forEach(h => {
    topTracksMap[h.song] = (topTracksMap[h.song] || 0) + 1;
  });

  const sortedTracks = Object.entries(topTracksMap)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([title, count]) => ({ title, count: count.toString() }));

  res.json({
    listeners,
    stats: {
      activeConnections: listeners.length.toString(),
      totalPlays24h: musicHistory.length.toString(),
      avgListenTime: 'Calculating...'
    },
    topTracks: sortedTracks
  });
});

app.post('/api/replays', upload.single('replay'), (req, res) => {
  const { username, battleId, winner } = req.body;
  if (!username || !req.file) return res.status(400).json({ error: 'Missing replay data' });

  const user = getUser(username);
  if (!user) return res.status(404).json({ error: 'User not found' });

  const replayMetadata = {
    id: path.basename(req.file.path),
    battleId: battleId || 'unknown',
    winner: winner || 'none',
    timestamp: new Date().toISOString(),
    filename: req.file.filename
  };

  // Manage 10-replay limit (FIFO)
  if (!user.recentReplays) user.recentReplays = [];
  user.recentReplays.unshift(replayMetadata);

  if (user.recentReplays.length > 10) {
    const oldest = user.recentReplays.pop();
    const oldestPath = path.join(REPLAYS_DIR, oldest.filename);
    if (fs.existsSync(oldestPath)) fs.unlinkSync(oldestPath);
    log('system', `Deleted oldest replay for user ${username}: ${oldest.filename}`);
  }

  saveUser(user);
  log('battle', `Replay saved for ${username}: ${battleId}`);
  res.json({ success: true, replay: replayMetadata });
});

app.get('/api/replays/:username', (req, res) => {
  const user = getUser(req.params.username);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user.recentReplays || []);
});

app.get('/api/replay/file/:filename', (req, res) => {
  const filePath = path.join(REPLAYS_DIR, req.params.filename);
  if (fs.existsSync(filePath)) {
    res.sendFile(filePath);
  } else {
    res.status(404).json({ error: 'Replay file not found' });
  }
});

const localIp = getLocalIP();
app.listen(port, '0.0.0.0', () => {
  console.log(`
    Pokemon Generations Backend is live
    --------------------------------------
    Local:   http://localhost:${port}
    Network: http://${localIp}:${port}
    APK Dir: ${APK_OUTPUT_DIR}
    Update:  http://${localIp}:${port}/app-update
    --------------------------------------
  `);
});
