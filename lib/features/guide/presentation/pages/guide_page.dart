import 'package:flutter/material.dart';
import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../goals/data/models/goal_model.dart';
import '../../../goals/presentation/bloc/goals_bloc.dart';
import '../../../goals/presentation/bloc/goals_event.dart';
import '../../../goals/presentation/widgets/goal_ui.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'image_viewer_page.dart';
import 'sources_web_view_page.dart';
import '../../../../core/widgets/radio_dot.dart';
import '../../../../core/widgets/noorva_mascot.dart';
import '../../../../core/widgets/noorva_chat_input.dart';
import '../../../../core/widgets/chat_attachments.dart';
import '../../../../core/widgets/perched_mascot.dart';

class GoalChatArguments {
  final String goalId;
  final int taskId;

  GoalChatArguments({
    required this.goalId,
    required this.taskId,
  });
}

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ChatAttachmentController _attachments = ChatAttachmentController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  List<String> _currentSuggestions = [];
  bool _isTyping = false;
  bool _showInitialWelcome = true;
  bool _isInputNotEmpty = false;
  bool _isInputFocused = false;
  String? _conversationTitle;

  bool _isInit = true;
  bool _isGoalChat = false;
  String? _goalId;
  int? _taskId;
  Goal? _chatGoal;
  GoalTask? _chatTask;
  bool _showSuccessOverlay = false;
  bool _isVideoPlaying = false;
  bool _isVideoBuffering = false;

  bool _isDraftingEmail = false;
  int _emailDraftStep = 0;

  // ── Toast overlay state ──────────────────────────────────────────────────
  bool _showToastBanner = false;
  String _toastMessage = '';
  bool _toastIsBlue = false;
  bool _toastIsRed = false;
  late AnimationController _toastController;
  late Animation<Offset> _toastSlide;

  // Animated dots controller
  late AnimationController _dotController;

  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  final TextEditingController _customTitleController =
      TextEditingController(text: 'The Morning Anchor');
  bool _shouldFailGalleryDownload = true;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _toastSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _toastController,
      curve: Curves.easeOutCubic,
    ));

    _currentSuggestions = [
      "How to beat the afternoon energy slump without coffee",
      "Draft an email to Sumanth."
    ];

    _messages.add(ChatMessage(
      text:
          "I see you are ready for guidance. I will walk with you from here. What should we plan out first?",
      isUser: false,
      type: MessageType.initial,
      showCharacter: false,
    ));

    _messageController.addListener(() {
      final isNotEmpty = _messageController.text.trim().isNotEmpty;
      if (isNotEmpty != _isInputNotEmpty) {
        setState(() => _isInputNotEmpty = isNotEmpty);
      }
    });

    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus != _isInputFocused) {
        setState(() => _isInputFocused = _inputFocusNode.hasFocus);
      }
    });

    _initSpeech();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is GoalChatArguments) {
        _isGoalChat = true;
        _goalId = args.goalId;
        _taskId = args.taskId;
        _showInitialWelcome = false;
        // The generic starter prompts don't apply to a goal conversation.
        _currentSuggestions = [];

        final goal = context.read<GoalsBloc>().state.getGoalById(_goalId!);
        if (goal != null) {
          _chatGoal = goal;
          final task = goal.tasks.firstWhere((t) => t.id == _taskId,
              orElse: () => goal.tasks.first);
          _chatTask = task;
          _conversationTitle = goal.title;

          _messages.clear();
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            type: MessageType.goalTaskCard,
          ));
          _messages.add(ChatMessage(
            text: 'Do you need any help to finish this ${task.title} task?',
            isUser: false,
            showCharacter: true,
            type: MessageType.options,
            options: const [
              'Yes, I finished it',
              'I\'m having trouble',
            ],
          ));
        }
      }
      _isInit = false;
    }
  }

  void _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      debugPrint('Speech initialization error: $e');
    }
  }

  void _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) => debugPrint('onStatus: $val'),
          onError: (val) => debugPrint('onError: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              _lastWords = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _messageController.text = _lastWords;
              }
            }),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _attachments.dispose();
    _customTitleController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _dotController.dispose();
    _toastController.dispose();
    _speech.stop();
    super.dispose();
  }

  // ── Mascot mood ────────────────────────────────────────────────────────────

  MascotMood get _guideMood {
    if (_isListening) return MascotMood.listening;
    if (_isTyping) return MascotMood.thinking;
    if (_isInputFocused || _isInputNotEmpty) return MascotMood.typing;
    return MascotMood.explaining;
  }

  // ── Bot response helper ────────────────────────────────────────────────────

  void _simulateBotResponse(ChatMessage response, {int delayMs = 1000}) {
    setState(() => _isTyping = true);

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(response);
          _currentSuggestions = [];
        });
        _scrollToBottom();
      }
    });
  }

  // ── Message sending ────────────────────────────────────────────────────────

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _showInitialWelcome = false;
      _messages.add(ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _attachments.clear();
      _currentSuggestions = [];
      _isInputNotEmpty = false;
    });
    _scrollToBottom();

    final lower = text.toLowerCase();

    // Email drafting active flow check
    if (_isDraftingEmail) {
      if (_emailDraftStep == 1) {
        setState(() {
          _messages.add(ChatMessage(text: text, isUser: true));
          _emailDraftStep = 2;
        });
        _scrollToBottom();

        _simulateBotResponse(ChatMessage(
          text:
              "Got it. I drafted something straightforward so it doesn't create unnecessary back-and-forth. How does this sound?",
          isUser: false,
          type: MessageType.emailDraft,
          showCharacter: true,
        ));
        return;
      }
    }

    if ((lower.contains('draft') ||
            lower.contains('write') ||
            lower.contains('send')) &&
        (lower.contains('email') || lower.contains('mail')) &&
        lower.contains('sumanth')) {
      setState(() {
        _showInitialWelcome = false;
        _messages.add(ChatMessage(text: text, isUser: true));
        _isDraftingEmail = true;
        _emailDraftStep = 1;
      });
      _scrollToBottom();

      _simulateBotResponse(ChatMessage(
        text:
            "Sure thing. What’s the core message you want to get across to Sumanth today? Are we just giving him a quick update, or do you need him to take action on something?",
        isUser: false,
        showCharacter: true,
      ));
      return;
    }

    if (lower.contains('afternoon slump') ||
        lower.contains('energy slump') ||
        lower.contains('slump without coffee') ||
        lower.contains('beat the afternoon')) {
      final loadingMessage = ChatMessage(
        text: "",
        isUser: false,
        type: MessageType.preciseSearch,
        showCharacter: true,
      );
      setState(() {
        _showInitialWelcome = false;
        _messages.add(loadingMessage);
      });
      _scrollToBottom();
      return;
    }

    // Image fetch request
    if ((lower.contains('generate') ||
                lower.contains('fetch') ||
                lower.contains('find')) &&
            (lower.contains('image') ||
                lower.contains('photo') ||
                lower.contains('picture')) ||
        (lower.contains('zen monk') || lower.contains('monk meditating'))) {
      _simulateBotResponse(ChatMessage(
        text:
            "No, I can't generate images as of now, but i can fetch some images for you",
        isUser: false,
        type: MessageType.imageGallery,
        imagePaths: [
          'assets/images/zen_monk.png',
          'assets/images/zen_monk.png',
        ],
        showCharacter: false,
      ));
      // User specified a time → settlement + priority
    } else if ((lower.contains('meditate at') ||
            lower.contains('want to meditate') ||
            lower.contains('i want to meditate at')) &&
        (lower.contains('am') || lower.contains('pm'))) {
      _simulateBotResponse(ChatMessage(
        text:
            "It is settled. I will quietly tap your shoulder at 6:55 AM tomorrow so you don't have to watch the clock",
        secondaryText:
            "To ensure my nudge matches the weight of your intention, what priority should we assign to this reminder?",
        isUser: false,
        type: MessageType.options,
        options: [
          "High Priority",
          "Medium Priority",
          "Low Priority",
          "I'll decide later",
        ],
        showCharacter: true,
      ));
    } else if (lower.contains('meditate') || lower.contains('meditation')) {
      setState(() => _conversationTitle = 'Meditation for inner peace');
      _simulateBotResponse(ChatMessage(
        text:
            "Inner peace is a profound and beautiful goal. When the mind is quiet, everything else we must handle during the day becomes a little easier to navigate. To help us build a rhythm that truly serves you, tell me - which style do you prefer?",
        isUser: false,
        type: MessageType.options,
        options: [
          "Spiritual way",
          "Scientific way",
          "Suggest me the best option",
        ],
        showCharacter: true,
      ));
    } else if (lower.contains('inner peace')) {
      _simulateBotResponse(ChatMessage(
        text:
            "That is a beautiful intention. Finding inner peace through meditation is a journey of self-discovery. Shall we begin with your first session today?",
        isUser: false,
        showCharacter: true,
      ));
    } else {
      _simulateBotResponse(ChatMessage(
        text:
            "That's an interesting thought! As your Noorva Guide, I'm here to help you navigate your journey. Would you like to explore a meditation practice or perhaps plan your daily routine?",
        isUser: false,
        showCharacter: true,
      ));
    }
  }

  // ── Toast Banner ────────────────────────────────────────────────────────────

  void _showToast(String message, {bool isBlue = false, bool isRed = false}) {
    setState(() {
      _toastMessage = message;
      _toastIsBlue = isBlue;
      _toastIsRed = isRed;
      _showToastBanner = true;
    });
    _toastController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        _toastController.reverse().then((_) {
          if (mounted) {
            setState(() => _showToastBanner = false);
          }
        });
      }
    });
  }

  // ── Image Viewer navigation ───────────────────────────────────────────────

  Future<void> _openImageViewer(String imagePath) async {
    final result = await ImageViewerPage.push(context, imagePath);
    if (!mounted) return;
    switch (result) {
      case 'copied':
        _showToast('Image Copied');
        break;
      case 'failed':
        _showToast('Image Failed to downloaded. Retry again', isRed: true);
        break;
      case 'downloaded':
        _showToast('Image Downloaded', isBlue: true);
        break;
      default:
        break;
    }
  }

  // ── Option selection ───────────────────────────────────────────────────────

  void _handleOptionSelected(String option) {
    if (option == "Looks good, send it") {
      setState(() {
        _isDraftingEmail = false;
        _emailDraftStep = 0;
      });
      _simulateBotResponse(ChatMessage(
        text:
            "Done. That is sent and off your plate. You can clear Sumanth from your mind for now and get back to your focus",
        isUser: false,
        showCharacter: true,
      ));
      return;
    } else if (option == "Let's tweak the tone") {
      _simulateBotResponse(ChatMessage(
        text: "Sure! Should we make it more formal, friendly, or concise?",
        isUser: false,
        type: MessageType.options,
        options: const ["More formal", "More friendly", "Keep it concise"],
        showCharacter: true,
      ));
      return;
    } else if (option == "Save it for later") {
      setState(() {
        _isDraftingEmail = false;
        _emailDraftStep = 0;
      });
      _simulateBotResponse(ChatMessage(
        text:
            "I have saved this draft for you. You can resume writing or send it whenever you are ready.",
        isUser: false,
        showCharacter: true,
      ));
      return;
    }

    if (option == "Yes, generate my reset plan") {
      _simulateBotResponse(ChatMessage(
        text:
            "Excellent. I will structure a precise routine utilizing light, movement, and hydration. To ensure it fits your workday, what time do you usually feel this energy drop hit the hardest?",
        isUser: false,
        type: MessageType.options,
        options: const [
          "Around 1:30 PM",
          "Around 3:00 PM",
          "Enter the specific time",
        ],
        showCharacter: true,
      ));
      return;
    } else if (option == "Yes, but let's focus only on diet") {
      _simulateBotResponse(ChatMessage(
        text:
            "Understood. We will focus purely on post-meal nutrition, blood sugar stabilization, and smart snacking. What time does your slump usually occur?",
        isUser: false,
        type: MessageType.options,
        options: const [
          "Around 1:30 PM",
          "Around 3:00 PM",
          "Enter the specific time",
        ],
        showCharacter: true,
      ));
      return;
    } else if (option == "No, I just need the information") {
      _simulateBotResponse(ChatMessage(
        text:
            "Of course. Let me know if you would like me to summarize any other scientific insights or neurobiology data regarding health and wellness.",
        isUser: false,
        showCharacter: true,
      ));
      return;
    } else if (option == "Around 1:30 PM" || option == "Around 3:00 PM") {
      _simulateBotResponse(ChatMessage(
        text:
            "Wonderful. I have added a daily 15-minute 'Afternoon Reset' task to your goals list, starting tomorrow at ${option.replaceAll('Around ', '')}. I will be here to nudge you when the time comes.",
        isUser: false,
        showCharacter: true,
      ));
      return;
    }

    if (_isGoalChat) {
      setState(() {
        _messages.add(ChatMessage(text: option, isUser: true));
        _currentSuggestions = [];
      });
      _scrollToBottom();

      if (option == 'Yes, I finished it') {
        _simulateBotResponse(
            ChatMessage(
              text:
                  'Incredible work! I have marked this task as completed. Keep up the amazing progress.',
              isUser: false,
              showCharacter: true,
            ),
            delayMs: 600);

        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) {
            setState(() {
              _showSuccessOverlay = true;
            });
          }
        });
      } else if (option == 'I\'m having trouble') {
        _simulateBotResponse(ChatMessage(
          text:
              'It\'s completely okay. Settle down, take a deep breath. Let me guide you through the pause. What part is feeling difficult?',
          isUser: false,
          showCharacter: true,
          type: MessageType.options,
          options: const [
            'Physical posture',
            'Mind is wandering too much',
            'I don\'t have enough time',
          ],
        ));
      } else {
        _simulateBotResponse(ChatMessage(
          text:
              'I understand. Remember, consistency is about making space for the pause, even if it feels incomplete. Let\'s try together next time!',
          isUser: false,
          showCharacter: true,
        ));
      }
      return;
    }

    setState(() {
      _showInitialWelcome = false;
      _messages.add(ChatMessage(text: option, isUser: true));
      _currentSuggestions = [];
    });
    _scrollToBottom();

    if (option == "Spiritual way") {
      _simulateBotResponse(ChatMessage(
        text:
            "Consistency is the foundation of any spiritual practice. To help you build this habit sustainably, how many days would you like to commit to this meditation practice?",
        isUser: false,
        type: MessageType.options,
        options: ["21 Days", "45 Days", "60 Days", "90 Days"],
        hasInputOption: true,
        showCharacter: true,
      ));
    } else if (option.contains("Days")) {
      // Roadmap message: text + PDF attachment + time-of-day options
      _simulateBotResponse(
        ChatMessage(
          text:
              "Twenty-one days is the perfect window to wire a new habit into your daily life. By the end of this journey, finding your inner peace will feel as natural as taking a breath",
          secondaryText:
              "To help us build a rhythm that truly serves you, tell me - when do you usually want to meditate?",
          isUser: false,
          type: MessageType.options,
          options: [
            "Morning (Between 6AM - 10AM)",
            "Afternoon (Between 12PM - 3PM)",
            "Evening (Between 4PM - 8PM)",
            "I'll decide later",
          ],
          hasPdfAttachment: true,
          pdfName: "21 days Meditation roadmap.pdf",
          pdfSize: "100Kb",
          showCharacter: true,
        ),
        delayMs: 800,
      );
    } else if (option.startsWith("Morning") ||
        option.startsWith("Afternoon") ||
        option.startsWith("Evening")) {
      final period = option.startsWith("Morning")
          ? "morning"
          : option.startsWith("Afternoon")
              ? "afternoon"
              : "evening";
      _simulateBotResponse(ChatMessage(
        text: "Tell me the exact time you want to meditate in the $period",
        isUser: false,
        showCharacter: false,
      ));
    } else if (option == "Suggest me the best option") {
      setState(() => _conversationTitle = 'Meditation for inner peace');
      // First send a text response, then follow with the video message
      _simulateBotResponse(ChatMessage(
        text:
            "The most effective approach combines both ancient wisdom and modern science. Let me show you some teachings from respected masters to help you find what resonates best with you.",
        isUser: false,
        showCharacter: true,
      ));
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) {
          _simulateBotResponse(
            ChatMessage(
              text: '',
              isUser: false,
              type: MessageType.videoWithSources,
              showCharacter: false,
            ),
            delayMs: 300,
          );
        }
      });
      // After the video, follow up with the day commitment options
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (mounted) {
          _simulateBotResponse(
            ChatMessage(
              text:
                  "To help you build a lasting habit, how many days would you like to commit to this meditation practice?",
              isUser: false,
              type: MessageType.options,
              options: ["21 Days", "45 Days", "60 Days", "90 Days"],
              hasInputOption: true,
              showCharacter: true,
            ),
            delayMs: 600,
          );
        }
      });
    } else if (option == "High Priority") {
      _simulateBotResponse(ChatMessage(
        text:
            "High priority. I have noted the weight of this commitment. I will be firm but gentle tomorrow morning—I will not let this window slide by unnoticed. To help anchor your focus the moment you hear my chime, what shall we call this morning intention?",
        isUser: false,
        type: MessageType.titleInput,
        showCharacter: true,
      ));
    } else if (option == "Medium Priority" ||
        option == "Low Priority" ||
        option == "I'll decide later") {
      _simulateBotResponse(ChatMessage(
        text:
            "Intention set. I have noted the weight of this commitment. I will nudge you gently tomorrow morning. To help anchor your focus the moment you hear my chime, what shall we call this morning intention?",
        isUser: false,
        type: MessageType.titleInput,
        showCharacter: true,
      ));
    }
  }

  void _handleTitleSubmitted(String title) {
    setState(() {
      _messages.add(ChatMessage(text: title, isUser: true));
    });
    _scrollToBottom();

    _simulateBotResponse(ChatMessage(
      text:
          "Since we are already here and your intention is clear, would you like to do a brief, three-minute trial session right now? It is a gentle way to get comfortable with the practice before tomorrow morning",
      isUser: false,
      type: MessageType.trialPrompt,
      showCharacter: true,
    ));
  }

  void _handleTrialPromptSelected(String option) {
    setState(() {
      _messages.add(ChatMessage(text: option, isUser: true));
    });
    _scrollToBottom();

    if (option == "Let me try it") {
      _simulateBotResponse(ChatMessage(
        text: "Meditation for inner peace",
        isUser: false,
        type: MessageType.trialCarousel,
        showCharacter: false,
      ));
    } else {
      _simulateBotResponse(ChatMessage(
        text:
            "Perfect. Rest well tonight. I will quietly tap your shoulder tomorrow morning to begin our journey together.",
        isUser: false,
        showCharacter: true,
      ));
    }
  }

  void _handleTrialFinished() {
    setState(() {
      _messages
          .add(ChatMessage(text: "Trial session completed!", isUser: true));
    });
    _scrollToBottom();

    _simulateBotResponse(ChatMessage(
      text:
          "Perfect. I've noted your preference. Your 21-day journey to inner peace begins tomorrow morning. I'll be quietly by your side every step of the way.",
      isUser: false,
      showCharacter: true,
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: size.width * 0.18,
        leading: Padding(
          padding: EdgeInsets.only(left: size.width * 0.04),
          child: _buildHeaderButton(
            'assets/icons/menu.png',
            onTap: () => Navigator.pushNamed(context, AppRoutes.menu),
          ),
        ),
        title: _conversationTitle != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: GoalUi.card,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: GoalUi.cardBorder),
                ),
                child: Text(
                  _conversationTitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: size.width * 0.04),
            child: _buildHeaderButton('assets/icons/edit.png'),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Initial Welcome Overlay ──────────────────────────────────
            if (_showInitialWelcome) ...[
              Positioned(
                bottom: size.height * 0.11,
                left: 0,
                right: 0,
                child: Center(
                  child: NoorvaMascot(
                    mood: MascotMood.hello,
                    height: size.height * 0.54,
                    fallbackAsset: 'assets/images/forgot_password.png',
                  ),
                ),
              ),
              Positioned(
                bottom: size.height * 0.47,
                right: size.width * 0.20,
                child: Transform.rotate(
                  angle: 5 * (pi / 180),
                  child: Opacity(
                    opacity: 0.75,
                    child:
                        Image.asset('assets/images/dots_home.png', width: 36),
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.04,
                left: size.width * 0.05,
                right: size.width * 0.05,
                child: _buildWelcomeBubble(),
              ),
            ],

            // ── Main Column ──────────────────────────────────────────────
            Column(
              children: [
                if (!_showInitialWelcome)
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ListView.builder(
                            controller: _scrollController,
                            // Bottom room so the latest message can always be
                            // scrolled clear of Noorva standing on the bar.
                            padding: EdgeInsets.fromLTRB(size.width * 0.04, 20,
                                size.width * 0.04, 16 + PerchedMascot.height),
                            itemCount: _messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _messages.length) {
                                return _buildTypingIndicator();
                              }
                              final message = _messages[index];
                              if (message.type == MessageType.initial) {
                                return const SizedBox.shrink();
                              }
                              return _buildMessageTile(message);
                            },
                          ),
                        ),
                        // Only the input bar's top margin sits between the
                        // chat area and the bar; with suggestions showing he
                        // stands on top of them instead.
                        PerchedMascot(
                          gapToBar: _currentSuggestions.isEmpty ? 8 : 0,
                          mood: _guideMood,
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                _buildInputSection(),
              ],
            ),

            // ── Animated Toast Banner ────────────────────────────────────
            if (_showToastBanner)
              Positioned(
                left: size.width * 0.04,
                right: size.width * 0.04,
                bottom: size.height * 0.11,
                child: SlideTransition(
                  position: _toastSlide,
                  child: Material(
                    color: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: _toastIsRed
                            ? const Color(0xFFE05252)
                            : _toastIsBlue
                                ? const Color(0xFF4CA6FF)
                                : const Color(0xFF2A2A2D),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        _toastMessage,
                        style: TextStyle(
                          color: (_toastIsBlue || _toastIsRed)
                              ? Colors.white
                              : Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Success Checkmark Overlay ──────────────────────────────
            _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: GoalUi.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GoalUi.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedDots(),
              const SizedBox(width: 6),
              const Text(
                "Noorva is thinking",
                style: TextStyle(color: GoalUi.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTaskCard() {
    if (_chatTask == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
      decoration: GoalUi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_chatTask!.title, style: GoalUi.cardTitle),
          const SizedBox(height: 4),
          Text(
            _chatTask!.subtitle,
            style: const TextStyle(color: GoalUi.textBody, fontSize: 14),
          ),
          const SizedBox(height: 14),
          const Divider(color: GoalUi.cardBorder, height: 1),
          const SizedBox(height: 14),
          Text(
            _chatTask!.content,
            style: const TextStyle(
              color: Color(0xFFE5E5E7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (_chatTask!.id == 1 && _goalId == 'inner-peace') ...[
            const SizedBox(height: 20),
            _buildYouTubeVideoMockupForChat(),
            const SizedBox(height: 12),
            _buildVideoPageIndicatorsForChat(),
          ],
        ],
      ),
    );
  }

  Widget _buildYouTubeVideoMockupForChat() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    'assets/images/mindful_breathing.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white10,
                      child: const Center(
                        child:
                            Icon(Icons.image, color: Colors.white30, size: 40),
                      ),
                    ),
                  ),
                ),
                if (!_isVideoPlaying)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVideoBuffering = true;
                        });
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          if (mounted) {
                            setState(() {
                              _isVideoBuffering = false;
                              _isVideoPlaying = true;
                            });
                          }
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: _isVideoBuffering
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      color: Colors.black54,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isVideoPlaying = false;
                              });
                            },
                            child: const Icon(Icons.pause,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: LinearProgressIndicator(
                              value: 0.15,
                              backgroundColor: Colors.white24,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "0:45 / 5:00",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/noorva_guide.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mindful breathing in 5 minutes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Mystic World • 100K Views • 5 years ago",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.more_vert,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPageIndicatorsForChat() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('●', style: TextStyle(color: Colors.white, fontSize: 10)),
        SizedBox(width: 6),
        Text('○', style: TextStyle(color: Colors.white38, fontSize: 10)),
        SizedBox(width: 6),
        Text('○', style: TextStyle(color: Colors.white38, fontSize: 10)),
        SizedBox(width: 6),
        Text('○', style: TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildSuccessOverlay() {
    if (!_showSuccessOverlay) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: const Color(0xD9000000), // Avoid withOpacity deprecation warning
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0x264CC35A),
                      shape: BoxShape.circle,
                      border: Border.all(color: GoalUi.progressFill, width: 3),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: GoalUi.progressFill,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Task Completed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You are one step closer to your goal of\n"${_chatGoal?.title ?? ''}"',
                  textAlign: TextAlign.center,
                  style: GoalUi.body.copyWith(height: 1.45),
                ),
                const SizedBox(height: 36),
                GoalPillButton(
                  label: 'Back to Home',
                  onTap: () {
                    if (_goalId != null && _taskId != null) {
                      context
                          .read<GoalsBloc>()
                          .add(GoalTaskCompleted(_goalId!, _taskId!));
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Welcome Bubble ─────────────────────────────────────────────────────────

  Widget _buildWelcomeBubble() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "I see you are ready for guidance. I will walk with you from here. What should we plan out first?",
            style: TextStyle(color: Colors.white, fontSize: 17, height: 1.55),
          ),
          const SizedBox(height: 14),
          _buildAnimatedDots(),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final raw = (_dotController.value - delay) % 1.0;
            final opacity = sin(raw * pi).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Opacity(
                opacity: 0.25 + (opacity * 0.75),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ── Header Button ──────────────────────────────────────────────────────────

  Widget _buildHeaderButton(String assetPath, {VoidCallback? onTap}) {
    return Align(
      alignment: Alignment.center,
      child: GoalCircleButton(asset: assetPath, onTap: onTap),
    );
  }

  // ── Message Tile ───────────────────────────────────────────────────────────

  Widget _buildMessageTile(ChatMessage message) {
    if (message.type == MessageType.goalTaskCard) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _buildGoalTaskCard(),
      );
    }

    // ── User bubble ──
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showToast('Text Copied');
                    },
                    child: Image.asset('assets/icons/copy.png',
                        width: 18, height: 18, color: Colors.white38),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset('assets/icons/edit.png',
                        width: 18, height: 18, color: Colors.white38),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: GoalUi.secondaryButton,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(6),
                  ),
                  border: Border.all(color: const Color(0xFF3A3B40)),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Bot bubble ──
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Noorva stands on the input bar now; keep just the read-aloud icon.
        if (message.showCharacter)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset('assets/icons/audio.png',
                  width: 22, height: 22, color: Colors.white70),
            ),
          ),

        // Message card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: GoalUi.cardDecoration(radius: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info type (nested bullet card)
              if (message.type == MessageType.info) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GoalUi.inset,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "First let me explain why this is the right choice:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...() {
                        final points = message.text.split('\n•');
                        return points
                            .where((p) =>
                                p.trim().isNotEmpty &&
                                !p.contains("First let me explain"))
                            .map((point) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 7),
                                        child: Icon(Icons.circle,
                                            color: Colors.white54, size: 5),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          point.trim(),
                                          style: const TextStyle(
                                            color: GoalUi.textBody,
                                            fontSize: 14,
                                            height: 1.55,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList();
                      }(),
                    ],
                  ),
                ),
              ] else ...[
                // Primary text (skip for videoWithSources which renders its own content)
                if (message.type != MessageType.videoWithSources &&
                    message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Color(0xFFE5E5E7),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
              ],

              // PDF attachment card
              if (message.hasPdfAttachment &&
                  message.pdfName != null &&
                  message.pdfSize != null) ...[
                const SizedBox(height: 14),
                _buildPdfAttachment(message.pdfName!, message.pdfSize!),
              ],

              // Secondary paragraph
              if (message.secondaryText != null &&
                  message.type != MessageType.info) ...[
                const SizedBox(height: 14),
                Text(
                  message.secondaryText!,
                  style: const TextStyle(
                    color: GoalUi.textBody,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],

              // Option buttons
              if (message.type == MessageType.options &&
                  message.options != null) ...[
                const SizedBox(height: 20),
                ...message.options!.map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionButton(option),
                    )),
                if (message.hasInputOption) _buildInputOption(),
              ],

              // Custom Title input bubble
              if (message.type == MessageType.titleInput) ...[
                const SizedBox(height: 20),
                _buildCustomTitleInputField(message),
              ],

              // Trial Prompt buttons
              if (message.type == MessageType.trialPrompt) ...[
                const SizedBox(height: 20),
                _buildTrialPromptButtons(message),
              ],

              // Trial Carousel
              if (message.type == MessageType.trialCarousel) ...[
                const SizedBox(height: 10),
                MeditationCarousel(
                  onFinished: _handleTrialFinished,
                ),
              ],

              // Image Gallery
              if (message.type == MessageType.imageGallery &&
                  message.imagePaths != null &&
                  message.imagePaths!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildImageGallery(message.imagePaths!),
              ],

              // Video with Sources
              if (message.type == MessageType.videoWithSources) ...[
                _buildVideoWithSourcesWidget(message),
              ],

              // Precise Search loading state
              if (message.type == MessageType.preciseSearch) ...[
                PreciseSearchLoadingWidget(
                  onFinished: () => _transitionSearchToResults(message),
                ),
              ],

              // Precise Search Result state
              if (message.type == MessageType.preciseSearchResult) ...[
                _buildPreciseSearchResultWidget(message),
              ],

              // Email Draft state
              if (message.type == MessageType.emailDraft) ...[
                _buildEmailDraftCard(message),
                const SizedBox(height: 20),
                GoalPillButton(
                  label: "Looks good, send it",
                  height: 52,
                  onTap: () => _handleOptionSelected("Looks good, send it"),
                ),
                const SizedBox(height: 12),
                GoalPillButton(
                  label: "Let's tweak the tone",
                  primary: false,
                  height: 52,
                  onTap: () => _handleOptionSelected("Let's tweak the tone"),
                ),
                const SizedBox(height: 12),
                GoalPillButton(
                  label: "Save it for later",
                  primary: false,
                  height: 52,
                  onTap: () => _handleOptionSelected("Save it for later"),
                ),
              ],
            ],
          ),
        ),

        // Reaction row
        const SizedBox(height: 8),
        Row(
          children: [
            const Spacer(),
            _buildActionIcon('assets/icons/copy.png', onTap: () {
              _showToast('Text Copied');
            }),
            _buildActionIcon('assets/icons/reload.png'),
            _buildBotBubbleMenu(context),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── PDF Attachment Card ────────────────────────────────────────────────────

  Widget _buildPdfAttachment(String name, String size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // File type indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: Colors.white60,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  size,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Download action
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              'assets/icons/download.png',
              width: 20,
              height: 20,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  // ── Option Button ──────────────────────────────────────────────────────────

  Widget _buildOptionButton(String text) {
    return Material(
      color: GoalUi.secondaryButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF3A3B40)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleOptionSelected(text),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputOption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.selection,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter your choice',
          hintStyle: TextStyle(color: Colors.white38),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCustomTitleInputField(ChatMessage message) {
    final isLast = _messages.last == message;
    if (!isLast) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.selection,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _customTitleController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Enter your custom title for this goal',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        _handleTitleSubmitted(val.trim());
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () {
                  final text = _customTitleController.text.trim();
                  if (text.isNotEmpty) {
                    _handleTitleSubmitted(text);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _handleTitleSubmitted("Skip for now"),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Skip for now",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrialPromptButtons(ChatMessage message) {
    final isLast = _messages.last == message;
    if (!isLast) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GoalPillButton(
          label: "Let me try it",
          onTap: () => _handleTrialPromptSelected("Let me try it"),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _handleTrialPromptSelected("I'll start from tomorrow"),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "I'll start from tomorrow",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(String assetPath, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child:
            Image.asset(assetPath, width: 20, height: 20, color: Colors.white),
      ),
    );
  }

  // ── Video With Sources ────────────────────────────────────────────────────

  Widget _buildVideoWithSourcesWidget(ChatMessage message) {
    return _StandaloneVideoCard(steps: message.steps);
  }

  // ── Image Gallery ──────────────────────────────────────────────────────────

  Widget _buildImageGallery(List<String> paths) {
    // Show single wide image if only one, two side-by-side otherwise
    if (paths.length == 1) {
      return _buildGalleryImage(paths[0], isFull: true);
    }
    return Row(
      children: paths.take(2).map((p) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: p == paths.first && paths.length > 1 ? 6 : 0),
            child: _buildGalleryImage(p, isFull: false),
          ),
        );
      }).toList(),
    );
  }

  void _showImageContextMenu(
      BuildContext context, String assetPath, TapDownDetails details) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      overlay.size.width - details.globalPosition.dx,
      overlay.size.height - details.globalPosition.dy,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: const Color(0xFF1E1E21),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      elevation: 12,
      items: [
        PopupMenuItem<String>(
          value: 'copy',
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Image.asset('assets/icons/copy.png',
                    width: 18, height: 18, color: Colors.white70),
                const SizedBox(width: 12),
                const Text('Copy Image',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'download',
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1, color: AppColors.borderLight),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Image.asset('assets/icons/download.png',
                        width: 18, height: 18, color: Colors.white70),
                    const SizedBox(width: 12),
                    const Text('Download Image',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'report',
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Divider(height: 1, color: AppColors.borderLight),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        color: Colors.white70, size: 18),
                    SizedBox(width: 12),
                    Text('Report an Issue',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!mounted) return;

    if (result == 'copy') {
      _showToast('Image Copied');
    } else if (result == 'download') {
      if (_shouldFailGalleryDownload) {
        _shouldFailGalleryDownload = false;
        _showToast('Image Failed to downloaded. Retry again', isRed: true);
      } else {
        _shouldFailGalleryDownload = true;
        _showToast('Image Downloaded', isBlue: true);
      }
    } else if (result == 'report') {
      _showToast('Issue reported');
    }
  }

  Widget _buildGalleryImage(String assetPath, {required bool isFull}) {
    TapDownDetails? tapDownDetails;
    return GestureDetector(
      onTapDown: (details) => tapDownDetails = details,
      onTap: () => _openImageViewer(assetPath),
      onLongPress: () {
        if (tapDownDetails != null) {
          _showImageContextMenu(context, assetPath, tapDownDetails!);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: isFull ? 16 / 9 : 1,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.selection,
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    color: Colors.white38, size: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Input Section ──────────────────────────────────────────────────────────

  Widget _buildInputSection() {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Suggestion chip
        if (_currentSuggestions.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04, vertical: 8),
            child: Row(
              children: [
                Image.asset('assets/icons/edit.png',
                    width: 20, height: 20, color: Colors.white54),
                const SizedBox(width: 8),
                Expanded(
                  child: Material(
                    color: GoalUi.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: GoalUi.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () =>
                          _handleSendMessage(_currentSuggestions.first),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          _currentSuggestions.first,
                          style: const TextStyle(
                              color: GoalUi.textBody, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Tasks / Goals quick actions (welcome state only)
        if (_showInitialWelcome &&
            _currentSuggestions.isEmpty &&
            !_isInputNotEmpty &&
            !_isInputFocused)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04, vertical: 8),
            child: Row(
              children: [
                _buildQuickActionButton(Icons.checklist_rtl_outlined, "Tasks"),
                const SizedBox(width: 12),
                _buildQuickActionButton(Icons.track_changes_outlined, "Goals"),
              ],
            ),
          ),

        // Main input container
        NoorvaChatInput(
          controller: _messageController,
          focusNode: _inputFocusNode,
          onSubmitted: _handleSendMessage,
          showSend: _isInputNotEmpty,
          onSend: () => _handleSendMessage(_messageController.text),
          pillIconAsset: 'assets/icons/guide.png',
          pillLabel: 'Guide',
          attachments: _attachments,
          onMicTap: _listen,
          isListening: _isListening,
          homeStyle: true,
        ),
      ],
    );
  }

  // ── Quick Action Buttons ───────────────────────────────────────────────────

  Widget _buildQuickActionButton(IconData icon, String label) {
    return Material(
      color: GoalUi.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: GoalUi.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: GoalUi.textBody, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotBubbleMenu(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: const Color(0xFF1E1E21),
      ),
      child: PopupMenuButton<String>(
        icon: Image.asset(
          'assets/icons/hori_dots.png',
          width: 20,
          height: 20,
          color: Colors.white,
        ),
        padding: const EdgeInsets.only(left: 16),
        color: const Color(0xFF1E1E21),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        elevation: 12,
        onSelected: (val) {
          if (val == 'add') {
            _showToast('Added to tasks');
          } else if (val == 'pin') {
            _showToast('Pinned to top');
          } else if (val == 'report') {
            _showReportContentDialog(context);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'add',
            child: Row(
              children: [
                Icon(Icons.playlist_add, color: Colors.white70, size: 18),
                SizedBox(width: 12),
                Text('Add to tasks',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'pin',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Divider(height: 1, color: AppColors.borderLight),
                Row(
                  children: [
                    Icon(Icons.pin_drop_outlined,
                        color: Colors.white70, size: 18),
                    SizedBox(width: 12),
                    Text('Pin / Highlight',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'report',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Divider(height: 1, color: AppColors.borderLight),
                Row(
                  children: [
                    Icon(Icons.report_problem_outlined,
                        color: Colors.white70, size: 18),
                    SizedBox(width: 12),
                    Text('Report an Issue',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailDraftCard(ChatMessage message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "To: Sumanth",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Subject:",
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            "Quick update on Q3 designs",
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          const Text(
            "Body:",
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            "Hi Sumanth,\n\n"
            "I wanted to give you a quick update on the Q3 design phase. We're currently rethinking the core architecture to make sure the foundation is solid, which means the initial delivery will be slightly delayed, but we will have a new timeline outlined for you by this Friday. Thanks for your patience while we get this right.\n\n"
            "Best regards,\n"
            "${context.read<AuthBloc>().state.user?.name ?? 'User'}",
            style: const TextStyle(
                color: Colors.white70, fontSize: 15, height: 1.45),
          ),
        ],
      ),
    );
  }

  void _transitionSearchToResults(ChatMessage loadingMessage) {
    setState(() {
      final index = _messages.indexOf(loadingMessage);
      if (index != -1) {
        _messages[index] = ChatMessage(
          text: "How to beat the afternoon energy slump without coffee",
          secondaryText:
              "The afternoon slump, typically hitting between 1:00 PM and 3:00 PM, is not a sign of weakness; it is a biological reality driven by three factors: a natural dip in your circadian rhythm, a buildup of adenosine (a sleep-inducing chemical), and post-meal blood sugar fluctuations. Pushing through it with caffeine only delays the crash. Here is how to naturally reset your system",
          isUser: false,
          type: MessageType.preciseSearchResult,
          showCharacter: true,
        );
      }
    });
    _scrollToBottom();

    // After 2.5 seconds, send Noorva's follow-up suggestion option message
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text:
                "Understanding the biology is the first step. The second is building a system to handle it. Would you like me to step in as your guide and generate a personalized 15-minute 'Afternoon Reset' plan to tackle this tomorrow?",
            isUser: false,
            type: MessageType.options,
            options: const [
              "Yes, generate my reset plan",
              "Yes, but let's focus only on diet",
              "No, I just need the information",
            ],
            showCharacter: true,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  Widget _buildPreciseSearchResultWidget(ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AccordionWidget(
          title: "Thought for 6 seconds",
          content: Text(
            "User is looking for natural ways to beat the afternoon slump without relying on caffeine. I need to avoid generic lifestyle advice and focus on proven biological triggers: circadian rhythm adjustments, adenosine clearing, and proper hydration to maintain cognitive performance.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
        const AccordionWidget(
          title: "Found 12 results",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "• Nature Neuroscience - Circadian Rhythms & Cognitive Performance (2024)",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4)),
              SizedBox(height: 6),
              Text(
                  "• Journal of Clinical Sleep Medicine - Adenosine Accumulation Dynamics",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4)),
              SizedBox(height: 6),
              Text(
                  "• Harvard Health Publishing - Dehydration and Brain Function",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4)),
              SizedBox(height: 6),
              Text(
                  "• Journal of Applied Physiology - Short Walks and Alertness",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        if (message.secondaryText != null)
          Text(
            message.secondaryText!,
            style: const TextStyle(
              color: Colors.black38,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          "The 3-step biological reset",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "1. Clear the adenosine with movement: A 10-minute brisk walk increases blood flow and oxygen to the brain, naturally flushing out the adenosine that makes you feel groggy.\n\n"
          "2. Signal wakefulness with light: Viewing natural sunlight (without sunglasses) for even 5 minutes triggers the optic nerve to suppress melatonin production, instantly boosting alertness.\n\n"
          "3. Stabilize your hydration: Even a 2% drop in hydration causes a noticeable decline in cognitive performance. Drink 16 ounces of cold water immediately when the slump begins.",
          style: TextStyle(
            color: Colors.black38,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            _showToast("Opening 12 Sources", isBlue: true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF262629),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link, color: Colors.white70, size: 16),
                SizedBox(width: 6),
                Text(
                  "Sources",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

enum MessageType {
  text,
  options,
  initial,
  info,
  question,
  titleInput,
  trialPrompt,
  trialCarousel,
  imageGallery,
  goalTaskCard,
  videoWithSources,
  preciseSearch,
  preciseSearchResult,
  emailDraft,
}

class ChatMessage {
  final String text;
  final String? secondaryText;
  final bool isUser;
  final MessageType type;
  final List<String>? options;
  final bool hasInputOption;
  final bool showCharacter;
  final bool hasPdfAttachment;
  final String? pdfName;
  final String? pdfSize;
  final List<String>? imagePaths;

  /// When type == videoWithSources, these steps appear above the exploration text
  final List<String>? steps;

  ChatMessage({
    required this.text,
    this.secondaryText,
    required this.isUser,
    this.type = MessageType.text,
    this.options,
    this.hasInputOption = false,
    this.showCharacter = false,
    this.hasPdfAttachment = false,
    this.pdfName,
    this.pdfSize,
    this.imagePaths,
    this.steps,
  });
}

// ── Standalone Video Card (videoWithSources message type) ─────────────────────────

class _StandaloneVideoCard extends StatefulWidget {
  final List<String>? steps;
  const _StandaloneVideoCard({this.steps});

  @override
  State<_StandaloneVideoCard> createState() => _StandaloneVideoCardState();
}

class _StandaloneVideoCardState extends State<_StandaloneVideoCard> {
  bool _isVideoPlaying = false;
  bool _isVideoBuffering = false;
  int _currentDot = 0;

  int _selectedSourceTab = 0;
  bool _isHarvardExpanded = true;
  bool _isApaExpanded = true;
  bool _showControls = true;
  bool _isVideoMuted = false;

  static const _totalDots = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional step instructions above the exploration text
        if (widget.steps != null && widget.steps!.isNotEmpty) ...[
          ...widget.steps!.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              )),
          const SizedBox(height: 6),
        ],

        // "If you would like to explore…" text
        const Text(
          "If you would like to explore, I have curated a few brief teachings from respected masters of inner peace",
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 14),

        // YouTube-style video card
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Video thumbnail + play overlay
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        'assets/images/mindful_breathing.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white10,
                          child: const Center(
                            child: Icon(Icons.image,
                                color: Colors.white30, size: 40),
                          ),
                        ),
                      ),
                    ),
                    if (!_isVideoPlaying)
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isVideoBuffering = true);
                            Future.delayed(const Duration(milliseconds: 1200),
                                () {
                              if (mounted) {
                                setState(() {
                                  _isVideoBuffering = false;
                                  _isVideoPlaying = true;
                                });
                              }
                            });
                          },
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: _isVideoBuffering
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.play_arrow,
                                    color: Colors.white, size: 36),
                          ),
                        ),
                      )
                    else ...[
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showControls = !_showControls),
                        child: Container(color: Colors.transparent),
                      ),
                      if (_showControls)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _showControls = !_showControls),
                            child: Container(
                              color: Colors.black54,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Rewound 10 seconds'),
                                                duration: Duration(seconds: 1)),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white60,
                                                width: 1.5),
                                          ),
                                          child: const Icon(Icons.replay_10,
                                              color: Colors.white, size: 24),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isVideoPlaying = false;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.pause,
                                              color: Colors.black, size: 28),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Skipped forward 10 seconds'),
                                                duration: Duration(seconds: 1)),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white60,
                                                width: 1.5),
                                          ),
                                          child: const Icon(Icons.forward_10,
                                              color: Colors.white, size: 24),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          height: 4,
                                          child: LinearProgressIndicator(
                                            value: 0.15,
                                            backgroundColor: Colors.white24,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.red),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "0:45 / 5:00",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isVideoMuted =
                                                          !_isVideoMuted;
                                                    });
                                                  },
                                                  child: Icon(
                                                    _isVideoMuted
                                                        ? Icons.volume_off
                                                        : Icons.volume_up,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                GestureDetector(
                                                  onTap: () {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Fullscreen Mode'),
                                                          duration: Duration(
                                                              seconds: 1)),
                                                    );
                                                  },
                                                  child: const Icon(
                                                      Icons.fullscreen,
                                                      color: Colors.white,
                                                      size: 20),
                                                ),
                                              ],
                                            ),
                                          ],
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
                  ],
                ),
              ),

              // Video metadata row
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                          color: Colors.white10, shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset('assets/images/noorva_guide.png',
                            fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mindful breathing in 5 minutes",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Mystic World • 100K Views • 5 years ago",
                            style:
                                TextStyle(color: Colors.white38, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.play_circle_fill,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: Colors.white54, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: const Color(0xFF1E1E21),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.borderLight),
                      ),
                      elevation: 12,
                      onSelected: (val) {
                        if (val == 'share') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Video shared successfully!')),
                          );
                        } else if (val == 'report') {
                          _showReportContentDialog(context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share,
                                  color: Colors.white70, size: 18),
                              SizedBox(width: 12),
                              Text('Share',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(height: 1, color: AppColors.borderLight),
                              Row(
                                children: [
                                  Icon(Icons.report_problem_outlined,
                                      color: Colors.white70, size: 18),
                                  SizedBox(width: 12),
                                  Text('Report an Issue',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Dot pagination
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalDots, (i) {
            final isActive = _currentDot == i;
            return GestureDetector(
              onTap: () => setState(() => _currentDot = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 8 : 6,
                height: isActive ? 8 : 6,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 14),

        // Sources links pill
        InkWell(
          onTap: () {
            _showSourcesBottomSheet(context);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentDot == 0 ? 'Sources links' : 'Sources',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Image.asset(
                  'assets/icons/link.png',
                  width: 14,
                  height: 14,
                  color: Colors.white70,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.link,
                    color: Colors.white70,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSourcesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: const BoxDecoration(
            color: Color(0xFF151517),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  // Horizontal Toggle / Segmented Pill Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildTabItem(setSheetState, 0, "Organizations",
                            _selectedSourceTab == 0),
                        const SizedBox(width: 12),
                        _buildTabItem(setSheetState, 1, "Experts",
                            _selectedSourceTab == 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: _selectedSourceTab == 0
                          ? _buildOrganizationsTab(context, setSheetState)
                          : _buildExpertsTab(context, setSheetState),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabItem(
      StateSetter setSheetState, int tabIndex, String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        setSheetState(() {
          _selectedSourceTab = tabIndex;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white10,
          borderRadius: BorderRadius.circular(24),
          border: isActive ? null : Border.all(color: Colors.white12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationsTab(
      BuildContext context, StateSetter setSheetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Organizational Sources",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Forbes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Forbes is an American business magazine founded by B. C. Forbes in 1917. It has been owned by the Hong Kong-based investment group Integrated Whale Media Investments since 2014. Its chairman and editor-in-chief is Steve Forbes, while Sherry Phillips has been CEO since January 2025. The company is headquartered in Jersey City, New Jersey.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SourcesWebViewPage(
                  title: "Forbes",
                  url: "https://forbes.com",
                ),
              ),
            );
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Visit Website",
                style: TextStyle(
                  color: Color(0xFFE4A15D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.north_east, color: Color(0xFFE4A15D), size: 14),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E21),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _isHarvardExpanded ? const Color(0xFFE4A15D) : Colors.white10,
              width: _isHarvardExpanded ? 1.0 : 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setSheetState(() {
                    _isHarvardExpanded = !_isHarvardExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Harvard Medical School",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        _isHarvardExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isHarvardExpanded) ...[
                const Divider(color: Colors.white10, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Extracted insight:",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Clinical findings detailing how daily meditation physically lowers resting cortisol levels, shifting the body's baseline response from anxiety to clarity.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SourcesWebViewPage(
                                title: "Harvard Medical School",
                                url: "https://hms.harvard.edu",
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "View clinical summary",
                              style: TextStyle(
                                color: Color(0xFFE4A15D),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.north_east,
                                color: Color(0xFFE4A15D), size: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpertsTab(BuildContext context, StateSetter setSheetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Expert Sources",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Name",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/sandy_wild.png',
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 220,
              color: Colors.white10,
              child: const Icon(Icons.person, color: Colors.white30, size: 64),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "About Name:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla rhoncus sem eros, quis feugiat libero tincidunt et. Suspendisse tempor dui et tincidunt aliquet. Vestibulum sit amet turpis non nisi dictum dignissim. Vivamus lacinia ante in erat lacinia, eget viverra leo ultrices. Nam vel interdum nisi. Sed eget tristique ex. Donec auctor, ipsum vel porta ornare, ex nisi sagittis tortor, non sagittis purus ligula molestie sapien.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SourcesWebViewPage(
                  title: "Expert Bio",
                  url: "https://example.com/expert",
                ),
              ),
            );
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Learn More",
                style: TextStyle(
                  color: Color(0xFFE4A15D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.north_east, color: Color(0xFFE4A15D), size: 13),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E21),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isApaExpanded ? const Color(0xFF4CA6FF) : Colors.white10,
              width: _isApaExpanded ? 1.0 : 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setSheetState(() {
                    _isApaExpanded = !_isApaExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "American Psychological Association",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        _isApaExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isApaExpanded) ...[
                const Divider(color: Colors.white10, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Extracted insight:",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Research demonstrating how regular mindfulness meditation strengthens neural pathways, significantly improving the brain's ability to refocus attention after distractions",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SourcesWebViewPage(
                                title: "American Psychological Association",
                                url: "https://www.apa.org",
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Read full article",
                              style: TextStyle(
                                color: Color(0xFFE4A15D),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.north_east,
                                color: Color(0xFFE4A15D), size: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Meditation Carousel Stateful Widget ───────────────────────────────────────────

class MeditationCarousel extends StatefulWidget {
  final VoidCallback? onFinished;

  const MeditationCarousel({super.key, this.onFinished});

  @override
  State<MeditationCarousel> createState() => _MeditationCarouselState();
}

class _MeditationCarouselState extends State<MeditationCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Video state for Slide 2
  bool _isVideoBuffering = false;
  bool _isVideoPlaying = false;

  // Audio state for Slide 3
  bool _isForestPlaying = false;
  double _forestVolume = 0.5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF151517),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carousel Slider Area
          SizedBox(
            height: 400,
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildSlide1(),
                _buildSlide2(),
                _buildSlide3(),
                _buildSlide4(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Page indicators (Dots) and Sources row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Pagination dots matching the mockup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 8 : 6,
                      height: isActive ? 8 : 6,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Sources button pill matching exactly
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _showSourcesBottomSheet(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == 0 ? 'Sources links' : 'Sources',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Image.asset(
                              'assets/icons/link.png',
                              width: 14,
                              height: 14,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 1 Layout
  Widget _buildSlide1() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "If you would like to explore, I have curated a few brief teachings from respected masters of inner peace",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
          ),
          const Spacer(),
          _buildYouTubeVideoMockup(),
        ],
      ),
    );
  }

  // Slide 2 Layout (Exactly like Image 1!)
  Widget _buildSlide2() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 3 - If your mind wanders, let the thought pass like a cloud",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4),
          ),
          const SizedBox(height: 10),
          const Text(
            "Step 4 - Gently bring your focus back to the present moment",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4),
          ),
          const SizedBox(height: 14),
          const Text(
            "If you would like to explore, I have curated a few brief teachings from respected masters of inner peace",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
          ),
          const Spacer(),

          // YouTube video mockup block
          _buildYouTubeVideoMockup(),
        ],
      ),
    );
  }

  Widget _buildYouTubeVideoMockup() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video Player Box
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video thumbnail (our beautiful generated image)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    'assets/images/mindful_breathing.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // Play overlay
                if (!_isVideoPlaying)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVideoBuffering = true;
                        });
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          if (mounted) {
                            setState(() {
                              _isVideoBuffering = false;
                              _isVideoPlaying = true;
                            });
                          }
                        });
                      },
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: _isVideoBuffering
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      color: Colors.black54,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isVideoPlaying = false;
                              });
                            },
                            child: const Icon(Icons.pause,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: LinearProgressIndicator(
                              value: 0.15,
                              backgroundColor: Colors.white24,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "0:45 / 5:00",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Metadata Row (YouTube layout)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mystic world avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/noorva_guide.png', // Reusing monk as avatar
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mindful breathing in 5 minutes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Mystic World • 100K Views • 5 years ago",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // YouTube Red Logo
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white54, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: const Color(0xFF1E1E21),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  elevation: 12,
                  onSelected: (val) {
                    if (val == 'share') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Video shared successfully!')),
                      );
                    } else if (val == 'report') {
                      _showReportContentDialog(context);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, color: Colors.white70, size: 18),
                          SizedBox(width: 12),
                          Text('Share',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Divider(height: 1, color: AppColors.borderLight),
                          Row(
                            children: [
                              Icon(Icons.report_problem_outlined,
                                  color: Colors.white70, size: 18),
                              SizedBox(width: 12),
                              Text('Report an Issue',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3 Layout
  Widget _buildSlide3() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 5 - Scan your body for any tension and consciously release it",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4),
          ),
          const SizedBox(height: 10),
          const Text(
            "Step 6 - Rest in the silence between your thoughts",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4),
          ),
          const SizedBox(height: 14),
          const Text(
            "A quiet mind is not the absence of thoughts, but the space around them. Allow yourself to just be.",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
          ),
          const Spacer(),
          // Audio Player Volume/Control block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isForestPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _isForestPlaying = !_isForestPlaying;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Forest Ambient Sounds",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Slider(
                  value: _forestVolume,
                  onChanged: (val) {
                    setState(() {
                      _forestVolume = val;
                    });
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // Slide 4 Layout
  Widget _buildSlide4() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Step 7 - Gently bring your awareness back to the room",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4),
          ),
          const SizedBox(height: 10),
          const Text(
            "Step 8 - Open your eyes when you are ready, carrying this peace with you",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4),
          ),
          const SizedBox(height: 14),
          const Text(
            "Congratulations! You have completed your first trial session. Tomorrow morning at 6:55 AM, we will anchor this habit together.",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
          ),
          const Spacer(),
          // Large White Submit button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
            ),
            onPressed: widget.onFinished,
            child: const Text(
              "Finish & Register Goal",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Global Helper for Report Content Dialog ─────────────────────────────────

void _showReportContentDialog(BuildContext context) {
  int selectedValue = 0;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Report Content",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildReportDialogOption(
                    index: 0,
                    title: "Copyright Infringement",
                    subtitle: "Report unlawful use of copyright-protected work",
                    isSelected: selectedValue == 0,
                    onTap: () => setDialogState(() => selectedValue = 0),
                  ),
                  const SizedBox(height: 12),
                  _buildReportDialogOption(
                    index: 1,
                    title: "Court Order",
                    subtitle:
                        "Report content that a court decision has determined is unlawful",
                    isSelected: selectedValue == 1,
                    onTap: () => setDialogState(() => selectedValue = 1),
                  ),
                  const SizedBox(height: 12),
                  _buildReportDialogOption(
                    index: 2,
                    title: "Other",
                    subtitle:
                        "Report content for a legal reason not listed above (for example, content violating local anti-terrorism or hate speech laws)",
                    isSelected: selectedValue == 2,
                    onTap: () => setDialogState(() => selectedValue = 2),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report submitted successfully'),
                          backgroundColor: Color(0xFF2A2A2D),
                        ),
                      );
                    },
                    child: const Text(
                      "Submit",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildReportDialogOption({
  required int index,
  required String title,
  required String subtitle,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white24 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: RadioDot(selected: isSelected),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Sources Bottom Sheet (shared top-level) ───────────────────────────────────

void _showSourcesBottomSheet(BuildContext context) {
  int selectedSourceTab = 0;
  bool isHarvardExpanded = true;
  bool isApaExpanded = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        height: MediaQuery.of(ctx).size.height * 0.82,
        decoration: const BoxDecoration(
          color: Color(0xFF151517),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: StatefulBuilder(
          builder: (BuildContext ctx2, StateSetter setSheetState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildSourcesTabItem(
                        'Organizations',
                        selectedSourceTab == 0,
                        () => setSheetState(() => selectedSourceTab = 0),
                      ),
                      const SizedBox(width: 12),
                      _buildSourcesTabItem(
                        'Experts',
                        selectedSourceTab == 1,
                        () => setSheetState(() => selectedSourceTab = 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: selectedSourceTab == 0
                        ? _buildSourcesOrganizationsContent(
                            ctx2,
                            isHarvardExpanded,
                            () => setSheetState(
                                () => isHarvardExpanded = !isHarvardExpanded),
                          )
                        : _buildSourcesExpertsContent(
                            ctx2,
                            isApaExpanded,
                            () => setSheetState(
                                () => isApaExpanded = !isApaExpanded),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Widget _buildSourcesTabItem(
    String title, bool isActive, VoidCallback onSelect) {
  return GestureDetector(
    onTap: onSelect,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white10,
        borderRadius: BorderRadius.circular(24),
        border: isActive ? null : Border.all(color: Colors.white12),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}

Widget _buildSourcesOrganizationsContent(
  BuildContext context,
  bool isHarvardExpanded,
  VoidCallback onHarvardToggle,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Organizational Sources",
        style: TextStyle(
          color: Colors.white38,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        "Forbes",
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          fontFamily: 'serif',
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        "Forbes is an American business magazine founded by B. C. Forbes in 1917. It has been owned by the Hong Kong-based investment group Integrated Whale Media Investments since 2014. Its chairman and editor-in-chief is Steve Forbes, while Sherry Phillips has been CEO since January 2025. The company is headquartered in Jersey City, New Jersey.",
        style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 16),
      InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SourcesWebViewPage(
                title: "Forbes", url: "https://forbes.com"),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Visit Website",
              style: TextStyle(
                  color: Color(0xFFE4A15D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Icon(Icons.north_east, color: Color(0xFFE4A15D), size: 14),
          ],
        ),
      ),
      const SizedBox(height: 32),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E21),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHarvardExpanded ? const Color(0xFFE4A15D) : Colors.white10,
            width: isHarvardExpanded ? 1.0 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onHarvardToggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Harvard Medical School",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      isHarvardExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isHarvardExpanded) ...[
              const Divider(color: Colors.white10, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Extracted insight:",
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Clinical findings detailing how daily meditation physically lowers resting cortisol levels, shifting the body's baseline response from anxiety to clarity.",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SourcesWebViewPage(
                            title: "Harvard Medical School",
                            url: "https://hms.harvard.edu",
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "View clinical summary",
                            style: TextStyle(
                                color: Color(0xFFE4A15D),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.north_east,
                              color: Color(0xFFE4A15D), size: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

Widget _buildSourcesExpertsContent(
  BuildContext context,
  bool isApaExpanded,
  VoidCallback onApaToggle,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Expert Sources",
        style: TextStyle(
          color: Colors.white38,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        "Name",
        style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/sandy_wild.png',
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: double.infinity,
            height: 220,
            color: Colors.white10,
            child: const Icon(Icons.person, color: Colors.white30, size: 64),
          ),
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        "About Name:",
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla rhoncus sem eros, quis feugiat libero tincidunt et. Suspendisse tempor dui et tincidunt aliquet. Vestibulum sit amet turpis non nisi dictum dignissim. Vivamus lacinia ante in erat lacinia, eget viverra leo ultrices. Nam vel interdum nisi. Sed eget tristique ex. Donec auctor, ipsum vel porta ornare, ex nisi sagittis tortor, non sagittis purus ligula molestie sapien.",
        style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
      ),
      const SizedBox(height: 16),
      InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SourcesWebViewPage(
                title: "Expert Bio", url: "https://example.com/expert"),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Learn More",
              style: TextStyle(
                  color: Color(0xFFE4A15D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Icon(Icons.north_east, color: Color(0xFFE4A15D), size: 13),
          ],
        ),
      ),
      const SizedBox(height: 32),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E21),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isApaExpanded ? const Color(0xFF4CA6FF) : Colors.white10,
            width: isApaExpanded ? 1.0 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onApaToggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "American Psychological Association",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      isApaExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isApaExpanded) ...[
              const Divider(color: Colors.white10, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Extracted insight:",
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Research demonstrating how regular mindfulness meditation strengthens neural pathways, significantly improving the brain's ability to refocus attention after distractions",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SourcesWebViewPage(
                            title: "American Psychological Association",
                            url: "https://www.apa.org",
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Read full article",
                            style: TextStyle(
                                color: Color(0xFFE4A15D),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.north_east,
                              color: Color(0xFFE4A15D), size: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

// ── Precise Search Custom Widgets ──────────────────────────────────────────────

class PreciseSearchLoadingWidget extends StatefulWidget {
  final VoidCallback onFinished;
  const PreciseSearchLoadingWidget({super.key, required this.onFinished});

  @override
  State<PreciseSearchLoadingWidget> createState() =>
      _PreciseSearchLoadingWidgetState();
}

class _PreciseSearchLoadingWidgetState
    extends State<PreciseSearchLoadingWidget> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _currentStep = 1);
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) {
            setState(() => _currentStep = 2);
            Future.delayed(const Duration(milliseconds: 1800), () {
              if (mounted) {
                widget.onFinished();
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep("Filtering out lifestyle blogs...", _currentStep >= 0),
        if (_currentStep >= 0) _buildDivider(_currentStep >= 1),
        _buildStep("Extracting verified health routines...", _currentStep >= 1),
        if (_currentStep >= 1) _buildDivider(_currentStep >= 2),
        _buildStep("Scanning neurobiology journals and clinical sleep data",
            _currentStep >= 2),
      ],
    );
  }

  Widget _buildStep(String text, bool active) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: active ? 1.0 : 0.25,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildDivider(bool active) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: active ? 1.0 : 0.25,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(
          "|",
          style: TextStyle(
            color: Colors.white24,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class AccordionWidget extends StatefulWidget {
  final String title;
  final Widget content;
  const AccordionWidget(
      {super.key, required this.title, required this.content});

  @override
  State<AccordionWidget> createState() => _AccordionWidgetState();
}

class _AccordionWidgetState extends State<AccordionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white30,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.content,
            ),
        ],
      ),
    );
  }
}
