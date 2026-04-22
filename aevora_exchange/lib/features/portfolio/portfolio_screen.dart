import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_client.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  final String username;
  const PortfolioScreen({super.key, required this.username});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  List<dynamic> _portfolio = [];
  List<dynamic> _marketData = [];
  Map<String, dynamic> _bankData = {};
  bool _loading = true;

  final _fmt = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final client = ref.read(apiClientProvider);
    final results = await Future.wait([
      client.getBankData(widget.username),
      client.fetchMarketData(),
    ]);
    if (mounted) {
      setState(() {
        _bankData = results[0] as Map<String, dynamic>;
        _portfolio = (_bankData['bank']?['portfolio'] ?? []).cast<dynamic>();
        _marketData = (results[1] as List<dynamic>);
        _loading = false;
      });
    }
  }

  Map<String, dynamic>? _marketAsset(String assetId) {
    try {
      return Map<String, dynamic>.from(
        _marketData.firstWhere(
          (m) => (m['id'] ?? '') == assetId || (m['ticker'] ?? '') == assetId,
          orElse: () => <String, dynamic>{},
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Compute totals
    double totalValue = 0;
    double totalCost = 0;
    for (final h in _portfolio) {
      final shares = (h['shares'] ?? 0).toDouble();
      final avg = (h['avgPrice'] ?? 0).toDouble();
      final asset = _marketAsset(h['id'] as String? ?? '');
      final cur = asset != null && (asset['price'] ?? 0) != 0
          ? (asset['price'] as num).toDouble()
          : avg;
      totalValue += shares * cur;
      totalCost += shares * avg;
    }
    final gain = totalValue - totalCost;
    final gainPct = totalCost > 0 ? (gain / totalCost * 100) : 0.0;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.black,
      onRefresh: _fetch,
      child: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildHeader(totalValue, gain, gainPct),
          ),

          // ── Empty state ───────────────────────────────────────────────────
          if (_portfolio.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pie_chart_outline, color: Colors.white12, size: 56),
                    SizedBox(height: 16),
                    Text('NO ACTIVE HOLDINGS',
                        style: TextStyle(
                            color: Colors.white24, fontSize: 10, letterSpacing: 3)),
                    SizedBox(height: 8),
                    Text('Visit MARKET to purchase your first asset',
                        style: TextStyle(color: Colors.white12, fontSize: 9)),
                  ],
                ),
              ),
            )
          else ...[
            // ── Holdings list ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildCard(_portfolio[i]),
                  childCount: _portfolio.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Header card ─────────────────────────────────────────────────────────────
  Widget _buildHeader(double totalValue, double gain, double gainPct) {
    final isUp = gain >= 0;
    final gainColor = isUp ? Colors.greenAccent : Colors.redAccent;
    final pokedollars = (_bankData['pokedollars'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio label + positions count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PORTFOLIO_VALUE',
                  style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Text(
                  '${_portfolio.length} POSITION${_portfolio.length != 1 ? 'S' : ''}',
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 8, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total value
          Text(
            '${_fmt.format(totalValue)} V',
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: -1),
          ),
          const SizedBox(height: 6),

          // Gain/loss row
          Row(
            children: [
              Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: gainColor, size: 12),
              const SizedBox(width: 4),
              Text(
                '${isUp ? '+' : ''}${_fmt.format(gain)} V   '
                '(${isUp ? '+' : ''}${gainPct.toStringAsFixed(2)}%) unrealized',
                style: TextStyle(color: gainColor, fontSize: 10),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          // Wallet balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('WALLET',
                  style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2)),
              Text('${_fmt.format(pokedollars)} V',
                  style: const TextStyle(
                      color: Colors.white54, fontFamily: 'monospace', fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Holding card ─────────────────────────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> h) {
    final assetId = (h['id'] ?? '').toString();
    final ticker = (h['ticker'] ?? assetId).toString();
    final shares = (h['shares'] ?? 0).toDouble();
    final avg = (h['avgPrice'] ?? 0).toDouble();
    final dimension = (h['dimension'] ?? 'AEVORA').toString();

    final asset = _marketAsset(assetId);
    final cur = asset != null && (asset['price'] ?? 0) != 0
        ? (asset['price'] as num).toDouble()
        : avg;
    final curVal = shares * cur;
    final cost = shares * avg;
    final gain = curVal - cost;
    final gainPct = cost > 0 ? (gain / cost * 100) : 0.0;
    final isUp = gain >= 0;
    final gainColor = isUp ? Colors.greenAccent : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Top row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticker badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (ticker.length > 4 ? ticker.substring(0, 4) : ticker).toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + dimension
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assetId,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(dimension,
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 9, letterSpacing: 1)),
                    ],
                  ),
                ),

                // Value + P&L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${_fmt.format(curVal)} V',
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                            color: gainColor, size: 9),
                        Text(
                          ' ${isUp ? '+' : ''}${_fmt.format(gain)} (${gainPct.toStringAsFixed(1)}%)',
                          style: TextStyle(color: gainColor, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: Colors.white.withOpacity(0.02),
            child: Row(
              children: [
                _stat('SHARES',
                    shares == shares.truncateToDouble()
                        ? shares.toInt().toString()
                        : shares.toStringAsFixed(2)),
                _stat('AVG PRICE', '${avg.toStringAsFixed(2)} V'),
                _stat('MKT PRICE', '${cur.toStringAsFixed(2)} V'),
                const Spacer(),
                _sellBtn(h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white24, fontSize: 7, letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _sellBtn(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _showSell(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.08),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: const Text('SELL',
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
      ),
    );
  }

  void _showSell(Map<String, dynamic> item) {
    final ctrl = TextEditingController(text: item['shares'].toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text('LIQUIDATE: ${item['id']}',
            style: const TextStyle(
                color: AppColors.primary, fontSize: 13, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available: ${item['shares']} shares',
                style: const TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 4),
            const Text('0.1% Dimensional Brokerage Fee applies.',
                style: TextStyle(fontSize: 8, color: Colors.white24)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'SHARES TO SELL',
                labelStyle: TextStyle(color: AppColors.primary, fontSize: 11),
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
                backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              final qty = int.tryParse(ctrl.text) ?? 0;
              if (qty <= 0 || qty > (item['shares'] as num).toInt()) return;
              final client = ref.read(apiClientProvider);
              await client.post('/economy/market/sell', {
                'username': widget.username,
                'assetId': item['id'],
                'shares': qty,
                'priceAtTrade': item['avgPrice'],
              });
              if (mounted) {
                Navigator.pop(context);
                _fetch();
              }
            },
            child: const Text('EXECUTE'),
          ),
        ],
      ),
    );
  }
}
