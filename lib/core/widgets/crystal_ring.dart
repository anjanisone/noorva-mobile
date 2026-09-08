import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrystalRing extends StatelessWidget {
  final double size;
  final double opacity;

  const CrystalRing({
    super.key,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002) // Perspective
          ..rotateX(0.4) // Tilt back
          ..rotateY(0.3) // Tilt right
          ..rotateZ(-120 * math.pi / 360), // 70-degree rotation
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow/Shadow
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8 * opacity),
                    blurRadius: size * 0.4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Blurred Glass Effect11
            ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12 * opacity),
                  ),
                ),
              ),
            ),
            // Crystal Details
            CustomPaint(
              size: Size(size, size),
              painter: CrystalPainter(opacity: opacity),
            ),
          ],
        ),
      ),
    );
  }
}

class CrystalPainter extends CustomPainter {
  final double opacity;

  CrystalPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.12;

    // 1. Main Ring Body with Depth and Refraction Gradient
    final bodyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.2 * opacity),
          Colors.white.withValues(alpha: 0.4 * opacity),
          const Color(0xFFE0E0FF).withValues(alpha: 0.5 * opacity),
          const Color(0xFFFFE0E0).withValues(alpha: 0.4 * opacity),
          Colors.white.withValues(alpha: 0.3 * opacity),
          Colors.white.withValues(alpha: 0.1 * opacity),
          Colors.white.withValues(alpha: 0.2 * opacity),
        ],
        stops: const [0.0, 0.2, 0.4, 0.6, 0.75, 0.9, 1.0],
        transform: const GradientRotation(-0.5),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - (strokeWidth / 2), bodyPaint);

    // 2. Beveled Edge / Rim Highlight (Outer)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 1.0 * opacity),
          Colors.white.withValues(alpha: 0.3 * opacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 0.4, rimPaint);

    // 3. Inner Rim Highlight
    final innerRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [
          Colors.white.withValues(alpha: 
            0.6 * opacity),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromCircle(
            center: center,
            radius: radius - strokeWidth));

    canvas.drawCircle(
      center, 
      radius - strokeWidth + 0.25, 
      innerRimPaint);

    // 4. Specular Glints (Small bright spots)
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 1.0 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal,
       0.5);

    // Top-left glint
    canvas.drawCircle(
      Offset(
      center.dx - radius * 0.6, 
      center.dy - radius * 0.6),
      radius * 0.08,
      glintPaint,
    );

    // Bottom-right subtle glint
    canvas.drawCircle(
      Offset(
      center.dx + radius * 0.5, 
      center.dy + radius * 0.5),
      radius * 0.05,
      glintPaint..color = Colors.white.withValues(alpha: 0.6 * opacity),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
