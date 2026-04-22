import 'dart:async';
import 'package:flutter/material.dart';
import 'economy_service.dart';

void main() {
  runApp(const EconomyAdminApp());
}

class EconomyAdminApp extends StatelessWidget {
  const EconomyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
      ),
      home: const EconomyDashboard(),
    );
  }
}

class EconomyDashboard extends StatefulWidget {
  const EconomyDashboard({super.key});

  @override
  State<EconomyDashboard> createState() => _EconomyDashboardState();
}

class _EconomyDashboardState extends State<EconomyDashboard> {
  final _service = EconomyService();
  Map<String, dynamic> _status = {};
  List<dynamic> _market = [];
  Timer? _timer;
  
  double _manualTax = 0.05;
  bool _overrideEnabled = false;
  bool _isSyncingNews = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      final status = await _service.fetchStatus();
      final market = await _service.fetchMarket();
      setState(() {
        _status = status;
        _market = market;
        if (!_overrideEnabled) {
          _manualTax = (status['taxRate'] ?? 0.05).toDouble();
        }
      });
    } catch (_) {}
  }

  Future<void> _syncNews() async {
    setState(() => _isSyncingNews = true);
    try {
      await _service.syncNews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NEWS SYNC SUCCESSFUL'), backgroundColor: Colors.greenAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SYNC FAILED: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncingNews = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ECONOMY COMMAND CENTER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
      bottomNavigationBar: _buildAdminPortal(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 300,
      color: Colors.black38,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetric('BITCOIN (PRICE)', '\$${(_status['bitcoinPrice'] ?? 0).toLocaleString()}', Icons.currency_bitcoin, Colors.amber),
          const SizedBox(height: 24),
          _buildMetric('NASDAQ INDEX', '${(_status['nasdaqIndex'] ?? 0).toLocaleString()}', Icons.show_chart, Colors.blueAccent),
          const SizedBox(height: 24),
          _buildMetric('GLOBAL TAX RATE', '${((_status['taxRate'] ?? 0.0) * 100).toStringAsFixed(1)}%', Icons.percent, Colors.purpleAccent),
          const Spacer(),
          const Text('SYSTEM HEALTH', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 8),
          _buildStatusRow('API CONNECTED', true),
          _buildStatusRow('MARKET SYNC', true),
          _buildStatusRow('TREASURY ACTIVE', true),
          const SizedBox(height: 32),
          const Text('TERMINAL BROADCAST', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSyncingNews ? null : _syncNews,
              icon: _isSyncingNews 
                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync_alt, size: 16),
              label: Text(_isSyncingNews ? 'SYNCING...' : 'ACTIVATE NEWS SYNC'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusRow(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: ok ? Colors.greenAccent : Colors.redAccent),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('OPERATIONAL STACK MONITOR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              _buildLiveUserCounter(),
            ],
          ),
          const SizedBox(height: 24),
          const ServiceStackMonitor(),
          const SizedBox(height: 32),
          const Text('SYSTEM LOGS & COMMUNICATIONS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          const Expanded(child: AdminTerminalWindow()),
        ],
      ),
    );
  }

  Widget _buildLiveUserCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: Colors.greenAccent, size: 14),
          const SizedBox(width: 8),
          Text(
            '${_status['activeUsers'] ?? 0} TRAINERS ONLINE',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPortal() {
    return Container(
      height: 120,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ECONOMIC STIMULUS CONTROLS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
              Row(
                children: [
                  Checkbox(
                    value: _overrideEnabled, 
                    onChanged: (v) => setState(() => _overrideEnabled = v ?? false)
                  ),
                  const Text('ENABLE MANUAL OVERRIDE', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('MANUAL TAX RATE', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    Text('${(_manualTax * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _manualTax,
                  min: 0.02,
                  max: 0.15,
                  onChanged: _overrideEnabled ? (v) => setState(() => _manualTax = v) : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          ElevatedButton(
            onPressed: _overrideEnabled ? () => _service.updateTax(_manualTax, _overrideEnabled) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            child: const Text('PUSH UPDATES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class ServiceStackMonitor extends StatelessWidget {
  const ServiceStackMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      'API ENGINE', 'DB CLUSTER', 'AUTH SOCKET', 'MARKET WATCH', 'TREASURY',
      'SOCIAL SYNC', 'BATTLE CORE', 'PC STORAGE', 'ASSET CDN', 'NEWS PARSER',
      'CRYPTO FEED', 'LOG AGGREGATOR', 'GEO PROVIDER', 'MAIL SERVER', 'BACKUP PROC'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 15, // 5x3 Grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final health = 0.85 + (index % 5) * 0.03; // Simulated health
        final color = health > 0.95 ? Colors.greenAccent : (health > 0.9 ? Colors.orangeAccent : Colors.redAccent);
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(services[index], style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(health * 100).toInt()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                  const Icon(Icons.check_circle, size: 12, color: Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: health,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminTerminalWindow extends StatefulWidget {
  const AdminTerminalWindow({super.key});

  @override
  State<AdminTerminalWindow> createState() => _AdminTerminalWindowState();
}

class _AdminTerminalWindowState extends State<AdminTerminalWindow> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _logs = [
    {'level': 'OK', 'msg': 'CORE SYSTEM BOOT SUCCESSFUL', 'time': '02:54:01.223'},
    {'level': 'OK', 'msg': 'API ENGINE: HANDSHAKE ESTABLISHED @PORT 8192', 'time': '02:54:01.450'},
    {'level': 'WARN', 'msg': 'MARKET WATCH: DETECTED BTC VOLATILITY OFFSET', 'time': '02:54:02.112'},
    {'level': 'CRIT', 'msg': 'AUTH: REJECTED CONNECTION FROM UNAUTHORIZED IP', 'time': '02:54:03.001'},
    {'level': 'OK', 'msg': 'TREASURY: AUTOMATED RETIREMENT SYNC COMPLETE', 'time': '02:54:05.882'},
    {'level': 'OK', 'msg': 'SOCIAL: 14 NEW TRAINER CONNECTIONS LOGGED', 'time': '02:54:06.120'},
    {'level': 'WARN', 'msg': 'CDN: ASSET PRE-FETCH CACHE MISS @GEN5_SPRITES', 'time': '02:54:07.443'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _logs.where((l) => l['msg'].toString().contains(_searchController.text.toUpperCase())).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 14, color: Colors.white24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() {}),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'SEARCH LOGS / FILTER BY LEVEL...',
                    hintStyle: TextStyle(fontSize: 10, color: Colors.white24),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: ListView.builder(
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                final color = log['level'] == 'OK' ? Colors.greenAccent : (log['level'] == 'WARN' ? Colors.orangeAccent : Colors.redAccent);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 11),
                      children: [
                        TextSpan(text: '[${log['time']}] ', style: const TextStyle(color: Colors.white24)),
                        TextSpan(text: '${log['level']}: ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        TextSpan(text: log['msg'], style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

extension NumberFormatting on num {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
