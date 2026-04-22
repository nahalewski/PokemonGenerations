import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'core/theme/app_colors.dart';
import 'core/widgets/glass_card.dart';
import 'domain/models/social.dart';

void main() {
  runApp(const OnlineMenuApp());
}

class OnlineMenuApp extends StatelessWidget {
  const OnlineMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Generations - Online Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: AppColors.surface,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<SocialUser> _users = [];
  List<ChatMessage> _chatMessages = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _timer;
  String _baseUrl = 'http://localhost:8194';
  final _urlController = TextEditingController(text: 'http://localhost:8194');
  final _broadcastController = TextEditingController();
  int _activeTab = 0; // 0: Trainers, 1: Moderation

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    await _fetchUsers();
    await _fetchChat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _urlController.dispose();
    _broadcastController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/social/users'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _users = data.map((e) => SocialUser.fromJson(e)).toList();
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        _setError('Server returned ${response.statusCode}');
      }
    } catch (e) {
      _setError('Cannot reach backend at $_baseUrl');
    }
  }

  Future<void> _fetchChat() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/social/chat'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _chatMessages = data.map((e) => ChatMessage.fromJson(e)).toList().reversed.toList();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _sendBroadcast() async {
    final text = _broadcastController.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/social/broadcast'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text, 'sentBy': 'Admin Dashboard'}),
      );
      if (response.statusCode == 200) {
        _broadcastController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Broadcast sent to all trainers!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send broadcast: $e')),
        );
      }
    }
  }

  Future<void> _suspendUser(String username, bool suspend) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/admin/suspend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'suspended': suspend}),
      );
      _fetchUsers();
    } catch (_) {}
  }

  Future<void> _banIP(String ip) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/admin/ban-ip'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ip': ip}),
      );
    } catch (_) {}
  }

  Future<void> _eraseUser(String username) async {
    final confirmController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: Text('ERASE DATA: $username', style: const TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action is permanent. Type DELETE to confirm:',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                hintText: 'DELETE',
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, confirmController.text == 'DELETE'),
            child: const Text('ERASE EVERYTHING'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/admin/erase'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': username, 'confirmation': 'DELETE'}),
        );
        _fetchUsers();
      } catch (_) {}
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text('Backend URL', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _urlController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'http://localhost:8194',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.outline),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() {
                _baseUrl = _urlController.text.trim();
                _isLoading = true;
                _hasError = false;
              });
              Navigator.pop(ctx);
              _fetchUsers();
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color(0xFF1A1C1E), Color(0xFF0D0E0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (!_isLoading && !_hasError) _buildStatsBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _hasError
                        ? _buildErrorState()
                        : Column(
                            children: [
                              _buildTabBar(),
                              Expanded(child: _buildContent()),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final onlineCount = _users.where((u) => u.status == 'online' || u.status == 'battling').length;
    final isConnected = !_hasError && !_isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'POKEMON CENTER ADMIN PORTAL',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 4,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('POKEMON',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
                  Text(' GENERATIONS',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Text(
                      '$onlineCount',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent),
                    ),
                    Text(
                      'ONLINE NOW',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.computer_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'POKEMON CENTER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'MAC ADMIN SUITE',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isConnected ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConnected ? 'CONNECTED' : 'DISCONNECTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isConnected ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                        Text(
                          _baseUrl,
                          style: TextStyle(
                              fontSize: 9, color: Colors.white.withOpacity(0.4)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showUrlDialog,
                      child: Icon(Icons.settings,
                          size: 16, color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final total = _users.length;
    final online = _users.where((u) => u.status == 'online').length;
    final battling = _users.where((u) => u.status == 'battling').length;
    final offline = _users.where((u) => u.status == 'offline').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Row(
        children: [
          _statChip('TOTAL', '$total', Colors.white70),
          const SizedBox(width: 12),
          _statChip('ONLINE', '$online', Colors.greenAccent),
          const SizedBox(width: 12),
          _statChip('BATTLING', '$battling', Colors.orangeAccent),
          const SizedBox(width: 12),
          _statChip('OFFLINE', '$offline', Colors.grey),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontSize: 10,
                letterSpacing: 1,
                color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Retrying automatically every 3 seconds',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchUsers();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Now'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _showUrlDialog,
            child: const Text('Change Backend URL'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          _navItem('TRAINER NETWORK', 0, Icons.grid_view_rounded),
          const SizedBox(width: 16),
          _navItem('MODERATION HUB', 1, Icons.admin_panel_settings_rounded),
        ],
      ),
    );
  }

  Widget _navItem(String label, int index, IconData icon) {
    final active = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: active ? AppColors.primary.withOpacity(0.2) : null,
        child: Row(
          children: [
            Icon(icon, size: 18, color: active ? AppColors.primary : Colors.white54),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: active ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_users.isEmpty && _activeTab == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No trainers registered yet',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Connected to $_baseUrl',
              style: TextStyle(color: Colors.greenAccent.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return _activeTab == 0 ? _buildTrainerGrid() : _buildModerationPanel();
  }

  Widget _buildTrainerGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSidebar(),
        Expanded(child: _buildGrid()),
      ],
    );
  }

  Widget _buildModerationPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildBroadcastControl(),
                const SizedBox(height: 20),
                Expanded(child: _buildChatAdmin()),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildUserStatusAdmin(),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastControl() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GLOBAL BROADCAST',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _broadcastController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Send message to all online trainers...',
                    hintStyle: TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _sendBroadcast,
                icon: const Icon(Icons.send),
                label: const Text('BROADCAST'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatAdmin() {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('LIVE CHAT MONITOR & MODERATION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _chatMessages.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (ctx, i) {
                final msg = _chatMessages[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Row(
                    children: [
                      Text(msg.sender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                      const SizedBox(width: 8),
                      Text(msg.ip ?? 'No IP', style: const TextStyle(fontSize: 10, color: Colors.white24)),
                      const Spacer(),
                      Text(msg.timestamp.split('T')[1].substring(0, 5), style: const TextStyle(fontSize: 10, color: Colors.white24)),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _adminActionChip('BAN IP', Colors.redAccent, () => _banIP(msg.ip ?? '')),
                          _adminActionChip('ERASE USER', Colors.red, () => _eraseUser(msg.sender)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminActionChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildUserStatusAdmin() {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('USER STATUS CONTROL',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (ctx, i) {
                final u = _users[i];
                return ListTile(
                  dense: true,
                  title: Text(u.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _suspendUser(u.username, true),
                        child: const Text('SUSPEND', style: TextStyle(color: Colors.orange, fontSize: 11)),
                      ),
                      TextButton(
                        onPressed: () => _eraseUser(u.username),
                        child: const Text('ERASE', style: TextStyle(color: Colors.red, fontSize: 11)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final sorted = [..._users]..sort((a, b) {
        const order = {'online': 0, 'battling': 1, 'offline': 2};
        return (order[a.status] ?? 3).compareTo(order[b.status] ?? 3);
      });

    return Container(
      width: 240,
      margin: const EdgeInsets.only(left: 32, bottom: 32),
      child: GlassCard(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'ALL TRAINERS',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: Colors.white.withOpacity(0.4)),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withOpacity(0.05), height: 1),
                itemBuilder: (context, i) {
                  final u = sorted[i];
                  final color = _statusColor(u.status);
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(u.displayName[0],
                          style: const TextStyle(fontSize: 12)),
                    ),
                    title: Text(
                      u.displayName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: color),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          u.status.toUpperCase(),
                          style: TextStyle(fontSize: 9, color: color),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${u.wins}W',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiary),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 32, 32),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisExtent: 220,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final isOnline = user.status != 'offline';
        final statusColor = _statusColor(user.status);

        return GlassCard(
          padding: const EdgeInsets.all(20),
          color: isOnline ? AppColors.primary.withOpacity(0.05) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(user.displayName[0],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user.username}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.4)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: statusColor),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.status.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.wins}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text('WINS',
                          style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'ACTIVE SQUAD',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: Colors.white.withOpacity(0.25)),
              ),
              const SizedBox(height: 6),
              if (user.roster.isEmpty)
                Text('No Pokémon in roster',
                    style: TextStyle(
                        fontSize: 11, color: Colors.white.withOpacity(0.15)))
              else
                Row(
                  children: user.roster.take(6).map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Tooltip(
                        message: p.pokemonId,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Center(
                            child: Text(
                              p.pokemonId.isNotEmpty
                                  ? p.pokemonId[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.greenAccent;
      case 'battling':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }
}
