import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/currency_indicator.dart';
import '../../../../core/widgets/nasdaq_ticker.dart';
import '../../../../core/settings/app_settings_controller.dart';
import '../../../../data/services/api_client.dart';
import '../../auth/auth_controller.dart';
import '../../../../core/widgets/pokemon_message_box.dart';
import '../../bank/widgets/fortune_500_list.dart';
import '../../bank/widgets/banking_handbook.dart';

class BankTab extends ConsumerStatefulWidget {
  const BankTab({super.key});

  @override
  ConsumerState<BankTab> createState() => _BankTabState();
}

class _BankTabState extends ConsumerState<BankTab> {
  List<dynamic> _stocks = [];
  List<dynamic> _rankings = [];
  bool _isLoading = true;
  bool _isRankingLoading = true;
  bool _showRankings = false;
  bool _showIntro = true;
  bool _isEnrolling = false;

  @override
  void initState() {
    super.initState();
    _refreshMarket();
  }

  Future<void> _refreshMarket() async {
    final baseUrl = ref.read(appSettingsProvider).resolvedBackendUrl;
    try {
      final stocks = await ref.read(apiClientProvider.notifier).fetchMarketAssets(baseUrl);
      final rankings = await ref.read(apiClientProvider.notifier).fetchFortune500(baseUrl);
      if (mounted) {
        setState(() {
          _stocks = stocks;
          _rankings = rankings;
          _isLoading = false;
          _isRankingLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _isRankingLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authControllerProvider).profile;
    if (profile == null) return const Center(child: Text('LOG IN TO ACCESS BANKING'));

    // Check Enrollment First
    if (!profile.agreedToBankTerms && !_isEnrolling) {
      return _buildEnrollmentWall();
    }

    return Stack(
      children: [
        Column(
          children: [
            const NasdaqTicker(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPortfolioHeader(profile),
                    const SizedBox(height: 32),
                    _buildViewToggle(),
                    const SizedBox(height: 16),
                    _showRankings 
                      ? _isRankingLoading ? const Center(child: CircularProgressIndicator()) : Fortune500List(rankings: _rankings)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MARKET OPPORTUNITIES', style: AppTypography.headlineSmall),
                            const SizedBox(height: 16),
                            _isLoading 
                              ? const Center(child: CircularProgressIndicator())
                              : _buildStockGrid(),
                            const SizedBox(height: 40),
                            Text('RETIREMENT & INSURANCE', style: AppTypography.headlineSmall),
                            const SizedBox(height: 16),
                            _buildRetirementPanel(),
                          ],
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_showIntro)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: PokemonMessageBox(
              message: 'WELCOME TO THE POKEMON WALL STREET TERMINAL. I CAN HELP YOU MANAGE YOUR ASSETS AND REIREMENT.',
              onComplete: () => Future.delayed(const Duration(seconds: 3), () {
                if (mounted) setState(() => _showIntro = false);
              }),
            ).animate().slideY(begin: 1, end: 0).fade(),
          ),
      ],
    ).animate().fade(duration: 400.ms);
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        _buildToggleItem('MARKET', !_showRankings, () => setState(() => _showRankings = false)),
        const SizedBox(width: 12),
        _buildToggleItem('FORTUNE 500', _showRankings, () => setState(() => _showRankings = true)),
      ],
    );
  }

  Widget _buildToggleItem(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.primary : Colors.white10),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: active ? Colors.white : AppColors.outline,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEnrollmentWall() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text('TRADING ACCOUNT REQUIRED', style: AppTypography.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'To access stock and coin trading, you must agree to the Silph Co. Terms of Service and data usage agreements.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildTCRow('FDIC Insurance covers up to PD 50,000.'),
                _buildTCRow('CEO Salary and stocks are governed by the platform admin.'),
                _buildTCRow('Market volatility may lead to asset loss.'),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _completeEnrollment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            ),
            child: const Text('AGREE & OPEN ACCOUNT'),
          ),
        ],
      ),
    ).animate().fade().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTCRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.greenAccent),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }

  Future<void> _completeEnrollment() async {
    // Implement enrollment call in next step
    setState(() => _isEnrolling = true);
  }

  void _showHandbook(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: BankingHandbook(),
      ),
    );
  }

  Widget _buildPortfolioHeader(dynamic profile) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NET WORTH', style: AppTypography.labelMedium.copyWith(color: AppColors.outline)),
                  Text(
                    'PD ${(profile.pokedollars + (profile.bank['balance'] ?? 0)).toLocaleString()}',
                    style: AppTypography.displayLarge.copyWith(fontSize: 32),
                  ),
                ],
              ),
              const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 40),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatChip('INSURED', 'PD 50,000', Colors.blueAccent),
              const SizedBox(width: 12),
              _buildStatChip('INVESTED', 'PD ${(profile.bank['balance'] ?? 0).toLocaleString()}', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStockGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _stocks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final stock = _stocks[index];
        final isUp = stock['trend'] == 'up';
        
        return GlassCard(
          onTap: () => _showTradeSheet(stock),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(stock['id'], style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                  Icon(
                    isUp ? Icons.show_chart : Icons.stacked_line_chart, 
                    color: isUp ? Colors.greenAccent : Colors.redAccent,
                    size: 16,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PD ${stock['price'].toStringAsFixed(2)}', style: AppTypography.headlineSmall.copyWith(fontSize: 18)),
                  Text(
                    '${(stock['flux'] * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isUp ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRetirementPanel() {
    return Column(
      children: [
        _buildRetirementItem(
          'PROF. OAK\'S 401K', 
          'Tax-deferred long term growth.', 
          Icons.forest, 
          Colors.greenAccent
        ),
        const SizedBox(height: 12),
        _buildRetirementItem(
          'TRAINER ROTH IRA', 
          'Post-tax retirement security.', 
          Icons.shield, 
          Colors.orangeAccent
        ),
      ],
    );
  }

  Widget _buildRetirementItem(String title, String subtitle, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
              ],
            ),
          ),
          const Icon(Icons.lock, color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  void _showTradeSheet(dynamic stock) {
    // Basic trade implementation placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trading Floor: ${stock['name']} detail view incoming...')),
    );
  }
}
