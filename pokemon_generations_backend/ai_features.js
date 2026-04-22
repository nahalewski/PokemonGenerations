const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

function registerAiFeatures(app, helpers) {
  const {
    rootDir,
    backendDir,
    getUsers,
    getUser,
    saveUser,
    getGlobalEconomy,
    getGlobalBroadcast,
    setGlobalBroadcast,
    log,
  } = helpers;

  const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL || 'http://127.0.0.1:11434';
  const DEFAULT_MODEL = process.env.OLLAMA_DEFAULT_MODEL || 'qwen2.5:3b-instruct';
  const AI_STATE_FILE = path.join(backendDir, 'data', 'ai_state.json');
  const NEWS_FILE = path.join(backendDir, 'data', 'news.json');
  const CHANGELOG_FILE = path.join(rootDir, 'pokemon_generations', 'assets', 'CHANGELOG.md');
  const DEVOPS_CHANGELOG_FILE = path.join(rootDir, 'devops', 'devchangelog_v3.0.0.md');
  const IMPLEMENTATION_CHECKLIST_FILE = path.join(rootDir, 'checklist.md');
  const NEWS_ARCHIVE_DIR = path.join(rootDir, '.logs', 'news_archive');
  const AI_OUTPUT_DIR = path.join(rootDir, '.logs', 'ai_outputs');
  const CHAT_EXPORT_DIR = path.join(rootDir, '.logs', 'ai_chat_exports');

  const automationCatalog = {
    generate_daily_briefing: { title: 'Daily Briefing', implemented: true, mode: 'dedicated' },
    sync_home_news: { title: 'Home News', implemented: true, mode: 'dedicated' },
    send_trade_alerts: { title: 'Trade Alerts', implemented: true, mode: 'dedicated' },
    send_low_balance_alerts: { title: 'Low Balance Alerts', implemented: true, mode: 'dedicated' },
    generate_release_changelog: { title: 'Release Notes', implemented: true, mode: 'dedicated' },
    summarize_logs: { title: 'Log Summary', implemented: true, mode: 'dedicated' },
    market_movers_report: { title: 'Market Movers', implemented: true, mode: 'dedicated' },
    portfolio_digest: { title: 'Portfolio Digest', implemented: true, mode: 'dedicated' },
    battle_recap_digest: { title: 'Battle Recap', implemented: true, mode: 'dedicated' },
    moderation_scan: { title: 'Moderation Scan', implemented: true, mode: 'dedicated' },
    quest_bulletin: { title: 'Quest Bulletin', implemented: true, mode: 'dedicated' },
    event_spotlight: { title: 'Event Spotlight', implemented: true, mode: 'dedicated' },
    devops_digest: { title: 'DevOps Digest', implemented: true, mode: 'dedicated' },
    ops_checklist: { title: 'Checklist', implemented: true, mode: 'dedicated' },
    trainer_reengagement: { title: 'Trainer Nudge', implemented: true, mode: 'dedicated' },
    market_news_translation: { title: 'News Rewrite', implemented: true, mode: 'dedicated' },
    banking_risk_audit: { title: 'Risk Audit', implemented: true, mode: 'dedicated' },
    mail_campaign: { title: 'Mail Campaign', implemented: true, mode: 'dedicated' },
    support_reply_draft: { title: 'Support Draft', implemented: true, mode: 'dedicated' },
    custom_prompt: { title: 'Custom Prompt', implemented: true, mode: 'dedicated' },
    stock_storyboard: { title: 'Stock Story', implemented: true, mode: 'dedicated' },
    lore_sync: { title: 'Lore Sync', implemented: true, mode: 'dedicated' },
    release_briefing_mail: { title: 'Release Mail', implemented: true, mode: 'dedicated' },
    broadcast_polish: { title: 'Broadcast Polish', implemented: true, mode: 'dedicated' },
    system_storyline: { title: 'System Story', implemented: true, mode: 'dedicated' },
  };

  const modelCatalog = {
    'qwen2.5:3b-instruct-q3_K_S': {
      estimatedSize: 1400000000,
      recommendation: 'lightweight',
      ramGuidance: 'Recommended for an M1 MacBook Pro 32GB while also running the game stack.',
    },
  };
  const allowedModels = Object.keys(modelCatalog);

  const installState = {
    active: false,
    model: null,
    status: 'idle',
    phase: null,
    total: 0,
    completed: 0,
    percent: 0,
    etaSeconds: null,
    bytesPerSecond: null,
    startedAt: null,
    finishedAt: null,
    error: null,
    output: [],
  };

  let installAbortController = null;

  function defaultAiState() {
    return {
      dailyBriefings: {},
      automationHistory: [],
      installHistory: [],
      generatedArtifacts: [],
      moderationQueue: [],
      supportQueue: [],
      telemetry: {
        totalRequests: 0,
        totalPromptTokens: 0,
        totalResponseTokens: 0,
        totalDurationMs: 0,
        averageDurationMs: 0,
        lastRequest: null,
        recentRequests: [],
      },
      conversations: {
        currentSessionId: null,
        sessions: [],
      },
    };
  }

  function ensureParent(targetPath) {
    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
  }

  function readJson(targetPath, fallback) {
    try {
      if (!fs.existsSync(targetPath)) return fallback;
      return JSON.parse(fs.readFileSync(targetPath, 'utf8'));
    } catch (_) {
      return fallback;
    }
  }

  function writeJson(targetPath, data) {
    ensureParent(targetPath);
    fs.writeFileSync(targetPath, JSON.stringify(data, null, 2));
  }

  function normalizeAiState(state) {
    const base = defaultAiState();
    const next = { ...base, ...(state || {}) };
    next.dailyBriefings = next.dailyBriefings || {};
    next.automationHistory = Array.isArray(next.automationHistory)
      ? next.automationHistory
      : [];
    next.installHistory = Array.isArray(next.installHistory) ? next.installHistory : [];
    next.generatedArtifacts = Array.isArray(next.generatedArtifacts)
      ? next.generatedArtifacts
      : [];
    next.moderationQueue = Array.isArray(next.moderationQueue) ? next.moderationQueue : [];
    next.supportQueue = Array.isArray(next.supportQueue) ? next.supportQueue : [];
    next.telemetry = { ...base.telemetry, ...(next.telemetry || {}) };
    next.telemetry.recentRequests = Array.isArray(next.telemetry.recentRequests)
      ? next.telemetry.recentRequests
      : [];
    next.conversations = { ...base.conversations, ...(next.conversations || {}) };
    next.conversations.sessions = Array.isArray(next.conversations.sessions)
      ? next.conversations.sessions
      : [];
    return next;
  }

  function readAiState() {
    return normalizeAiState(readJson(AI_STATE_FILE, defaultAiState()));
  }

  function writeAiState(state) {
    writeJson(AI_STATE_FILE, normalizeAiState(state));
  }

  function updateAiState(updater) {
    const state = readAiState();
    const updated = updater(state) || state;
    writeAiState(updated);
    return updated;
  }

  function nowIso() {
    return new Date().toISOString();
  }

  function todayKey() {
    return nowIso().split('T')[0];
  }

  function toSlug(value) {
    return String(value || 'artifact')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 60);
  }

  function createConversationSession(title = 'New Chat') {
    const id = `chat_${Date.now()}`;
    const timestamp = nowIso();
    return {
      id,
      title,
      createdAt: timestamp,
      updatedAt: timestamp,
      archivedAt: null,
      messages: [
        {
          role: 'assistant',
          content:
            'Silph-Gold Union AI online. I can help draft news, changelogs, player mail, banking alerts, and automation content.',
          timestamp,
        },
      ],
    };
  }

  function ensureCurrentConversation(state) {
    if (!state.conversations.currentSessionId) {
      const session = createConversationSession();
      state.conversations.currentSessionId = session.id;
      state.conversations.sessions.unshift(session);
      return session;
    }

    let session = state.conversations.sessions.find(
      (item) => item.id === state.conversations.currentSessionId
    );

    if (!session) {
      session = createConversationSession();
      state.conversations.currentSessionId = session.id;
      state.conversations.sessions.unshift(session);
    }

    return session;
  }

  function listConversationSummaries(state) {
    return state.conversations.sessions.map((session) => ({
      id: session.id,
      title: session.title,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      archivedAt: session.archivedAt || null,
      messageCount: Array.isArray(session.messages) ? session.messages.length : 0,
      preview:
        (Array.isArray(session.messages) ? session.messages : [])
          .slice(-1)
          .map((item) => item.content)
          .join('') || '',
    }));
  }

  function getConversationStatePayload() {
    const state = updateAiState((current) => {
      ensureCurrentConversation(current);
      return current;
    });
    const currentSession = ensureCurrentConversation(state);
    return {
      currentSessionId: state.conversations.currentSessionId,
      currentSession: currentSession,
      sessions: listConversationSummaries(state),
    };
  }

  function archiveCurrentConversation(state, reason = 'manual') {
    const current = ensureCurrentConversation(state);
    current.archivedAt = current.archivedAt || nowIso();
    current.archiveReason = reason;
    current.updatedAt = nowIso();
    return current;
  }

  function startNewConversation(title = 'New Chat') {
    const state = updateAiState((current) => {
      if (current.conversations.currentSessionId) {
        archiveCurrentConversation(current, 'new_chat_started');
      }
      const session = createConversationSession(title);
      current.conversations.currentSessionId = session.id;
      current.conversations.sessions.unshift(session);
      current.conversations.sessions = current.conversations.sessions.slice(0, 30);
      return current;
    });

    return getConversationStatePayload(state);
  }

  function appendConversationMessage(sessionId, message) {
    return updateAiState((current) => {
      const session =
        current.conversations.sessions.find((item) => item.id === sessionId) ||
        ensureCurrentConversation(current);
      session.messages = Array.isArray(session.messages) ? session.messages : [];
      session.messages.push({
        role: message.role,
        content: message.content,
        timestamp: message.timestamp || nowIso(),
        telemetry: message.telemetry || null,
      });
      if (!session.title || session.title === 'New Chat') {
        const source = session.messages.find((item) => item.role === 'user');
        if (source?.content) {
          session.title = source.content.slice(0, 48);
        }
      }
      session.updatedAt = nowIso();
      current.conversations.currentSessionId = session.id;
      return current;
    });
  }

  function fetchConversationSession(sessionId) {
    const state = readAiState();
    const session = state.conversations.sessions.find((item) => item.id === sessionId);
    return session || null;
  }

  function exportConversation(sessionId) {
    const session = fetchConversationSession(sessionId);
    if (!session) {
      throw new Error(`Conversation ${sessionId} not found.`);
    }

    fs.mkdirSync(CHAT_EXPORT_DIR, { recursive: true });
    const filename = `${toSlug(session.title || sessionId)}_${session.id}.md`;
    const filePath = path.join(CHAT_EXPORT_DIR, filename);
    const content = [
      `# AI Chat Export`,
      '',
      `Session ID: ${session.id}`,
      `Title: ${session.title || 'Untitled Session'}`,
      `Created: ${session.createdAt}`,
      `Updated: ${session.updatedAt}`,
      '',
      ...session.messages.flatMap((message) => [
        `## ${String(message.role || 'assistant').toUpperCase()}`,
        '',
        message.content || '',
        '',
        message.telemetry
          ? `Telemetry: ${JSON.stringify(message.telemetry, null, 2)}`
          : '',
        '',
      ]),
    ]
      .filter(Boolean)
      .join('\n');
    fs.writeFileSync(filePath, content);
    return filePath;
  }

  function appendInboxMessage(user, message) {
    if (!user.inbox) user.inbox = [];
    user.inbox = user.inbox.filter((item) => item.id !== message.id);
    user.inbox.unshift(message);
    if (user.inbox.length > 50) {
      user.inbox = user.inbox.slice(0, 50);
    }
    saveUser(user);
  }

  function recordInstallHistory(entry) {
    updateAiState((state) => {
      state.installHistory.unshift(entry);
      state.installHistory = state.installHistory.slice(0, 40);
      return state;
    });
  }

  function recordAutomationHistory(entry) {
    updateAiState((state) => {
      state.automationHistory.unshift(entry);
      state.automationHistory = state.automationHistory.slice(0, 80);
      return state;
    });
  }

  function recordGeneratedArtifact(entry) {
    updateAiState((state) => {
      state.generatedArtifacts.unshift(entry);
      state.generatedArtifacts = state.generatedArtifacts.slice(0, 80);
      return state;
    });
  }

  function recordModerationQueue(entry) {
    updateAiState((state) => {
      state.moderationQueue.unshift(entry);
      state.moderationQueue = state.moderationQueue.slice(0, 80);
      return state;
    });
  }

  function recordSupportQueue(entry) {
    updateAiState((state) => {
      state.supportQueue.unshift(entry);
      state.supportQueue = state.supportQueue.slice(0, 80);
      return state;
    });
  }

  function updateQueueEntry(queueType, queueId, changes) {
    const collectionName =
      queueType === 'moderation'
        ? 'moderationQueue'
        : queueType === 'support'
        ? 'supportQueue'
        : null;

    if (!collectionName) return null;

    let updatedEntry = null;
    updateAiState((state) => {
      const queue = Array.isArray(state[collectionName]) ? state[collectionName] : [];
      state[collectionName] = queue.map((entry) => {
        if (entry.id !== queueId) return entry;
        updatedEntry = {
          ...entry,
          ...changes,
          updatedAt: nowIso(),
        };
        return updatedEntry;
      });
      return state;
    });
    return updatedEntry;
  }

  function readArtifactPreview(savedPath) {
    try {
      if (!savedPath || !fs.existsSync(savedPath)) return '';
      return fs.readFileSync(savedPath, 'utf8').split('\n').slice(0, 32).join('\n');
    } catch (_) {
      return '';
    }
  }

  function recordTelemetry(entry) {
    updateAiState((state) => {
      state.telemetry.totalRequests += 1;
      state.telemetry.totalPromptTokens += Number(entry.promptTokens || 0);
      state.telemetry.totalResponseTokens += Number(entry.responseTokens || 0);
      state.telemetry.totalDurationMs += Number(entry.durationMs || 0);
      state.telemetry.averageDurationMs = state.telemetry.totalRequests
        ? Math.round(state.telemetry.totalDurationMs / state.telemetry.totalRequests)
        : 0;
      state.telemetry.lastRequest = entry;
      state.telemetry.recentRequests.unshift(entry);
      state.telemetry.recentRequests = state.telemetry.recentRequests.slice(0, 20);
      return state;
    });
  }

  function buildStatusPayload() {
    const state = readAiState();
    return fetchStatus(state);
  }

  async function callOllamaChat({
    messages,
    model = DEFAULT_MODEL,
    systemPrompt,
    temperature = 0.4,
    source = 'chat',
    sessionId = null,
  }) {
    const startedAt = Date.now();
    try {
      const response = await fetch(`${OLLAMA_BASE_URL}/api/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model,
          stream: false,
          messages: [
            ...(systemPrompt ? [{ role: 'system', content: systemPrompt }] : []),
            ...messages,
          ],
          options: { temperature },
        }),
      });

      if (!response.ok) {
        throw new Error(await response.text());
      }

      const data = await response.json();
      const telemetry = {
        source,
        sessionId,
        model,
        durationMs: Number(data.total_duration || 0) / 1000000 || Date.now() - startedAt,
        promptTokens: Number(data.prompt_eval_count || 0),
        responseTokens: Number(data.eval_count || 0),
        totalDurationNs: Number(data.total_duration || 0),
        loadDurationNs: Number(data.load_duration || 0),
        promptEvalDurationNs: Number(data.prompt_eval_duration || 0),
        evalDurationNs: Number(data.eval_duration || 0),
        createdAt: nowIso(),
      };
      recordTelemetry(telemetry);

      return {
        content: data.message?.content?.trim() || '',
        telemetry,
      };
    } catch (error) {
      log('error', `[AI] Ollama request failed: ${error.message}`);
      return null;
    }
  }

  function readLogBlock(scope = 'all') {
    const files = {
      system: path.join(backendDir, '.logs', 'system.log'),
      battle: path.join(backendDir, '.logs', 'battle.log'),
      social: path.join(backendDir, '.logs', 'social.log'),
      error: path.join(backendDir, '.logs', 'error.log'),
    };
    const scopes = scope === 'all' ? Object.keys(files) : [scope];
    return scopes
      .map((key) => {
        const file = files[key];
        if (!fs.existsSync(file)) return `${key.toUpperCase()}\nNo log data found`;
        const lines = fs
          .readFileSync(file, 'utf8')
          .trim()
          .split('\n')
          .filter(Boolean)
          .slice(-18)
          .join('\n');
        return `${key.toUpperCase()}\n${lines}`;
      })
      .join('\n\n');
  }

  function loadBankSnapshot(username) {
    const safeName = String(username || '').trim().toLowerCase();
    if (!safeName) {
      return {
        balance: 0,
        savings: 0,
        portfolio: [],
        retirement: { roth: 0, k401: 0 },
        transactions: [],
      };
    }

    const bankFile = path.join(backendDir, 'data', 'bank', `${safeName}_bank.json`);
    return readJson(bankFile, {
      balance: 0,
      savings: 0,
      portfolio: [],
      retirement: { roth: 0, k401: 0 },
      transactions: [],
    });
  }

  async function fetchLiveMarketSnapshot(region = 'AEVORA') {
    const backendPort = process.env.PORT || 8193;
    try {
      const response = await fetch(
        `http://127.0.0.1:${backendPort}/economy/market?region=${encodeURIComponent(region)}`
      );
      if (!response.ok) {
        return { priceMap: {}, available: false, source: 'market_unavailable' };
      }
      const assets = await response.json();
      const priceMap = {};
      for (const asset of Array.isArray(assets) ? assets : []) {
        if (!asset?.id) continue;
        priceMap[String(asset.id).toUpperCase()] = {
          currentPrice: Number(asset.currentPrice || asset.price || 0),
          ticker: asset.ticker || null,
          region: asset.dimension || region,
          name: asset.name || asset.id,
        };
      }
      return {
        priceMap,
        available: Object.keys(priceMap).length > 0,
        source: 'economy_market_endpoint',
      };
    } catch (_) {
      return { priceMap: {}, available: false, source: 'market_unreachable' };
    }
  }

  async function buildPortfolioMetrics(username, region = 'AEVORA') {
    const bank = loadBankSnapshot(username);
    const portfolio = Array.isArray(bank.portfolio) ? bank.portfolio : [];
    const liveMarket = await fetchLiveMarketSnapshot(region);
    const holdings = portfolio.map((holding) => {
      const shares = Number(holding.shares || 0);
      const avgPrice = Number(holding.avgPrice || holding.price || 0);
      const assetId = String(holding.id || holding.ticker || 'UNKNOWN').toUpperCase();
      const liveQuote = liveMarket.priceMap[assetId];
      const currentPrice = Number(liveQuote?.currentPrice || avgPrice || 0);
      const basisValue = Number((shares * avgPrice).toFixed(2));
      const estimatedValue = Number((shares * currentPrice).toFixed(2));
      return {
        id: assetId,
        shares,
        avgPrice,
        currentPrice,
        basisValue,
        estimatedValue,
        gainLoss: Number((estimatedValue - basisValue).toFixed(2)),
        pricingSource: liveQuote ? 'live_market' : 'avg_price_fallback',
        dimension: holding.dimension || liveQuote?.region || region || 'global',
      };
    });
    const estimatedPortfolioValue = holdings.reduce(
      (sum, holding) => sum + Number(holding.estimatedValue || 0),
      0
    );
    const largestHolding = holdings
      .slice()
      .sort((left, right) => Number(right.estimatedValue || 0) - Number(left.estimatedValue || 0))[0];
    const recentTransactions = (Array.isArray(bank.transactions) ? bank.transactions : []).slice(0, 5);

    return {
      checking: Number(bank.balance || 0),
      savings: Number(bank.savings || 0),
      retirement:
        Number(bank.retirement?.k401 || 0) + Number(bank.retirement?.roth || 0),
      holdingsCount: holdings.length,
      holdings,
      estimatedPortfolioValue: Number(estimatedPortfolioValue.toFixed(2)),
      netWorthEstimate: Number(
        (
          Number(bank.balance || 0) +
          Number(bank.savings || 0) +
          Number(bank.retirement?.k401 || 0) +
          Number(bank.retirement?.roth || 0) +
          estimatedPortfolioValue
        ).toFixed(2)
      ),
      largestHolding: largestHolding || null,
      recentTransactions,
      livePricingAvailable: liveMarket.available,
      pricingSource: liveMarket.source,
    };
  }

  async function applyQueueStatus(queueType, queueId, status, note) {
    const state = readAiState();
    const queue =
      queueType === 'moderation'
        ? state.moderationQueue
        : queueType === 'support'
        ? state.supportQueue
        : null;

    if (!queue) {
      return {
        success: false,
        title: 'Queue Update Failed',
        summary: `Unknown queue type: ${queueType}.`,
      };
    }

    const entry = queue.find((item) => item.id === queueId);
    if (!entry) {
      return {
        success: false,
        title: 'Queue Update Failed',
        summary: `Queue item ${queueId} was not found.`,
      };
    }

    const normalizedStatus = String(status || '').trim().toLowerCase();
    if (!normalizedStatus) {
      return {
        success: false,
        title: 'Queue Update Failed',
        summary: 'A new status is required.',
      };
    }

    const update = {
      status: normalizedStatus,
      operatorNote: note || null,
      handledBy: 'bn200n',
    };

    if (queueType === 'support' && normalizedStatus === 'sent' && entry.username) {
      const user = getUser(entry.username);
      if (user && !entry.deliveredAt) {
        const body = readArtifactPreview(entry.savedPath) || entry.summary || 'Support reply ready.';
        appendInboxMessage(user, {
          id: `support_reply_${queueId}`,
          from: 'bn200n',
          fromDisplay: 'Pokemon Center Support',
          subject: `SUPPORT_REPLY // ${entry.username}`,
          body,
          sentAt: nowIso(),
          read: false,
          type: 'support_reply',
        });
        update.deliveredAt = nowIso();
      }
    }

    if (queueType === 'moderation' && normalizedStatus === 'escalated') {
      const admin = getUser('bn200n');
      if (admin) {
        appendInboxMessage(admin, {
          id: `moderation_escalation_${queueId}`,
          from: 'bn200n',
          fromDisplay: 'AI Moderation Queue',
          subject: `MODERATION_ESCALATED // ${queueId}`,
          body: [
            `Queue ID: ${queueId}`,
            `Severity: ${entry.severity || 'unknown'}`,
            note ? `Operator Note: ${note}` : null,
            '',
            entry.summary || 'Moderation case escalated for follow-up.',
          ]
            .filter(Boolean)
            .join('\n'),
          sentAt: nowIso(),
          read: false,
          type: 'moderation_escalation',
        });
      }
    }

    const updatedEntry = updateQueueEntry(queueType, queueId, update);
    if (!updatedEntry) {
      return {
        success: false,
        title: 'Queue Update Failed',
        summary: `Unable to update queue item ${queueId}.`,
      };
    }

    recordAutomationHistory({
      actionId: `${queueType}_queue_update`,
      title:
        queueType === 'moderation' ? 'Moderation Queue Update' : 'Support Queue Update',
      summary: `Updated ${queueId} to ${normalizedStatus}.`,
      ranAt: nowIso(),
      success: true,
      approved: true,
      requiresApproval: false,
      savedPaths: updatedEntry.savedPath ? [updatedEntry.savedPath] : [],
      metadata: {
        queueType,
        queueId,
        status: normalizedStatus,
      },
    });

    return {
      success: true,
      title: 'Queue Updated',
      summary: `Updated ${queueId} to ${normalizedStatus}.`,
      preview: updatedEntry.summary || '',
      savedPaths: updatedEntry.savedPath ? [updatedEntry.savedPath] : [],
      metadata: {
        queueType,
        queueId,
        status: normalizedStatus,
      },
      entry: updatedEntry,
    };
  }

  function assessModerationSeverity(text) {
    const content = String(text || '').toLowerCase();
    const rules = [
      { label: 'violence', pattern: /\b(kill|murder|hurt|attack)\b/g, weight: 20 },
      { label: 'harassment', pattern: /\b(stupid|idiot|trash|hate you)\b/g, weight: 15 },
      { label: 'scam', pattern: /\b(free money|send password|hack|cheat)\b/g, weight: 18 },
      { label: 'sexual', pattern: /\b(sex|nude|explicit)\b/g, weight: 30 },
      { label: 'slur', pattern: /\b(fag|retard|nigger)\b/g, weight: 45 },
    ];

    const findings = [];
    let score = 0;
    for (const rule of rules) {
      const matches = content.match(rule.pattern) || [];
      if (!matches.length) continue;
      score += matches.length * rule.weight;
      findings.push({
        label: rule.label,
        matches: matches.length,
        sample: matches[0],
      });
    }

    return {
      score,
      severity:
        score >= 60 ? 'critical' : score >= 35 ? 'high' : score >= 15 ? 'medium' : 'low',
      findings,
    };
  }

  function writeOutputArtifact(filename, content, category = 'general') {
    fs.mkdirSync(AI_OUTPUT_DIR, { recursive: true });
    const filePath = path.join(AI_OUTPUT_DIR, filename);
    fs.writeFileSync(filePath, content);
    recordGeneratedArtifact({
      path: filePath,
      category,
      createdAt: nowIso(),
      size: Buffer.byteLength(content, 'utf8'),
    });
    return filePath;
  }

  function createApprovalResult({
    actionId,
    title,
    summary,
    preview,
    metadata = {},
    savedPaths = [],
  }) {
    return {
      success: true,
      title,
      summary,
      preview,
      savedPaths,
      metadata: {
        actionId,
        requiresApproval: true,
        approved: false,
        ...metadata,
      },
    };
  }

  async function fetchStatus(existingState) {
    let serviceReachable = false;
    let models = [];

    try {
      const response = await fetch(`${OLLAMA_BASE_URL}/api/tags`);
      if (response.ok) {
        const data = await response.json();
        serviceReachable = true;
        models = (data.models || []).map((item) => ({
          name: item.name,
          size: Number(item.size || 0),
          modifiedAt: item.modified_at || null,
          digest: item.digest || null,
        }));
      }
    } catch (_) {}

    const candidates = ['/opt/homebrew/bin/ollama', '/usr/local/bin/ollama'];
    let cliPath = candidates.find((candidate) => fs.existsSync(candidate)) || null;
    if (!cliPath) {
      const lookup = spawnSync('which', ['ollama'], { encoding: 'utf8' });
      if (lookup.status === 0 && lookup.stdout.trim()) {
        cliPath = lookup.stdout.trim();
      }
    }

    const state = normalizeAiState(existingState || readAiState());
    const currentConversation = ensureCurrentConversation(state);
    writeAiState(state);

    return {
      serviceReachable,
      cliInstalled: Boolean(cliPath),
      cliPath,
      models,
      defaultModel: DEFAULT_MODEL,
      recommendedModel: 'qwen2.5:3b-instruct-q3_K_S',
      baseUrl: OLLAMA_BASE_URL,
      currentBroadcastType: getGlobalBroadcast()?.type || null,
      install: { ...installState },
      installHistory: state.installHistory,
      automationCatalog,
      automationHistory: state.automationHistory,
      moderationQueue: state.moderationQueue,
      supportQueue: state.supportQueue,
      modelCatalog,
      telemetry: state.telemetry,
      conversations: {
        currentSessionId: state.conversations.currentSessionId,
        sessions: listConversationSummaries(state),
        currentSession: currentConversation,
      },
    };
  }

  function pushInstallOutput(line) {
    if (!line) return;
    installState.output.push(line);
    if (installState.output.length > 12) {
      installState.output = installState.output.slice(-12);
    }
  }

  function updateInstallProgress(progress) {
    if (!progress || typeof progress !== 'object') return;
    const now = Date.now();
    const total = Number(progress.total || installState.total || 0);
    const completed = Number(progress.completed || installState.completed || 0);
    installState.phase = progress.status || installState.phase;
    installState.status = progress.status || installState.status || 'running';
    installState.total = total;
    installState.completed = completed;
    installState.percent =
      total > 0 ? Number(((completed / total) * 100).toFixed(1)) : installState.percent;

    if (installState.startedAt && completed > 0) {
      const elapsedSeconds = Math.max(
        1,
        (now - new Date(installState.startedAt).getTime()) / 1000
      );
      const bytesPerSecond = completed / elapsedSeconds;
      installState.bytesPerSecond = Math.round(bytesPerSecond);
      if (total > completed && bytesPerSecond > 0) {
        installState.etaSeconds = Math.round((total - completed) / bytesPerSecond);
      }
    }
  }

  async function startModelInstall(model) {
    if (installState.active) {
      return {
        success: false,
        summary: `Another model install is already running for ${installState.model}.`,
      };
    }

    installAbortController = new AbortController();
    installState.active = true;
    installState.model = model;
    installState.status = 'starting';
    installState.phase = 'preparing';
    installState.total = 0;
    installState.completed = 0;
    installState.percent = 0;
    installState.etaSeconds = null;
    installState.bytesPerSecond = null;
    installState.startedAt = nowIso();
    installState.finishedAt = null;
    installState.error = null;
    installState.output = [];

    try {
      const response = await fetch(`${OLLAMA_BASE_URL}/api/pull`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model }),
        signal: installAbortController.signal,
      });

      if (!response.ok) {
        throw new Error(await response.text());
      }

      const reader = response.body?.getReader();
      const decoder = new TextDecoder();
      let buffer = '';

      while (reader) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
          const trimmed = line.trim();
          if (!trimmed) continue;
          pushInstallOutput(trimmed);
          try {
            updateInstallProgress(JSON.parse(trimmed));
          } catch (_) {
            installState.status = 'running';
          }
        }
      }

      if (buffer.trim()) {
        pushInstallOutput(buffer.trim());
        try {
          updateInstallProgress(JSON.parse(buffer.trim()));
        } catch (_) {}
      }

      installState.active = false;
      installState.status = 'completed';
      installState.phase = 'completed';
      installState.percent = 100;
      installState.finishedAt = nowIso();
      recordInstallHistory({
        model,
        status: 'completed',
        startedAt: installState.startedAt,
        finishedAt: installState.finishedAt,
        bytesDownloaded: installState.completed,
        totalBytes: installState.total,
      });
      log('system', `[AI] Installed Ollama model ${model}`);
      return {
        success: true,
        summary: `Installed ${model} successfully.`,
      };
    } catch (error) {
      const canceled = error.name === 'AbortError';
      installState.active = false;
      installState.status = canceled ? 'canceled' : 'failed';
      installState.phase = canceled ? 'canceled' : 'failed';
      installState.error = error.message;
      installState.finishedAt = nowIso();
      pushInstallOutput(canceled ? 'Install canceled by operator.' : error.message);
      recordInstallHistory({
        model,
        status: canceled ? 'canceled' : 'failed',
        startedAt: installState.startedAt,
        finishedAt: installState.finishedAt,
        bytesDownloaded: installState.completed,
        totalBytes: installState.total,
        error: canceled ? null : error.message,
      });
      throw error;
    } finally {
      installAbortController = null;
    }
  }

  function cancelModelInstall() {
    if (!installState.active || !installAbortController) {
      return {
        success: false,
        summary: 'No active model download to cancel.',
      };
    }
    installAbortController.abort();
    return {
      success: true,
      summary: `Cancel requested for ${installState.model}.`,
    };
  }

  async function generateDailyBriefing({
    username,
    deliverToInbox = true,
    force = false,
    approved = true,
  }) {
    const state = readAiState();
    const date = todayKey();
    let briefing = state.dailyBriefings[date]?.content;

    if (!briefing || force) {
      const economy = getGlobalEconomy();
      const news = readJson(NEWS_FILE, {});
      const aiResult = await callOllamaChat({
        messages: [
          {
            role: 'user',
            content: [
              `Create a concise daily login bulletin for ${date}.`,
              `Tax rate: ${(Number(economy.taxRate || 0.05) * 100).toFixed(1)}%.`,
              `Nasdaq proxy: ${Number(economy.nasdaqIndex || 0).toFixed(2)}.`,
              `BTC proxy: ${Number(economy.bitcoinPrice || 0).toFixed(2)}.`,
              `Latest release headline: ${news?.changelog?.title || 'Silph-Gold Union production build'}.`,
              'Write one short intro paragraph followed by 3 bullet points.',
            ].join('\n'),
          },
        ],
        systemPrompt:
          'You write in-universe game operations bulletins. Keep the tone polished, concise, and useful.',
        source: 'automation.generate_daily_briefing',
      });
      briefing =
        aiResult?.content ||
        [
          `Silph-Gold Union Daily Briefing // ${date}`,
          '',
          'Global Link systems are stable, banking terminals are synchronized, and the production rollout remains green across the main site, admin web, and Aevora Exchange.',
          '',
          '- Market watch remains stable.',
          '- Banking watch shows normal vault activity.',
          '- Inbox watch: check your mail for trade confirmations and vault alerts.',
        ].join('\n');
      state.dailyBriefings[date] = {
        createdAt: nowIso(),
        content: briefing,
      };
      writeAiState(state);
    }

    if (!approved) {
      return createApprovalResult({
        actionId: 'generate_daily_briefing',
        title: 'Approve Daily Briefing',
        summary: deliverToInbox
          ? `Review the daily briefing before sending it to ${username || 'the selected inbox target'}.`
          : 'Review the daily briefing before saving it.',
        preview: briefing,
      });
    }

    let delivered = false;
    if (username && deliverToInbox) {
      const user = getUser(username);
      if (user) {
        if (!user.aiFlags) user.aiFlags = {};
        if (!Array.isArray(user.aiFlags.deliveredBriefings)) {
          user.aiFlags.deliveredBriefings = [];
        }
        const deliveryId = `daily_briefing_${date}`;
        const alreadyDelivered = user.aiFlags.deliveredBriefings.includes(deliveryId);
        if (!alreadyDelivered || force) {
          user.aiFlags.deliveredBriefings = user.aiFlags.deliveredBriefings.filter((item) => item !== deliveryId);
          user.aiFlags.deliveredBriefings.push(deliveryId);
          appendInboxMessage(user, {
            id: deliveryId,
            from: 'bn200n',
            fromDisplay: 'Silph-Gold Union Briefing Desk',
            subject: `DAILY_LOGIN_BRIEFING // ${date}`,
            body: briefing,
            sentAt: nowIso(),
            read: false,
            type: 'daily_briefing',
          });
          delivered = true;
        }
      }
    }

    return {
      success: true,
      title: 'Daily Briefing Ready',
      summary: delivered
        ? `Prepared the ${date} briefing and delivered it to ${username}.`
        : `Prepared the ${date} briefing.`,
      preview: briefing,
      savedPaths: [AI_STATE_FILE],
      metadata: { date, delivered, applied: true },
    };
  }

  async function sendTradeAlert({
    username,
    action = 'buy',
    assetId = 'SLPH',
    shares = 0,
    priceAtTrade = 0,
    approved = true,
  }) {
    const user = getUser(username);
    if (!user) {
      return {
        success: false,
        title: 'Trade Alert Failed',
        summary: `User ${username} not found.`,
      };
    }

    const aiResult = await callOllamaChat({
      messages: [
        {
          role: 'user',
          content: `Write a concise ${action} confirmation for ${username}. Asset: ${assetId}. Shares: ${shares}. Price: ${priceAtTrade} PD.`,
        },
      ],
      systemPrompt:
        'Write a short market-terminal inbox confirmation with a premium in-universe tone.',
      source: 'automation.send_trade_alerts',
    });

    const body =
      aiResult?.content ||
      `Trade execution confirmed. ${action.toUpperCase()} ${shares} shares of ${assetId} at ${Number(priceAtTrade).toFixed(2)} PD.`;

    if (!approved) {
      return createApprovalResult({
        actionId: 'send_trade_alerts',
        title: 'Approve Trade Alert',
        summary: `Review the trade alert before sending it to ${username}.`,
        preview: body,
      });
    }

    appendInboxMessage(user, {
      id: `trade_alert_${Date.now()}_${username}`,
      from: 'bn200n',
      fromDisplay: 'Silph-Gold Union Trading Desk',
      subject: `TRADE_EXECUTED // ${assetId}`,
      body,
      sentAt: nowIso(),
      read: false,
      type: 'trade_alert',
    });

    return {
      success: true,
      title: 'Trade Alert Sent',
      summary: `Sent a ${action} trade confirmation to ${username}.`,
      preview: body,
      metadata: { applied: true },
    };
  }

  async function sendLowBalanceAlerts({
    threshold = 2500,
    username,
    allUsers = true,
    approved = true,
  }) {
    const users = allUsers
      ? getUsers()
      : username
      ? [getUser(username)].filter(Boolean)
      : [];
    const notified = [];
    const drafts = [];

    for (const user of users) {
      const bank = loadBankSnapshot(user?.username);
      const vaultBalance = Number(bank.balance || 0);
      if (vaultBalance > Number(threshold)) continue;

      const aiResult = await callOllamaChat({
        messages: [
          {
            role: 'user',
            content: `Write a concise banking warning for ${user.username}. Their vault balance is ${vaultBalance} PD, below the ${threshold} PD threshold.`,
          },
        ],
        systemPrompt:
          'Write a short risk-management inbox alert for a Pokemon-themed banking system.',
        source: 'automation.send_low_balance_alerts',
      });
      const body =
        aiResult?.content ||
        `Silph-Gold Union risk monitors detected that your vault balance is ${vaultBalance.toFixed(2)} PD, below the configured threshold of ${Number(threshold).toFixed(2)} PD.`;

      drafts.push({ username: user.username, body, vaultBalance });

      if (!approved) continue;

      appendInboxMessage(user, {
        id: `low_balance_${todayKey()}_${user.username}`,
        from: 'bn200n',
        fromDisplay: 'Silph-Gold Union Risk Desk',
        subject: 'LOW_VAULT_BALANCE_ALERT',
        body,
        sentAt: nowIso(),
        read: false,
        type: 'low_balance_alert',
      });
      notified.push(user.username);
    }

    if (!approved) {
      return createApprovalResult({
        actionId: 'send_low_balance_alerts',
        title: 'Approve Low Balance Alerts',
        summary: drafts.length
          ? `Review ${drafts.length} low-balance alert(s) before delivery.`
          : 'No players crossed the low-balance threshold.',
        preview: drafts
          .map(
            (item) =>
              `${item.username} // ${Number(item.vaultBalance).toFixed(2)} PD\n${item.body}`
          )
          .join('\n\n'),
      });
    }

    return {
      success: true,
      title: 'Low Balance Scan Complete',
      summary: notified.length
        ? `Sent low-balance alerts to ${notified.join(', ')}.`
        : 'No players crossed the low-balance threshold.',
      preview: notified.length
        ? `Threshold: ${threshold} PD\nRecipients: ${notified.join(', ')}`
        : 'No alerts were needed.',
      metadata: { applied: true },
    };
  }

  function writeReleaseFiles(version, changelogOverride, devopsOverride, checklistOverride) {
    const changelog =
      changelogOverride ||
      [
        '# Changelog',
        '',
        'All notable changes to the Pokemon Generations project will be documented in this file.',
        '',
        `## [${version.replace(/^v/i, '')}] - ${todayKey()}`,
        '### Added',
        '- AI Operations Suite tab with local Ollama chat and automation grid.',
        '- Persistent AI chat memory and approval-based automations.',
        '',
        '### Changed',
        '- Unified service ports to 8191 / 8192 / 8193.',
        '',
        '### Fixed',
        '- Model download visibility, telemetry, and automation truthfulness in the admin app.',
        '',
      ].join('\n');

    const devopsLog =
      devopsOverride ||
      [
        `# DevOps Changelog ${version}`,
        '',
        `Updated: ${nowIso()}`,
        '',
        '## Completed',
        '- Added approval workflows and persistent AI memory.',
        '- Added install history, automation history, and chat telemetry.',
        '',
      ].join('\n');

    const checklist =
      checklistOverride ||
      [
        '# Implementation Checklist',
        '',
        `Updated: ${nowIso()}`,
        '',
        '- [x] AI panel telemetry',
        '- [x] Persistent chat sessions',
        '- [x] Approval workflow',
        '- [x] Install history',
        '- [x] Automation history',
        '',
      ].join('\n');

    ensureParent(CHANGELOG_FILE);
    fs.writeFileSync(CHANGELOG_FILE, changelog);
    ensureParent(DEVOPS_CHANGELOG_FILE);
    fs.writeFileSync(DEVOPS_CHANGELOG_FILE, devopsLog);
    ensureParent(IMPLEMENTATION_CHECKLIST_FILE);
    fs.writeFileSync(IMPLEMENTATION_CHECKLIST_FILE, checklist);

    return [CHANGELOG_FILE, DEVOPS_CHANGELOG_FILE, IMPLEMENTATION_CHECKLIST_FILE];
  }

  async function generateReleaseChangelog({ version = 'v3.0.0+1', writeFiles = true, approved = true }) {
    const aiResult = await callOllamaChat({
      messages: [
        {
          role: 'user',
          content: `Write GitHub-style release notes for ${version} covering the AI admin tab, unified production ports, inbox automations, persistent chat memory, and automation approvals.`,
        },
      ],
      systemPrompt: 'Write clean engineering release notes under Added, Changed, and Fixed headings.',
      source: 'automation.generate_release_changelog',
    });
    const preview = aiResult?.content || 'Release notes generated with local fallback content.';

    if (!approved && writeFiles) {
      return createApprovalResult({
        actionId: 'generate_release_changelog',
        title: 'Approve Release Notes',
        summary: `Review the generated release notes before writing them for ${version}.`,
        preview,
      });
    }

    const savedPaths = writeFiles ? writeReleaseFiles(version, preview) : [];
    return {
      success: true,
      title: 'Release Notes Generated',
      summary: `Prepared ${version} changelog and devops update content.`,
      preview,
      savedPaths,
      metadata: { applied: writeFiles, version },
    };
  }

  async function syncHomeNews({ headline, broadcast = true, approved = true }) {
    const aiResult = await callOllamaChat({
      messages: [
        {
          role: 'user',
          content: `Draft a polished home-screen release bulletin. Headline focus: ${headline || 'Silph-Gold Union Production Build'}.`,
        },
      ],
      systemPrompt:
        'Write concise release bulletin copy for a Pokemon-themed operations dashboard.',
      source: 'automation.sync_home_news',
    });
    const intro =
      aiResult?.content ||
      'AI Operations Suite is now available in the Pokemon Center Admin mac app.';
    const news = {
      changelog: {
        version: 'v3.0.0+1',
        title: headline || 'SILPH-GOLD UNION PRODUCTION BUILD',
        items: intro.split('\n').filter(Boolean).slice(0, 5),
        date: 'Apr 2026',
      },
      upcoming: [
        'Expanded AI-generated market commentary',
        'Scheduled stock and banking automation jobs',
        'Additional admin telemetry surfaces',
      ],
      features: [
        'Daily login briefing delivery',
        'Trade and low-vault inbox alerts',
        'Local Ollama chat',
        'Command center multi-service launcher',
      ],
      platforms: [
        { name: 'Main Site', status: 'PORT 8191', details: ['Pokemon Generations web build', 'Player-facing home and news'] },
        { name: 'Aevora Exchange', status: 'PORT 8192', details: ['Stock market and banking terminal', 'Silph-Gold Union services'] },
        { name: 'Backend API', status: 'PORT 8193', details: ['Node.js Express API', 'Centralized data sync'] },
      ],
      marketStory: intro,
      lastUpdated: nowIso(),
    };

    if (!approved) {
      return createApprovalResult({
        actionId: 'sync_home_news',
        title: 'Approve Home News Update',
        summary: 'Review the home/news update before writing it and broadcasting it.',
        preview: [news.changelog.title, ...news.changelog.items].join('\n'),
      });
    }

    writeJson(NEWS_FILE, news);
    fs.mkdirSync(NEWS_ARCHIVE_DIR, { recursive: true });
    const archivePath = path.join(NEWS_ARCHIVE_DIR, `news_${todayKey()}_ai_sync.json`);
    fs.writeFileSync(archivePath, JSON.stringify(news, null, 2));

    if (broadcast) {
      setGlobalBroadcast({
        type: 'news',
        text: `POKEMON CENTER BROADCAST: ${news.changelog.title} is now live across the main site, admin web, and Aevora Exchange.`,
        sentAt: nowIso(),
        sentBy: 'SILPH-GOLD UNION AI',
      });
    }

    return {
      success: true,
      title: 'Home News Updated',
      summary: 'Updated the shared home/news feed and archived the latest release bulletin.',
      preview: [news.changelog.title, ...news.changelog.items].join('\n'),
      savedPaths: [NEWS_FILE, archivePath],
      metadata: { applied: true, broadcast },
    };
  }

  async function summarizeLogs({ scope = 'all' }) {
    const text = readLogBlock(scope);
    const aiResult = await callOllamaChat({
      messages: [{ role: 'user', content: `Summarize these operations logs into short actionable bullets:\n\n${text}` }],
      systemPrompt: 'Summarize logs for a game operations admin in clean bullet points.',
      source: 'automation.summarize_logs',
    });
    const preview = aiResult?.content || text;

    return {
      success: true,
      title: 'Log Summary Ready',
      summary: `Summarized ${scope} logs.`,
      preview,
      metadata: { scope },
    };
  }

  async function draftAndApplyArtifact({
    actionId,
    prompt,
    systemPrompt,
    filename,
    category,
    approvalSummary,
    successTitle,
    successSummary,
    writeToFile = true,
    approved = true,
    extraSavedPaths = [],
    afterApply,
  }) {
    const aiResult = await callOllamaChat({
      messages: [{ role: 'user', content: prompt }],
      systemPrompt,
      source: `automation.${actionId}`,
    });
    const preview = aiResult?.content || `${successTitle} generated with local fallback output.`;

    if (!approved && writeToFile) {
      return createApprovalResult({
        actionId,
        title: `Approve ${successTitle}`,
        summary: approvalSummary,
        preview,
      });
    }

    const savedPaths = [];
    if (writeToFile && filename) {
      savedPaths.push(writeOutputArtifact(filename, preview, category));
    }
    if (typeof afterApply === 'function') {
      const extra = await afterApply(preview);
      if (Array.isArray(extra)) {
        savedPaths.push(...extra);
      }
    }
    savedPaths.push(...extraSavedPaths);

    return {
      success: true,
      title: successTitle,
      summary: successSummary,
      preview,
      savedPaths,
      metadata: { actionId, applied: true },
    };
  }

  async function runAutomation(actionId, options = {}, approved = false) {
    const title = automationCatalog[actionId]?.title || actionId;
    const targetUser = options.username || 'bn200n';

    switch (actionId) {
      case 'generate_daily_briefing':
        return generateDailyBriefing({
          username: options.username,
          deliverToInbox: options.deliverToInbox !== false,
          force: options.force === true,
          approved,
        });
      case 'sync_home_news':
        return syncHomeNews({
          headline: options.headline,
          broadcast: options.broadcast !== false,
          approved,
        });
      case 'send_trade_alerts':
        return sendTradeAlert({
          username: options.username,
          assetId: options.assetId,
          action: options.action,
          shares: Number(options.shares || 0),
          priceAtTrade: Number(options.priceAtTrade || 0),
          approved,
        });
      case 'send_low_balance_alerts':
        return sendLowBalanceAlerts({
          threshold: Number(options.threshold || 2500),
          username: options.username,
          allUsers: options.allUsers !== false,
          approved,
        });
      case 'generate_release_changelog':
        return generateReleaseChangelog({
          version: options.version || 'v3.0.0+1',
          writeFiles: options.writeFiles !== false,
          approved,
        });
      case 'summarize_logs':
        return summarizeLogs({ scope: options.scope || 'all' });
      case 'devops_digest': {
        const summary = await summarizeLogs({ scope: options.scope || 'all' });
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve DevOps Digest',
            summary: 'Review the DevOps digest before writing it to the changelog.',
            preview: summary.preview || '',
          });
        }
        const digest = [
          `# DevOps Changelog v3.0.0+1`,
          '',
          `Updated: ${nowIso()}`,
          '',
          `## AI Digest`,
          '',
          summary.preview || '',
          '',
        ].join('\n');
        fs.writeFileSync(DEVOPS_CHANGELOG_FILE, digest);
        return {
          success: true,
          title: 'DevOps Digest Updated',
          summary: 'Wrote the latest AI-generated digest into the DevOps changelog.',
          preview: summary.preview,
          savedPaths: [DEVOPS_CHANGELOG_FILE],
          metadata: { applied: true },
        };
      }
      case 'ops_checklist': {
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Checklist Refresh',
            summary: 'Review the checklist refresh before writing it.',
            preview: writeReleaseFiles('v3.0.0+1')[2],
          });
        }
        return {
          success: true,
          title: 'Checklist Refreshed',
          summary: 'Implementation checklist has been refreshed.',
          preview: fs.readFileSync(writeReleaseFiles('v3.0.0+1')[2], 'utf8'),
          savedPaths: [IMPLEMENTATION_CHECKLIST_FILE],
          metadata: { applied: true },
        };
      }
      case 'market_movers_report':
        return draftAndApplyArtifact({
          actionId,
          prompt: `Create a market movers report using the current economy snapshot: ${JSON.stringify(
            getGlobalEconomy()
          )}.`,
          systemPrompt:
            'Write a concise market movers report for a game economy command center.',
          filename: `market_movers_${todayKey()}.md`,
          category: 'market',
          approvalSummary:
            'Review the market movers report before publishing it to the AI output archive and home news feed.',
          successTitle: 'Market Movers Report Published',
          successSummary:
            'Generated the market movers report, saved it, and updated the shared market news entry.',
          approved,
          afterApply: async (preview) => {
            const news = readJson(NEWS_FILE, {});
            news.marketStory = preview;
            news.lastUpdated = nowIso();
            writeJson(NEWS_FILE, news);
            if (options.broadcast !== false) {
              const firstLine = preview.split('\n')[0] || preview;
              setGlobalBroadcast({
                type: 'market',
                text: firstLine,
                sentAt: nowIso(),
                sentBy: 'SILPH-GOLD UNION AI',
              });
            }
            return [NEWS_FILE];
          },
        });
      case 'portfolio_digest': {
        const user = getUser(targetUser);
        if (!user) {
          return {
            success: false,
            title: 'Portfolio Digest Failed',
            summary: `User ${targetUser} not found.`,
          };
        }
        const metrics = await buildPortfolioMetrics(targetUser);
        const prompt = `Write a premium portfolio digest for ${targetUser} using this account snapshot: ${JSON.stringify(
          {
            metrics,
            inventoryCount: Object.keys(user.inventory || {}).length,
            boxCount: user.boxes?.length || 0,
            rosterCount: user.roster?.length || 0,
          },
          null,
          2
        )}`;
        const aiResult = await callOllamaChat({
          messages: [{ role: 'user', content: prompt }],
          systemPrompt: 'Write an investor-style digest for a Pokemon-themed stock and banking system.',
          source: 'automation.portfolio_digest',
        });
        const preview = aiResult?.content || `Portfolio digest ready for ${targetUser}.`;
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Portfolio Digest',
            summary: `Review the enriched digest before sending it to ${targetUser}.`,
            preview: [
              `NET WORTH ESTIMATE: ${metrics.netWorthEstimate.toFixed(2)} PD`,
              `CHECKING: ${metrics.checking.toFixed(2)} PD`,
              `SAVINGS: ${metrics.savings.toFixed(2)} PD`,
              `RETIREMENT: ${metrics.retirement.toFixed(2)} PD`,
              `PORTFOLIO VALUE: ${metrics.estimatedPortfolioValue.toFixed(2)} PD`,
              `LIVE PRICING: ${metrics.livePricingAvailable ? 'ONLINE' : 'FALLBACK'}`,
              '',
              preview,
            ].join('\n'),
          });
        }
        appendInboxMessage(user, {
          id: `portfolio_digest_${Date.now()}_${targetUser}`,
          from: 'bn200n',
          fromDisplay: 'Silph-Gold Union Investor Desk',
          subject: 'PORTFOLIO_DIGEST',
          body: preview,
          sentAt: nowIso(),
          read: false,
          type: 'portfolio_digest',
        });
        const savedPath = writeOutputArtifact(
          `portfolio_digest_${toSlug(targetUser)}_${todayKey()}.md`,
          [
            `# Portfolio Digest`,
            '',
            `Username: ${targetUser}`,
            `Generated: ${nowIso()}`,
            '',
            `Net Worth Estimate: ${metrics.netWorthEstimate.toFixed(2)} PD`,
            `Checking: ${metrics.checking.toFixed(2)} PD`,
            `Savings: ${metrics.savings.toFixed(2)} PD`,
            `Retirement: ${metrics.retirement.toFixed(2)} PD`,
            `Portfolio Value: ${metrics.estimatedPortfolioValue.toFixed(2)} PD`,
            `Live Pricing: ${metrics.livePricingAvailable ? 'ONLINE' : 'FALLBACK'} (${metrics.pricingSource})`,
            `Holdings: ${metrics.holdingsCount}`,
            `Largest Holding: ${metrics.largestHolding ? `${metrics.largestHolding.id} (${metrics.largestHolding.estimatedValue.toFixed(2)} PD)` : 'None'}`,
            '',
            preview,
          ].join('\n'),
          'mail'
        );
        return {
          success: true,
          title: 'Portfolio Digest Delivered',
          summary: `Sent the enriched portfolio digest to ${targetUser}.`,
          preview,
          savedPaths: [savedPath],
          metadata: {
            applied: true,
            username: targetUser,
            netWorthEstimate: metrics.netWorthEstimate,
            holdingsCount: metrics.holdingsCount,
          },
        };
      }
      case 'battle_recap_digest': {
        const prompt = `Summarize the latest battle logs for admin review:\n\n${readLogBlock('battle')}`;
        const result = await draftAndApplyArtifact({
          actionId,
          prompt,
          systemPrompt: 'Write a battle recap digest for an operations dashboard.',
          filename: `battle_recap_${todayKey()}.md`,
          category: 'battle',
          approvalSummary: 'Review the battle recap before saving and mailing it.',
          successTitle: 'Battle Recap Saved',
          successSummary: 'Saved the latest battle recap digest.',
          approved,
          afterApply: async (preview) => {
            const user = getUser(targetUser);
            if (user) {
              appendInboxMessage(user, {
                id: `battle_recap_${Date.now()}_${targetUser}`,
                from: 'bn200n',
                fromDisplay: 'Battle Monitor',
                subject: 'BATTLE_RECAP_DIGEST',
                body: preview,
                sentAt: nowIso(),
                read: false,
                type: 'battle_recap',
              });
            }
            return [];
          },
        });
        return result;
      }
      case 'moderation_scan': {
        const moderationInput = `Scan the latest news, broadcast, and social log content for moderation concerns.\n\nNEWS:\n${JSON.stringify(
          readJson(NEWS_FILE, {}),
          null,
          2
        )}\n\nBROADCAST:\n${JSON.stringify(getGlobalBroadcast(), null, 2)}\n\nSOCIAL:\n${readLogBlock(
          'social'
        )}`;
        const heuristic = assessModerationSeverity(moderationInput);
        const aiResult = await callOllamaChat({
          messages: [{ role: 'user', content: moderationInput }],
          systemPrompt:
            'Write a moderation scan report with clear risk flags, likely categories, and recommended follow-up actions.',
          source: 'automation.moderation_scan',
        });
        const preview = aiResult?.content || 'Moderation scan complete.';
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Moderation Scan',
            summary: `Review the moderation scan before saving it and placing it in the moderation queue. Estimated severity: ${heuristic.severity.toUpperCase()}.`,
            preview: [
              `Heuristic Score: ${heuristic.score}`,
              `Heuristic Severity: ${heuristic.severity.toUpperCase()}`,
              `Findings: ${heuristic.findings.length ? heuristic.findings.map((item) => `${item.label} x${item.matches}`).join(', ') : 'none'}`,
              '',
              preview,
            ].join('\n'),
          });
        }

        const queueId = `mod_${Date.now()}`;
        const savedPath = writeOutputArtifact(
          `moderation_scan_${todayKey()}_${queueId}.md`,
          [
            `# Moderation Queue Report`,
            '',
            `Queue ID: ${queueId}`,
            `Created: ${nowIso()}`,
            `Severity: ${heuristic.severity.toUpperCase()}`,
            `Score: ${heuristic.score}`,
            `Findings: ${heuristic.findings.length ? heuristic.findings.map((item) => `${item.label} x${item.matches}`).join(', ') : 'none'}`,
            '',
            preview,
          ].join('\n'),
          'moderation'
        );
        const queueEntry = {
          id: queueId,
          createdAt: nowIso(),
          status: 'pending_review',
          severity: heuristic.severity,
          score: heuristic.score,
          findings: heuristic.findings,
          savedPath,
          summary: preview.split('\n')[0] || 'Moderation review queued.',
        };
        recordModerationQueue(queueEntry);
        const admin = getUser('bn200n');
        if (admin) {
          appendInboxMessage(admin, {
            id: `moderation_queue_${queueId}`,
            from: 'bn200n',
            fromDisplay: 'AI Moderation Queue',
            subject: `MODERATION_REVIEW // ${heuristic.severity.toUpperCase()}`,
            body: [
              `Queue ID: ${queueId}`,
              `Severity: ${heuristic.severity.toUpperCase()}`,
              `Score: ${heuristic.score}`,
              `Findings: ${heuristic.findings.length ? heuristic.findings.map((item) => `${item.label} x${item.matches}`).join(', ') : 'none'}`,
              '',
              preview,
            ].join('\n'),
            sentAt: nowIso(),
            read: false,
            type: 'moderation_queue',
          });
        }
        return {
          success: true,
          title: 'Moderation Scan Queued',
          summary: `Saved the moderation report and placed it in the review queue with ${heuristic.severity.toUpperCase()} severity.`,
          preview,
          savedPaths: [savedPath],
          metadata: {
            applied: true,
            queueId,
            severity: heuristic.severity,
            score: heuristic.score,
          },
        };
      }
      case 'quest_bulletin': {
        const recipient = options.username || 'bn200n';
        const prompt = `Draft a daily quest bulletin for ${recipient}.`;
        const aiResult = await callOllamaChat({
          messages: [{ role: 'user', content: prompt }],
          systemPrompt: 'Write a short, energizing quest bulletin for a Pokemon game inbox.',
          source: 'automation.quest_bulletin',
        });
        const preview = aiResult?.content || 'Quest bulletin ready.';
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Quest Bulletin',
            summary: `Review the bulletin before sending it to ${recipient}.`,
            preview,
          });
        }
        const user = getUser(recipient);
        if (user) {
          appendInboxMessage(user, {
            id: `quest_bulletin_${Date.now()}_${recipient}`,
            from: 'bn200n',
            fromDisplay: 'Operations Bulletin Board',
            subject: 'DAILY_QUEST_BULLETIN',
            body: preview,
            sentAt: nowIso(),
            read: false,
            type: 'quest_bulletin',
          });
        }
        const savedPath = writeOutputArtifact(`quest_bulletin_${todayKey()}.md`, preview, 'bulletin');
        return {
          success: true,
          title: 'Quest Bulletin Delivered',
          summary: `Quest bulletin saved and routed to ${recipient}.`,
          preview,
          savedPaths: [savedPath],
          metadata: { applied: true, username: recipient },
        };
      }
      case 'event_spotlight':
        return draftAndApplyArtifact({
          actionId,
          prompt: 'Create event spotlight promo copy for the home screen and admin queue.',
          systemPrompt: 'Write polished event promo copy for a live game operations team.',
          filename: `event_spotlight_${todayKey()}.md`,
          category: 'event',
          approvalSummary: 'Review the spotlight copy before saving and broadcasting it.',
          successTitle: 'Event Spotlight Saved',
          successSummary: 'Saved the event spotlight copy.',
          approved,
          afterApply: async (preview) => {
            if (options.broadcast !== false) {
              setGlobalBroadcast({
                type: 'event',
                text: preview.split('\n')[0] || preview,
                sentAt: nowIso(),
                sentBy: 'SILPH-GOLD UNION AI',
              });
            }
            return [];
          },
        });
      case 'trainer_reengagement': {
        const recipient = options.username || 'bn200n';
        const user = getUser(recipient);
        if (!user) {
          return {
            success: false,
            title: 'Trainer Nudge Failed',
            summary: `User ${recipient} not found.`,
          };
        }
        const aiResult = await callOllamaChat({
          messages: [{ role: 'user', content: `Write a re-engagement inbox mail for returning player ${recipient}.` }],
          systemPrompt: 'Write warm return-player messaging for a Pokemon game inbox.',
          source: 'automation.trainer_reengagement',
        });
        const preview = aiResult?.content || `Come back in, ${recipient}. Your adventure is waiting.`;
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Trainer Nudge',
            summary: `Review the message before sending it to ${recipient}.`,
            preview,
          });
        }
        appendInboxMessage(user, {
          id: `trainer_nudge_${Date.now()}_${recipient}`,
          from: 'bn200n',
          fromDisplay: 'Pokemon Center Outreach',
          subject: 'RETURNING_TRAINER_UPDATE',
          body: preview,
          sentAt: nowIso(),
          read: false,
          type: 'trainer_nudge',
        });
        return {
          success: true,
          title: 'Trainer Nudge Sent',
          summary: `Sent a re-engagement message to ${recipient}.`,
          preview,
          metadata: { applied: true, username: recipient },
        };
      }
      case 'market_news_translation': {
        const aiResult = await callOllamaChat({
          messages: [
            {
              role: 'user',
              content: `Rewrite this economy data into in-world market news:\n${JSON.stringify(
                getGlobalEconomy(),
                null,
                2
              )}`,
            },
          ],
          systemPrompt: 'Write market news in a Pokemon Gen V themed financial terminal voice.',
          source: 'automation.market_news_translation',
        });
        const preview = aiResult?.content || 'Market news rewrite ready.';
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Market News Rewrite',
            summary: 'Review the rewritten market news before saving it into news.json.',
            preview,
          });
        }
        const news = readJson(NEWS_FILE, {});
        news.marketStory = preview;
        news.lastUpdated = nowIso();
        writeJson(NEWS_FILE, news);
        return {
          success: true,
          title: 'Market News Updated',
          summary: 'Wrote the rewritten market story into the shared news payload.',
          preview,
          savedPaths: [NEWS_FILE],
          metadata: { applied: true },
        };
      }
      case 'banking_risk_audit':
        return draftAndApplyArtifact({
          actionId,
          prompt: `Audit these player banking records for risk:\n${JSON.stringify(
            getUsers().map((user) => ({
              username: user.username,
              balance: user.bank?.balance || 0,
              inboxCount: user.inbox?.length || 0,
            })),
            null,
            2
          )}`,
          systemPrompt: 'Write a banking risk audit with concrete concerns and recommendations.',
          filename: `banking_risk_audit_${todayKey()}.md`,
          category: 'banking',
          approvalSummary:
            'Review the banking risk audit before saving it, routing it to ops, and triggering any low-balance follow-up.',
          successTitle: 'Banking Risk Audit Applied',
          successSummary:
            'Saved the banking risk audit, routed it to ops, and processed optional low-balance follow-up.',
          approved,
          afterApply: async (preview) => {
            const admin = getUser('bn200n');
            if (admin) {
              appendInboxMessage(admin, {
                id: `banking_risk_${Date.now()}_bn200n`,
                from: 'bn200n',
                fromDisplay: 'Silph-Gold Union Risk Desk',
                subject: 'BANKING_RISK_AUDIT',
                body: preview,
                sentAt: nowIso(),
                read: false,
                type: 'banking_risk_audit',
              });
            }
            if (options.sendAlerts !== false) {
              await sendLowBalanceAlerts({
                threshold: Number(options.threshold || 2500),
                approved: true,
                allUsers: true,
              });
            }
            return [];
          },
        });
      case 'mail_campaign': {
        const recipients = String(options.recipients || 'bn200n')
          .split(',')
          .map((item) => item.trim())
          .filter(Boolean);
        const subject = options.subject || 'OPERATIONS_UPDATE';
        const aiResult = await callOllamaChat({
          messages: [
            {
              role: 'user',
              content: `Write a concise multi-player announcement for these recipients: ${recipients.join(', ')}.`,
            },
          ],
          systemPrompt: 'Write inbox campaign copy for a Pokemon game operations team.',
          source: 'automation.mail_campaign',
        });
        const preview = aiResult?.content || 'Campaign message ready.';
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Mail Campaign',
            summary: `Review the campaign before sending it to ${recipients.join(', ')}.`,
            preview,
          });
        }
        const delivered = [];
        for (const recipient of recipients) {
          const user = getUser(recipient);
          if (!user) continue;
          appendInboxMessage(user, {
            id: `mail_campaign_${Date.now()}_${recipient}`,
            from: 'bn200n',
            fromDisplay: 'Pokemon Center Command',
            subject,
            body: preview,
            sentAt: nowIso(),
            read: false,
            type: 'mail_campaign',
          });
          delivered.push(recipient);
        }
        const savedPath = writeOutputArtifact(`mail_campaign_${todayKey()}.md`, preview, 'mail');
        return {
          success: true,
          title: 'Mail Campaign Sent',
          summary: delivered.length
            ? `Delivered the campaign to ${delivered.join(', ')}.`
            : 'No matching recipients were found.',
          preview,
          savedPaths: [savedPath],
          metadata: { applied: true, recipients: delivered },
        };
      }
      case 'support_reply_draft': {
        const supportContext = options.prompt || 'General account assistance.';
        const aiResult = await callOllamaChat({
          messages: [
            {
              role: 'user',
              content: `Draft a support reply for ${targetUser}. Additional context: ${supportContext}`,
            },
          ],
          systemPrompt: 'Write a support-ready admin reply in a calm, helpful tone.',
          source: 'automation.support_reply_draft',
        });
        const preview = aiResult?.content || `Support draft ready for ${targetUser}.`;
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Support Draft',
            summary: `Review the support reply before saving it and routing it into the support queue for ${targetUser}.`,
            preview,
          });
        }

        const ticketId = `support_${Date.now()}`;
        const savedPath = writeOutputArtifact(
          `support_reply_${toSlug(targetUser)}_${todayKey()}_${ticketId}.md`,
          [
            `# Support Draft`,
            '',
            `Ticket ID: ${ticketId}`,
            `Target User: ${targetUser}`,
            `Created: ${nowIso()}`,
            `Status: draft_ready`,
            '',
            `Context: ${supportContext}`,
            '',
            preview,
          ].join('\n'),
          'support'
        );
        const queueEntry = {
          id: ticketId,
          createdAt: nowIso(),
          status: 'draft_ready',
          username: targetUser,
          context: supportContext,
          savedPath,
          summary: preview.split('\n')[0] || `Support draft ready for ${targetUser}.`,
        };
        recordSupportQueue(queueEntry);
        const admin = getUser('bn200n');
        if (admin) {
          appendInboxMessage(admin, {
            id: `support_queue_${ticketId}`,
            from: 'bn200n',
            fromDisplay: 'AI Support Queue',
            subject: `SUPPORT_DRAFT_READY // ${targetUser}`,
            body: [
              `Ticket ID: ${ticketId}`,
              `Target User: ${targetUser}`,
              `Status: draft_ready`,
              '',
              preview,
            ].join('\n'),
            sentAt: nowIso(),
            read: false,
            type: 'support_queue',
          });
        }
        return {
          success: true,
          title: 'Support Draft Queued',
          summary: `Saved the support draft for ${targetUser} and routed it into the support queue.`,
          preview,
          savedPaths: [savedPath],
          metadata: {
            applied: true,
            username: targetUser,
            ticketId,
            status: 'draft_ready',
          },
        };
      }
      case 'custom_prompt':
        return draftAndApplyArtifact({
          actionId,
          prompt: options.prompt || 'Execute a custom AI task for Pokemon Generations operations.',
          systemPrompt:
            'You are a production operations AI helping run a Pokemon-themed game platform. Return concise practical output.',
          filename: `custom_prompt_${Date.now()}.md`,
          category: 'custom',
          approvalSummary: 'Review the custom prompt output before saving it.',
          successTitle: 'Custom Prompt Saved',
          successSummary: 'Saved the custom prompt output.',
          approved,
        });
      case 'stock_storyboard':
        return draftAndApplyArtifact({
          actionId,
          prompt: 'Write a narrative stock-market storyboard for today’s market cycle.',
          systemPrompt: 'Write vivid but concise stock-market narrative copy in a Pokemon Gen V terminal style.',
          filename: `stock_storyboard_${todayKey()}.md`,
          category: 'market',
          approvalSummary: 'Review the stock story before saving it and optionally broadcasting it.',
          successTitle: 'Stock Story Saved',
          successSummary: 'Saved the stock-market storyboard.',
          approved,
        });
      case 'lore_sync':
        return draftAndApplyArtifact({
          actionId,
          prompt: `Align the following systems language to the project lore tone. Topic: ${options.topic || 'Global Link + Silph-Gold operations'}.`,
          systemPrompt: 'Write lore-aligned copy for a Pokemon-themed operations platform.',
          filename: `lore_sync_${todayKey()}.md`,
          category: 'lore',
          approvalSummary: 'Review the lore sync pass before saving it.',
          successTitle: 'Lore Sync Saved',
          successSummary: 'Saved the lore synchronization notes.',
          approved,
        });
      case 'release_briefing_mail': {
        const recipients = String(options.recipients || 'bn200n')
          .split(',')
          .map((item) => item.trim())
          .filter(Boolean);
        const changelog = fs.existsSync(CHANGELOG_FILE)
          ? fs.readFileSync(CHANGELOG_FILE, 'utf8')
          : 'Release notes not found.';
        const aiResult = await callOllamaChat({
          messages: [
            {
              role: 'user',
              content: `Turn this release note into inbox mail:\n\n${changelog}`,
            },
          ],
          systemPrompt: 'Write a crisp release-summary inbox mail.',
          source: 'automation.release_briefing_mail',
        });
        const preview = aiResult?.content || 'Release summary mail ready.';
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Release Mail',
            summary: `Review the release mail before sending it to ${recipients.join(', ')}.`,
            preview,
          });
        }
        const delivered = [];
        for (const recipient of recipients) {
          const user = getUser(recipient);
          if (!user) continue;
          appendInboxMessage(user, {
            id: `release_mail_${Date.now()}_${recipient}`,
            from: 'bn200n',
            fromDisplay: 'Release Coordination',
            subject: 'RELEASE_BRIEFING',
            body: preview,
            sentAt: nowIso(),
            read: false,
            type: 'release_briefing_mail',
          });
          delivered.push(recipient);
        }
        return {
          success: true,
          title: 'Release Mail Delivered',
          summary: delivered.length
            ? `Sent the release briefing to ${delivered.join(', ')}.`
            : 'No matching recipients were found.',
          preview,
          metadata: { applied: true, recipients: delivered },
        };
      }
      case 'broadcast_polish': {
        const sourceText =
          options.prompt ||
          getGlobalBroadcast()?.text ||
          'New systems update incoming for Pokemon Center players.';
        const aiResult = await callOllamaChat({
          messages: [{ role: 'user', content: `Polish this broadcast:\n\n${sourceText}` }],
          systemPrompt: 'Polish this into a concise system-wide game broadcast.',
          source: 'automation.broadcast_polish',
        });
        const preview = aiResult?.content || sourceText;
        if (!approved) {
          return createApprovalResult({
            actionId,
            title: 'Approve Broadcast Polish',
            summary: 'Review the broadcast before publishing it globally.',
            preview,
          });
        }
        setGlobalBroadcast({
          type: 'announcement',
          text: preview,
          sentAt: nowIso(),
          sentBy: 'SILPH-GOLD UNION AI',
        });
        return {
          success: true,
          title: 'Broadcast Updated',
          summary: 'Published the polished global broadcast.',
          preview,
          metadata: { applied: true },
        };
      }
      case 'system_storyline':
        return draftAndApplyArtifact({
          actionId,
          prompt: `Turn these system changes into themed copy: ${options.topic || 'AI panel production upgrade with approvals, telemetry, and memory.'}`,
          systemPrompt: 'Write system change notes as polished themed copy for internal and player-facing use.',
          filename: `system_storyline_${todayKey()}.md`,
          category: 'storyline',
          approvalSummary: 'Review the system storyline before saving it.',
          successTitle: 'System Storyline Saved',
          successSummary: 'Saved the system storyline copy.',
          approved,
        });
      default:
        return draftAndApplyArtifact({
          actionId,
          prompt: `Execute the automation "${title}" for Pokemon Generations and return concise admin-ready output.`,
          systemPrompt:
            'You are a production operations AI helping run a Pokemon-themed game platform. Return concise practical output.',
          filename: `${toSlug(title)}_${Date.now()}.md`,
          category: 'general',
          approvalSummary: `Review the ${title} output before saving it.`,
          successTitle: `${title} Saved`,
          successSummary: `Executed and saved ${title}.`,
          approved,
        });
    }
  }

  app.get('/ai/status', async (_req, res) => {
    res.json(await buildStatusPayload());
  });

  app.get('/ai/queues', (_req, res) => {
    const state = readAiState();
    res.json({
      success: true,
      moderation: state.moderationQueue,
      support: state.supportQueue,
    });
  });

  app.post('/ai/queues/:queueType/:id/status', async (req, res) => {
    const result = await applyQueueStatus(
      req.params.queueType,
      req.params.id,
      req.body?.status,
      req.body?.note
    );
    if (!result.success) {
      return res.status(400).json(result);
    }
    res.json(result);
  });

  app.get('/ai/chat/state', (_req, res) => {
    res.json(getConversationStatePayload());
  });

  app.get('/ai/chat/session/:id', (req, res) => {
    const session = fetchConversationSession(req.params.id);
    if (!session) {
      return res.status(404).json({
        success: false,
        summary: 'Conversation not found.',
      });
    }
    res.json({ success: true, session });
  });

  app.post('/ai/chat/new', (_req, res) => {
    res.json({
      success: true,
      summary: 'Started a new chat session.',
      ...startNewConversation(),
    });
  });

  app.post('/ai/chat/export', (req, res) => {
    try {
      const state = readAiState();
      const sessionId = req.body?.sessionId || state.conversations.currentSessionId;
      const filePath = exportConversation(sessionId);
      res.json({
        success: true,
        summary: 'Exported the conversation to markdown.',
        path: filePath,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        summary: error.message,
      });
    }
  });

  app.post('/ai/install-model', async (req, res) => {
    const model = req.body?.model || DEFAULT_MODEL;
    if (!allowedModels.includes(model)) {
      return res.status(400).json({
        success: false,
        summary:
          'Only lightweight Mac-safe model presets are allowed from the AI panel to protect the machine while the full stack is running.',
      });
    }
    const status = await fetchStatus();
    if (!status.cliInstalled) {
      return res.status(400).json({
        success: false,
        summary: 'Ollama CLI is not installed. Install the macOS app first, then pull the recommended model.',
      });
    }
    if (!status.serviceReachable) {
      return res.status(503).json({
        success: false,
        summary: 'Ollama runtime is offline. Since Ollama is expected to run at boot, verify the local service is healthy and retry.',
      });
    }
    if (installState.active) {
      return res.status(409).json({
        success: false,
        summary: `A model download is already running for ${installState.model}.`,
      });
    }

    try {
      res.json({
        success: true,
        summary: `Started downloading ${model}.`,
        install: { ...installState, model, status: 'starting' },
      });
      startModelInstall(model).catch((error) => {
        log('error', `[AI] Failed to install Ollama model ${model}: ${error.message}`);
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        summary: `Failed to install ${model}: ${error.message}`,
      });
    }
  });

  app.post('/ai/install-model/cancel', (_req, res) => {
    const result = cancelModelInstall();
    if (!result.success) {
      return res.status(400).json(result);
    }
    res.json(result);
  });

  app.post('/ai/chat', async (req, res) => {
    const state = readAiState();
    const session =
      fetchConversationSession(req.body?.sessionId) || ensureCurrentConversation(state);
    if (!fetchConversationSession(session.id)) {
      writeAiState(state);
    }

    const messageContent =
      req.body?.message ||
      (Array.isArray(req.body?.messages) ? req.body.messages.slice(-1)[0]?.content : '') ||
      '';

    if (!messageContent.trim()) {
      return res.status(400).json({
        success: false,
        reply: 'A chat message is required.',
      });
    }

    appendConversationMessage(session.id, {
      role: 'user',
      content: messageContent.trim(),
      timestamp: nowIso(),
    });

    const replyResult = await callOllamaChat({
      messages: Array.isArray(req.body?.messages)
        ? req.body.messages
        : [{ role: 'user', content: messageContent.trim() }],
      model: req.body?.model || DEFAULT_MODEL,
      systemPrompt: req.body?.systemPrompt,
      source: 'chat',
      sessionId: session.id,
    });

    if (!replyResult?.content) {
      return res.json({
        success: false,
        reply:
          'Local AI is not reachable yet. Ollama should already be running at boot, so check the service health and model availability.',
      });
    }

    appendConversationMessage(session.id, {
      role: 'assistant',
      content: replyResult.content,
      timestamp: nowIso(),
      telemetry: replyResult.telemetry,
    });

    const current = fetchConversationSession(session.id);
    res.json({
      success: true,
      reply: replyResult.content,
      telemetry: replyResult.telemetry,
      sessionId: session.id,
      messages: current?.messages || [],
    });
  });

  app.get('/ai/daily-login-briefing', async (req, res) => {
    res.json(
      await generateDailyBriefing({
        username: req.query?.username,
        deliverToInbox: req.query?.deliverToInbox !== 'false',
        force: req.query?.force === 'true',
        approved: true,
      })
    );
  });

  app.post('/ai/automation/run', async (req, res) => {
    const actionId = req.body?.actionId;
    if (!actionId) {
      return res.status(400).json({
        success: false,
        title: 'Missing Action',
        summary: 'actionId is required.',
      });
    }

    const approved = req.body?.approved === true;
    const result = await runAutomation(actionId, req.body?.options || {}, approved);
    recordAutomationHistory({
      actionId,
      title: result.title,
      summary: result.summary,
      ranAt: nowIso(),
      success: result.success,
      approved,
      requiresApproval: result.metadata?.requiresApproval === true,
      savedPaths: result.savedPaths || [],
      metadata: result.metadata || {},
    });
    res.json(result);
  });

  return {
    onTradeExecuted: async ({ username, action, assetId, shares, priceAtTrade }) => {
      try {
        await sendTradeAlert({
          username,
          action,
          assetId,
          shares,
          priceAtTrade,
          approved: true,
        });
      } catch (error) {
        log('error', `[AI] Trade alert failed: ${error.message}`);
      }
    },
    onBankBalanceChanged: async ({ username }) => {
      try {
        await sendLowBalanceAlerts({
          username,
          allUsers: false,
          threshold: 2500,
          approved: true,
        });
      } catch (error) {
        log('error', `[AI] Low balance alert failed: ${error.message}`);
      }
    },
  };
}

module.exports = { registerAiFeatures };
