import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/noorva_mascot.dart';
import '../../../../core/widgets/waveform_bars.dart';

/// One spoken part of Noorva's welcome script, captioned in the bubble.
class _ScriptLine {
  final String title;
  final String text;

  /// What the voice says, when it should differ from the caption
  /// (e.g. "24/7" → "twenty-four seven", "&" → "and").
  final String? spoken;
  final MascotMood mood;

  const _ScriptLine({
    required this.title,
    required this.text,
    this.spoken,
    this.mood = MascotMood.explaining,
  });

  String get speech => spoken ?? '$title. $text';
}

const _script = <_ScriptLine>[
  _ScriptLine(
    title: 'Hi, I’m Noorva',
    text: 'Your personal companion.',
    spoken: 'Hi, I’m Noorva, your personal companion.',
    mood: MascotMood.hello,
  ),
  _ScriptLine(
    title: 'Your 24/7 personal assistant',
    text:
        'Think of me as your 24/7 personal assistant, here to take the stress out of your daily life and make it easy. Whether you’re organizing work, managing schedules, setting goals, or tackling daily to-dos, I’m right here by your side to keep things running smoothly.',
    spoken:
        'Think of me as your twenty-four seven personal assistant, here to take the stress out of your daily life and make it easy. Whether you’re organizing work, managing schedules, setting goals, or tackling daily to-dos, I’m right here by your side to keep things running smoothly.',
  ),
  _ScriptLine(
    title: 'Noorva Companion Beta',
    text:
        'Right now, you’re using the Noorva Companion Beta, which gives you full access to Noorva Guide version 1.',
    spoken:
        'Right now, you’re using the Noorva Companion Beta, which gives you full access to Noorva Guide version one.',
  ),
  _ScriptLine(
    title: 'Your Guide',
    text:
        'As your Guide, I act as your personal mentor, Master strategist, and Right-hand person. I don’t just help you dream big—I help you map out real plans, work through every step of the journey with you, and stick with you until you get things done.',
    spoken:
        'As your Guide, I act as your personal mentor, master strategist, and right-hand person. I don’t just help you dream big. I help you map out real plans, work through every step of the journey with you, and stick with you until you get things done.',
  ),
  _ScriptLine(
    title: 'Four simple steps',
    text:
        'Whether you’re making a big career move, building a healthy new habit, working on a personal project, or just to stick to your daily routine, I’ll help you go from where you are right now to where you want to be in four simple steps:',
    spoken:
        'Whether you’re making a big career move, building a healthy new habit, working on a personal project, or just to stick to your daily routine, I’ll help you go from where you are right now to where you want to be in four simple steps.',
  ),
  _ScriptLine(
    title: 'Goal Breakdown & Roadmapping',
    text:
        'I’ll take those big, overwhelming goals and break them down into a simple, step-by-step game plan.',
    spoken:
        'One. Goal breakdown and roadmapping. I’ll take those big, overwhelming goals and break them down into a simple, step-by-step game plan.',
  ),
  _ScriptLine(
    title: 'Daily Actionable Tasks',
    text:
        'I’ll give you clear daily actions and timely reminders so you always know what to focus on next.',
    spoken:
        'Two. Daily actionable tasks. I’ll give you clear daily actions and timely reminders so you always know what to focus on next.',
  ),
  _ScriptLine(
    title: 'Active Execution Partner',
    text:
        'Whenever you hit a wall or have a question, I’m here with quick answers, clear insights, and solutions to keep you moving.',
    spoken:
        'Three. Active execution partner. Whenever you hit a wall or have a question, I’m here with quick answers, clear insights, and solutions to keep you moving.',
  ),
  _ScriptLine(
    title: 'Active Mentorship',
    text:
        'I’ll keep you on track, celebrate your progress, and adjust your plan whenever life changes speed on you.',
    spoken:
        'Four. Active mentorship. I’ll keep you on track, celebrate your progress, and adjust your plan whenever life changes speed on you.',
  ),
  _ScriptLine(
    title: 'Let’s begin',
    text:
        'Let’s begin your journey with me and discover how I’ll be there to support you every step of the way as your personal companion.',
    spoken:
        'Let’s begin your journey with me and discover how I’ll be there to support you every step of the way as your personal companion.',
    mood: MascotMood.hello,
  ),
];

/// Logo intro, then Noorva walks the user through the welcome script in voice
/// with live captions. "Get Started" appears once the final line begins.
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

  final FlutterTts _tts = FlutterTts();
  Timer? _timer;

  bool _showIntro = true;
  int _line = 0;
  bool _speaking = false;
  bool _finished = false;
  bool _leaving = false;

  bool get _showGetStarted => !_showIntro && (_line >= _script.length - 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initTts();
    _timer = Timer(_introDuration, () {
      if (!mounted) return;
      setState(() => _showIntro = false);
      _timer = Timer(_voiceDelay, _speakCurrent);
    });
  }

  Future<void> _initTts() async {
    _tts.setCompletionHandler(_onLineDone);
    _tts.setErrorHandler((message) {
      debugPrint('Onboarding TTS error: $message');
      _fallBackToTimer();
    });
    try {
      await _tts.awaitSpeakCompletion(false);
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(
          defaultTargetPlatform == TargetPlatform.iOS ? 0.5 : 0.48);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Play through the speaker even when the silent switch is on.
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
        );
      }
    } catch (e) {
      debugPrint('Onboarding TTS setup failed: $e');
    }
  }

  Future<void> _speakCurrent() async {
    if (!mounted || _leaving || _finished) return;
    _timer?.cancel();
    setState(() => _speaking = true);
    var started = false;
    try {
      started = (await _tts.speak(_script[_line].speech)) == 1;
    } catch (e) {
      debugPrint('Onboarding TTS speak failed: $e');
    }
    if (!started) _fallBackToTimer();
  }

  /// No usable voice engine: keep the captions moving at reading pace.
  void _fallBackToTimer() {
    if (!mounted || _leaving || _finished) return;
    _timer?.cancel();
    final words = _script[_line].text.split(RegExp(r'\s+')).length;
    _timer = Timer(Duration(milliseconds: 1200 + words * 380), _onLineDone);
  }

  void _onLineDone() {
    if (!mounted || _leaving || _finished) return;
    _timer?.cancel();
    if (_line < _script.length - 1) {
      setState(() => _line++);
      // A short breath between lines.
      _timer = Timer(const Duration(milliseconds: 350), _speakCurrent);
    } else {
      setState(() {
        _speaking = false;
        _finished = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      _tts.stop();
      if (mounted) setState(() => _speaking = false);
    } else if (state == AppLifecycleState.resumed &&
        !_showIntro &&
        !_finished &&
        !_leaving) {
      // Replay the line that was interrupted.
      _speakCurrent();
    }
  }

  void _leave() {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    _tts.stop();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  MascotMood get _mood {
    if (_showIntro) return MascotMood.idle;
    if (_finished) return MascotMood.hello;
    return _script[_line].mood;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final line = _script[_line];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Speech bubble (top right) above Noorva standing on the left.
            // A long bubble pushes him down rather than covering his head.
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showIntro ? 0 : 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: _buttonArea + 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: size.width * 0.64),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topRight,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              layoutBuilder: (current, previous) => Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ...previous,
                                  if (current != null) current,
                                ],
                              ),
                              child: _showIntro
                                  ? const SizedBox.shrink()
                                  : _SpeechBubble(
                                      key: ValueKey(_line),
                                      title: line.title,
                                      description: line.text,
                                      speaking: _speaking && !_finished,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Single persistent mascot: only its mood changes, so the
                    // Rive animation doesn't restart on every line.
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: size.width * 0.3),
                        child: NoorvaMascot(
                          mood: _mood,
                          alignment: Alignment.bottomCenter,
                          fallbackAsset: 'assets/images/noorva_onboard.png',
                        ),
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

            // Skip, for anyone who has heard it before.
            if (!_showIntro && !_showGetStarted)
              Positioned(
                top: 4,
                right: 8,
                child: TextButton(
                  onPressed: _leave,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

            // Get Started slides in as the final line begins.
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

/// Noorva's speech bubble: waveform, bold title and optional description.
/// The squared-off bottom-left corner points towards the mascot.
class _SpeechBubble extends StatelessWidget {
  final String title;
  final String description;
  final bool speaking;

  const _SpeechBubble({
    super.key,
    required this.title,
    required this.description,
    this.speaking = false,
  });

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
          WaveformBars(animate: speaking),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
