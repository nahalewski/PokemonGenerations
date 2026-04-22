import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_center/services/service_notifier.dart';
import 'package:pokemon_center/core/theme.dart';

/// Output verbosity modes for the console.
enum OutputMode { normal, simple }

class ConsoleView extends ConsumerStatefulWidget {
  final bool isPopOut;
  const ConsoleView({super.key, this.isPopOut = false});

  @override
  ConsumerState<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends ConsumerState<ConsoleView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedServiceId = 'global';
  OutputMode _outputMode = OutputMode.normal;

  // Filters
  bool _filterGreen = true;
  bool _filterYellow = true;
  bool _filterRed = true;

  // ── Simple-mode translator ─────────────────────────────────────────────────
  String _simplify(String line) {
    final l = line.toLowerCase();

    // Strip timestamp prefix like [08:42:30]
    final noTs = line.replaceFirst(RegExp(r'^\[\d{2}:\d{2}:\d{2}\] ?'), '').trim();

    if (l.contains('error') || l.contains('failed') || l.contains('exception')) {
      if (l.contains('connection refused') || l.contains('econnrefused')) {
        return '🔴 Can\'t connect — the server may be offline. Try restarting it.';
      }
      if (l.contains('build')) return '🔴 The build failed. Something went wrong during compilation.';
      if (l.contains('port') || l.contains('address already in use')) {
        return '🔴 A port is already in use. Stop the other process first.';
      }
      if (l.contains('timeout')) return '🔴 Timed out — took too long and gave up.';
      if (l.contains('auth') || l.contains('unauthorized') || l.contains('403')) {
        return '🔴 Access denied — credentials may be wrong or expired.';
      }
      if (l.contains('not found') || l.contains('404')) {
        return '🔴 Something was missing — file or route not found.';
      }
      return '🔴 An error occurred: $noTs';
    }

    if (l.contains('warning') || l.contains('warn')) {
      return '🟡 Heads-up: $noTs';
    }

    if (l.contains('build successful') || l.contains('build ok')) {
      return '✅ Build finished successfully — the app is ready to serve.';
    }
    if (l.contains('starting build') || l.contains('start build')) {
      return '🔨 Building the app now… this takes a minute.';
    }
    if (l.contains('starting') && l.contains('server')) {
      return '🚀 Starting up the server…';
    }
    if (l.contains('online') || l.contains('listening on') || l.contains('server running')) {
      return '✅ Server is up and running.';
    }
    if (l.contains('offline') || l.contains('stopped') || l.contains('exited')) {
      return '⚫ Server has stopped.';
    }
    if (l.contains('tunnel') && l.contains('start')) {
      return '🌐 Connecting to Cloudflare tunnel (makes the site public)…';
    }
    if (l.contains('tunnel') && (l.contains('connected') || l.contains('registered'))) {
      return '🌐 Tunnel connected — site is now accessible from the internet.';
    }
    if (l.contains('purge') && l.contains('cloudflare')) {
      return '🧹 Clearing the CDN cache so visitors get the latest version.';
    }
    if (l.contains('cache purged') || l.contains('purge success')) {
      return '✅ CDN cache cleared — users will see fresh content.';
    }
    if (l.contains('adb') && l.contains('reverse')) {
      return '📱 Setting up connection to Android device…';
    }
    if (l.contains('pub get') || l.contains('resolving dependencies')) {
      return '📦 Downloading packages…';
    }
    if (l.contains('process exited')) {
      final codeMatch = RegExp(r'code (\d+)').firstMatch(l);
      final code = codeMatch?.group(1) ?? '?';
      return code == '0' ? '✅ Process finished cleanly.' : '🔴 Process crashed (exit code $code).';
    }
    if (l.contains('kill') || l.contains('stopping')) {
      return '🛑 Stopping existing processes…';
    }
    if (l.contains('stack is online') || l.contains('start_all_completed')) {
      return '✅ Everything is up and running!';
    }
    if (l.contains('login') || l.contains('logged in')) {
      return '👤 A user logged in.';
    }
    if (l.contains('mail') || l.contains('inbox')) {
      return '📬 Mail activity detected.';
    }
    if (l.contains('trade') || l.contains('buy') || l.contains('sell')) {
      return '💱 A trade was processed.';
    }
    if (l.contains('health') && l.contains('ok')) {
      return '💚 Health check passed — backend is healthy.';
    }

    // Generic fallback: strip noise and show readable version
    final clean = noTs
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
    return clean.isEmpty ? line : '› $clean';
  }

  List<String> _buildSuggestions(List<dynamic> services) {
    final serviceTerms = services
        .map((service) => service.name.toString().toLowerCase())
        .toList();
    final serviceIds = services.map((service) => service.id.toString()).toList();
    final defaults = <String>[
      'global',
      'backend',
      'tunnel',
      'exchange',
      'main_site',
      'admin_web',
      'asset_server',
      'successful',
      'success',
      'error',
      'failed',
      'warning',
      'online',
      'starting',
      'build',
    ];

    final unique = <String>{...defaults, ...serviceTerms, ...serviceIds}.toList()
      ..sort();
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return unique.take(8).toList();
    }
    final matching = unique.where((term) => term.contains(query)).toList();
    return matching.take(8).toList();
  }

  void _applySuggestion(String value) {
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() {});
    _searchFocusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isPopOut) {
      DesktopMultiWindow.setMethodHandler(_handleWindowMethodCall);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestInitialSnapshot();
      });
    }
  }

  @override
  void dispose() {
    if (widget.isPopOut) {
      DesktopMultiWindow.setMethodHandler(null);
    }
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _requestInitialSnapshot() async {
    try {
      final snapshot = await DesktopMultiWindow.invokeMethod(
        0,
        'console_request_snapshot',
      );
      if (!mounted || snapshot is! Map) return;
      ref
          .read(serviceProvider.notifier)
          .applyConsoleSnapshot(Map<String, dynamic>.from(snapshot));
    } catch (_) {}
  }

  Future<dynamic> _handleWindowMethodCall(
    MethodCall call,
    int fromWindowId,
  ) async {
    if (!mounted) return null;

    if (call.method == 'console_log' && call.arguments is Map) {
      final payload = Map<String, dynamic>.from(call.arguments as Map);
      final serviceId = payload['serviceId']?.toString();
      final line = payload['line']?.toString();
      if (serviceId != null && line != null) {
        ref.read(serviceProvider.notifier).appendRemoteLog(serviceId, line);
      }
    } else if (call.method == 'console_snapshot' && call.arguments is Map) {
      ref
          .read(serviceProvider.notifier)
          .applyConsoleSnapshot(
            Map<String, dynamic>.from(call.arguments as Map),
          );
    }
    return null;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Color _getLineColor(String line) {
    if (line.contains('ERROR') ||
        line.contains('failed') ||
        line.contains('Failed') ||
        line.startsWith('🔴')) {
      return Colors.redAccent;
    }
    if (line.contains('WARNING') ||
        line.contains('starting') ||
        line.contains('Warn') ||
        line.startsWith('🟡')) {
      return Colors.orangeAccent;
    }
    if (line.contains('SUCCESS') ||
        line.contains('online') ||
        line.contains('successful') ||
        line.startsWith('✅') ||
        line.startsWith('🌐') ||
        line.startsWith('🚀')) {
      return Colors.greenAccent;
    }
    return AppColors.textBody;
  }

  bool _shouldShow(String line) {
    if (_searchController.text.isNotEmpty &&
        !line.toLowerCase().contains(_searchController.text.toLowerCase())) {
      return false;
    }

    final color = _getLineColor(line);
    if (color == Colors.greenAccent && !_filterGreen) return false;
    if (color == Colors.orangeAccent && !_filterYellow) return false;
    if (color == Colors.redAccent && !_filterRed) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceProvider);
    final notifier = ref.read(serviceProvider.notifier);
    final rawLogs = notifier.getLogs(_selectedServiceId);

    // Apply simple mode translation if needed
    final displayLogs = rawLogs
        .map((l) => _outputMode == OutputMode.simple ? _simplify(l) : l)
        .where(_shouldShow)
        .toList();

    final suggestions = _buildSuggestions(services);

    // Auto-scroll on new logs
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Container(
      padding: widget.isPopOut ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.terminal_rounded,
                      size: 20,
                      color: AppColors.textDim,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'SEARCH LOGS (BACKEND, EXCHANGE, ERROR, SUCCESS...)',
                          hintStyle: TextStyle(
                            color: AppColors.textDim.withOpacity(0.5),
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    _buildFilterIcon(
                      Icons.check_circle_rounded,
                      Colors.greenAccent,
                      _filterGreen,
                      () => setState(() => _filterGreen = !_filterGreen),
                    ),
                    _buildFilterIcon(
                      Icons.warning_rounded,
                      Colors.orangeAccent,
                      _filterYellow,
                      () => setState(() => _filterYellow = !_filterYellow),
                    ),
                    _buildFilterIcon(
                      Icons.error_rounded,
                      Colors.redAccent,
                      _filterRed,
                      () => setState(() => _filterRed = !_filterRed),
                    ),
                    const SizedBox(width: 8),
                    // ── Output mode selector ──────────────────────────────
                    DropdownButton<OutputMode>(
                      value: _outputMode,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: OutputMode.normal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.code, size: 14, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text('NORMAL'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: OutputMode.simple,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text('SIMPLE'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _outputMode = val);
                      },
                    ),
                    const SizedBox(width: 8),
                    // ── Service selector ──────────────────────────────────
                    DropdownButton<String>(
                      value: _selectedServiceId,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'global',
                          child: Text('GLOBAL LOG'),
                        ),
                        ...services.map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name.toUpperCase()),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedServiceId = val);
                      },
                    ),
                  ],
                ),
                // Simple mode banner
                if (_outputMode == OutputMode.simple) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'SIMPLE MODE — Technical logs translated to plain English',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions
                        .map(
                          (suggestion) => ActionChip(
                            label: Text(
                              suggestion.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: AppColors.surface,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                            ),
                            onPressed: () => _applySuggestion(suggestion),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: displayLogs.length,
              itemBuilder: (context, index) {
                final line = displayLogs[index];
                final color = _getLineColor(line);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontFamily: _outputMode == OutputMode.simple ? null : 'JetBrains Mono',
                      fontSize: _outputMode == OutputMode.simple ? 12 : 11,
                      color: color,
                      fontWeight: color != AppColors.textBody
                          ? FontWeight.bold
                          : FontWeight.normal,
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

  Widget _buildFilterIcon(
    IconData icon,
    Color color,
    bool active,
    VoidCallback onTap,
  ) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30),
      icon: Icon(
        icon,
        size: 16,
        color: active ? color : AppColors.textDim.withOpacity(0.3),
      ),
    );
  }
}
