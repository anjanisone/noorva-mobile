import 'package:flutter/material.dart';

import 'noorva_mascot.dart';

/// Noorva standing on the left end of a chat's input bar.
///
/// Place it in a [Stack] over the chat list whose bottom edge sits
/// [gapToBar] above the input bar. He stays put while the chat scrolls.
///
/// Give the chat list [height] of extra bottom padding so the latest message
/// can always be scrolled clear of him.
class PerchedMascot extends StatelessWidget {
  const PerchedMascot({
    super.key,
    this.gapToBar = 0,
    this.left = 24,
    this.mood = MascotMood.chatting,
  });

  /// Height of the perched mascot.
  static const double height = 110;

  /// Distance from the bottom of the chat area down to the input bar's top.
  final double gapToBar;
  final double left;

  /// Animation he plays while perched.
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      bottom: -gapToBar,
      height: height,
      child: IgnorePointer(
        child: NoorvaMascot(
          mood: mood,
          height: height,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
