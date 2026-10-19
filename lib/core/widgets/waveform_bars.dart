import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Audio-waveform glyph shown at the top of Noorva's speech bubbles.
///
/// - Default: a static glyph.
/// - [animate]: the bars pulse on a loop.
/// - [levels]: live mode; one loudness value (0–1) per bar, oldest first,
///   e.g. the last moments of audio that's playing.
class WaveformBars extends StatefulWidget {
  const WaveformBars({super.key, this.animate = false, this.levels});

  final bool animate;
  final List<double>? levels;

  static const barCount = 18;
  static const _maxHeight = 22.0;
  static const _minHeight = 3.0;

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
    // Fixed height so changing bars never resize the surrounding bubble.
    return SizedBox(
      height: WaveformBars._maxHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < WaveformBars.barCount; i++)
                AnimatedContainer(
                  // Short ease so live levels glide instead of jumping.
                  duration: widget.levels != null
                      ? const Duration(milliseconds: 60)
                      : Duration.zero,
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
      ),
    );
  }

  double _barHeight(int i) {
    final levels = widget.levels;
    if (levels != null) {
      final level = i < levels.length ? levels[i].clamp(0.0, 1.0) : 0.0;
      return WaveformBars._minHeight +
          level * (WaveformBars._maxHeight - WaveformBars._minHeight);
    }
    final base = WaveformBars._heights[i];
    if (!widget.animate) return base;
    // Each bar swings between 40% and 100% of its height, phase-shifted so
    // the wave travels across the row.
    final phase = _controller.value * 2 * math.pi + i * 0.7;
    return base * (0.7 + 0.3 * math.sin(phase));
  }
}
