import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Pokémon stat order clockwise from top
const _kStatOrder  = ['hp', 'atk', 'def', 'spa', 'spd', 'spe'];
const _kStatLabels = ['HP', 'ATK', 'DEF', 'SPA', 'SPD', 'SPE'];

// Classic Pokémon stat colours (matches in-game / Bulbapedia palette)
const _kStatColors = [
  Color(0xFFFF5959), // HP  — red
  Color(0xFFF5AC78), // ATK — orange
  Color(0xFFDAC447), // DEF — yellow
  Color(0xFF9DB7F5), // SPA — blue
  Color(0xFF72C493), // SPD — green
  Color(0xFFFA92B2), // SPE — pink
];

class StatRadarChart extends StatefulWidget {
  final Map<String, int> stats;
  final int maxValue;
  final double size;
  final Color? fillColor;   // null = use per-stat gradient blend
  final bool showLabels;

  const StatRadarChart({
    super.key,
    required this.stats,
    this.maxValue = 255,
    this.size = 200,
    this.fillColor,
    this.showLabels = true,
  });

  @override
  State<StatRadarChart> createState() => _StatRadarChartState();
}

class _StatRadarChartState extends State<StatRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(StatRadarChart old) {
    super.didUpdateWidget(old);
    if (!mapEquals(old.stats, widget.stats) ||
        old.maxValue != widget.maxValue) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RadarPainter(
            stats: widget.stats,
            maxValue: widget.maxValue,
            overrideFill: widget.fillColor,
            animT: _anim.value.clamp(0.0, 1.0),
            showLabels: widget.showLabels,
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Map<String, int> stats;
  final int maxValue;
  final Color? overrideFill;
  final double animT;
  final bool showLabels;

  const _RadarPainter({
    required this.stats,
    required this.maxValue,
    required this.overrideFill,
    required this.animT,
    required this.showLabels,
  });

  static double _axisAngle(int i) => (i * 60 - 90) * pi / 180;

  // Blend all 6 stat colours into one fill colour
  static Color get _blendedFill {
    int r = 0, g = 0, b = 0;
    for (final c in _kStatColors) {
      r += c.red; g += c.green; b += c.blue;
    }
    return Color.fromARGB(255, r ~/ 6, g ~/ 6, b ~/ 6);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final labelPad = showLabels ? 30.0 : 4.0;
    final radius = size.width / 2 - labelPad;

    _drawBackground(canvas, center, radius);
    _drawGrid(canvas, center, radius);
    _drawAxes(canvas, center, radius);
    _drawPolygon(canvas, center, radius);
    _drawVertexDots(canvas, center, radius);
    if (showLabels) _drawLabels(canvas, center, radius);
  }

  // Faint circular glow behind the chart
  void _drawBackground(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, r + 2, paint);
  }

  void _drawGrid(Canvas canvas, Offset c, double r) {
    for (int ring = 1; ring <= 5; ring++) {
      final frac = ring / 5;
      final rr = r * frac;

      // Subtle coloured glow on the outer ring
      final opacity = ring == 5 ? 0.25 : 0.10;
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring == 5 ? 1.2 : 0.8;

      final path = Path();
      for (int i = 0; i < 6; i++) {
        final a = _axisAngle(i);
        final pt = Offset(c.dx + rr * cos(a), c.dy + rr * sin(a));
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawAxes(Canvas canvas, Offset c, double r) {
    for (int i = 0; i < 6; i++) {
      final paint = Paint()
        ..color = _kStatColors[i].withOpacity(0.30)
        ..strokeWidth = 1.0;
      final a = _axisAngle(i);
      canvas.drawLine(c, Offset(c.dx + r * cos(a), c.dy + r * sin(a)), paint);
    }
  }

  void _drawPolygon(Canvas canvas, Offset c, double r) {
    final fill = overrideFill ?? _blendedFill;

    final fillPaint = Paint()
      ..color = fill.withOpacity(0.28)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = fill.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final raw = (stats[_kStatOrder[i]] ?? 0) / maxValue;
      final frac = raw.clamp(0.0, 1.0) * animT;
      final a = _axisAngle(i);
      final pt = Offset(c.dx + r * frac * cos(a), c.dy + r * frac * sin(a));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawVertexDots(Canvas canvas, Offset c, double r) {
    for (int i = 0; i < 6; i++) {
      final raw = (stats[_kStatOrder[i]] ?? 0) / maxValue;
      final frac = raw.clamp(0.0, 1.0) * animT;
      final a = _axisAngle(i);
      final pt = Offset(c.dx + r * frac * cos(a), c.dy + r * frac * sin(a));

      // Glow halo
      canvas.drawCircle(pt, 5.0, Paint()..color = _kStatColors[i].withOpacity(0.25));
      // Dot
      canvas.drawCircle(pt, 3.0, Paint()..color = _kStatColors[i]);
    }
  }

  void _drawLabels(Canvas canvas, Offset c, double r) {
    for (int i = 0; i < 6; i++) {
      final a = _axisAngle(i);
      final lr = r + 20;
      final x = c.dx + lr * cos(a);
      final y = c.dy + lr * sin(a);

      final value = stats[_kStatOrder[i]] ?? 0;
      final statColor = _kStatColors[i];

      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${_kStatLabels[i]}\n',
              style: TextStyle(
                color: statColor.withOpacity(0.85),
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                height: 1.4,
              ),
            ),
            TextSpan(
              text: '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      !mapEquals(old.stats, stats) ||
      old.animT != animT ||
      old.maxValue != maxValue ||
      old.overrideFill != overrideFill;
}
