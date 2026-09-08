import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThoughtBubbleDotsAlignment { left, right, center }

class ThoughtBubble extends StatelessWidget {
  final String text;
  final double maxWidth;
  final double? minHeight;
  final ThoughtBubbleDotsAlignment dotsAlignment;

  const ThoughtBubble({
    super.key,
    required this.text,
    this.maxWidth = 200,
    this.minHeight,
    this.dotsAlignment = ThoughtBubbleDotsAlignment.right,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _ThoughtBubblePainter(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: minHeight ?? 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        // Trailing dots pointing down
        if (dotsAlignment == ThoughtBubbleDotsAlignment.right) ...[
          Positioned(
            right: 52,
            bottom: -30,
            child: _dot(12),
          ),
          Positioned(
            right: 48,
            bottom: -42,
            child: _dot(8),
          ),
        ] else if (dotsAlignment == ThoughtBubbleDotsAlignment.left) ...[
          Positioned(
            left: 32,
            bottom: -35,
            child: _dot(12),
          ),
          Positioned(
            left: 18,
            bottom: -52,
            child: _dot(8),
          ),
        ] else ...[
          // Center - adjusted for larger cloud humps
          Positioned(
            left: 0,
            right: 0,
            bottom: -64,
            child: Center(child: _dot(12)),
          ),
          Positioned(
            left: -3,
            right: 0,
            bottom: -84, // Reduced gap from -142
            child: Center(child: _dot(8)),
          ),
        ],
      ],
    );
  }

  Widget _dot(double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DotPainter(),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.25);

    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width / 2, fill);
    canvas.drawCircle(c, size.width / 2, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ThoughtBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.25);

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Smaller humps for a more compact bubble
    final humps = [
      Offset(cx - 30, cy - 35),
      Offset(cx, cy - 40),
      Offset(cx + 30, cy - 35),
      Offset(cx + 55, cy - 15),
      Offset(cx + 60, cy + 10),
      Offset(cx + 40, cy + 35),
      Offset(cx, cy + 40),
      Offset(cx - 40, cy + 35),
      Offset(cx - 60, cy + 10),
      Offset(cx - 55, cy - 15),
    ];

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: size.width - 50,
          height: size.height - 50,
        ),
        const Radius.circular(20),
      ));

    for (final h in humps) {
      path = Path.combine(
        PathOperation.union,
        path,
        Path()..addOval(Rect.fromCircle(center: h, radius: 28)),
      );
    }

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
