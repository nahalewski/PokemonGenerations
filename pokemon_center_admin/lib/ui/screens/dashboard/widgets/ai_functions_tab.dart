import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme.dart';
import '../../../../models/admin_models.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/admin_tab_logger.dart';
import '../../../../services/ai_models.dart';

class AiFunctionsTab extends StatefulWidget {
  const AiFunctionsTab({super.key});

  @override
  State<AiFunctionsTab> createState() => _AiFunctionsTabState();
}

class _AiFunctionsTabState extends State<AiFunctionsTab> {
  final AdminService _service = AdminService();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  List<Map<String, String>> _messages = [];
  String _selectedModel = 'qwen2.5:3b-instruct-q3_K_S';
  String? _currentSessionId;
  Map<String, dynamic>? _status;
  List<Map<String, dynamic>> _sessionSummaries = const [];
  List<Map<String, dynamic>> _automationHistory = const [];
  List<Map<String, dynamic>> _installHistory = const [];
  List<Map<String, dynamic>> _moderationQueue = const [];
  List<Map<String, dynamic>> _supportQueue = const [];

  bool _isLoadingStatus = true;
  bool _isSending = false;
  bool _isInstallingModel = false;
  bool _statusPolling = false;
  String? _lastAutomationSummary;
  String? _lastCompletedInstallKey;

  static const List<_AiActionConfig> _actions = [
    _AiActionConfig(
      id: 'generate_daily_briefing',
      title: 'Daily Briefing',
      subtitle: 'Create the daily login post',
      icon: Icons.today_rounded,
      accent: Color(0xFF64FFDA),
      fields: [
        _AiFieldConfig(
          id: 'username',
          label: 'Inbox Username',
          type: _AiFieldType.text,
        ),
        _AiFieldConfig(
          id: 'deliverToInbox',
          label: 'Send To Inbox',
          type: _AiFieldType.toggle,
          initialBool: true,
        ),
        _AiFieldConfig(
          id: 'force',
          label: 'Force Refresh',
          type: _AiFieldType.toggle,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'sync_home_news',
      title: 'Home News',
      subtitle: 'Update home news + changelog',
      icon: Icons.newspaper_rounded,
      accent: Color(0xFFFFB86C),
      fields: [
        _AiFieldConfig(
          id: 'headline',
          label: 'Headline Focus',
          type: _AiFieldType.text,
        ),
        _AiFieldConfig(
          id: 'broadcast',
          label: 'Broadcast After Save',
          type: _AiFieldType.toggle,
          initialBool: true,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'send_trade_alerts',
      title: 'Trade Alerts',
      subtitle: 'Send player trade confirmations',
      icon: Icons.swap_horiz_rounded,
      accent: Color(0xFF8BE9FD),
      fields: [
        _AiFieldConfig(
          id: 'username',
          label: 'Username',
          type: _AiFieldType.text,
        ),
        _AiFieldConfig(
          id: 'assetId',
          label: 'Asset ID',
          type: _AiFieldType.text,
        ),
        _AiFieldConfig(
          id: 'action',
          label: 'Buy Or Sell',
          type: _AiFieldType.dropdown,
          options: ['buy', 'sell'],
        ),
        _AiFieldConfig(
          id: 'shares',
          label: 'Shares',
          type: _AiFieldType.text,
          initialText: '0',
        ),
        _AiFieldConfig(
          id: 'priceAtTrade',
          label: 'Trade Price',
          type: _AiFieldType.text,
          initialText: '0',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'send_low_balance_alerts',
      title: 'Low Balance',
      subtitle: 'Audit and warn low vault balances',
      icon: Icons.account_balance_wallet_outlined,
      accent: Color(0xFFFF5555),
      fields: [
        _AiFieldConfig(
          id: 'threshold',
          label: 'Threshold',
          type: _AiFieldType.text,
          initialText: '2500',
        ),
        _AiFieldConfig(
          id: 'allUsers',
          label: 'Scan All Users',
          type: _AiFieldType.toggle,
          initialBool: true,
        ),
        _AiFieldConfig(
          id: 'username',
          label: 'Single Username',
          type: _AiFieldType.text,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'generate_release_changelog',
      title: 'Release Notes',
      subtitle: 'Draft GitHub-style release notes',
      icon: Icons.assignment_rounded,
      accent: Color(0xFF50FA7B),
      fields: [
        _AiFieldConfig(
          id: 'version',
          label: 'Version',
          type: _AiFieldType.text,
          initialText: 'v3.0.0+1',
        ),
        _AiFieldConfig(
          id: 'writeFiles',
          label: 'Write To Files',
          type: _AiFieldType.toggle,
          initialBool: true,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'summarize_logs',
      title: 'Log Summary',
      subtitle: 'Condense backend and devops logs',
      icon: Icons.receipt_long_rounded,
      accent: Color(0xFFBD93F9),
      fields: [
        _AiFieldConfig(
          id: 'scope',
          label: 'Scope',
          type: _AiFieldType.dropdown,
          options: ['system', 'battle', 'social', 'all'],
          initialText: 'all',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'market_movers_report',
      title: 'Market Movers',
      subtitle: 'Publish the top movers report',
      icon: Icons.trending_up_rounded,
      accent: Color(0xFF64FFDA),
      fields: [
        _AiFieldConfig(
          id: 'broadcast',
          label: 'Broadcast Summary',
          type: _AiFieldType.toggle,
          initialBool: true,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'portfolio_digest',
      title: 'Portfolio Digest',
      subtitle: 'Create investor summary mail',
      icon: Icons.pie_chart_outline_rounded,
      accent: Color(0xFF8BE9FD),
      fields: [
        _AiFieldConfig(
          id: 'username',
          label: 'Username',
          type: _AiFieldType.text,
          initialText: 'bn200n',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'battle_recap_digest',
      title: 'Battle Recap',
      subtitle: 'Summarize recent battle logs',
      icon: Icons.sports_martial_arts_rounded,
      accent: Color(0xFFFFB86C),
      fields: [
        _AiFieldConfig(
          id: 'username',
          label: 'Notify Username',
          type: _AiFieldType.text,
          initialText: 'bn200n',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'moderation_scan',
      title: 'Moderation',
      subtitle: 'Scan mail/news wording',
      icon: Icons.policy_outlined,
      accent: Color(0xFFFF5555),
    ),
    _AiActionConfig(
      id: 'quest_bulletin',
      title: 'Quest Bulletin',
      subtitle: 'Draft and send a daily objective mail',
      icon: Icons.flag_outlined,
      accent: Color(0xFF50FA7B),
      fields: [
        _AiFieldConfig(
          id: 'username',
          label: 'Recipient Username',
          type: _AiFieldType.text,
          initialText: 'bn200n',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'event_spotlight',
      title: 'Event Spotlight',
      subtitle: 'Create event promo copy',
      icon: Icons.event_available_rounded,
      accent: Color(0xFFBD93F9),
      fields: [
        _AiFieldConfig(
          id: 'broadcast',
          label: 'Broadcast After Save',
          type: _AiFieldType.toggle,
          initialBool: true,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'devops_digest',
      title: 'DevOps Digest',
      subtitle: 'Update devops changelog',
      icon: Icons.settings_suggest_rounded,
      accent: Color(0xFF8BE9FD),
      fields: [
        _AiFieldConfig(
          id: 'scope',
          label: 'Scope',
          type: _AiFieldType.dropdown,
          options: ['system', 'battle', 'social', 'all'],
          initialText: 'all',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'ops_checklist',
      title: 'Checklist',
      subtitle: 'Refresh implementation checklist',
      icon: Icons.checklist_rounded,
      accent: Color(0xFF64FFDA),
    ),
    _AiActionConfig(
      id: 'trainer_reengagement',
      title: 'Trainer Nudge',
      subtitle: 'Write return-player mail',
      icon: Icons.mark_email_unread_outlined,
      accent: Color(0xFFFFB86C),
      fields: [
        _AiFieldConfig(
          id: 'username',
          label: 'Username',
          type: _AiFieldType.text,
          initialText: 'bn200n',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'market_news_translation',
      title: 'News Rewrite',
      subtitle: 'Turn raw market data into in-world copy',
      icon: Icons.translate_rounded,
      accent: Color(0xFFBD93F9),
    ),
    _AiActionConfig(
      id: 'banking_risk_audit',
      title: 'Risk Audit',
      subtitle: 'Check banking warning conditions',
      icon: Icons.security_rounded,
      accent: Color(0xFFFF5555),
      fields: [
        _AiFieldConfig(
          id: 'threshold',
          label: 'Low Balance Threshold',
          type: _AiFieldType.text,
          initialText: '2500',
        ),
        _AiFieldConfig(
          id: 'sendAlerts',
          label: 'Send Low Balance Follow-Up',
          type: _AiFieldType.toggle,
          initialBool: true,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'mail_campaign',
      title: 'Mail Campaign',
      subtitle: 'Compose multi-player announcement',
      icon: Icons.campaign_outlined,
      accent: Color(0xFF50FA7B),
      fields: [
        _AiFieldConfig(
          id: 'recipients',
          label: 'Recipients (comma separated)',
          type: _AiFieldType.multiline,
          initialText: 'bn200n',
        ),
        _AiFieldConfig(
          id: 'subject',
          label: 'Subject',
          type: _AiFieldType.text,
          initialText: 'OPERATIONS_UPDATE',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'support_reply_draft',
      title: 'Support Draft',
      subtitle: 'Prepare admin response copy',
      icon: Icons.support_agent_rounded,
      accent: Color(0xFF8BE9FD),
      fields: [
        _AiFieldConfig(
          id: 'username',
          label: 'Username',
          type: _AiFieldType.text,
          initialText: 'bn200n',
        ),
        _AiFieldConfig(
          id: 'prompt',
          label: 'Support Context',
          type: _AiFieldType.multiline,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'custom_prompt',
      title: 'Custom Prompt',
      subtitle: 'Run a custom AI task',
      icon: Icons.auto_awesome_rounded,
      accent: Color(0xFF64FFDA),
      fields: [
        _AiFieldConfig(
          id: 'prompt',
          label: 'Prompt',
          type: _AiFieldType.multiline,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'stock_storyboard',
      title: 'Stock Story',
      subtitle: 'Narrative stock ticker copy',
      icon: Icons.auto_graph_rounded,
      accent: Color(0xFFFFB86C),
    ),
    _AiActionConfig(
      id: 'lore_sync',
      title: 'Lore Sync',
      subtitle: 'Align region/world tone',
      icon: Icons.menu_book_rounded,
      accent: Color(0xFFBD93F9),
      fields: [
        _AiFieldConfig(
          id: 'topic',
          label: 'Topic',
          type: _AiFieldType.text,
          initialText: 'Global Link + Silph-Gold operations',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'release_briefing_mail',
      title: 'Release Mail',
      subtitle: 'Send release-summary inbox mail',
      icon: Icons.mail_lock_rounded,
      accent: Color(0xFF50FA7B),
      fields: [
        _AiFieldConfig(
          id: 'recipients',
          label: 'Recipients (comma separated)',
          type: _AiFieldType.multiline,
          initialText: 'bn200n',
        ),
      ],
    ),
    _AiActionConfig(
      id: 'broadcast_polish',
      title: 'Broadcast Polish',
      subtitle: 'Refine a world broadcast',
      icon: Icons.record_voice_over_rounded,
      accent: Color(0xFF8BE9FD),
      fields: [
        _AiFieldConfig(
          id: 'prompt',
          label: 'Current Broadcast',
          type: _AiFieldType.multiline,
        ),
      ],
    ),
    _AiActionConfig(
      id: 'system_storyline',
      title: 'System Story',
      subtitle: 'Turn ops into themed copy',
      icon: Icons.movie_filter_outlined,
      accent: Color(0xFF64FFDA),
      fields: [
        _AiFieldConfig(
          id: 'topic',
          label: 'System Topic',
          type: _AiFieldType.text,
          initialText: 'AI panel production upgrade',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    AdminTabLogger.log('ai_operations', 'tab_initialized');
    _initialize();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _refreshStatus();
    await _loadConversationState();
  }

  Future<void> _refreshStatus() async {
    if (mounted) {
      setState(() => _isLoadingStatus = true);
    }
    await AdminTabLogger.log('ai_operations', 'status_refresh_started');
    try {
      final status = await _service.fetchAiStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _automationHistory =
            ((status['automationHistory'] as List?) ?? const [])
                .whereType<Map>()
                .map(
                  (item) => item.map((key, value) => MapEntry('$key', value)),
                )
                .toList();
        _installHistory = ((status['installHistory'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => item.map((key, value) => MapEntry('$key', value)))
            .toList();
        _moderationQueue = ((status['moderationQueue'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => item.map((key, value) => MapEntry('$key', value)))
            .toList();
        _supportQueue = ((status['supportQueue'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => item.map((key, value) => MapEntry('$key', value)))
            .toList();
        _sessionSummaries =
            (((status['conversations'] as Map?)?['sessions'] as List?) ??
                    const [])
                .whereType<Map>()
                .map(
                  (item) => item.map((key, value) => MapEntry('$key', value)),
                )
                .toList();

        final configured = status['recommendedModel']?.toString();
        if (configured != null && configured.isNotEmpty) {
          _selectedModel = configured;
        }
      });
      await AdminTabLogger.log(
        'ai_operations',
        'status_refresh_completed',
        details: {
          'serviceReachable': status['serviceReachable'] == true,
          'cliInstalled': status['cliInstalled'] == true,
          'models': (status['models'] as List? ?? const []).length,
          'installing': (status['install'] as Map?)?['active'] == true,
        },
      );
      _syncInstallPolling(status);
    } catch (error) {
      await AdminTabLogger.log(
        'ai_operations',
        'status_refresh_failed',
        error: error,
      );
      if (!mounted) return;
      _showSnack('AI status error: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoadingStatus = false);
      }
    }
  }

  Future<void> _loadConversationState() async {
    try {
      final response = await _service.fetchAiChatState();
      final currentSession = ((response['currentSession'] as Map?) ?? const {})
          .map((key, value) => MapEntry('$key', value));
      final currentMessages =
          ((currentSession['messages'] as List?) ?? const [])
              .whereType<Map>()
              .map(
                (item) => {
                  'role': item['role']?.toString() ?? 'assistant',
                  'content': item['content']?.toString() ?? '',
                },
              )
              .toList();
      if (!mounted) return;
      setState(() {
        _currentSessionId = response['currentSessionId']?.toString();
        _messages = currentMessages;
        _sessionSummaries = ((response['sessions'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => item.map((key, value) => MapEntry('$key', value)))
            .toList();
      });
      _scrollToBottom();
    } catch (error) {
      await AdminTabLogger.log(
        'ai_operations',
        'chat_state_load_failed',
        error: error,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isSending) return;

    if (mounted) {
      setState(() => _isSending = true);
    }
    await AdminTabLogger.log(
      'ai_operations',
      'chat_message_sent',
      details: {'length': text.length, 'model': _selectedModel},
    );

    try {
      final response = await _service.chatWithAi(
        message: text,
        sessionId: _currentSessionId,
        messages: [
          for (final message in _messages)
            {
              'role': message['role'] ?? 'assistant',
              'content': message['content'] ?? '',
            },
          {'role': 'user', 'content': text},
        ],
        model: _selectedModel,
        systemPrompt:
            'You are the Silph-Gold Union operations AI. Speak clearly, stay practical, and help with game operations, news, banking alerts, release notes, and admin workflows.',
      );

      if (response['success'] != true) {
        throw Exception(
          response['reply']?.toString() ?? 'AI runtime unavailable.',
        );
      }

      final messages = ((response['messages'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => {
              'role': item['role']?.toString() ?? 'assistant',
              'content': item['content']?.toString() ?? '',
            },
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _currentSessionId =
            response['sessionId']?.toString() ?? _currentSessionId;
        _messages = messages;
        _chatController.clear();
      });
      await AdminTabLogger.log(
        'ai_operations',
        'chat_reply_received',
        details: {
          'model': _selectedModel,
          'durationMs': ((response['telemetry'] as Map?)?['durationMs'])
              ?.toString(),
        },
      );
      _scrollToBottom();
      await _refreshStatus();
    } catch (error) {
      await AdminTabLogger.log(
        'ai_operations',
        'chat_failed',
        details: {'model': _selectedModel},
        error: error,
      );
      if (!mounted) return;
      _showSnack('Chat failed: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _startNewChat() async {
    try {
      final response = await _service.startNewAiChat();
      final currentSession = ((response['currentSession'] as Map?) ?? const {})
          .map((key, value) => MapEntry('$key', value));
      final messages = ((currentSession['messages'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => {
              'role': item['role']?.toString() ?? 'assistant',
              'content': item['content']?.toString() ?? '',
            },
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _currentSessionId = response['currentSessionId']?.toString();
        _messages = messages;
        _sessionSummaries = ((response['sessions'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => item.map((key, value) => MapEntry('$key', value)))
            .toList();
      });
      _showSnack('Started a new chat. The previous session was archived.');
      _scrollToBottom();
    } catch (error) {
      _showSnack('Failed to start a new chat: $error', isError: true);
    }
  }

  Future<void> _exportChat() async {
    try {
      final response = await _service.exportAiChat(
        sessionId: _currentSessionId,
      );
      _showSnack(
        response['path']?.toString() != null
            ? 'Exported chat to ${response['path']}'
            : 'Exported chat.',
      );
    } catch (error) {
      _showSnack('Failed to export chat: $error', isError: true);
    }
  }

  Future<void> _installRecommendedModel() async {
    if (mounted) {
      setState(() => _isInstallingModel = true);
    }
    await AdminTabLogger.log(
      'ai_operations',
      'model_install_started',
      details: {'model': _selectedModel},
    );
    try {
      final result = await _service.installAiModel(model: _selectedModel);
      _showSnack(result['summary']?.toString() ?? 'Model download started.');
      await _refreshStatus();
    } catch (error) {
      await AdminTabLogger.log(
        'ai_operations',
        'model_install_failed',
        details: {'model': _selectedModel},
        error: error,
      );
      _showSnack('Model install failed: $error', isError: true);
      if (mounted) {
        setState(() => _isInstallingModel = false);
      }
    }
  }

  Future<void> _cancelModelInstall() async {
    try {
      final result = await _service.cancelAiModelInstall();
      _showSnack(result['summary']?.toString() ?? 'Cancel requested.');
      await _refreshStatus();
    } catch (error) {
      _showSnack('Cancel failed: $error', isError: true);
    }
  }

  Future<void> _openActionDialog(_AiActionConfig config) async {
    await AdminTabLogger.log(
      'ai_operations',
      'automation_dialog_opened',
      details: {'actionId': config.id},
    );
    if (!mounted) return;

    final result = await showDialog<AiAutomationActionResult>(
      context: context,
      builder: (context) => _AiAutomationDialog(
        config: config,
        onRun: (options, approved) => _service.runAiAutomation(
          actionId: config.id,
          options: options,
          approved: approved,
        ),
      ),
    );

    if (result == null || !mounted) return;
    await AdminTabLogger.log(
      'ai_operations',
      'automation_completed',
      details: {
        'actionId': config.id,
        'success': result.success,
        'approved': result.metadata['approved'] == true,
      },
    );
    setState(() => _lastAutomationSummary = result.summary);
    await _refreshStatus();
    if (!mounted) return;
    _showAutomationResult(result);
  }

  void _showAutomationResult(AiAutomationActionResult result) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(result.title),
        content: SizedBox(
          width: 540,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.summary),
                if ((result.preview ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(result.preview!),
                ],
                if (result.savedPaths.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Saved Files',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result.savedPaths.map(
                    (path) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              path,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _openSavedPath(path),
                            child: const Text('OPEN'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSavedPath(String path) async {
    try {
      await Process.start('open', [path], runInShell: true);
    } catch (error) {
      _showSnack('Failed to open path: $error', isError: true);
    }
  }

  Future<void> _openChatSessionsDialog() async {
    await _refreshStatus();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Chat Sessions'),
        content: SizedBox(
          width: 560,
          height: 420,
          child: ListView.separated(
            itemCount: _sessionSummaries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final session = _sessionSummaries[index];
              final isCurrent = session['id']?.toString() == _currentSessionId;
              return ListTile(
                leading: Icon(
                  isCurrent
                      ? Icons.mark_chat_read_rounded
                      : Icons.history_rounded,
                  color: isCurrent ? AppColors.primary : AppColors.textDim,
                ),
                title: Text(
                  session['title']?.toString().isNotEmpty == true
                      ? session['title'].toString()
                      : 'Untitled Session',
                ),
                subtitle: Text(
                  '${session['messageCount'] ?? 0} messages\n${session['preview'] ?? ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final detail = await _service.fetchAiChatSession(
                      session['id']?.toString() ?? '',
                    );
                    if (!context.mounted) return;
                    await showDialog<void>(
                      context: context,
                      builder: (context) => _AiSessionViewer(
                        session: ((detail['session'] as Map?) ?? const {}).map(
                          (key, value) => MapEntry('$key', value),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAutomationHistoryDialog() async {
    await _refreshStatus();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Automation Log'),
        content: SizedBox(
          width: 620,
          height: 440,
          child: ListView.separated(
            itemCount: _automationHistory.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = _automationHistory[index];
              final savedPaths = ((entry['savedPaths'] as List?) ?? const [])
                  .map((item) => item.toString())
                  .where((item) => item.isNotEmpty)
                  .toList();
              return ListTile(
                title: Text(
                  entry['title']?.toString() ??
                      entry['actionId']?.toString() ??
                      'Automation',
                ),
                subtitle: Text(
                  '${entry['ranAt'] ?? ''}\n${entry['summary'] ?? ''}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: SizedBox(
                  width: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              entry['approved'] == true ? 'APPLIED' : 'PREVIEW',
                              style: TextStyle(
                                color: entry['approved'] == true
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            if (savedPaths.isNotEmpty)
                              Text(
                                '${savedPaths.length} file(s)',
                                style: const TextStyle(
                                  color: AppColors.textDim,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _openHistoryEntryDetail(entry),
                        child: const Text('DETAILS'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openInstallHistoryDialog() async {
    await _refreshStatus();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Install History'),
        content: SizedBox(
          width: 620,
          height: 420,
          child: ListView.separated(
            itemCount: _installHistory.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = _installHistory[index];
              return ListTile(
                title: Text(entry['model']?.toString() ?? 'Model'),
                subtitle: Text(
                  '${entry['status'] ?? 'unknown'}\nStarted: ${entry['startedAt'] ?? '--'}\nFinished: ${entry['finishedAt'] ?? '--'}',
                ),
                trailing: Text(
                  _formatBytes(entry['bytesDownloaded'] as num?),
                  style: const TextStyle(color: AppColors.textDim),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openHistoryEntryDetail(Map<String, dynamic> entry) async {
    if (!mounted) return;
    final savedPaths = ((entry['savedPaths'] as List?) ?? const [])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
    final metadata = (entry['metadata'] as Map?)?.map(
      (key, value) => MapEntry('$key', value),
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          entry['title']?.toString() ??
              entry['actionId']?.toString() ??
              'Automation Entry',
        ),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['summary']?.toString() ?? ''),
                const SizedBox(height: 12),
                Text(
                  'Ran: ${entry['ranAt'] ?? '--'}',
                  style: const TextStyle(color: AppColors.textDim),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mode: ${entry['approved'] == true ? 'Applied' : 'Preview'}',
                  style: TextStyle(
                    color: entry['approved'] == true
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (savedPaths.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Affected Files',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...savedPaths.map(
                    (path) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              path,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _openSavedPath(path),
                            child: const Text('OPEN'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if ((metadata ?? const {}).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Metadata',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    const JsonEncoder.withIndent('  ').convert(metadata),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQueueStatus({
    required String queueType,
    required String queueId,
    required String status,
    String? note,
  }) async {
    try {
      final result = await _service.updateAiQueueStatus(
        queueType: queueType,
        queueId: queueId,
        status: status,
        note: note,
      );
      await AdminTabLogger.log(
        'ai_operations',
        'queue_status_updated',
        details: {'queueType': queueType, 'queueId': queueId, 'status': status},
      );
      await _refreshStatus();
      if (!mounted) return;
      _showSnack(result['summary']?.toString() ?? 'Queue updated.');
    } catch (error) {
      await AdminTabLogger.log(
        'ai_operations',
        'queue_status_update_failed',
        details: {'queueType': queueType, 'queueId': queueId, 'status': status},
        error: error,
      );
      if (!mounted) return;
      _showSnack('Queue update failed: $error', isError: true);
    }
  }

  Future<void> _promptQueueStatusUpdate({
    required String queueType,
    required Map<String, dynamic> entry,
    required String status,
  }) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Set ${entry['id']} to ${status.toUpperCase()}'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry['summary']?.toString() ?? ''),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Operator Note',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    final note = noteController.text.trim();
    noteController.dispose();
    if (confirmed != true) return;
    await _updateQueueStatus(
      queueType: queueType,
      queueId: entry['id']?.toString() ?? '',
      status: status,
      note: note.isEmpty ? null : note,
    );
  }

  Future<void> _openModerationQueueDialog() async {
    await _refreshStatus();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _AiQueueDialog(
        title: 'Moderation Queue',
        queueType: 'moderation',
        entries: _moderationQueue,
        accent: AppColors.warning,
        emptyMessage: 'No moderation items are waiting for review.',
        statusButtons: const [
          _QueueStatusAction(status: 'approved', label: 'APPROVE'),
          _QueueStatusAction(status: 'dismissed', label: 'DISMISS'),
          _QueueStatusAction(status: 'escalated', label: 'ESCALATE'),
        ],
        onOpenPath: _openSavedPath,
        onUpdateStatus: (entry, status) => _promptQueueStatusUpdate(
          queueType: 'moderation',
          entry: entry,
          status: status,
        ),
      ),
    );
  }

  Future<void> _openSupportQueueDialog() async {
    await _refreshStatus();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _AiQueueDialog(
        title: 'Support Queue',
        queueType: 'support',
        entries: _supportQueue,
        accent: AppColors.primary,
        emptyMessage: 'No support drafts are waiting for operator action.',
        statusButtons: const [
          _QueueStatusAction(status: 'in_review', label: 'IN REVIEW'),
          _QueueStatusAction(status: 'sent', label: 'SEND'),
          _QueueStatusAction(status: 'closed', label: 'CLOSE'),
        ],
        onOpenPath: _openSavedPath,
        onUpdateStatus: (entry, status) => _promptQueueStatusUpdate(
          queueType: 'support',
          entry: entry,
          status: status,
        ),
      ),
    );
  }

  void _syncInstallPolling(Map<String, dynamic> status) {
    final install = status['install'] as Map?;
    final isActive = install?['active'] == true;
    final installStatus = install?['status']?.toString();
    final completedInstallKey =
        '${install?['model']?.toString() ?? _selectedModel}:${install?['finishedAt']?.toString() ?? ''}';

    if (mounted) {
      final shouldInstall = _isInstallingModel || isActive;
      if (_isInstallingModel != shouldInstall) {
        setState(() => _isInstallingModel = shouldInstall);
      }
    }

    if (!isActive) {
      _statusPolling = false;
      if (installStatus == 'completed' &&
          _lastCompletedInstallKey != completedInstallKey) {
        _lastCompletedInstallKey = completedInstallKey;
        AdminTabLogger.log(
          'ai_operations',
          'model_install_completed',
          details: {'model': install?['model']?.toString() ?? _selectedModel},
        );
      }
      return;
    }

    if (_statusPolling) return;
    _statusPolling = true;
    Future<void>.delayed(const Duration(seconds: 2), () async {
      if (!mounted || !_statusPolling) return;
      await _refreshStatus();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.success,
      ),
    );
  }

  String _formatBytes(num? bytes) {
    final value = (bytes ?? 0).toDouble();
    if (value <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = value;
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final precision = size >= 100
        ? 0
        : size >= 10
        ? 1
        : 2;
    return '${size.toStringAsFixed(precision)} ${units[unitIndex]}';
  }

  String _formatDuration(num? milliseconds) {
    final value = (milliseconds ?? 0).round();
    if (value <= 0) return '--';
    if (value < 1000) return '${value}ms';
    final seconds = value / 1000;
    if (seconds < 60) return '${seconds.toStringAsFixed(1)}s';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).round();
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI OPERATIONS SUITE',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Persistent Ollama chat, install history, approval-based automations, and admin telemetry.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
                ),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildHeaderButton(
                  'SESSIONS',
                  Icons.forum_outlined,
                  _openChatSessionsDialog,
                ),
                _buildHeaderButton(
                  'AUTOMATION LOG',
                  Icons.history_rounded,
                  _openAutomationHistoryDialog,
                ),
                _buildHeaderButton(
                  'MOD QUEUE',
                  Icons.gavel_rounded,
                  _openModerationQueueDialog,
                ),
                _buildHeaderButton(
                  'SUPPORT QUEUE',
                  Icons.support_agent_rounded,
                  _openSupportQueueDialog,
                ),
                _buildHeaderButton(
                  'INSTALL HISTORY',
                  Icons.download_done_rounded,
                  _openInstallHistoryDialog,
                ),
                _buildHeaderButton(
                  'REFRESH STATUS',
                  Icons.refresh_rounded,
                  _isLoadingStatus ? null : _refreshStatus,
                ),
                FilledButton.icon(
                  onPressed: _isInstallingModel
                      ? _cancelModelInstall
                      : _installRecommendedModel,
                  icon: Icon(
                    _isInstallingModel
                        ? Icons.stop_circle_outlined
                        : Icons.download_rounded,
                  ),
                  label: Text(
                    _isInstallingModel ? 'CANCEL INSTALL' : 'INSTALL MODEL',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _isInstallingModel
                        ? Colors.redAccent
                        : AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildStatusRow(),
        const SizedBox(height: 16),
        _buildTelemetryRow(),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildChatPane()),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _buildAutomationPane()),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHeaderButton(
    String label,
    IconData icon,
    Future<void> Function()? onPressed,
  ) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatusRow() {
    final rawModels = (_status?['models'] as List? ?? const []);
    final modelCatalog = (_status?['modelCatalog'] as Map?)?.map(
      (key, value) => MapEntry('$key', value),
    );
    final install = (_status?['install'] as Map?)?.map(
      (key, value) => MapEntry('$key', value),
    );
    final models = rawModels
        .map((item) {
          if (item is Map) return item['name']?.toString() ?? '';
          return item.toString();
        })
        .where((item) => item.isNotEmpty)
        .toList();

    Map<String, dynamic>? selectedModelMeta;
    for (final item in rawModels.whereType<Map>()) {
      final normalized = item.map((key, value) => MapEntry('$key', value));
      if (normalized['name']?.toString() == _selectedModel) {
        selectedModelMeta = normalized;
        break;
      }
    }

    final selectedModelCatalog = (modelCatalog?[_selectedModel] as Map?)?.map(
      (key, value) => MapEntry('$key', value),
    );

    final availableModels = <String>{
      ...modelCatalog?.keys ?? const <String>{},
      if ((modelCatalog?.containsKey(_selectedModel) ?? false)) _selectedModel,
      ...models.where((model) => modelCatalog?.containsKey(model) ?? false),
    }.toList();

    return Row(
      children: [
        _buildStatusCard(
          label: 'OLLAMA',
          value: _status?['serviceReachable'] == true ? 'ONLINE' : 'OFFLINE',
          color: _status?['serviceReachable'] == true
              ? AppColors.success
              : AppColors.warning,
        ),
        const SizedBox(width: 16),
        _buildStatusCard(
          label: 'CLI',
          value: _status?['cliInstalled'] == true ? 'INSTALLED' : 'MISSING',
          color: _status?['cliInstalled'] == true
              ? AppColors.primary
              : Colors.redAccent,
        ),
        const SizedBox(width: 16),
        _buildStatusCard(
          label: 'MODEL SIZE',
          value: selectedModelMeta != null
              ? _formatBytes(selectedModelMeta['size'] as num?)
              : selectedModelCatalog?['estimatedSize'] != null
              ? 'EST. ${_formatBytes(selectedModelCatalog?['estimatedSize'] as num?)}'
              : 'UNKNOWN',
          color: selectedModelMeta != null
              ? AppColors.primary
              : AppColors.warning,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.memory_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MODEL',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: availableModels.contains(_selectedModel)
                              ? _selectedModel
                              : availableModels.first,
                          dropdownColor: AppColors.surface,
                          isExpanded: true,
                          items: availableModels
                              .map(
                                (model) => DropdownMenuItem(
                                  value: model,
                                  child: Text(model),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedModel = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (install != null) ...[
                  const SizedBox(width: 18),
                  SizedBox(width: 250, child: _buildInstallSummary(install)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryRow() {
    final telemetry = ((_status?['telemetry'] as Map?) ?? const {}).map(
      (key, value) => MapEntry('$key', value),
    );
    final lastRequest = ((telemetry['lastRequest'] as Map?) ?? const {}).map(
      (key, value) => MapEntry('$key', value),
    );

    return Row(
      children: [
        _buildMiniStat('REQUESTS', '${telemetry['totalRequests'] ?? 0}'),
        const SizedBox(width: 14),
        _buildMiniStat(
          'PROMPT TOKENS',
          '${telemetry['totalPromptTokens'] ?? 0}',
        ),
        const SizedBox(width: 14),
        _buildMiniStat(
          'REPLY TOKENS',
          '${telemetry['totalResponseTokens'] ?? 0}',
        ),
        const SizedBox(width: 14),
        _buildMiniStat(
          'AVG DURATION',
          _formatDuration(telemetry['averageDurationMs'] as num?),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.speed_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LAST REQUEST',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${lastRequest['model'] ?? _selectedModel}  |  ${_formatDuration(lastRequest['durationMs'] as num?)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lastRequest['source'] ?? 'none'}  |  ${lastRequest['createdAt'] ?? '--'}',
                        style: const TextStyle(
                          color: AppColors.textDim,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallSummary(Map<String, dynamic> install) {
    final active = install['active'] == true;
    final status = install['status']?.toString().toUpperCase() ?? 'IDLE';
    final percent = (install['percent'] as num?)?.toDouble() ?? 0;
    final total = install['total'] as num?;
    final completed = install['completed'] as num?;
    final speed = install['bytesPerSecond'] as num?;
    final eta = install['etaSeconds'] as num?;
    final output = (install['output'] as List? ?? const []).isNotEmpty
        ? (install['output'] as List).last.toString()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          active ? 'DOWNLOAD IN PROGRESS' : 'DOWNLOAD STATUS',
          style: const TextStyle(
            color: AppColors.textDim,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          status,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.textDim,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: total != null && total > 0
              ? (percent / 100).clamp(0.0, 1.0)
              : null,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        ),
        const SizedBox(height: 10),
        Text(
          total != null && total > 0
              ? '${percent.toStringAsFixed(1)}%  ${_formatBytes(completed)} / ${_formatBytes(total)}'
              : 'Waiting for download metadata...',
          style: const TextStyle(fontSize: 11, color: AppColors.textDim),
        ),
        const SizedBox(height: 4),
        Text(
          'Speed: ${speed == null ? '--' : '${_formatBytes(speed)}/s'}   ETA: ${_formatDuration((eta ?? 0) * 1000)}',
          style: const TextStyle(fontSize: 11, color: AppColors.textDim),
        ),
        if ((output ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            output!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textDim),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPane() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'MODEL CHAT',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _startNewChat,
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text('NEW CHAT'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _openChatSessionsDialog,
                icon: const Icon(Icons.history_rounded),
                label: const Text('HISTORY'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _exportChat,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('EXPORT'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentSessionId == null
                ? 'Loading current session...'
                : 'Session: $_currentSessionId',
            style: const TextStyle(color: AppColors.textDim, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              controller: _chatScrollController,
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isUser
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: SelectableText(
                      message['content'] ?? '',
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText:
                        'Ask the model to draft copy, summarize a release, or plan an automation...',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _isSending ? null : _sendMessage,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(120, 56),
                ),
                child: Text(_isSending ? 'SENDING...' : 'SEND'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationPane() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'AUTOMATION GRID',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _lastAutomationSummary ??
                'Each tile now supports preview, approval, and automatic apply for writes or sends.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: _actions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final action = _actions[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openActionDialog(action),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          action.accent.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                      border: Border.all(
                        color: action.accent.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(action.icon, color: action.accent, size: 24),
                        const Spacer(),
                        Text(
                          action.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          action.subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDim,
                            fontSize: 10.5,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAutomationBadge(action.id),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationBadge(String actionId) {
    final catalog = (_status?['automationCatalog'] as Map?)?.map(
      (key, value) => MapEntry('$key', value),
    );
    final entry = (catalog?[actionId] as Map?)?.map(
      (key, value) => MapEntry('$key', value),
    );
    final implemented = entry?['implemented'] == true;
    final mode = entry?['mode']?.toString() ?? 'todo';
    final label = switch (mode) {
      'dedicated' => 'LIVE',
      'ai_assisted' => 'ASSIST',
      _ => implemented ? 'LIVE' : 'TODO',
    };
    final color = switch (mode) {
      'dedicated' => AppColors.success,
      'ai_assisted' => AppColors.primary,
      _ => implemented ? AppColors.success : AppColors.warning,
    };

    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _AiAutomationDialog extends StatefulWidget {
  const _AiAutomationDialog({required this.config, required this.onRun});

  final _AiActionConfig config;
  final Future<AiAutomationActionResult> Function(
    Map<String, dynamic> options,
    bool approved,
  )
  onRun;

  @override
  State<_AiAutomationDialog> createState() => _AiAutomationDialogState();
}

class _AiAutomationDialogState extends State<_AiAutomationDialog> {
  final AdminService _service = AdminService();
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, bool> _toggles;
  late final Map<String, String> _dropdowns;
  List<AdminUser> _directoryUsers = const [];
  Set<String> _selectedDirectoryUsers = <String>{};
  bool _isRunning = false;
  AiAutomationActionResult? _previewResult;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.config.fields)
        if (field.type == _AiFieldType.text ||
            field.type == _AiFieldType.multiline)
          field.id: TextEditingController(text: field.initialText ?? ''),
    };
    _toggles = {
      for (final field in widget.config.fields)
        if (field.type == _AiFieldType.toggle)
          field.id: field.initialBool ?? false,
    };
    _dropdowns = {
      for (final field in widget.config.fields)
        if (field.type == _AiFieldType.dropdown)
          field.id: field.initialText ?? field.options.first,
    };
    _seedDirectorySelection();
    _loadDirectoryUsers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _collectOptions() {
    final options = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      if (entry.value.text.trim().isNotEmpty) {
        options[entry.key] = entry.value.text.trim();
      }
    }
    options.addAll(_toggles);
    options.addAll(_dropdowns);
    return options;
  }

  void _seedDirectorySelection() {
    for (final key in const ['recipients']) {
      final raw = _controllers[key]?.text ?? '';
      if (raw.trim().isEmpty) continue;
      _selectedDirectoryUsers = raw
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet();
    }
  }

  Future<void> _loadDirectoryUsers() async {
    if (!_usesDirectoryPicker) return;
    try {
      final users = await _service.fetchUsers();
      if (!mounted) return;
      setState(() => _directoryUsers = users);
    } catch (_) {}
  }

  bool get _usesDirectoryPicker =>
      widget.config.id == 'mail_campaign' ||
      widget.config.id == 'release_briefing_mail';

  void _syncRecipientsController() {
    final recipients = _selectedDirectoryUsers.toList()..sort();
    _controllers['recipients']?.text = recipients.join(', ');
  }

  Future<void> _openDirectoryPicker() async {
    if (_directoryUsers.isEmpty) {
      await _loadDirectoryUsers();
    }
    if (!mounted) return;
    final currentSelection = {..._selectedDirectoryUsers};
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) => _UserDirectoryDialog(
        users: _directoryUsers,
        initialSelection: currentSelection,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _selectedDirectoryUsers = result;
      _syncRecipientsController();
    });
  }

  Future<void> _preview() async {
    setState(() => _isRunning = true);
    try {
      final result = await widget.onRun(_collectOptions(), false);
      if (!mounted) return;
      if (result.metadata['requiresApproval'] != true) {
        Navigator.of(context).pop(result);
        return;
      }
      setState(() => _previewResult = result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preview failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }

  Future<void> _approve() async {
    setState(() => _isRunning = true);
    try {
      final result = await widget.onRun(_collectOptions(), true);
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apply failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.config.title),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.config.subtitle,
                style: const TextStyle(color: AppColors.textDim),
              ),
              if (widget.config.fields.isNotEmpty) ...[
                const SizedBox(height: 20),
                ...widget.config.fields.map(_buildField),
              ],
              if (_usesDirectoryPicker) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _openDirectoryPicker,
                      icon: const Icon(Icons.group_outlined),
                      label: const Text('SELECT FROM DIRECTORY'),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDirectoryUsers.length} selected',
                      style: const TextStyle(color: AppColors.textDim),
                    ),
                  ],
                ),
              ],
              if (_previewResult != null) ...[
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Approval Preview',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_previewResult!.summary),
                if ((_previewResult!.preview ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SelectableText(_previewResult!.preview!),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isRunning ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isRunning ? null : _preview,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white12,
            foregroundColor: Colors.white,
          ),
          child: Text(_isRunning ? 'RUNNING...' : 'PREVIEW'),
        ),
        FilledButton(
          onPressed: _previewResult == null || _isRunning ? null : _approve,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          child: const Text('APPROVE & APPLY'),
        ),
      ],
    );
  }

  Widget _buildField(_AiFieldConfig field) {
    switch (field.type) {
      case _AiFieldType.text:
      case _AiFieldType.multiline:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: _controllers[field.id],
            minLines: field.type == _AiFieldType.multiline ? 3 : 1,
            maxLines: field.type == _AiFieldType.multiline ? 8 : 1,
            decoration: InputDecoration(
              labelText: field.label,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      case _AiFieldType.toggle:
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          value: _toggles[field.id] ?? false,
          activeThumbColor: AppColors.primary,
          onChanged: (value) => setState(() => _toggles[field.id] = value),
        );
      case _AiFieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DropdownButtonFormField<String>(
            initialValue: _dropdowns[field.id],
            decoration: InputDecoration(
              labelText: field.label,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: AppColors.surface,
            items: field.options
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _dropdowns[field.id] = value);
            },
          ),
        );
    }
  }
}

class _UserDirectoryDialog extends StatefulWidget {
  const _UserDirectoryDialog({
    required this.users,
    required this.initialSelection,
  });

  final List<AdminUser> users;
  final Set<String> initialSelection;

  @override
  State<_UserDirectoryDialog> createState() => _UserDirectoryDialogState();
}

class _UserDirectoryDialogState extends State<_UserDirectoryDialog> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelection};
  }

  void _applyFilter(String filter) {
    final matching = switch (filter) {
      'all' => widget.users.map((user) => user.username),
      'online' =>
        widget.users
            .where((user) => user.status == AdminUserStatus.online)
            .map((user) => user.username),
      'battling' =>
        widget.users
            .where((user) => user.status == AdminUserStatus.battling)
            .map((user) => user.username),
      'offline' =>
        widget.users
            .where((user) => user.status == AdminUserStatus.offline)
            .map((user) => user.username),
      _ => const Iterable<String>.empty(),
    };
    setState(() => _selected = matching.toSet());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('User Directory'),
      content: SizedBox(
        width: 560,
        height: 460,
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _applyFilter('all'),
                  child: const Text('ALL'),
                ),
                OutlinedButton(
                  onPressed: () => _applyFilter('online'),
                  child: const Text('ONLINE'),
                ),
                OutlinedButton(
                  onPressed: () => _applyFilter('battling'),
                  child: const Text('BATTLING'),
                ),
                OutlinedButton(
                  onPressed: () => _applyFilter('offline'),
                  child: const Text('OFFLINE'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _selected.clear()),
                  child: const Text('CLEAR'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.users.length,
                itemBuilder: (context, index) {
                  final user = widget.users[index];
                  final checked = _selected.contains(user.username);
                  return CheckboxListTile(
                    value: checked,
                    activeColor: AppColors.primary,
                    title: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName
                          : user.username,
                    ),
                    subtitle: Text(
                      '${user.username}  |  ${user.status.name.toUpperCase()}',
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(user.username);
                        } else {
                          _selected.remove(user.username);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('USE SELECTION'),
        ),
      ],
    );
  }
}

class _AiSessionViewer extends StatelessWidget {
  const _AiSessionViewer({required this.session});

  final Map<String, dynamic> session;

  @override
  Widget build(BuildContext context) {
    final messages = ((session['messages'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(session['title']?.toString() ?? 'Chat Session'),
      content: SizedBox(
        width: 620,
        height: 460,
        child: ListView.separated(
          itemCount: messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final message = messages[index];
            final isUser = message['role'] == 'user';
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectableText(message['content']?.toString() ?? ''),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _AiQueueDialog extends StatelessWidget {
  const _AiQueueDialog({
    required this.title,
    required this.queueType,
    required this.entries,
    required this.accent,
    required this.emptyMessage,
    required this.statusButtons,
    required this.onOpenPath,
    required this.onUpdateStatus,
  });

  final String title;
  final String queueType;
  final List<Map<String, dynamic>> entries;
  final Color accent;
  final String emptyMessage;
  final List<_QueueStatusAction> statusButtons;
  final Future<void> Function(String path) onOpenPath;
  final Future<void> Function(Map<String, dynamic> entry, String status)
  onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title),
      content: SizedBox(
        width: 760,
        height: 520,
        child: entries.isEmpty
            ? Center(
                child: Text(
                  emptyMessage,
                  style: const TextStyle(color: AppColors.textDim),
                ),
              )
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final savedPath = entry['savedPath']?.toString();
                  final severity = entry['severity']?.toString();
                  final updatedAt = entry['updatedAt']?.toString();
                  final note = entry['operatorNote']?.toString();
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    entry['id']?.toString() ?? 'queue_item',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  _QueueChip(
                                    label:
                                        entry['status']
                                            ?.toString()
                                            .toUpperCase() ??
                                        'UNKNOWN',
                                    color: accent,
                                  ),
                                  if ((severity ?? '').isNotEmpty)
                                    _QueueChip(
                                      label: severity!.toUpperCase(),
                                      color: Colors.orangeAccent,
                                    ),
                                  if ((entry['username']?.toString() ?? '')
                                      .isNotEmpty)
                                    _QueueChip(
                                      label: entry['username'].toString(),
                                      color: AppColors.primary,
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              entry['createdAt']?.toString() ?? '--',
                              style: const TextStyle(
                                color: AppColors.textDim,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(entry['summary']?.toString() ?? ''),
                        if ((note ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Operator Note: $note',
                            style: const TextStyle(
                              color: AppColors.textDim,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if ((updatedAt ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Updated: $updatedAt',
                            style: const TextStyle(
                              color: AppColors.textDim,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final action in statusButtons)
                              FilledButton.tonal(
                                onPressed: () =>
                                    onUpdateStatus(entry, action.status),
                                child: Text(action.label),
                              ),
                            if ((savedPath ?? '').isNotEmpty)
                              TextButton.icon(
                                onPressed: () => onOpenPath(savedPath!),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text('OPEN FILE'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _QueueChip extends StatelessWidget {
  const _QueueChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _QueueStatusAction {
  const _QueueStatusAction({required this.status, required this.label});

  final String status;
  final String label;
}

class _AiActionConfig {
  const _AiActionConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.fields = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<_AiFieldConfig> fields;
}

class _AiFieldConfig {
  const _AiFieldConfig({
    required this.id,
    required this.label,
    required this.type,
    this.initialText,
    this.initialBool,
    this.options = const [],
  });

  final String id;
  final String label;
  final _AiFieldType type;
  final String? initialText;
  final bool? initialBool;
  final List<String> options;
}

enum _AiFieldType { text, multiline, toggle, dropdown }
