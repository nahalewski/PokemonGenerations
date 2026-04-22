import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/api_client.dart';
import './handbook_screen.dart';

// ── Section IDs ────────────────────────────────────────────────────────────────
enum _Section {
  summary,
  checking,
  savings,
  retirement,
  transactions,
}

extension _SectionExt on _Section {
  String get label {
    switch (this) {
      case _Section.summary: return 'Summary';
      case _Section.checking: return 'Checking Account';
      case _Section.savings: return 'Global Savings';
      case _Section.retirement: return 'Retirement Reserve';
      case _Section.transactions: return 'All Transactions';
    }
  }

  IconData get icon {
    switch (this) {
      case _Section.summary: return Icons.dashboard_outlined;
      case _Section.checking: return Icons.account_balance_outlined;
      case _Section.savings: return Icons.savings_outlined;
      case _Section.retirement: return Icons.shield_outlined;
      case _Section.transactions: return Icons.receipt_long_outlined;
    }
  }
}

// ── BankScreen ─────────────────────────────────────────────────────────────────
class BankScreen extends ConsumerStatefulWidget {
  final String username;
  const BankScreen({super.key, required this.username});

  @override
  ConsumerState<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends ConsumerState<BankScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _amountCtrl = TextEditingController();
  final _fmt = NumberFormat('#,##0.00');

  Map<String, dynamic> _bankData = {};
  List<dynamic> _history = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  _Section _section = _Section.summary;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    final client = ref.read(apiClientProvider);
    final data = await client.getBankData(widget.username);
    if (mounted) {
      setState(() {
        _bankData = data;
        _history = List<dynamic>.from(data['bank_history'] ?? []);
        _isLoading = false;
      });
    }
  }

  void _go(_Section s) {
    _scaffoldKey.currentState?.closeDrawer();
    setState(() => _section = s);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.black,
                    onRefresh: _fetch,
                    child: _buildSection(),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Top bar (hamburger + section name) ────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      height: 50,
      color: const Color(0xFF050505),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary, size: 22),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Open menu',
          ),
          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(width: 12),
          Text(
            _section.label.toUpperCase(),
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white24, size: 18),
            onPressed: _fetch,
          ),
        ],
      ),
    );
  }

  // ── Left drawer ───────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    final checking = (_bankData['bank']?['balance'] ?? 0).toDouble();
    final savings = (_bankData['bank']?['savings'] ?? 0).toDouble();
    final roth = (_bankData['bank']?['retirement']?['roth'] ?? 0).toDouble();
    final k401 = (_bankData['bank']?['retirement']?['k401'] ?? 0).toDouble();
    final pokedollars = (_bankData['pokedollars'] ?? 0).toDouble();
    final total = checking + savings + roth + k401;

    return Drawer(
      backgroundColor: const Color(0xFF070707),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BANK TERMINAL',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3)),
                  const SizedBox(height: 10),
                  Text('${_fmt.format(total)} V',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 2),
                  const Text('Total Vault Assets',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 9, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  // Wallet
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: Colors.white24, size: 12),
                      const SizedBox(width: 6),
                      Text('Wallet: ${_fmt.format(pokedollars)} V',
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              fontFamily: 'monospace')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Navigation items
            _drawerItem(_Section.summary, 'Total Assets',
                _fmt.format(total)),
            _drawerItem(_Section.checking, 'Checking',
                _fmt.format(checking)),
            _drawerItem(_Section.savings, 'Savings',
                _fmt.format(savings)),
            _drawerItem(_Section.retirement, 'Retirement',
                _fmt.format(roth + k401)),
            _drawerItem(_Section.transactions, 'History',
                '${_history.length} records'),

            const Spacer(),

            // Handbook link
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: OutlinedButton.icon(
                onPressed: () {
                  _scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HandbookScreen()),
                  );
                },
                icon: const Icon(Icons.help_outline, size: 14),
                label: const Text('HANDBOOK',
                    style: TextStyle(fontSize: 10, letterSpacing: 1)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white38,
                  side: const BorderSide(color: Colors.white10),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(_Section s, String label, String sub) {
    final selected = _section == s;
    return InkWell(
      onTap: () => _go(s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : null,
          border: selected
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 3))
              : const Border(
                  left: BorderSide(color: Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Icon(s.icon,
                color: selected ? AppColors.primary : Colors.white38,
                size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: selected ? AppColors.primary : Colors.white70,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  Text(sub,
                      style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 9,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.chevron_right,
                  color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Section router ─────────────────────────────────────────────────────────────
  Widget _buildSection() {
    switch (_section) {
      case _Section.summary: return _buildSummary();
      case _Section.checking: return _buildAccountDetail('checking');
      case _Section.savings: return _buildAccountDetail('savings');
      case _Section.retirement: return _buildRetirement();
      case _Section.transactions: return _buildTransactions(_history);
    }
  }

  // ── SUMMARY ────────────────────────────────────────────────────────────────────
  Widget _buildSummary() {
    final checking = (_bankData['bank']?['balance'] ?? 0).toDouble();
    final savings = (_bankData['bank']?['savings'] ?? 0).toDouble();
    final roth = (_bankData['bank']?['retirement']?['roth'] ?? 0).toDouble();
    final k401 = (_bankData['bank']?['retirement']?['k401'] ?? 0).toDouble();
    final pokedollars = (_bankData['pokedollars'] ?? 0).toDouble();
    final total = checking + savings + roth + k401;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Total asset hero
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF080810),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL VAULT ASSETS',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 9, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('${_fmt.format(total)} V',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: -1)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white24, size: 12),
                  const SizedBox(width: 6),
                  Text('Wallet: ${_fmt.format(pokedollars)} V',
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontFamily: 'monospace')),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Account cards (tappable)
        _summaryCard(
          'Checking Account',
          checking,
          AppColors.primary,
          Icons.account_balance_outlined,
          () => setState(() => _section = _Section.checking),
        ),
        const SizedBox(height: 10),
        _summaryCard(
          'Global Savings',
          savings,
          AppColors.secondary,
          Icons.savings_outlined,
          () => setState(() => _section = _Section.savings),
        ),
        const SizedBox(height: 10),
        _summaryCard(
          'Retirement Reserve',
          roth + k401,
          Colors.orange,
          Icons.shield_outlined,
          () => setState(() => _section = _Section.retirement),
        ),

        const SizedBox(height: 24),

        // Quick actions
        Row(
          children: [
            Expanded(
              child: _actionBtn(
                'DEPOSIT',
                Icons.arrow_upward,
                AppColors.primary,
                () => _showDepositWithdraw('DEPOSIT'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionBtn(
                'WITHDRAW',
                Icons.arrow_downward,
                Colors.redAccent,
                () => _showDepositWithdraw('WITHDRAW'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Recent transactions preview
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RECENT ACTIVITY',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 9, letterSpacing: 2)),
              TextButton(
                onPressed: () => setState(() => _section = _Section.transactions),
                child: const Text('VIEW ALL',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 9, letterSpacing: 1)),
              ),
            ],
          ),
          ..._history.take(5).map(_txTile),
        ],
      ],
    );
  }

  Widget _summaryCard(String label, double value, Color accent, IconData icon,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF080808),
          border: Border(left: BorderSide(color: accent, width: 2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('Tap to view statements',
                      style: TextStyle(
                          color: accent.withOpacity(0.5), fontSize: 8,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
            Text('${_fmt.format(value)} V',
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  // ── ACCOUNT DETAIL (checking / savings) ────────────────────────────────────────
  Widget _buildAccountDetail(String source) {
    final isChecking = source == 'checking';
    final balance = isChecking
        ? (_bankData['bank']?['balance'] ?? 0).toDouble()
        : (_bankData['bank']?['savings'] ?? 0).toDouble();
    final accent = isChecking ? AppColors.primary : AppColors.secondary;
    final txs = _history.where((t) => t['source'] == source).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Balance hero
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          color: const Color(0xFF080810),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isChecking ? 'CHECKING ACCOUNT' : 'GLOBAL SAVINGS',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 9, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text('${_fmt.format(balance)} V',
                  style: TextStyle(
                      color: accent,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: -1)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      isChecking ? 'DEPOSIT' : 'TRANSFER IN',
                      Icons.arrow_upward,
                      accent,
                      () => isChecking
                          ? _showDepositWithdraw('DEPOSIT')
                          : _showTransfer('vault_to_checking'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionBtn(
                      isChecking ? 'TO SAVINGS' : 'TO CHECKING',
                      Icons.compare_arrows,
                      Colors.white54,
                      () => isChecking
                          ? _showTransfer('checking_to_vault')
                          : _showTransfer('vault_to_checking'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Statements header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(width: 2, height: 12, color: accent),
              const SizedBox(width: 8),
              Text('STATEMENTS (${txs.length})',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 9, letterSpacing: 2)),
            ],
          ),
        ),

        if (txs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('NO TRANSACTIONS YET',
                  style: TextStyle(
                      color: Colors.white24, fontSize: 10, letterSpacing: 2)),
            ),
          )
        else
          ...txs.map(_txTile),

        const SizedBox(height: 32),
      ],
    );
  }

  // ── RETIREMENT ─────────────────────────────────────────────────────────────────
  Widget _buildRetirement() {
    final roth = (_bankData['bank']?['retirement']?['roth'] ?? 0).toDouble();
    final k401 = (_bankData['bank']?['retirement']?['k401'] ?? 0).toDouble();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Hero
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          color: const Color(0xFF080810),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RETIREMENT RESERVE',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 9, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('${_fmt.format(roth + k401)} V',
                  style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: -1)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // 401(k)
              _retirementCard(
                'Aevora 401(k)',
                'Employer-matched retirement savings',
                k401,
                Colors.orange,
                Icons.shield_moon,
                () => _showContribute('k401'),
              ),
              const SizedBox(height: 12),
              // Roth IRA
              _retirementCard(
                'Silph Roth IRA',
                'Tax-advantaged individual retirement',
                roth,
                Colors.blueAccent,
                Icons.security_update_good,
                () => _showContribute('roth'),
              ),

              const SizedBox(height: 20),

              // Info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.04),
                  border: Border.all(color: AppColors.primary.withOpacity(0.12)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 15),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'CEO PRIVILEGE: 6% employer matching applied automatically to all salary deposits.',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _retirementCard(String title, String subtitle, double value,
      Color accent, IconData icon, VoidCallback onContribute) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080808),
        border: Border(left: BorderSide(color: accent, width: 2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 9)),
                    ],
                  ),
                ),
                Text('${_fmt.format(value)} V',
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.02),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onContribute,
                    icon: const Icon(Icons.add, size: 12),
                    label: const Text('CONTRIBUTE',
                        style: TextStyle(fontSize: 9, letterSpacing: 1)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent.withOpacity(0.4)),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ALL TRANSACTIONS ───────────────────────────────────────────────────────────
  Widget _buildTransactions(List<dynamic> txs) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(width: 2, height: 12, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('ALL TRANSACTIONS (${txs.length})',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 9, letterSpacing: 2)),
            ],
          ),
        ),
        if (txs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: Text('NO TRANSACTION HISTORY',
                  style: TextStyle(
                      color: Colors.white24, fontSize: 10, letterSpacing: 2)),
            ),
          )
        else
          ...txs.map(_txTile),
      ],
    );
  }

  // ── Transaction tile ──────────────────────────────────────────────────────────
  Widget _txTile(dynamic tx) {
    final amount = (tx['amount'] ?? 0).toDouble();
    final isPositive = amount >= 0;
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;
    String dateStr = '';
    try {
      final dt = DateTime.parse(tx['timestamp']).toLocal();
      dateStr = DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {
      dateStr = tx['timestamp']?.toString() ?? '';
    }

    // Source badge color
    final source = (tx['source'] ?? '').toString();
    final sourceBadgeColor = source == 'checking'
        ? AppColors.primary.withOpacity(0.3)
        : source == 'savings'
            ? AppColors.secondary.withOpacity(0.3)
            : Colors.orange.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF080808),
        border: Border(
          left: BorderSide(color: color.withOpacity(0.4), width: 2),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            isPositive ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 12),

          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (tx['description'] ?? '').toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(dateStr,
                        style: const TextStyle(
                            color: Colors.white24, fontSize: 8)),
                    if (source.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        color: sourceBadgeColor,
                        child: Text(source.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 7, letterSpacing: 0.5,
                                color: Colors.white70)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${isPositive ? '+' : ''}${_fmt.format(amount)} V',
            style: TextStyle(
                color: color,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Action button ─────────────────────────────────────────────────────────────
  Widget _actionBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 13),
      label: Text(label,
          style: const TextStyle(fontSize: 9, letterSpacing: 0.5)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.4)),
        shape:
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────────
  void _showDepositWithdraw(String type) {
    _amountCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text(type == 'DEPOSIT' ? 'DEPOSIT TO VAULT' : 'ATM WITHDRAWAL',
            style: const TextStyle(
                color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type == 'DEPOSIT'
                  ? 'Transfer PokéDollars from wallet to checking.'
                  : 'Withdraw from checking to wallet.',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'AMOUNT (V)',
                labelStyle: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black),
            onPressed: () async {
              final amt = double.tryParse(_amountCtrl.text) ?? 0;
              if (amt <= 0) return;
              setState(() => _isProcessing = true);
              final client = ref.read(apiClientProvider);
              final endpoint = type == 'DEPOSIT'
                  ? '/economy/bank/deposit'
                  : '/economy/bank/withdraw';
              try {
                await client.post(endpoint,
                    {'username': widget.username, 'amount': amt});
                if (mounted) {
                  Navigator.pop(context);
                  _fetch();
                }
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            child: _isProcessing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : Text(type),
          ),
        ],
      ),
    );
  }

  void _showTransfer(String direction) {
    _amountCtrl.clear();
    final label = direction == 'checking_to_vault'
        ? 'CHECKING → SAVINGS'
        : 'SAVINGS → CHECKING';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text('TRANSFER: $label',
            style: const TextStyle(
                color: AppColors.primary, fontSize: 12, letterSpacing: 1)),
        content: TextField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'AMOUNT (V)',
            labelStyle: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black),
            onPressed: () async {
              final amt = double.tryParse(_amountCtrl.text) ?? 0;
              if (amt <= 0) return;
              await ref
                  .read(apiClientProvider)
                  .transferFunds(widget.username, amt, direction);
              if (mounted) {
                Navigator.pop(context);
                _fetch();
              }
            },
            child: const Text('TRANSFER'),
          ),
        ],
      ),
    );
  }

  void _showContribute(String type) {
    _amountCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text(
            'CONTRIBUTE: ${type == 'k401' ? '401(k)' : 'Roth IRA'}',
            style: const TextStyle(
                color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
        content: TextField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'AMOUNT (V)',
            labelStyle: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black),
            onPressed: () async {
              final amt = double.tryParse(_amountCtrl.text) ?? 0;
              if (amt <= 0) return;
              await ref
                  .read(apiClientProvider)
                  .contributeRetirement(widget.username, amt, type);
              if (mounted) {
                Navigator.pop(context);
                _fetch();
              }
            },
            child: const Text('CONTRIBUTE'),
          ),
        ],
      ),
    );
  }
}
