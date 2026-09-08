import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrystalBorderPainter extends CustomPainter {
  final double borderRadius;
  final double strokeWidth;

  CrystalBorderPainter({
    this.borderRadius = 40.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 173.83 degrees converted to radians for LinearGradient
    // CSS degrees to Flutter: (angle - 90) * pi / 180
    const angle = 173.83;
    final radians = (angle - 90) * (math.pi / 180);

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      transform: GradientRotation(radians),
      colors: [
        Colors.white.withValues(alpha: 0.6),
        Colors.white.withValues(alpha: 0.6),
        Colors.white.withValues(alpha: 0.15),
        Colors.white.withValues(alpha: 0.6),
      ],
      stops: const [0.0482, 0.3808, 0.5668, 0.951],
    ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
