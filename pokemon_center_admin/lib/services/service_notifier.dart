import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemon_center/core/constants.dart';
import 'package:pokemon_center/models/service_info.dart';
import 'package:pokemon_center/services/admin_tab_logger.dart';
import 'package:pokemon_center/services/cloudflare_service.dart';

final serviceProvider =
    StateNotifierProvider<ServiceNotifier, List<ServiceInfo>>((ref) {
      return ServiceNotifier();
    });

class ServiceNotifier extends StateNotifier<List<ServiceInfo>> {
  static const String _suppressedMetalToolchainWarning =
      "search path '/var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain";
  static const List<String> _suppressedNoiseSnippets = [
    _suppressedMetalToolchainWarning,
    'Wasm dry run succeeded.',
    'Use --no-wasm-dry-run to disable these warnings.',
    'See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm',
  ];

  static const List<ServiceInfo> _managedServices = [
    ServiceInfo(
      id: 'backend',
      name: 'Backend (Node.js)',
      description: 'Unified API server for Global Link, banking, mail, and AI',
      port: PokemonCenterConstants.backendPort,
      path: PokemonCenterConstants.backendDir,
      supportedUrls: [
        'https://poke.orosapp.us',
        'http://127.0.0.1:${PokemonCenterConstants.backendPort}/health',
      ],
      autoStart: true,
    ),
    ServiceInfo(
      id: 'main_site',
      name: 'Main Site',
      description: 'Pokemon Generations public web client',
      port: PokemonCenterConstants.mainSitePort,
      path: '${PokemonCenterConstants.mainSiteDir}/build/web',
      supportedUrls: [
        'https://generations.orosapp.us',
        'https://app.orosapp.us',
        'https://pokeroster.orosapp.us',
        'http://127.0.0.1:${PokemonCenterConstants.mainSitePort}',
      ],
      autoStart: true,
    ),
    ServiceInfo(
      id: 'admin_web',
      name: 'Admin Web',
      description: 'Pokemon Generations command center web console',
      port: PokemonCenterConstants.adminWebPort,
      path: '${PokemonCenterConstants.adminWebDir}/build/web',
      supportedUrls: [
        'http://127.0.0.1:${PokemonCenterConstants.adminWebPort}',
      ],
      autoStart: true,
    ),
    ServiceInfo(
      id: 'exchange',
      name: 'Aevora Exchange',
      description: 'Silph-Gold Union market and banking web terminal',
      port: PokemonCenterConstants.exchangePort,
      path: '${PokemonCenterConstants.exchangeDir}/build/web',
      supportedUrls: [
        'https://exchange.orosapp.us',
        'http://127.0.0.1:${PokemonCenterConstants.exchangePort}',
      ],
      autoStart: true,
    ),
    ServiceInfo(
      id: 'tunnel',
      name: 'Cloudflare Tunnel',
      description: 'External access tunnel',
      path: PokemonCenterConstants.cloudflaredPath,
      supportedUrls: const ['Cloudflare edge routes for public *.orosapp.us traffic'],
      autoStart: true,
    ),
    ServiceInfo(
      id: 'db_sync',
      name: 'Database Sync',
      description: 'Synchronizes local and cloud rosters',
      path: '${PokemonCenterConstants.rootDir}/devops/db',
      supportedUrls: const ['Internal sync worker for roster and persistence jobs'],
    ),
    ServiceInfo(
      id: 'metrics',
      name: 'Node Metrics',
      description: 'System performance monitoring',
      port: 8195,
      path: '${PokemonCenterConstants.rootDir}/devops/metrics',
      supportedUrls: const ['http://127.0.0.1:8195'],
    ),
    ServiceInfo(
      id: 'cdn_purge',
      name: 'CDN Watcher',
      description: 'Automatic Cloudflare edge purging',
      path: '${PokemonCenterConstants.rootDir}/devops/cdn',
      supportedUrls: const ['Internal Cloudflare purge automation'],
    ),
    ServiceInfo(
      id: 'auth_proxy',
      name: 'Auth Proxy',
      description: 'Secure authentication gateway',
      port: 8196,
      path: '${PokemonCenterConstants.rootDir}/devops/auth',
      supportedUrls: const ['http://127.0.0.1:8196'],
    ),
    ServiceInfo(
      id: 'asset_server',
      name: 'Asset Server',
      description: 'High-res sprite delivery node',
      port: PokemonCenterConstants.assetServerPort,
      path: '${PokemonCenterConstants.rootDir}/asset_sources',
      supportedUrls: [
        'http://127.0.0.1:${PokemonCenterConstants.assetServerPort}',
      ],
      autoStart: true,
    ),
    ServiceInfo(
      id: 'ollama',
      name: 'Ollama Runtime',
      description: 'Local AI runtime for chat, changelogs, and automations',
      port: PokemonCenterConstants.ollamaPort,
      supportedUrls: [PokemonCenterConstants.ollamaBaseUrl],
      autoStart: false,
    ),
    ServiceInfo(
      id: 'task_runner',
      name: 'Task Runner',
      description: 'Background cron & maintenance',
      path: '${PokemonCenterConstants.rootDir}/devops/tasks',
      supportedUrls: const ['Internal scheduled maintenance worker'],
    ),
    ServiceInfo(
      id: 'redis_cache',
      name: 'Redis Cache',
      description: 'Fast data retrieval layer',
      port: 6379,
      path: '${PokemonCenterConstants.rootDir}/devops/redis',
      supportedUrls: const ['redis://127.0.0.1:6379'],
    ),
    ServiceInfo(
      id: 'log_aggregator',
      name: 'Log Aggregator',
      description: 'Centralized ELK stack processor',
      port: 8198,
      path: '${PokemonCenterConstants.rootDir}/devops/logs',
      supportedUrls: const ['http://127.0.0.1:8198'],
    ),
    ServiceInfo(
      id: 'social_bridge',
      name: 'Social Bridge',
      description: 'Real-time WebSocket dispatcher',
      port: 8199,
      path: '${PokemonCenterConstants.rootDir}/devops/social',
      supportedUrls: const ['ws://127.0.0.1:8199'],
    ),
    ServiceInfo(
      id: 'dev_monitor',
      name: 'Dev Monitor',
      description: 'Auto-reloading development tool',
      path: '${PokemonCenterConstants.rootDir}/devops/dev',
      supportedUrls: const ['Internal developer monitor'],
    ),
    ServiceInfo(
      id: 'security_gate',
      name: 'Security Gate',
      description: 'DDOS & Rate-limiting monitor',
      path: '${PokemonCenterConstants.rootDir}/devops/security',
      supportedUrls: const ['Internal rate-limit and security guardrail service'],
    ),
    ServiceInfo(
      id: 'battle',
      name: 'Battle Tracker',
      description: 'Live combat telemetry & logs',
      supportedUrls: const ['Battle telemetry log stream'],
      autoStart: false,
    ),
    ServiceInfo(
      id: 'auth',
      name: 'Auth Events',
      description: 'Login & registration security logs',
      supportedUrls: const ['Authentication event log stream'],
      autoStart: false,
    ),
    ServiceInfo(
      id: 'sync',
      name: 'Sync Audit',
      description: 'Roster & data integrity logs',
      supportedUrls: const ['Sync audit log stream'],
      autoStart: false,
    ),
    ServiceInfo(
      id: 'social',
      name: 'Social Feed',
      description: 'Friends & gifting logs',
      supportedUrls: const ['Social activity log stream'],
      autoStart: false,
    ),
    ServiceInfo(
      id: 'build',
      name: 'Build Logs',
      description: 'Deployment & compilation history',
      supportedUrls: const ['Build and deployment log stream'],
      autoStart: false,
    ),
  ];

  ServiceNotifier() : super(_managedServices);

  final Map<String, Process> _processes = {};
  final Map<String, List<String>> _logs = {
    'backend': [],
    'main_site': [],
    'admin_web': [],
    'exchange': [],
    'tunnel': [],
    'db_sync': [],
    'metrics': [],
    'cdn_purge': [],
    'auth_proxy': [],
    'asset_server': [],
    'task_runner': [],
    'redis_cache': [],
    'log_aggregator': [],
    'social_bridge': [],
    'dev_monitor': [],
    'security_gate': [],
    'ollama': [],
    'global': [],
    'battle': [],
    'auth': [],
    'sync': [],
    'social': [],
    'build': [],
  };

  List<String> getLogs(String id) => _logs[id] ?? [];
  List<ServiceInfo> get stackServices =>
      state.where((service) => service.autoStart).toList();
  bool get isStackOnline =>
      stackServices.isNotEmpty &&
      stackServices.every((service) => service.status == ServiceStatus.online);
  bool get isStackBusy => stackServices.any(
    (service) =>
        service.status == ServiceStatus.starting ||
        service.status == ServiceStatus.building,
  );

  Map<String, dynamic> exportConsoleSnapshot() {
    return {
      'services': [
        for (final service in state)
          {'id': service.id, 'status': service.status.name},
      ],
      'logs': {
        for (final entry in _logs.entries)
          entry.key: List<String>.from(entry.value),
      },
    };
  }

  void applyConsoleSnapshot(Map<String, dynamic> snapshot) {
    final services = snapshot['services'];
    if (services is List) {
      final statusById = <String, ServiceStatus>{};
      for (final item in services) {
        if (item is Map) {
          final id = item['id']?.toString();
          final statusName = item['status']?.toString();
          final status = ServiceStatus.values
              .where((value) => value.name == statusName)
              .firstOrNull;
          if (id != null && status != null) {
            statusById[id] = status;
          }
        }
      }
      state = [
        for (final service in state)
          service.copyWith(status: statusById[service.id] ?? service.status),
      ];
    }

    final logs = snapshot['logs'];
    if (logs is Map) {
      for (final entry in logs.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is List) {
          _logs[key] = value
              .map((line) => line.toString())
              .where((line) => !_shouldSuppressLogLine(line))
              .toList();
        }
      }
      state = [...state];
    }
  }

  void appendRemoteLog(String id, String line) {
    if (line.trim().isEmpty || _shouldSuppressLogLine(line)) return;
    _logs.putIfAbsent(id, () => []);
    _logs[id]!.add(line);
    if ((_logs[id]?.length ?? 0) > 1000) {
      _logs[id]!.removeAt(0);
    }
    if (id != 'global') {
      _logs.putIfAbsent('global', () => []);
      final globalLine = line.startsWith('[$id] ') ? line : '[$id] $line';
      _logs['global']!.add(globalLine);
      if ((_logs['global']?.length ?? 0) > 1000) {
        _logs['global']!.removeAt(0);
      }
    }
    state = [...state];
  }

  void _addLog(String id, String line) {
    if (line.trim().isEmpty || _shouldSuppressLogLine(line)) return;
    // Suppress noisy Wasm dry run warnings as requested
    if (line.contains('--no-wasm-dry-run')) return;

    final timestamp = DateTime.now()
        .toIso8601String()
        .split('T')[1]
        .split('.')[0];

    // Parse category prefixes from backend stdout
    String targetId = id;
    String cleanLine = line;

    if (line.startsWith('[BATTLE] ')) {
      targetId = 'battle';
      cleanLine = line.replaceFirst('[BATTLE] ', '');
    } else if (line.startsWith('[AUTH] ')) {
      targetId = 'auth';
      cleanLine = line.replaceFirst('[AUTH] ', '');
    } else if (line.startsWith('[SYNC] ')) {
      targetId = 'sync';
      cleanLine = line.replaceFirst('[SYNC] ', '');
    } else if (line.startsWith('[SOCIAL] ')) {
      targetId = 'social';
      cleanLine = line.replaceFirst('[SOCIAL] ', '');
    } else if (line.startsWith('[BUILD] ')) {
      targetId = 'build';
      cleanLine = line.replaceFirst('[BUILD] ', '');
    } else if (line.startsWith('[ERROR] ')) {
      targetId = 'global';
      cleanLine = 'ERROR: ${line.replaceFirst('[ERROR] ', '')}';
    }

    final formatted = '[$timestamp] $cleanLine';
    _logs[targetId]?.add(formatted);

    // Always add to the source service log too
    if (targetId != id) {
      _logs[id]?.add(formatted);
    }

    _logs['global']?.add('[$targetId] $formatted');
    if ((_logs[targetId]?.length ?? 0) > 1000) _logs[targetId]?.removeAt(0);
    state = [...state]; // Trigger UI update for logs
    unawaited(_broadcastLog(targetId, formatted));
  }

  bool _shouldSuppressLogLine(String line) {
    return _suppressedNoiseSnippets.any(line.contains);
  }

  Future<void> _broadcastLog(String id, String formatted) async {
    try {
      final windowIds = await DesktopMultiWindow.getAllSubWindowIds();
      for (final windowId in windowIds) {
        unawaited(
          DesktopMultiWindow.invokeMethod(windowId, 'console_log', {
            'serviceId': id,
            'line': formatted,
          }),
        );
      }
    } catch (_) {}
  }

  Future<void> killAll() async {
    await AdminTabLogger.log('stack_management', 'kill_all_started');
    _addLog('global', 'Stopping all services...');

    // Kill specific ports
    for (final port in [
      PokemonCenterConstants.mainSitePort,
      PokemonCenterConstants.adminWebPort,
      PokemonCenterConstants.exchangePort,
      PokemonCenterConstants.backendPort,
      PokemonCenterConstants.assetServerPort,
      PokemonCenterConstants.ollamaPort,
    ]) {
      try {
        await Process.run('lsof', ['-ti', ':$port', '-sTCP:LISTEN']);
        // If we found something, kill it
        await Process.run('sh', ['-c', 'lsof -ti :$port | xargs kill -9']);
      } catch (_) {}
    }

    // Kill processes managed by us
    for (final id in _processes.keys) {
      _processes[id]?.kill();
    }
    _processes.clear();

    state = state
        .map((s) => s.copyWith(status: ServiceStatus.offline))
        .toList();
    await AdminTabLogger.log('stack_management', 'kill_all_completed');
  }

  Future<void> startAll() async {
    await killAll();
    await AdminTabLogger.log('stack_management', 'start_all_started');
    _addLog('global', 'Starting automatic stack launch...');

    // 1. Build Web Apps first (sequential)
    await buildService('main_site');
    await buildService('admin_web');
    await buildService('exchange');

    // 2. Start Backend
    await startService('backend');

    // 3. Start Static Servers (Web & Dashboard)
    await startService('main_site');
    await startService('admin_web');
    await startService('exchange');
    await startService('asset_server');

    // 4. Start Tunnel
    await startService('tunnel');

    // 5. Purge Cloudflare Cache
    _addLog('global', 'Stack is online. Purging Cloudflare edge cache...');
    final cloudflare = CloudflareService();
    final success = await cloudflare.purgeEverything();
    if (success == true) {
      _addLog('global', 'Cloudflare cache purged successfully!');
    } else if (success == false) {
      _addLog(
        'global',
        'WARNING: Cloudflare cache purge failed. Check credentials.',
      );
    } else {
      _addLog(
        'global',
        'Cloudflare cache purge skipped because no credentials were loaded for this app process.',
      );
    }
    await AdminTabLogger.log(
      'stack_management',
      'start_all_completed',
      details: {'cloudflarePurgeSuccess': success == true},
    );
  }

  Future<void> buildService(String id) async {
    final serviceIdx = state.indexWhere((s) => s.id == id);
    if (serviceIdx == -1) return;

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == serviceIdx)
          state[i].copyWith(status: ServiceStatus.building)
        else
          state[i],
    ];

    final dir = switch (id) {
      'main_site' => PokemonCenterConstants.mainSiteDir,
      'admin_web' => PokemonCenterConstants.adminWebDir,
      'exchange' => PokemonCenterConstants.exchangeDir,
      _ => '',
    };

    if (dir.isEmpty) {
      _markServiceFailed(serviceIdx, 'No build directory configured for $id.');
      return;
    }

    _addLog(id, 'Starting build for $id...');
    await AdminTabLogger.log(
      'stack_management',
      'service_build_started',
      details: {'serviceId': id},
    );

    try {
      final process = await Process.start(
        './build_web.sh',
        [],
        workingDirectory: dir,
      );

      process.stdout
          .transform(utf8.decoder)
          .listen((line) => _addLog(id, line));
      process.stderr
          .transform(utf8.decoder)
          .listen((line) => _addLog(id, 'ERROR: $line'));

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        _addLog(id, 'Build successful!');
        await AdminTabLogger.log(
          'stack_management',
          'service_build_completed',
          details: {'serviceId': id, 'exitCode': exitCode},
        );
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == serviceIdx)
              state[i].copyWith(status: ServiceStatus.offline)
            else
              state[i],
        ];
      } else {
        _addLog(id, 'Build failed with code $exitCode');
        await AdminTabLogger.log(
          'stack_management',
          'service_build_failed',
          details: {'serviceId': id, 'exitCode': exitCode},
        );
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == serviceIdx)
              state[i].copyWith(status: ServiceStatus.failed)
            else
              state[i],
        ];
      }
    } catch (e) {
      _addLog(id, 'Build error: $e');
      await AdminTabLogger.log(
        'stack_management',
        'service_build_exception',
        details: {'serviceId': id},
        error: e,
      );
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == serviceIdx)
            state[i].copyWith(status: ServiceStatus.failed)
          else
            state[i],
      ];
    }
  }

  Future<void> startService(String id) async {
    final serviceIdx = state.indexWhere((s) => s.id == id);
    if (serviceIdx == -1) return;

    if (state[serviceIdx].status == ServiceStatus.online) return;
    final service = state[serviceIdx];
    if (service.path != null &&
        !Directory(service.path!).existsSync() &&
        !File(service.path!).existsSync()) {
      _markServiceFailed(
        serviceIdx,
        'Configured path is missing: ${service.path}',
      );
      return;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == serviceIdx)
          state[i].copyWith(status: ServiceStatus.starting)
        else
          state[i],
    ];

    Process? process;
    try {
      await AdminTabLogger.log(
        'stack_management',
        'service_start_requested',
        details: {'serviceId': id},
      );
      if (id == 'backend') {
        process = await Process.start(
          PokemonCenterConstants.nodePath,
          ['server.js'],
          workingDirectory: PokemonCenterConstants.backendDir,
        );
      } else if (id == 'main_site' || id == 'admin_web' || id == 'exchange') {
        final port = switch (id) {
          'main_site' => PokemonCenterConstants.mainSitePort,
          'admin_web' => PokemonCenterConstants.adminWebPort,
          'exchange' => PokemonCenterConstants.exchangePort,
          _ => PokemonCenterConstants.mainSitePort,
        };
        final dir = switch (id) {
          'main_site' => '${PokemonCenterConstants.mainSiteDir}/build/web',
          'admin_web' => '${PokemonCenterConstants.adminWebDir}/build/web',
          'exchange' => '${PokemonCenterConstants.exchangeDir}/build/web',
          _ => '${PokemonCenterConstants.mainSiteDir}/build/web',
        };
        process = await Process.start('python3', [
          '-m',
          'http.server',
          port.toString(),
          '--directory',
          dir,
        ]);
      } else if (id == 'asset_server') {
        process = await Process.start('python3', [
          '-m',
          'http.server',
          PokemonCenterConstants.assetServerPort.toString(),
          '--directory',
          '${PokemonCenterConstants.rootDir}/asset_sources',
        ]);
      } else if (id == 'ollama') {
        final ollamaBinary =
            File(PokemonCenterConstants.ollamaAltCliPath).existsSync()
            ? PokemonCenterConstants.ollamaAltCliPath
            : PokemonCenterConstants.ollamaCliPath;
        process = await Process.start(
          ollamaBinary,
          ['serve'],
          environment: {'HOME': Platform.environment['HOME'] ?? ''},
        );
      } else if (id == 'tunnel') {
        process = await Process.start(
          PokemonCenterConstants.cloudflaredPath,
          ['tunnel', 'run'],
          environment: {'HOME': Platform.environment['HOME'] ?? ''},
        );
      } else {
        _markServiceFailed(
          serviceIdx,
          'Grid control restored, but no local launch command is configured for ${service.name} yet.',
        );
        return;
      }

      final startedProcess = process;
      _processes[id] = startedProcess;
      startedProcess.stdout
          .transform(utf8.decoder)
          .listen((line) => _addLog(id, line));
      startedProcess.stderr
          .transform(utf8.decoder)
          .listen((line) => _addLog(id, line));

      // Wait a bit to ensure it didn't crash immediately
      await Future.delayed(const Duration(seconds: 1));

      state = [
        for (int i = 0; i < state.length; i++)
          if (i == serviceIdx)
            state[i].copyWith(status: ServiceStatus.online)
          else
            state[i],
      ];

      startedProcess.exitCode.then((code) {
        _addLog(id, 'Process exited with code $code');
        AdminTabLogger.log(
          'stack_management',
          'service_process_exited',
          details: {'serviceId': id, 'exitCode': code},
        );
        _processes.remove(id);
        if (mounted) {
          state = [
            for (int i = 0; i < state.length; i++)
              if (i == serviceIdx)
                state[i].copyWith(status: ServiceStatus.offline)
              else
                state[i],
          ];
        }
      });
    } catch (e) {
      await AdminTabLogger.log(
        'stack_management',
        'service_start_failed',
        details: {'serviceId': id},
        error: e,
      );
      _markServiceFailed(serviceIdx, 'Failed to start: $e');
    }
  }

  void stopService(String id) {
    AdminTabLogger.log(
      'stack_management',
      'service_stop_requested',
      details: {'serviceId': id},
    );
    _processes[id]?.kill();
    _processes.remove(id);

    // Also kill port if it's a web service
    final service = state.firstWhere((s) => s.id == id);
    if (service.port != null) {
      Process.run('sh', ['-c', 'lsof -ti :${service.port} | xargs kill -9']);
    }

    state = state
        .map((s) => s.id == id ? s.copyWith(status: ServiceStatus.offline) : s)
        .toList();
  }

  void _markServiceFailed(int serviceIdx, String message) {
    final id = state[serviceIdx].id;
    _addLog(id, message);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == serviceIdx)
          state[i].copyWith(status: ServiceStatus.failed)
        else
          state[i],
    ];
  }
}
