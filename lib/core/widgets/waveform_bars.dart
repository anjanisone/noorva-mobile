import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Audio-waveform glyph shown at the top of Noorva's speech bubbles.
/// With [animate] the bars pulse, e.g. while Noorva is speaking.
class WaveformBars extends StatefulWidget {
  const WaveformBars({super.key, this.animate = false});

  final bool animate;

  static const _heights = <double>[
    4, 8, 14, 9, 18, 12, 6, 15, 20, 11, 5, 13, 17, 8, 12, 6, 10, 4, //
  ];

  @override
  State<WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<WaveformBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant WaveformBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < WaveformBars._heights.length; i++)
              Container(
                width: 2.5,
                height: _barHeight(i),
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B9BFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Each bar swings between 40% and 100% of its height, phase-shifted so
  /// the wave travels across the row.
  double _barHeight(int i) {
    final base = WaveformBars._heights[i];
    if (!widget.animate) return base;
    final phase = _controller.value * 2 * math.pi + i * 0.7;
    return base * (0.7 + 0.3 * math.sin(phase));
  }
}
