import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/assets/dynamic_resource_service.dart';
import '../../../core/theme/app_colors.dart';

class DynamicDownloaderScreen extends StatefulWidget {
  final Map<String, dynamic> manifest;
  final VoidCallback onComplete;

  const DynamicDownloaderScreen({
    super.key,
    required this.manifest,
    required this.onComplete,
  });

  @override
  State<DynamicDownloaderScreen> createState() => _DynamicDownloaderScreenState();
}

class _DynamicDownloaderScreenState extends State<DynamicDownloaderScreen> {
  final DynamicResourceService _service = DynamicResourceService();
  double _progress = 0.0;
  String _status = 'INITIALISING QUANTUM SYNC...';

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _startDownload() {
    _service.downloadPatches(widget.manifest).listen(
      (p) {
        setState(() {
          _progress = p;
          _status = 'SYNCHRONISING ASSETS: ${(_progress * 100).toInt()}%';
        });
      },
      onDone: () {
        setState(() {
          _status = 'SYCHRONISATION COMPLETE';
          _progress = 1.0;
        });
        Future.delayed(const Duration(seconds: 1), widget.onComplete);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Elements
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset('assets/images/home_bg.png', fit: BoxFit.cover),
            ),
          ),
          
          // Energy Nexus Animation
          Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildPulseRing(2.0, AppColors.primary.withOpacity(0.1)),
                  _buildPulseRing(1.5, AppColors.primary.withOpacity(0.2)),
                  _buildRotatingNexus(),
                  _buildInnerHologram(),
                ],
              ),
            ),
          ),

          // Progress Overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _status,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProgressBar(),
                  const SizedBox(height: 12),
                  const Text(
                    'POKEMON GENERATIONS DATA LAKE V2.4',
                    style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseRing(double scale, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    ).animate(onPlay: (c) => c.repeat()).scale(
      begin: const Offset(1, 1),
      end: Offset(scale, scale),
      duration: 3.seconds,
      curve: Curves.easeOut,
    ).fadeOut();
  }

  Widget _buildRotatingNexus() {
    return CustomPaint(
      size: const Size(200, 200),
      painter: NexusPainter(progress: _progress),
    ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds);
  }

  Widget _buildInnerHologram() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3 * _progress),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.catching_pokemon,
        size: 50,
        color: Colors.white.withOpacity(0.8),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }

  Widget _buildProgressBar() {
    return Container(
      width: 250,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 250 * _progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.5), AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NexusPainter extends CustomPainter {
  final double progress;
  NexusPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(x, y), paint);
      canvas.drawCircle(Offset(x, y), 3, paint..style = PaintingStyle.fill);
    }

    canvas.drawCircle(center, radius * progress, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
