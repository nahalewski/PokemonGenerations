import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';

class HybridSplashScreen extends StatefulWidget {
  const HybridSplashScreen({super.key});

  @override
  State<HybridSplashScreen> createState() => _HybridSplashScreenState();
}

class _HybridSplashScreenState extends State<HybridSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate initial asset loading/initialization
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/splash.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Subtle Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          // Loading Section (Wrapped in a translucent bar for readability)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: ClipRRect(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'INITIALIZING GENERATIONS ENGINE...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
