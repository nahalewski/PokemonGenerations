import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'glass_card.dart';

class PokemonMessageBox extends StatefulWidget {
  final String message;
  final String? spriteAsset;
  final VoidCallback? onComplete;

  const PokemonMessageBox({
    super.key,
    required this.message,
    this.spriteAsset,
    this.onComplete,
  });

  @override
  State<PokemonMessageBox> createState() => _PokemonMessageBoxState();
}

class _PokemonMessageBoxState extends State<PokemonMessageBox> {
  String _displayedText = '';
  int _charIndex = 0;
  Timer? _timer;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < widget.message.length) {
        setState(() {
          _displayedText += widget.message[_charIndex];
          _charIndex++;
        });
      } else {
        _timer?.cancel();
        setState(() => _isComplete = true);
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.spriteAsset != null) ...[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(widget.spriteAsset!),
            ).animate().slideX(begin: -0.2, end: 0).fade(),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayedText,
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'Courier', // For that retro feel
                  ),
                ),
                if (_isComplete)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                    ).animate(onPlay: (c) => c.repeat()).fadeOut().fadeIn(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
