import 'package:flutter/material.dart';

import 'noorva_mascot.dart';

/// Noorva standing on top of a chat's input bar.
///
/// Place it in a [Stack] over the chat list whose bottom edge sits
/// [gapToBar] above the input bar. He rises out of the bar as the user
/// scrolls up through older messages and sinks back behind it at the latest
/// one, tracking the scroll position of [controller] directly.
///
/// Give the chat list [height] of extra bottom padding so the latest message
/// can always be scrolled clear of him.
class PerchedMascot extends StatefulWidget {
  const PerchedMascot({
    super.key,
    required this.controller,
    this.gapToBar = 0,
    this.right = 32,
    this.mood = MascotMood.idle,
  });

  /// Height of the perched mascot.
  static const double height = 110;

  /// Scroll distance from the latest message over which he fully appears.
  static const double scrollRange = 140;

  final ScrollController controller;

  /// Distance from the bottom of the chat area down to the input bar's top.
  final double gapToBar;
  final double right;

  /// Animation he plays while perched.
  final MascotMood mood;

  @override
  State<PerchedMascot> createState() => _PerchedMascotState();
}

class _PerchedMascotState extends State<PerchedMascot> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant PerchedMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final controller = widget.controller;
    if (!controller.hasClients) return;
    final position = controller.position;
    final fromBottom = position.maxScrollExtent - position.pixels;
    final progress = (fromBottom / PerchedMascot.scrollRange).clamp(0.0, 1.0);
    if (progress != _progress) setState(() => _progress = progress);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: widget.right,
      bottom: -widget.gapToBar,
      height: PerchedMascot.height,
      child: IgnorePointer(
        child: ClipRect(
          child: Transform.translate(
            offset: Offset(0, (1 - _progress) * PerchedMascot.height),
            child: Opacity(
              opacity: _progress,
              child: NoorvaMascot(
                mood: widget.mood,
                height: PerchedMascot.height,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
