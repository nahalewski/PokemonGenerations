import 'package:flutter/material.dart';

class ScanlineOverlay extends StatelessWidget {
  const ScanlineOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.5),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            backgroundBlendMode: BlendMode.overlay,
          ),
          child: CustomPaint(
            painter: _ScanlinePainter(),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1.0;

    for (var i = 0.0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    var rPaint = Paint()
      ..color = Colors.red.withOpacity(0.06)
      ..strokeWidth = 3.0;
    for (var i = 0.0; i < size.width; i += 12) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), rPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
