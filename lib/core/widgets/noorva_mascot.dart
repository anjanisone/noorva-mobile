import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

export 'package:rive/rive.dart' show Fit;

/// Moods of the Noorva old-man mascot.
///
/// Most moods are driven by the `Number 1` input of `State Machine 1` in
/// `old_men_v9.riv`. [sad] has no state in the state machine, so it plays the
/// `sad loop` timeline directly.
enum MascotMood {
  idle(0),
  listening(1),
  thinking(2),
  explaining(3),
  failed(4),
  success(5),
  hello(6),
  walk(7),
  sad(null);

  const MascotMood(this.stateValue);

  /// Value for the `Number 1` input, or null when played as a single animation.
  final int? stateValue;
}

/// Animated Noorva mascot backed by the shared Rive file.
///
/// Change [mood] (e.g. from a BLoC state) and the state machine transitions
/// to the matching animation. Falls back to [fallbackAsset] if Rive fails.
class NoorvaMascot extends StatefulWidget {
  const NoorvaMascot({
    super.key,
    this.mood = MascotMood.idle,
    this.width,
    this.height,
    this.fit = Fit.contain,
    this.alignment = Alignment.center,
    this.fallbackAsset = 'assets/images/noorva_home.png',
  });

  final MascotMood mood;
  final double? width;
  final double? height;
  final Fit fit;
  final Alignment alignment;
  final String fallbackAsset;

  static const _asset = 'assets/rive/old_men_v9.riv';
  static const _artboard = 'Old men';
  static const _stateMachine = 'State Machine 1';
  static const _input = 'Number 1';
  static const _sadAnimation = 'sad loop';

  static final FileLoader _loader =
      FileLoader.fromAsset(_asset, riveFactory: Factory.flutter);

  /// Loads the Rive file ahead of time so mascots render on their first frame.
  static Future<void> preload() async {
    try {
      final file = await _loader.file();
      if (kDebugMode) _debugDump(file);
    } catch (e) {
      debugPrint('NoorvaMascot preload failed: $e');
    }
  }

  /// Prints everything the .riv exposes plus the mood table, in one block.
  static void _debugDump(File file) {
    final out = StringBuffer('\n===== NoorvaMascot dump: $_asset =====\n');
    for (var a = 0;; a++) {
      final artboard = file.artboardAt(a);
      if (artboard == null) break;
      out.writeln('Artboard[$a]: ${artboard.name} '
          '(${artboard.width} x ${artboard.height})');
      for (var i = 0; i < artboard.animationCount(); i++) {
        final animation = artboard.animationAt(i);
        out.writeln('  Animation[$i]: ${animation.name} '
            '(${animation.duration.toStringAsFixed(2)}s)');
        animation.dispose();
      }
      for (var s = 0; s < artboard.stateMachineCount(); s++) {
        final machine = artboard.stateMachineAt(s);
        if (machine == null) continue;
        out.writeln('  StateMachine[$s]: ${machine.name}');
        // ignore: deprecated_member_use
        for (final input in machine.inputs) {
          final value = input is NumberInput ? ' value=${input.value}' : '';
          out.writeln('    Input: ${input.name} '
              '(${input.runtimeType})$value');
        }
        machine.dispose();
      }
      artboard.dispose();
    }
    out.writeln('Mood table (sets "$_input" on "$_stateMachine"):');
    for (final mood in MascotMood.values) {
      out.writeln('  ${mood.name.padRight(11)} -> '
          '${mood.stateValue ?? 'plays "$_sadAnimation" directly'}');
    }
    out.write('===== end dump =====');
    debugPrint(out.toString());
  }

  @override
  State<NoorvaMascot> createState() => _NoorvaMascotState();
}

class _NoorvaMascotState extends State<NoorvaMascot> {
  RiveWidgetController? _controller;
  NumberInput? _input;
  CallbackHandler? _stateLog;
  Artboard? _sadArtboard;
  SingleAnimationPainter? _sadPainter;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final file = NoorvaMascot._loader.fileSync;
    if (file != null) {
      _setup(file);
    } else {
      NoorvaMascot._loader.file().then((file) {
        if (mounted) setState(() => _setup(file));
      }).catchError((Object e) {
        debugPrint('NoorvaMascot load failed: $e');
        if (mounted) setState(() => _failed = true);
      });
    }
  }

  void _setup(File file) {
    try {
      final value = widget.mood.stateValue;
      if (value == null) {
        _sadArtboard = file.artboard(NoorvaMascot._artboard);
        _sadPainter = SingleAnimationPainter(
          NoorvaMascot._sadAnimation,
          fit: widget.fit,
          alignment: widget.alignment,
        );
      } else {
        final controller = _controller ??= RiveWidgetController(
          file,
          artboardSelector: ArtboardSelector.byName(NoorvaMascot._artboard),
          stateMachineSelector:
              StateMachineSelector.byName(NoorvaMascot._stateMachine),
        );
        if (kDebugMode && _stateLog == null) {
          // Shows which animation state actually plays after a mood change.
          // ignore: deprecated_member_use, invalid_use_of_internal_member
          _stateLog = controller.stateMachine.onStateChanged(
              (state) => debugPrint('NoorvaMascot state: $state'));
        }
        // The .riv drives moods with a state machine input, not data binding.
        // ignore: deprecated_member_use
        _input ??= controller.stateMachine.number(NoorvaMascot._input);
        final input = _input;
        if (input == null) {
          debugPrint('NoorvaMascot: input "${NoorvaMascot._input}" not found');
          return;
        }
        input.value = value.toDouble();
        if (kDebugMode) {
          debugPrint('NoorvaMascot mood: ${widget.mood.name} -> '
              'Name: ${input.name}, Value: ${input.value}');
        }
      }
    } catch (e) {
      debugPrint('NoorvaMascot setup failed: $e');
      _failed = true;
    }
  }

  void _disposeSad() {
    _sadPainter?.dispose();
    _sadArtboard?.dispose();
    _sadPainter = null;
    _sadArtboard = null;
  }

  @override
  void didUpdateWidget(covariant NoorvaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == oldWidget.mood) return;
    final file = NoorvaMascot._loader.fileSync;
    if (file == null || _failed) return;
    if (oldWidget.mood == MascotMood.sad) _disposeSad();
    _setup(file);
  }

  @override
  void dispose() {
    _disposeSad();
    _stateLog?.dispose();
    _input?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_failed) {
      child = Image.asset(widget.fallbackAsset, fit: BoxFit.contain);
    } else if (_sadPainter != null && _sadArtboard != null) {
      child =
          RiveArtboardWidget(artboard: _sadArtboard!, painter: _sadPainter!);
    } else if (_controller != null) {
      child = RiveWidget(
        controller: _controller!,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    } else {
      child = const SizedBox.shrink();
    }

    // Like Image.asset: when only one side is given, derive the other from
    // the artboard's aspect ratio so the mascot can sit in Rows/Positioned.
    var width = widget.width;
    var height = widget.height;
    final artboard = _controller?.artboard ?? _sadArtboard;
    if (artboard != null && (width == null) != (height == null)) {
      final ratio = artboard.width / artboard.height;
      width ??= height! * ratio;
      height ??= width / ratio;
    }
    return SizedBox(width: width, height: height, child: child);
  }
}
