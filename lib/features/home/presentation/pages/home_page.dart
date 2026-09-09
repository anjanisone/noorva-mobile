import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final TextEditingController _inputController = TextEditingController();
  int _currentCardPage = 0;
  Timer? _timer;

  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  bool _isInputNotEmpty = false;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isChatActive = false;
  bool _isVoiceModeActive = false;
  bool _showCaptions = true;

  final List<Map<String, dynamic>> _chatMessages = [];

  final List<Map<String, dynamic>> _conversations = [
    {
      'tag': 'Toady\'s tasks',
      'title': 'The afternoon reset to overcome the fatigue',
      'subtitle': 'Scheduled for 1:30 PM',
      'welcomeMessage':
          'You have a scheduled task to reset yourself to overcome the afternoon energy drops',
      'isMissed': false,
    },
    {
      'tag': 'Toady\'s tasks',
      'title': 'Meditate for inner peace - Day 1: The Pause',
      'subtitle': 'Scheduled for 7AM Today',
      'welcomeMessage':
          'You missed the morning anchor of\nmeditating for inner peace.',
      'isMissed': true,
    },
    {
      'tag': 'Priority conversation',
      'title': 'Help me plan my weekend marathon',
      'subtitle':
          'A wise choice—preparation shapes endurance.\nLet us structure your weekend with care.',
      'welcomeMessage':
          'You need to look into your weekend marathon training plan',
      'isMissed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlider();
    _initSpeech();

    _inputController.addListener(() {
      final isNotEmpty = _inputController.text.trim().isNotEmpty;
      if (isNotEmpty != _isInputNotEmpty) {
        setState(() {
          _isInputNotEmpty = isNotEmpty;
        });
      }
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _isFocused) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      debugPrint('Speech initialization error: $e');
    }
  }

  void _startAutoSlider() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentCardPage < _conversations.length - 1) {
        _currentCardPage++;
      } else {
        _currentCardPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentCardPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            debugPrint('onStatus: $val');
            if (val == 'done' || val == 'notListening') {
              setState(() => _isListening = false);
              if (_inputController.text.isNotEmpty) {
                _handleSendMessage();
              }
            }
          },
          onError: (val) => debugPrint('onError: $val'),
        );
        if (available) {
          setState(() {
            _isListening = true;
            _lastWords = '';
          });
          _speech.listen(
            onResult: (val) {
              setState(() {
                _lastWords = val.recognizedWords;
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _inputController.text = _lastWords;
                }
              });
              if (val.finalResult && _inputController.text.isNotEmpty) {
                _handleSendMessage();
              }
            },
            listenOptions: stt.SpeechListenOptions(cancelOnError: true),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_inputController.text.isNotEmpty) {
        _handleSendMessage();
      }
    }
  }

  void _openVoiceMode() {
    setState(() {
      _isVoiceModeActive = true;
      _lastWords = '';
    });
    if (!_isListening) {
      _listen();
    }
  }

  void _closeVoiceMode() {
    setState(() {
      _isVoiceModeActive = false;
      if (_isListening) {
        _listen();
      }
    });
  }

  void _handleSendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isChatActive = true;
      _chatMessages.add({
        'isUser': true,
        'text': text,
      });

      // Mock AI response
      String mockAiResponse = 'London. A city of infinite layers and constant motion. To plan a journey on such short notice often invites unnecessary noise. Before we look at the map, let us decide on the nature of this trip. Are we traveling to execute work, or to find a season of rest?';
      
      final lowerText = text.toLowerCase();
      if (lowerText.contains('story')) {
        mockAiResponse = 'There was once a young architect who sought to build a great sanctuary in the center of a loud, endless city.\n\nEvery day the merchants in the marketplace shouted at him. \'Build faster,\' they demanded. \'Add more rooms. Do not stop until the roof touches the sky.\' Hearing the constant noise, the young architect abandoned his careful blueprint. He began laying bricks frantically in all directions, terrified that if he paused to rest, he would fall behind the others.';
      } else if (lowerText.contains('stop') || lowerText.contains('other time')) {
        mockAiResponse = 'Sure, i will be waiting...';
      }

      _chatMessages.add({
        'isUser': false,
        'text': mockAiResponse,
      });

      _lastWords = ''; // clear speech words
      _isListening = false; // ensure listening stops UI-wise
    });

    _inputController.clear();
    _focusNode.unfocus();
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: _isFocused || _isInputNotEmpty
                  ? size.height * 0.15
                  : size.height * 0.26,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isFocused || _isInputNotEmpty
                    ? size.height * 0.45
                    : size.height * 0.72,
                child: Image.asset(
                  'assets/images/noorva_home.png',
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Thought Bubbles (Hidden when focused/typing)
            if (!_isFocused && !_isInputNotEmpty)
              Positioned(
                top: size.height * 0.30,
                left: -7,
                right: -30,
                child: _buildDecorativeDots(),
              ),

            // Main Content Scrollable
            Column(
              children: [
                Expanded(
                  child: _isChatActive
                      ? _buildChatContent()
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Custom App Bar
                              _buildHomeHeader(),
                              const SizedBox(height: 20),
                              // Welcome Message (Changes style when focused)
                              Center(
                                child: CrystalCard(
                                  width: (_isFocused || _isInputNotEmpty)
                                      ? 180
                                      : 320,
                                  padding: (_isFocused || _isInputNotEmpty)
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10)
                                      : const EdgeInsets.all(24),
                                  borderRadius: (_isFocused || _isInputNotEmpty)
                                      ? 20
                                      : 32,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  borderColor: const Color(0xFF3B3B3B),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        (_isFocused || _isInputNotEmpty)
                                            ? 'How can I help?'
                                            : 'Hey ${context.watch<AuthBloc>().state.user?.name ?? 'User'}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              (_isFocused || _isInputNotEmpty)
                                                  ? 16
                                                  : 24,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (!_isFocused && !_isInputNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 500),
                                            child: Text(
                                              _conversations.isNotEmpty && _currentCardPage >= 0 && _currentCardPage < _conversations.length
                                                  ? _conversations[_currentCardPage]['welcomeMessage']!
                                                  : 'You are all caught up!',
                                              key: ValueKey(_currentCardPage),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 5),

                // Priority Card (Only visible in home state)
                if (!_isChatActive && !_isFocused && !_isInputNotEmpty)
                  Visibility(
                    visible: true,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 260,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentCardPage = index;
                              });
                            },
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                child: _buildConversationCard(
                                    _conversations[index]),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                // Bottom Input Area
                _buildInputSection(),
              ],
            ),

            // Listening Overlay
            if (_isVoiceModeActive)
              Positioned.fill(
                child: Container(
                  color: AppColors.background,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _closeVoiceMode,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showCaptions = !_showCaptions;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Icon(
                                    _showCaptions ? Icons.subtitles_outlined : Icons.subtitles_off_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Noorva Avatar
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'assets/images/noorva_home.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // Caption Box
                        if (_showCaptions)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1E),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF007AFF).withValues(alpha: 0.8), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              _isListening 
                                  ? (_lastWords.isEmpty ? 'Listening...' : _lastWords)
                                  : (_chatMessages.isNotEmpty && !_chatMessages.last['isUser'] 
                                      ? _chatMessages.last['text'] 
                                      : 'How can I help you today?'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                height: 1.4,
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Bottom Control Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Mic button
                              GestureDetector(
                                onTap: _listen,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Icon(
                                    _isListening ? Icons.mic_none : Icons.mic_off_outlined, 
                                    color: Colors.white, 
                                    size: 28
                                  ),
                                ),
                              ),
                              // Close button
                              GestureDetector(
                                onTap: _closeVoiceMode,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon,
      {bool hasBadge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          if (hasBadge)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF8A8A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(String assetPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Image.asset(assetPath,
              width: 24, height: 24, color: Colors.white),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildWelcomeCard() {
    // ignore: unused_local_variable
    final currentConversation = _conversations[_currentCardPage];
    return Center(
      child: CrystalCard(
        width: 320,
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        crossAxisAlignment: CrossAxisAlignment.center,
        borderColor: const Color(0xFF3B3B3B),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _isInputNotEmpty ? 'How can I help?' : 'Hey ${context.watch<AuthBloc>().state.user?.name ?? 'User'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!_isInputNotEmpty) ...[
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _conversations.isNotEmpty && _currentCardPage >= 0 && _currentCardPage < _conversations.length
                      ? _conversations[_currentCardPage]['welcomeMessage']!
                      : 'You are all caught up!',
                  key: ValueKey(_currentCardPage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRecalibrateBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding:
              const EdgeInsets.only(top: 12, bottom: 48, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/noorva_home.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Text(
                        'How do you plan to\nrecalibrate?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              _buildRecalibrateOption('I will step away and complete it immediately', () {
                Navigator.pop(context);
                _releaseTask();
              }),
              _buildRecalibrateOption('Move this task to the end of my day.', () {
                Navigator.pop(context);
                _showRescheduleDialog();
              }),
              _buildRecalibrateOption('Let it go. We will try again tomorrow', () {
                Navigator.pop(context);
                _releaseTask();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecalibrateOption(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _showRescheduleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reschedule Missed Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tell me the specific time, you want me to\nmove this task',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter response',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _releaseTask();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -60,
                left: -20,
                child: Image.asset(
                  'assets/images/noorva_home.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _releaseTask() {
    setState(() {
      _conversations.removeAt(_currentCardPage);
      if (_currentCardPage >= _conversations.length) {
        _currentCardPage = _conversations.length - 1;
      }
    });
    
    // Show Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF4A90E2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 120, left: 24, right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'The task is released. Rest well tonight, and we\nwill rebuild the foundation tomorrow',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> data) {
    bool isMissed = data['isMissed'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isMissed 
            ? const LinearGradient(
                colors: [Color(0xFF8B4A4A), Color(0xFF5C3333)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: isMissed ? null : const Color(0xFF1C1C1E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF3B3B3B)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Text(
                data['tag']!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
                if (!isMissed)
                  const SizedBox(width: 12),
                if (!isMissed)
                  const Icon(Icons.north_east, color: Colors.white, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data['subtitle']!,
              style: TextStyle(
                color: isMissed ? const Color(0xFFFFA9A9) : Colors.white70,
                fontSize: 14,
                fontStyle: isMissed ? FontStyle.italic : FontStyle.normal,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            if (isMissed) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showRecalibrateBottomSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      'Tap to recalibrate',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _conversations.length,
                (index) => _buildDot(isActive: _currentCardPage == index),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }

  void _showOptionsBottomSheet(
    BuildContext context, {
    required List<Map<String, dynamic>> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141416),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding:
              const EdgeInsets.only(top: 12, bottom: 32, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select an option',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...options.map((option) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (option['onTap'] != null) {
                      option['onTap']();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Center(
                            child: option['icon'] is String
                                ? Image.asset(option['icon'],
                                    width: 24, height: 24, color: Colors.white)
                                : Icon(option['icon'] as IconData,
                                    color: Colors.white, size: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          option['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Ask Noorva Anything',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 18),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildInputIconButton(
                icon: Icons.attach_file_rounded,
                onTap: () {
                _showOptionsBottomSheet(
                  context,
                  options: [
                    {
                      'title': 'Gallery',
                      'icon': Icons.image_outlined,
                      'onTap': () {},
                    },
                    {
                      'title': 'Files',
                      'icon': Icons.description_outlined,
                      'onTap': () {},
                    },
                  ],
                );
              }),
              if (!_isChatActive) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _showOptionsBottomSheet(
                      context,
                      options: [
                        {
                          'title': 'Guide',
                          'icon': 'assets/icons/guide.png',
                          'onTap': () =>
                              Navigator.pushNamed(context, AppRoutes.guide),
                        },
                        {
                          'title': 'Events',
                          'icon': Icons.calendar_today_outlined,
                          'onTap': () =>
                              Navigator.pushNamed(context, AppRoutes.interactiveEventCreation),
                        },
                      ],
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/guide.png',
                            width: 20, height: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Guide',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white60, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (_isInputNotEmpty)
                _buildSendButton()
              else ...[
                _buildInputIconButton(
                  icon: Icons.mic_none,
                  onTap: _openVoiceMode,
                  isActive: _isVoiceModeActive,
                ),
                const SizedBox(width: 4),
                _buildInputIconButton(
                  assetPath: 'assets/icons/recording.png',
                  onTap: _openVoiceMode,
                  isActive: _isVoiceModeActive,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _handleSendMessage,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_upward, color: Colors.black, size: 24),
      ),
    );
  }

  Widget _buildInputIconButton(
      {String? assetPath, IconData? icon, VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white10 : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: icon != null
            ? Icon(icon, color: isActive ? AppColors.blueAccent : Colors.white54, size: 24)
            : Image.asset(
                assetPath!,
                width: 24,
                height: 24,
                color: isActive ? AppColors.blueAccent : Colors.white54,
              ),
      ),
    );
  }

  Widget _buildDecorativeDots() {
    return Column(
      children: [
        // Top Circle (Shifted right)
        Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateZ(0.5),
            child: const _CrystalDot(size: 20),
          ),
        ),
        const SizedBox(height: 6),
        // Bottom Circle (Shifted left)
        Padding(
          padding: const EdgeInsets.only(right: .5),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateZ(-0.5),
            child: const _CrystalDot(size: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderIconButton(
            'assets/icons/menu.png',
            onTap: () => Navigator.pushNamed(context, AppRoutes.menu),
          ),
          _buildHeaderButton(
            Icons.notifications_outlined,
            hasBadge: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    return Column(
      children: [
        _buildChatHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[index];
              if (message['isUser']) {
                return _buildUserMessage(message['text']);
              } else {
                return _buildNoorvaResponse(message['text']);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderIconButton(
            'assets/icons/menu.png',
            onTap: () => Navigator.pushNamed(context, AppRoutes.menu),
          ),
          _buildHeaderIconButton(
            'assets/icons/edit.png', // New Chat icon from Image 2
            onTap: () => setState(() {
              _isChatActive = false;
              _chatMessages.clear();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.copy_rounded, color: Colors.white24, size: 20),
          const SizedBox(width: 12),
          Image.asset(
            'assets/icons/edit.png',
            color: Colors.white24,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoorvaResponse(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/noorva_home.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              const Icon(Icons.volume_up_outlined,
                  color: Colors.white70, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          CrystalCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 32,
            borderColor: const Color(0xFF3B3B3B),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.copy_rounded, color: Colors.white24, size: 20),
              SizedBox(width: 20),
              Icon(Icons.refresh_rounded, color: Colors.white24, size: 20),
              SizedBox(width: 20),
              Icon(Icons.more_horiz, color: Colors.white24, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _CrystalDot extends StatelessWidget {
  final double size;

  const _CrystalDot({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CrystalDotPainter(),
    );
  }
}

class _CrystalDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    borderPaint.shader = ui.Gradient.linear(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.6, size.height),
      [
        Colors.white.withValues(alpha: 0.4),
        Colors.white.withValues(alpha: 0.4),
        Colors.white.withValues(alpha: 0.0001),
        Colors.white.withValues(alpha: 0.4),
      ],
      [0.0482, 0.3808, 0.5668, 0.951],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawOval(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
