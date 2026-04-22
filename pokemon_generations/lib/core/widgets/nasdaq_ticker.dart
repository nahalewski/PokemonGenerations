import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../settings/app_settings_controller.dart';

class NasdaqTicker extends ConsumerStatefulWidget {
  const NasdaqTicker({super.key});

  @override
  ConsumerState<NasdaqTicker> createState() => _NasdaqTickerState();
}

class _NasdaqTickerState extends ConsumerState<NasdaqTicker> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  List<dynamic> _marketData = [];
  Timer? _dataTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
      _fetchMarketData();
    });
    
    // Refresh market data every 30 seconds
    _dataTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchMarketData());
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 1,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  Future<void> _fetchMarketData() async {
    final baseUrl = ref.read(appSettingsProvider).resolvedBackendUrl;
    try {
      final markets = await ref.read(apiClientProvider.notifier).fetchMarketAssets(baseUrl);
      if (mounted) {
        setState(() => _marketData = markets);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer?.cancel();
    _dataTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_marketData.isEmpty) return const SizedBox(height: 32);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = _marketData[index % _marketData.length];
          final isUp = item['flux'] >= 0;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  '${item['id']}',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(item['price'] as double).toStringAsFixed(2)}',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: isUp ? Colors.greenAccent : Colors.redAccent,
                  size: 16,
                ),
                Text(
                  '${(item['flux'] * 100).toStringAsFixed(1)}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: isUp ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
