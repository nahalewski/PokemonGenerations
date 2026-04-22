import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_colors.dart';

class ImmersiveWebFrame extends StatefulWidget {
  final Widget child;

  const ImmersiveWebFrame({super.key, required this.child});

  @override
  State<ImmersiveWebFrame> createState() => _ImmersiveWebFrameState();
}

class _ImmersiveWebFrameState extends State<ImmersiveWebFrame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated themed background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => CustomPaint(
                painter: PokeLogoPainter(_controller.value),
              ),
            ),
          ),

          // Subtle vignette overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // Full-screen app content — no panel, no constraints
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class PokeLogoPainter extends CustomPainter {
  final double progress;
  PokeLogoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    
    // 1. Solid Dark Background
    canvas.drawRect(rect, Paint()..color = const Color(0xFF080808));

    // 2. Center Poké Ball Logo
    _drawPokeBall(canvas, center, size.width * 0.15);

    // 3. Circling Elemental Orbs
    final primaryElements = [
      ('Fire', AppColors.typeColors['Fire']!),
      ('Water', AppColors.typeColors['Water']!),
      ('Grass', AppColors.typeColors['Grass']!),
      ('Electric', AppColors.typeColors['Electric']!),
      ('Psychic', AppColors.typeColors['Psychic']!),
      ('Ghost', AppColors.typeColors['Ghost']!),
      ('Dragon', AppColors.typeColors['Dragon']!),
      ('Steel', AppColors.typeColors['Steel']!),
    ];

    final orbitRadius = size.width * 0.35;
    final t = progress * 2 * math.pi;

    for (int i = 0; i < primaryElements.length; i++) {
      final angle = (2 * math.pi * i / primaryElements.length) + (t * 0.15);
      final orbOffset = Offset(
        center.dx + orbitRadius * math.cos(angle),
        center.dy + orbitRadius * math.sin(angle),
      );
      
      _drawElementOrb(canvas, orbOffset, primaryElements[i].$2, size.width * 0.04);
    }
    
    // 4. Subtle Ambient Glow
    final ambientPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(center, size.width * 0.4, ambientPaint);
  }

  void _drawPokeBall(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Outer black border
    paint.color = Colors.black;
    canvas.drawCircle(center, radius, paint);

    // Top Red Half
    final redPaint = Paint()..color = AppColors.primary;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.95),
      math.pi,
      math.pi,
      true,
      redPaint,
    );

    // Bottom White Half
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.95),
      0,
      math.pi,
      true,
      whitePaint,
    );

    // Horizontal Black Belt
    final beltHeight = radius * 0.15;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: radius * 1.9, height: beltHeight),
      Paint()..color = Colors.black,
    );

    // Center Button
    canvas.drawCircle(center, radius * 0.3, Paint()..color = Colors.black);
    canvas.drawCircle(center, radius * 0.2, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius * 0.12, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawElementOrb(Canvas canvas, Offset offset, Color color, double radius) {
    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);
    canvas.drawCircle(offset, radius * 1.2, glowPaint);

    // Core Orb
    final orbPaint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));
    canvas.drawCircle(offset, radius, orbPaint);
    
    // Highlight
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(
      offset + Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.2,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(PokeLogoPainter oldDelegate) => oldDelegate.progress != progress;
}
