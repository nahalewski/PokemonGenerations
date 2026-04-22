import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_client.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic> _user = {};
  Map<String, dynamic> _bank = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final client = ref.read(apiClientProvider);
    final results = await Future.wait([
      client.fetchUserPortfolio(widget.username),
      client.getBankData(widget.username),
    ]);
    if (mounted) {
      setState(() {
        _user = results[0] as Map<String, dynamic>;
        _bank = results[1] as Map<String, dynamic>;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final displayName = _user['displayName'] ?? widget.username;
    final username = widget.username;
    final status = (_user['status'] ?? 'offline').toString();
    final wins = (_user['wins'] ?? 0) as int;
    final losses = (_user['losses'] ?? 0) as int;
    final total = wins + losses;
    final winRate = total > 0 ? (wins / total * 100).toStringAsFixed(1) : '—';
    final pokedollars = (_bank['pokedollars'] ?? 0).toDouble();
    final job = _bank['job'];
    final friends = (_user['friends'] ?? []) as List;
    final roster = (_user['roster'] ?? []) as List;
    final lastSeen = _user['lastSeen'] as String?;
    final profileImageUrl = _user['profileImageUrl'] as String?;

    final isOnline = status == 'online';

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.black,
      onRefresh: _fetch,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Hero banner ───────────────────────────────────────────────────
          _buildHero(displayName, username, status, isOnline, profileImageUrl, lastSeen),

          // ── Stats row ─────────────────────────────────────────────────────
          _buildStatsRow(wins, losses, winRate, friends.length),

          const SizedBox(height: 12),

          // ── Financial card ────────────────────────────────────────────────
          _buildSection('FINANCIAL SUMMARY', [
            _buildRow(Icons.monetization_on_outlined, 'WALLET',
                '${NumberFormat('#,##0.00').format(pokedollars)} V'),
            if (job != null)
              _buildRow(Icons.work_outline, 'OCCUPATION',
                  job['title']?.toString() ?? 'Unemployed'),
          ]),

          const SizedBox(height: 12),

          // ── Battle record ─────────────────────────────────────────────────
          _buildSection('BATTLE RECORD', [
            _buildRow(Icons.emoji_events_outlined, 'VICTORIES', '$wins'),
            _buildRow(Icons.close, 'DEFEATS', '$losses'),
            _buildRow(Icons.percent, 'WIN RATE', '$winRate%'),
          ]),

          const SizedBox(height: 12),

          // ── Active roster ─────────────────────────────────────────────────
          if (roster.isNotEmpty)
            _buildSection('ACTIVE ROSTER (${roster.length})',
                roster.map((p) => _buildPokemonRow(p)).toList()),

          const SizedBox(height: 12),

          // ── Friends ───────────────────────────────────────────────────────
          if (friends.isNotEmpty)
            _buildSection('LINKED TRAINERS (${friends.length})',
                friends.map((f) => _buildFriendRow(f.toString())).toList()),

          const SizedBox(height: 32),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(sessionProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout, size: 14),
              label: const Text('DISCONNECT SESSION',
                  style: TextStyle(fontSize: 10, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────────
  Widget _buildHero(
    String displayName,
    String username,
    String status,
    bool isOnline,
    String? imageUrl,
    String? lastSeen,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      color: Colors.black,
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
                ),
                child: ClipOval(
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 1, color: AppColors.primary)),
                          errorWidget: (_, __, ___) => _avatarFallback(displayName),
                        )
                      : _avatarFallback(displayName),
                ),
              ),
              // Online dot
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? Colors.greenAccent : Colors.white24,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(displayName,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('@$username',
              style: const TextStyle(
                  color: Colors.white38, fontSize: 11, letterSpacing: 1)),

          if (lastSeen != null) ...[
            const SizedBox(height: 6),
            Text(
              isOnline
                  ? '● ONLINE'
                  : 'LAST SEEN: ${_fmtDate(lastSeen)}',
              style: TextStyle(
                color: isOnline ? Colors.greenAccent : Colors.white24,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────────
  Widget _buildStatsRow(int wins, int losses, String winRate, int friends) {
    return Container(
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _statChip('WINS', '$wins', Colors.greenAccent),
          _statDivider(),
          _statChip('LOSSES', '$losses', Colors.redAccent),
          _statDivider(),
          _statChip('WIN RATE', '$winRate%', AppColors.primary),
          _statDivider(),
          _statChip('FRIENDS', '$friends', Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white24, fontSize: 7, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 32, color: Colors.white10);

  // ── Section card ──────────────────────────────────────────────────────────────
  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
              color: AppColors.primary.withOpacity(0.04),
            ),
            child: Row(
              children: [
                Container(width: 2, height: 12, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'monospace', fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPokemonRow(dynamic p) {
    final name = (p['pokemonName'] ?? p['name'] ?? 'Unknown').toString();
    final level = p['level']?.toString() ?? '?';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const Spacer(),
          Text('Lv.$level',
              style: const TextStyle(
                  color: Colors.white24, fontFamily: 'monospace', fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildFriendRow(String friendUsername) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Colors.white24, size: 16),
          const SizedBox(width: 12),
          Text('@$friendUsername',
              style: const TextStyle(color: Colors.white70, fontSize: 11,
                  fontFamily: 'monospace')),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

  String _fmtDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }
}
