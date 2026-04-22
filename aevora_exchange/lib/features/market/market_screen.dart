import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/api_client.dart';

class MarketScreen extends ConsumerStatefulWidget {
  final String username;
  const MarketScreen({super.key, this.username = 'guest'});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _allMarketData = [];
  List<dynamic> _filteredMarketData = [];
  List<dynamic> _newsData = [];
  List<dynamic> _dimensions = [];
  String _currentRegionId = 'AEVORA';
  String _selectedSector = 'ALL';
  String _searchQuery = '';
  Map<String, dynamic>? _selectedHeroAsset;
  int _unreadMailCount = 0;
  late AnimationController _pulseController;

  bool _isLoading = true;
  bool _isDimensionShifting = false;
  bool _isBuying = false;
  bool _isHeroHistoryLoading = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _fetch();
    _fetchDims();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchDims() async {
    final client = ref.read(apiClientProvider);
    final dims = await client.fetchDimensions();
    if (mounted) setState(() => _dimensions = dims);
  }

  Future<void> _fetch({String? region}) async {
    final client = ref.read(apiClientProvider);
    final targetRegion = region ?? _currentRegionId;

    if (region != null && region != _currentRegionId) {
      setState(() => _isDimensionShifting = true);
      await Future.delayed(const Duration(milliseconds: 600));
    }

    final market = await client.fetchMarketData(region: targetRegion);
    final news = await client.fetchNewsData();

    if (mounted) {
      setState(() {
        _allMarketData = market;
        _newsData = news;
        _currentRegionId = targetRegion;
        _applyFilters();
        if (_filteredMarketData.isNotEmpty && _selectedHeroAsset == null) {
          _selectedHeroAsset = _filteredMarketData[0];
        }
        _isLoading = false;
        _isDimensionShifting = false;
      });

      // Refresh hero chart history after loading
      if (_selectedHeroAsset != null) {
        _refreshHeroHistory(_selectedHeroAsset!);
      }
    }
  }

  /// Fetches fresh candle history for the selected hero asset
  Future<void> _refreshHeroHistory(Map<String, dynamic> asset) async {
    if (_isHeroHistoryLoading) return;
    final assetId = asset['id']?.toString() ?? '';
    if (assetId.isEmpty) return;

    setState(() => _isHeroHistoryLoading = true);

    final client = ref.read(apiClientProvider);
    final history = await client.fetchMarketHistory(assetId);

    if (mounted && history.isNotEmpty) {
      setState(() {
        // Only update if this is still the selected hero
        if (_selectedHeroAsset?['id'] == assetId) {
          _selectedHeroAsset = {
            ..._selectedHeroAsset!,
            'history': history,
          };
        }
        _isHeroHistoryLoading = false;
      });
    } else if (mounted) {
      setState(() => _isHeroHistoryLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredMarketData = _allMarketData.where((asset) {
        final matchesSector =
            _selectedSector == 'ALL' || asset['sector'] == _selectedSector;
        final matchesSearch = asset['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            asset['ticker']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        return matchesSector && matchesSearch;
      }).toList();
    });
  }

  void _selectHero(Map<String, dynamic> asset) {
    setState(() => _selectedHeroAsset = asset);
    _refreshHeroHistory(asset);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final currentDim = _dimensions.firstWhere(
        (d) => d['id'] == _currentRegionId,
        orElse: () => {});
    final theme = currentDim['theme'] ?? 'standard';

    return Scaffold(
      // Use a Column body so the news ticker sits BELOW the scroll area
      // without floating over it (eliminates button/content overlap)
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildThemedBackground(theme),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMarketHeader(),
                      const SizedBox(height: 20),
                      _buildSearchAndFilterHub(),
                      const SizedBox(height: 24),
                      _buildDimensionSelector(),
                      const SizedBox(height: 32),
                      if (_selectedHeroAsset != null)
                        _buildHeroAssetChart(_selectedHeroAsset!),
                      const SizedBox(height: 32),
                      Text(
                        'MARKET_REGISTRY_${_currentRegionId}',
                        style: AppTypography.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildAssetList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                if (_isDimensionShifting) _buildDimensionalDriftOverlay(),
              ],
            ),
          ),

          // News ticker is rendered BELOW the scroll area — no overlap possible
          if (_newsData.isNotEmpty) _buildNewsTicker(),
        ],
      ),
    );
  }

  Widget _buildThemedBackground(String theme) {
    if (theme == 'sepia') {
      return Container(color: const Color(0xFFE5D3B3).withOpacity(0.1));
    } else if (theme == 'hologram') {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.transparent
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSearchAndFilterHub() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (val) {
            _searchQuery = val;
            _applyFilters();
          },
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'SEARCH_ASSETS...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.primary, size: 16),
            filled: true,
            fillColor: Colors.black,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              'ALL',
              'TECH',
              'RETAIL',
              'MEDIA',
              'INDUSTRIAL',
              'PENNY',
              'GUILD'
            ].map((sector) {
              final isSelected = _selectedSector == sector;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(sector,
                      style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? Colors.black : Colors.white)),
                  selected: isSelected,
                  onSelected: (val) {
                    _selectedSector = sector;
                    _applyFilters();
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerLow,
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroAssetChart(Map<String, dynamic> asset) {
    final history = List<dynamic>.from(asset['history'] ?? []);
    final price = (asset['currentPrice'] ?? 0.0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: name + price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset['name'].toString().toUpperCase(),
                        style: AppTypography.textTheme.headlineSmall
                            ?.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        asset['ticker'] ?? '',
                        style: const TextStyle(
                            color: Colors.white24, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${price.toStringAsFixed(2)} V',
                  style: AppTypography.textTheme.displayMedium?.copyWith(
                      fontSize: 24, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart area
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                border: Border.all(color: Colors.white10),
              ),
              child: _isHeroHistoryLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : history.isEmpty
                      ? _buildEmptyChartPlaceholder(asset)
                      : CustomPaint(painter: CandlePainter(history)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PITCH_1M_RESOLUTION',
                    style: TextStyle(color: Colors.white12, fontSize: 8)),
                Row(
                  children: [
                    const Icon(Icons.show_chart,
                        color: AppColors.primary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'REAL_TIME_SYNC_OK',
                      style: TextStyle(
                          color: AppColors.primary.withOpacity(0.5),
                          fontSize: 8,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action buttons — stacked in a Column so they never overlap on small screens
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showTradeDialog(asset),
                    icon: const Icon(Icons.trending_up, size: 14),
                    label: const Text('BUY SHARES'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('ASSET_TRACKED — watch list updated')),
                      );
                    },
                    icon: const Icon(Icons.bookmark_border, size: 14),
                    label: const Text('TRACK ASSET'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHighest,
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredMarketData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _filteredMarketData[index];
        final name = item['name'] ?? 'ASSET_LOADING';
        final ticker = item['ticker'] ?? '\$???';
        final price = (item['currentPrice'] ?? 0.0).toDouble();
        final history = List<dynamic>.from(item['history'] ?? []);
        final dim = item['dimension'] ?? 'UNKNOWN';

        return Card(
          color: AppColors.surfaceContainerLow,
          child: ListTile(
            onTap: () => _selectHero(item),
            leading: Container(
              width: 40,
              height: 40,
              color: Colors.black,
              alignment: Alignment.center,
              child: Text(
                name[0],
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    name.toString().toUpperCase(),
                    style: AppTypography.textTheme.headlineSmall
                        ?.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  color: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    dim.toString().length >= 2
                        ? dim.toString().substring(0, 2)
                        : dim.toString(),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              ticker,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant),
            ),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (history.isNotEmpty)
                    SizedBox(
                      width: 40,
                      height: 20,
                      child: CustomPaint(painter: SparklinePainter(history)),
                    ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${price.toStringAsFixed(2)} V',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        item['sector'] ?? 'CORE',
                        style: const TextStyle(
                            fontSize: 8, color: Colors.white24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsTicker() {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _newsData.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final news = _newsData[index];
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 48),
              child: Text(
                news['headline'].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentRegionId,
              style: AppTypography.textTheme.headlineMedium
                  ?.copyWith(color: AppColors.primary, letterSpacing: -1),
            ),
            const Text(
              'LIVE_DIMENSIONAL_DATA_STREAM',
              style: TextStyle(
                  color: Colors.white24, fontSize: 8, letterSpacing: 1),
            ),
          ],
        ),
        Row(
          children: [
            if (_unreadMailCount > 0)
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(
                    parent: _pulseController, curve: Curves.easeInOut)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.mail, color: AppColors.primary, size: 18),
                ),
              ),
            const SizedBox(width: 12),
            _buildHeaderStat('SYNC_STATUS', 'OPERATIONAL', AppColors.secondary),
            const SizedBox(width: 12),
            _buildHeaderStat(
              'EST',
              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              Colors.white24,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white24, fontSize: 7, letterSpacing: 1)),
        Text(
          value,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildDimensionSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dimensions.length,
        itemBuilder: (context, index) {
          final dim = _dimensions[index];
          final isSelected = dim['id'] == _currentRegionId;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => _fetch(region: dim['id']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
                  border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white10),
                ),
                alignment: Alignment.center,
                child: Text(
                  dim['id'],
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyChartPlaceholder(Map<String, dynamic> asset) {
    final price = (asset['currentPrice'] ?? 0.0).toDouble();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.candlestick_chart_outlined,
            color: Colors.white12, size: 32),
        const SizedBox(height: 8),
        const Text(
          'AWAITING PRICE DATA',
          style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2),
        ),
        const SizedBox(height: 4),
        Text(
          'Current: ${price.toStringAsFixed(2)} V  ·  Data syncs on next market tick',
          style: const TextStyle(color: Colors.white12, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildDimensionalDriftOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text('DIMENSIONAL_BRIDGE_SYNCING...',
                style: AppTypography.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }

  void _showTradeDialog(Map<String, dynamic>? asset) {
    if (asset == null) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          title: Text('TRADE: ${asset['name']}',
              style: const TextStyle(color: AppColors.primary, fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MARKET_PRICE: ${asset['currentPrice'].toStringAsFixed(2)} PD',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'QUANTITY',
                  labelStyle:
                      TextStyle(color: AppColors.primary, fontSize: 10),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary)),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          actions: [
            if (_isBuying)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              ElevatedButton(
                onPressed: () async {
                  final qty = int.tryParse(_quantityController.text) ?? 1;
                  setState(() => _isBuying = true);

                  final success = await ref.read(apiClientProvider).buyStock(
                        username: widget.username,
                        assetId: asset['id'],
                        shares: qty,
                        price: asset['currentPrice'].toDouble(),
                        dimension: asset['dimension'],
                      );

                  if (context.mounted) {
                    setState(() => _isBuying = false);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(success
                              ? 'TRADE_EXECUTED_SUCCESSFULLY'
                              : 'TRADE_FAILED: INSUFFICIENT_FUNDS_OR_LIMIT')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black),
                child: const Text('EXECUTE'),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Candle Chart Painter ───────────────────────────────────────────────────────
class CandlePainter extends CustomPainter {
  final List<dynamic> data;
  CandlePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()..strokeWidth = 1.0;

    // Use (as num).toDouble() to handle both int and double from JSON
    final maxHigh =
        data.map((e) => (e['h'] as num).toDouble()).reduce(math.max);
    final minLow =
        data.map((e) => (e['l'] as num).toDouble()).reduce(math.min);
    final range = maxHigh - minLow;
    final scaleY = size.height / (range == 0 ? 1 : range);
    final candleWidth = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final candle = data[i];
      final o = (candle['o'] as num).toDouble();
      final c = (candle['c'] as num).toDouble();
      final h = (candle['h'] as num).toDouble();
      final l = (candle['l'] as num).toDouble();

      final isUp = c >= o;
      paint.color = isUp ? AppColors.secondary : AppColors.error;
      paint.style = PaintingStyle.fill;

      final x = i * candleWidth + (candleWidth * 0.2);
      final top = (maxHigh - math.max(o, c)) * scaleY;
      final bottom = (maxHigh - math.min(o, c)) * scaleY;

      // Body
      canvas.drawRect(
          Rect.fromLTRB(x, top, x + (candleWidth * 0.6), bottom), paint);

      // Wick
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.0;
      canvas.drawLine(
        Offset(x + (candleWidth * 0.3), (maxHigh - h) * scaleY),
        Offset(x + (candleWidth * 0.3), (maxHigh - l) * scaleY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Sparkline Painter ─────────────────────────────────────────────────────────
class SparklinePainter extends CustomPainter {
  final List<dynamic> data;
  SparklinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Use (as num).toDouble() to safely handle int/double from JSON
    final prices = data.map((e) => (e['c'] as num).toDouble()).toList();
    final maxP = prices.reduce(math.max);
    final minP = prices.reduce(math.min);
    final range = maxP - minP;
    final scaleY = size.height / (range == 0 ? 1 : range);
    final stepX = size.width / (prices.length - 1);

    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final y = size.height - (prices[i] - minP) * scaleY;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
