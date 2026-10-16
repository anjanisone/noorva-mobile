import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

export 'package:rive/rive.dart' show Fit;

/// Moods of the Noorva old-man mascot.
///
/// Most moods are driven by the `Number 1` input of `State Machine 1` in
/// `old_men_v9.riv`. [welcome] and [sad] have no state in the state machine,
/// so they play their timelines directly.
enum MascotMood {
  idle(0),
  listening(1),
  thinking(2),
  explaining(3),
  failed(4),
  success(5),
  hello(6),
  walk(7),
  welcome(null, 'Welcome'),

  /// Shown while the user types (see [NoorvaMascot.reactToTyping]).
  typing(null, 'Entry loop'),
  sad(null, 'sad loop');

  const MascotMood(this.stateValue, [this.animation]);

  /// Value for the `Number 1` input, or null when played as a single animation.
  final int? stateValue;

  /// Timeline played directly when [stateValue] is null.
  final String? animation;
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
    this.reactToTyping = false,
  });

  final MascotMood mood;

  /// Plays [MascotMood.typing] while any text field has focus, as long as
  /// [mood] is a resting one (idle, hello, explaining, welcome). Busy moods
  /// like thinking, listening, success or failed always win.
  final bool reactToTyping;
  final double? width;
  final double? height;
  final Fit fit;
  final Alignment alignment;
  final String fallbackAsset;

  static const _asset = 'assets/rive/old_men_v9.riv';
  static const _artboard = 'Old men';
  static const _stateMachine = 'State Machine 1';
  static const _input = 'Number 1';

  static final FileLoader _loader =
      FileLoader.fromAsset(_asset, riveFactory: Factory.flutter);

  /// Length of a directly played mood's timeline (e.g. [MascotMood.welcome]),
  /// or null if it isn't loaded yet or the mood uses the state machine.
  static Duration? durationOf(MascotMood mood) {
    final name = mood.animation;
    return name == null ? null : animationDuration(name);
  }

  /// Length of the timeline called [name] in the artboard, or null if it
  /// isn't loaded yet or doesn't exist.
  static Duration? animationDuration(String name) {
    final artboard = _loader.fileSync?.artboard(_artboard);
    if (artboard == null) return null;
    try {
      for (var i = 0; i < artboard.animationCount(); i++) {
        final animation = artboard.animationAt(i);
        final match = animation.name == name;
        final seconds = animation.duration;
        animation.dispose();
        if (match) {
          return Duration(milliseconds: (seconds * 1000).round());
        }
      }
      return null;
    } finally {
      artboard.dispose();
    }
  }

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
          '${mood.stateValue ?? 'plays "${mood.animation}" directly'}');
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
  // Used by moods that play a timeline directly (welcome, sad).
  Artboard? _animArtboard;
  SingleAnimationPainter? _animPainter;
  bool _failed = false;

  /// Mood currently shown, which may be [MascotMood.typing] instead of
  /// [NoorvaMascot.mood].
  MascotMood? _applied;
  bool _typing = false;

  static const _typingOverrides = {
    MascotMood.idle,
    MascotMood.hello,
    MascotMood.explaining,
    MascotMood.welcome,
  };

  MascotMood get _effectiveMood =>
      widget.reactToTyping && _typing && _typingOverrides.contains(widget.mood)
          ? MascotMood.typing
          : widget.mood;

  @override
  void initState() {
    super.initState();
    if (widget.reactToTyping) _listenToFocus();
    final file = NoorvaMascot._loader.fileSync;
    if (file != null) {
      _apply(file);
    } else {
      NoorvaMascot._loader.file().then((file) {
        if (mounted) setState(() => _apply(file));
      }).catchError((Object e) {
        debugPrint('NoorvaMascot load failed: $e');
        if (mounted) setState(() => _failed = true);
      });
    }
  }

  void _listenToFocus() {
    _typing = _textFieldFocused;
    FocusManager.instance.addListener(_onFocusChanged);
  }

  static bool get _textFieldFocused =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>() !=
      null;

  void _onFocusChanged() {
    final typing = _textFieldFocused;
    if (typing == _typing || !mounted) return;
    _typing = typing;
    final file = NoorvaMascot._loader.fileSync;
    if (file != null && !_failed) setState(() => _apply(file));
  }

  /// Switches to [_effectiveMood] if it differs from what's showing.
  void _apply(File file) {
    final mood = _effectiveMood;
    if (mood == _applied) return;
    if (_applied?.animation != null) _disposeAnimation();
    _applied = mood;
    _setup(file, mood);
  }

  void _setup(File file, MascotMood mood) {
    try {
      final value = mood.stateValue;
      if (value == null) {
        _animArtboard = file.artboard(NoorvaMascot._artboard);
        _animPainter = SingleAnimationPainter(
          mood.animation!,
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
          debugPrint('NoorvaMascot mood: ${mood.name} -> '
              'Name: ${input.name}, Value: ${input.value}');
        }
      }
    } catch (e) {
      debugPrint('NoorvaMascot setup failed: $e');
      _failed = true;
    }
  }

  void _disposeAnimation() {
    _animPainter?.dispose();
    _animArtboard?.dispose();
    _animPainter = null;
    _animArtboard = null;
  }

  @override
  void didUpdateWidget(covariant NoorvaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reactToTyping != oldWidget.reactToTyping) {
      if (widget.reactToTyping) {
        _listenToFocus();
      } else {
        FocusManager.instance.removeListener(_onFocusChanged);
      }
    }
    final file = NoorvaMascot._loader.fileSync;
    if (file == null || _failed) return;
    _apply(file);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChanged);
    _disposeAnimation();
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
    } else if (_animPainter != null && _animArtboard != null) {
      child =
          RiveArtboardWidget(artboard: _animArtboard!, painter: _animPainter!);
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
    final artboard = _controller?.artboard ?? _animArtboard;
    if (artboard != null && (width == null) != (height == null)) {
      final ratio = artboard.width / artboard.height;
      width ??= height! * ratio;
      height ??= width / ratio;
    }
    return SizedBox(width: width, height: height, child: child);
  }
}
