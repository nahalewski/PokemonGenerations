import 'dart:math';
import 'package:flutter/material.dart';

enum PokeballTheme {
  poke,
  great,
  ultra,
  master,
}

class PokeballSynthwaveVisualizer extends StatefulWidget {
  final double amplitude;
  final double rotation;
  final PokeballTheme theme;

  const PokeballSynthwaveVisualizer({
    super.key,
    required this.amplitude,
    required this.rotation,
    required this.theme,
  });

  @override
  State<PokeballSynthwaveVisualizer> createState() => _PokeballSynthwaveVisualizerState();
}

class _PokeballSynthwaveVisualizerState extends State<PokeballSynthwaveVisualizer> {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: widget.rotation * 2 * pi,
      child: CustomPaint(
        size: const Size(260, 260),
        painter: _PokeballPainter(
          amplitude: widget.amplitude,
          theme: widget.theme,
        ),
      ),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  final double amplitude;
  final PokeballTheme theme;

  _PokeballPainter({required this.amplitude, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Define colors based on theme
    Color topColor;
    Color bottomColor = Colors.white;
    Color accentColor;

    switch (theme) {
      case PokeballTheme.poke:
        topColor = Colors.red.shade700;
        accentColor = Colors.redAccent;
        break;
      case PokeballTheme.great:
        topColor = Colors.blue.shade700;
        accentColor = Colors.redAccent; // Great ball has red strips
        break;
      case PokeballTheme.ultra:
        topColor = Colors.grey.shade900;
        accentColor = Colors.yellow.shade700; // Ultra ball has yellow strips
        break;
      case PokeballTheme.master:
        topColor = Colors.purple.shade700;
        accentColor = Colors.pinkAccent; // Master ball has pink circles
        break;
    }

    // 1. Draw Background Glow
    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.05 + (amplitude * 0.15))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center, radius + 20, glowPaint);

    // 2. Draw Top Half with Gradient
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, topColor.withOpacity(0.8)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      true,
      topPaint,
    );

    // 3. Draw Bottom Half
    final bottomPaint = Paint()..color = bottomColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      pi,
      true,
      bottomPaint,
    );

    // 4. Draw Theme Accents (Strips/Circles) with Glow
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    
    final accentGlow = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    if (theme == PokeballTheme.great) {
      // Great ball red strips
      final r1 = Rect.fromLTWH(center.dx - radius * 0.7, center.dy - radius * 0.85, radius * 0.25, radius * 0.6);
      final r2 = Rect.fromLTWH(center.dx + radius * 0.45, center.dy - radius * 0.85, radius * 0.25, radius * 0.6);
      canvas.drawRect(r1, accentGlow);
      canvas.drawRect(r2, accentGlow);
      canvas.drawRect(r1, accentPaint);
      canvas.drawRect(r2, accentPaint);
    } else if (theme == PokeballTheme.ultra) {
      // Ultra ball yellow strips
      final r1 = Rect.fromLTWH(center.dx - radius * 0.15, center.dy - radius * 1.0, radius * 0.3, radius * 0.7);
      final r2 = Rect.fromLTWH(center.dx - radius * 0.6, center.dy - radius * 0.8, radius * 0.2, radius * 0.4);
      final r3 = Rect.fromLTWH(center.dx + radius * 0.4, center.dy - radius * 0.8, radius * 0.2, radius * 0.4);
      canvas.drawRect(r1, accentPaint);
      canvas.drawRect(r2, accentPaint);
      canvas.drawRect(r3, accentPaint);
    } else if (theme == PokeballTheme.master) {
      // Master ball purple/pink circles
      final c1 = Offset(center.dx - radius * 0.5, center.dy - radius * 0.5);
      final c2 = Offset(center.dx + radius * 0.5, center.dy - radius * 0.5);
      canvas.drawCircle(c1, radius * 0.25, accentGlow);
      canvas.drawCircle(c2, radius * 0.25, accentGlow);
      canvas.drawCircle(c1, radius * 0.22, accentPaint);
      canvas.drawCircle(c2, radius * 0.22, accentPaint);
      
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.65), radius * 0.08, whitePaint);
    }

    // 5. Draw Black Middle Band
    final bandPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), bandPaint);

    // 6. Draw Center Button
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius * 0.22, shadowPaint);

    final outerRing = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(center, radius * 0.2, outerRing);
    
    final innerRing = Paint()
      ..color = Colors.white
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.grey.shade300],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.12));
    canvas.drawCircle(center, radius * 0.12, innerRing);

    // 7. Draw Synthwave Waves (Electric Rings)
    for (int i = 1; i <= 4; i++) {
       final waveRadius = (radius * 0.22) + (i * 45 * amplitude);
       if (waveRadius < radius * 1.5) {
         final wavePaint = Paint()
           ..color = accentColor.withValues(alpha: (1.0 - (waveRadius / (radius * 1.5))).clamp(0.0, 0.4))
           ..style = PaintingStyle.stroke
           ..strokeWidth = 3 - (i * 0.5);
         canvas.drawCircle(center, waveRadius, wavePaint);
       }
    }
    
    // 8. Outer Rim/Neon Edge
    final rimPaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, rimPaint);

    final neonRim = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, radius + 2, neonRim);
  }

  @override
  bool shouldRepaint(covariant _PokeballPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude || oldDelegate.theme != theme;
  }
}
