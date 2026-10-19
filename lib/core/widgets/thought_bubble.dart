import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThoughtBubbleDotsAlignment { left, right, center }

class ThoughtBubble extends StatelessWidget {
  final String text;
  final double maxWidth;
  final double? minHeight;
  final ThoughtBubbleDotsAlignment dotsAlignment;

  /// Smaller text, padding and cloud for tight layouts.
  final bool compact;

  const ThoughtBubble({
    super.key,
    required this.text,
    this.maxWidth = 200,
    this.minHeight,
    this.dotsAlignment = ThoughtBubbleDotsAlignment.right,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _ThoughtBubblePainter(compact: compact),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: minHeight ?? 0,
            ),
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: compact ? 10 : 12,
                  height: compact ? 1 : 1.2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        // Trailing dots pointing down
        if (dotsAlignment == ThoughtBubbleDotsAlignment.right) ...[
          Positioned(
            right: compact ? 44 : 52,
            bottom: compact ? -22 : -30,
            child: _dot(compact ? 10 : 12),
          ),
          Positioned(
            right: compact ? 40 : 48,
            bottom: compact ? -32 : -42,
            child: _dot(compact ? 6 : 8),
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
  _ThoughtBubblePainter({this.compact = false});

  final bool compact;

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

    // Hump offsets are tuned for a ~200x110 bubble; compact bubbles scale
    // them down so the cloud doesn't spill far past the text box.
    final sx = compact ? (size.width / 200).clamp(0.6, 1.0) : 1.0;
    final sy = compact ? (size.height / 110).clamp(0.6, 1.0) : 1.0;
    final radius = 28 * (sx < sy ? sx : sy);

    // Smaller humps for a more compact bubble
    final humps = [
      Offset(cx - 30 * sx, cy - 35 * sy),
      Offset(cx, cy - 40 * sy),
      Offset(cx + 30 * sx, cy - 35 * sy),
      Offset(cx + 55 * sx, cy - 15 * sy),
      Offset(cx + 60 * sx, cy + 10 * sy),
      Offset(cx + 40 * sx, cy + 35 * sy),
      Offset(cx, cy + 40 * sy),
      Offset(cx - 40 * sx, cy + 35 * sy),
      Offset(cx - 60 * sx, cy + 10 * sy),
      Offset(cx - 55 * sx, cy - 15 * sy),
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
        Path()..addOval(Rect.fromCircle(center: h, radius: radius)),
      );
    }

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _ThoughtBubblePainter oldDelegate) =>
      oldDelegate.compact != compact;
}
