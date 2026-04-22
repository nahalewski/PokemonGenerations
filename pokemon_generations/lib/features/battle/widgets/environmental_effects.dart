import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/weather_service.dart';

class BattleEnvironmentOverlay extends StatelessWidget {
  final WeatherData? weather;
  
  const BattleEnvironmentOverlay({super.key, this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather == null) return const SizedBox.shrink();

    return Stack(
      children: [
        // 1. Time of Day Lighting Filter
        _buildLightingFilter(weather!.isDay),
        
        // 2. Weather Specific Overlays
        if (weather!.condition == WeatherCondition.rain)
          _buildRainOverlay(),
        if (weather!.condition == WeatherCondition.snow)
          _buildSnowOverlay(),
        if (weather!.condition == WeatherCondition.sandstorm)
          _buildSandstormOverlay(),
        if (weather!.condition == WeatherCondition.storm)
          ...[_buildRainOverlay(isStorm: true), _buildLightningFlash()],
      ],
    );
  }

  Widget _buildLightingFilter(bool isDay) {
    if (isDay) return const SizedBox.shrink();
    
    // Night filter: Deep blue/purple tint with slight darkening
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF191970).withOpacity(0.35),
      ),
    );
  }

  Widget _buildRainOverlay({bool isStorm = false}) {
    return Positioned.fill(
      child: CustomPaint(
        painter: RainPainter(intensity: isStorm ? 1.0 : 0.6),
      ).animate(onPlay: (controller) => controller.repeat())
       .shimmer(duration: 2.seconds, color: Colors.blue.withOpacity(0.1)),
    );
  }

  Widget _buildSnowOverlay() {
    return Positioned.fill(
      child: Center(
        child: const Icon(Icons.ac_unit, color: Colors.white24, size: 24)
          .animate(onPlay: (controller) => controller.repeat())
          .move(begin: const Offset(0, -500), end: const Offset(50, 500), duration: 5.seconds)
          .fade(begin: 0, end: 0.3),
      ),
    );
  }

  Widget _buildSandstormOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.orange.withOpacity(0.1),
      ).animate(onPlay: (controller) => controller.repeat())
       .move(begin: const Offset(-50, 0), end: const Offset(50, 0), duration: 2.seconds)
       .shimmer(color: Colors.brown.withOpacity(0.2)),
    );
  }

  Widget _buildLightningFlash() {
    return Positioned.fill(
      child: Container(color: Colors.white)
        .animate(onPlay: (controller) => controller.repeat())
        .visibility(maintain: true, duration: 100.ms)
        .then()
        .visibility(maintain: true, duration: 200.ms)
        .then(delay: 4.seconds),
    );
  }
}

class RainPainter extends CustomPainter {
  final double intensity;
  RainPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 1.0;
    
    final count = (200 * intensity).toInt();
    for (int i = 0; i < count; i++) {
       // Random rain streaks logic
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

