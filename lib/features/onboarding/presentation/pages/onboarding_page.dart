import 'dart:async';
import 'dart:convert';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/noorva_mascot.dart';
import '../../../../core/widgets/waveform_bars.dart';

/// Noorva's recorded welcome.
const _welcomeAudio = 'assets/audio/noorva_welcome.mp3';

/// Loudness of [_welcomeAudio] per window (0–100), precomputed from the
/// recording so the waveform moves with the actual voice. Regenerate it
/// whenever the recording changes.
const _welcomeLevels = 'assets/audio/noorva_welcome_levels.json';

const _greeting = 'Hi, I’m Noorva—your personal companion';

/// Logo intro, then Noorva plays his recorded welcome with a live waveform.
/// "Get Started" appears as the recording nears its end.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with WidgetsBindingObserver {
  /// Space kept free at the bottom for the button (height + bottom gap).
  static const double _buttonArea = 64 + 24;
  static const _introDuration = Duration(milliseconds: 1800);

  /// Lets the mascot's hello animation start before the voice does.
  static const _voiceDelay = Duration(milliseconds: 700);

  /// "Get Started" shows this long before the recording ends (roughly the
  /// closing "Let's begin your journey…" line).
  static const _getStartedLead = Duration(seconds: 9);

  /// Noorva waves for the opening greeting, then explains.
  static const _helloDuration = Duration(seconds: 3);

  final AudioPlayer _player = AudioPlayer();
  late final Future<void> _audioLoaded = _loadAudio();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  Timer? _timer;

  List<int> _levels = const [];
  int _levelStepMs = 50;

  /// Bar heights for the bubble's waveform; updated many times a second, so
  /// only the waveform listens to it rather than rebuilding the page.
  final ValueNotifier<List<double>> _bars = ValueNotifier(
    List.filled(WaveformBars.barCount, 0),
  );

  Duration _total = Duration.zero;
  Duration _position = Duration.zero;
  bool _audioReady = false;
  bool _showIntro = true;
  bool _started = false;
  bool _finished = false;
  bool _leaving = false;

  bool get _showGetStarted {
    if (_showIntro) return false;
    // Without audio there's nothing to wait for.
    if (_finished || !_audioReady) return true;
    return _total > Duration.zero && _total - _position <= _getStartedLead;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioLoaded; // start loading during the logo intro
    _timer = Timer(_introDuration, () {
      if (!mounted) return;
      setState(() => _showIntro = false);
      _timer = Timer(_voiceDelay, _start);
    });
  }

  Future<void> _loadAudio() async {
    try {
      // Spoken-audio session: plays through the speaker and, on iOS, even
      // with the silent switch on.
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _total = await _player.setAsset(_welcomeAudio) ?? Duration.zero;
      _audioReady = true;
    } catch (e) {
      debugPrint('Onboarding audio failed to load: $e');
      return;
    }

    try {
      final json = jsonDecode(await rootBundle.loadString(_welcomeLevels));
      _levelStepMs = json['stepMs'] as int;
      _levels = (json['levels'] as List).cast<int>();
    } catch (e) {
      // Audio still plays; the waveform just stays flat.
      debugPrint('Onboarding waveform levels failed to load: $e');
    }

    _positionSub = _player
        .createPositionStream(
          minPeriod: const Duration(milliseconds: 40),
          maxPeriod: const Duration(milliseconds: 40),
        )
        .listen(_onPosition);
    _stateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) _finish();
      if (!state.playing) _flattenBars();
    });
  }

  Future<void> _start() async {
    await _audioLoaded;
    if (!mounted || _leaving) return;
    _started = true;
    if (_audioReady) {
      _player.play();
    } else {
      setState(() {}); // shows Get Started straight away
    }
  }

  void _onPosition(Duration position) {
    if (!mounted || _finished) return;
    _updateBars(position);
    // Only rebuild the page when something it shows actually changes.
    final crossedHello =
        (_position < _helloDuration) != (position < _helloDuration);
    final wasShowing = _showGetStarted;
    _position = position;
    if (crossedHello || wasShowing != _showGetStarted) setState(() {});
  }

  /// The bars show the last [WaveformBars.barCount] windows of audio up to
  /// [position], so the wave scrolls left in time with the voice.
  void _updateBars(Duration position) {
    if (_levels.isEmpty || !_player.playing) return;
    final current = position.inMilliseconds ~/ _levelStepMs;
    _bars.value = [
      for (var i = WaveformBars.barCount - 1; i >= 0; i--)
        _levelAt(current - i),
    ];
  }

  double _levelAt(int index) =>
      index < 0 || index >= _levels.length ? 0 : _levels[index] / 100;

  void _flattenBars() => _bars.value = List.filled(WaveformBars.barCount, 0);

  void _finish() {
    if (_finished || !mounted) return;
    _flattenBars();
    setState(() => _finished = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started || !_audioReady || _finished || _leaving) return;
    if (state == AppLifecycleState.paused) {
      _player.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Carry on from where it was interrupted.
      _player.play();
    }
  }

  void _leave() {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    _player.stop();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    _bars.dispose();
    super.dispose();
  }

  MascotMood get _mood {
    if (_showIntro) return MascotMood.idle;
    if (_position < _helloDuration || _showGetStarted) return MascotMood.hello;
    return MascotMood.explaining;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Speech bubble (top right) above Noorva standing on the left.
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showIntro ? 0 : 1,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 96, bottom: _buttonArea + 20),
                child: Stack(
                  children: [
                    // Single persistent mascot: only its mood changes, so the
                    // Rive animation doesn't restart. Starts just below the
                    // bubble's top so his head sits beside it, not under a gap.
                    Positioned.fill(
                      top: 72,
                      right: size.width * 0.3,
                      child: NoorvaMascot(
                        mood: _mood,
                        alignment: Alignment.bottomCenter,
                        fallbackAsset: 'assets/images/noorva_onboard.png',
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 19,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: size.width * 0.42),
                        child: _SpeechBubble(title: _greeting, bars: _bars),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Logo intro.
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showIntro ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: _buttonArea),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/splash_icon.png',
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'NOORVA',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Get Started slides in as the recording nears its end.
            Positioned(
              left: 32,
              right: 32,
              bottom: 24,
              child: IgnorePointer(
                ignoring: !_showGetStarted,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  offset: _showGetStarted ? Offset.zero : const Offset(0, 0.4),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showGetStarted ? 1 : 0,
                    child: NoorvaButton(
                      text: 'Get Started',
                      onPressed: _leave,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Noorva's speech bubble: live waveform above the greeting.
/// The squared-off bottom-left corner points towards the mascot.
class _SpeechBubble extends StatelessWidget {
  final String title;
  final ValueListenable<List<double>> bars;

  const _SpeechBubble({required this.title, required this.bars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
          bottomLeft: Radius.circular(6),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<List<double>>(
            valueListenable: bars,
            builder: (context, levels, _) => WaveformBars(levels: levels),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
