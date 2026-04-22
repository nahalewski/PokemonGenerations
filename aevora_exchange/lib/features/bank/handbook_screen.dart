import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'dart:math' as math;

class HandbookScreen extends StatefulWidget {
  const HandbookScreen({super.key});

  @override
  State<HandbookScreen> createState() => _HandbookScreenState();
}

class _HandbookScreenState extends State<HandbookScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<HandbookCard> _cards = [
    HandbookCard(
      title: 'ATM & WALLET 101',
      description: 'The "Wallet" in your terminal represents liquid cash (PokeDollars). Moving funds to the "Checking" account secures your assets for inter-dimensional trade execution.',
      icon: Icons.account_balance,
      color: AppColors.primary,
      tip: 'Wallet balance is used for local market purchases.',
    ),
    HandbookCard(
      title: 'SAVINGS & GROWTH',
      description: 'The Vault offers a standard 4.5% APY, calculated and applied every 30 days. Keeping credits in the Vault protects them from dimensional inflation.',
      icon: Icons.trending_up,
      color: AppColors.secondary,
      tip: 'Interest is applied automatically upon vault access.',
    ),
    HandbookCard(
      title: 'RETIREMENT: 401(k)',
      description: 'Employer-sponsored retirement plan. Contributions from your salary are partially matched by Silph Co. (up to 6% for CEOs).',
      icon: Icons.shield,
      color: Colors.orangeAccent,
      tip: 'Matched funds are locked until the next dimensional cycle.',
    ),
    HandbookCard(
      title: 'RETIREMENT: ROTH IRA',
      description: 'Individual retirement account for post-tax credits. While not matched, Roth IRA gains are tax-exempt during withdrawal.',
      icon: Icons.security,
      color: Colors.blueAccent,
      tip: 'Best for long-term wealth stabilization.',
    ),
    HandbookCard(
      title: 'DIMENSIONAL LINK TAX',
      description: 'Inter-region trades (e.g., Kanto assets traded from Johto) incur a 5% Dimensional Link Tax to maintain local economies.',
      icon: Icons.sync,
      color: AppColors.error,
      tip: 'Local assets (Aevora region) remain tax-free.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AEVORA_FINANCIAL_HANDBOOK', style: AppTypography.textTheme.labelLarge),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: _HandbookCardWidget(card: _cards[index]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_cards.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    width: _currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? AppColors.primary : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Text(
                'SWIPE TO ROTATE HANDBOOK',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HandbookCard {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String tip;

  HandbookCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tip,
  });
}

class _HandbookCardWidget extends StatelessWidget {
  final HandbookCard card;
  const _HandbookCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: card.color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: card.color.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(card.icon, color: card.color, size: 48),
          const SizedBox(height: 32),
          Text(
            card.title,
            style: TextStyle(
              color: card.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            card.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    card.tip,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
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
}
