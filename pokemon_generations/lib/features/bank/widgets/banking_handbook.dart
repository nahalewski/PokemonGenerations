import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

class BankingHandbook extends StatefulWidget {
  const BankingHandbook({super.key});

  @override
  State<BankingHandbook> createState() => _BankingHandbookState();
}

class _BankingHandbookState extends State<BankingHandbook> {
  bool _isFlipped = false;

  void _toggleFlip() {
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _isFlipped ? 180 : 0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutBack,
        builder: (context, value, child) {
          final isBack = value >= 90;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(value * pi / 180),
            alignment: Alignment.center,
            child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildBack(),
                )
              : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: 250,
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513), // Leather brown
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(5, 5)),
        ],
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 4),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance, color: Colors.amber, size: 80),
                const SizedBox(height: 20),
                Text(
                  'BANKING\nHANDBOOK',
                  textAlign: TextAlign.center,
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.amber,
                    fontSize: 24,
                    shadows: [const Shadow(color: Colors.black, offset: Offset(2, 2))],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Icon(Icons.touch_app, color: Colors.amber.withOpacity(0.5), size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: 250,
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INVESTOR GUIDE', style: AppTypography.labelLarge.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.black26),
          _buildBullet('SALARY: 1m online = 20m work.'),
          _buildBullet('MATCH: 6% bonus 401k match.'),
          _buildBullet('INSURANCE: 50k PD protected.'),
          _buildBullet('DIMENSIONS: 5% Link Tax applies.'),
          _buildBullet('CEO: Exclusive stock options.'),
          const Spacer(),
          Center(
            child: Text(
              'TAP TO CLOSE',
              style: AppTypography.labelSmall.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: AppTypography.bodySmall.copyWith(color: Colors.black87))),
        ],
      ),
    );
  }
}
