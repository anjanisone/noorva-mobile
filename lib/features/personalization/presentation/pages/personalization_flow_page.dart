import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/radio_dot.dart';
import '../../../../core/widgets/thought_bubble.dart';
import '../../../../core/widgets/noorva_mascot.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PersonalizationFlowPage
// Steps:
//   0 → Welcome
//   1 → What should I call you?
//   2 → Define how expressive and interactive Noorva should be?
//   3 → How do you want Noorva to communicate
//   4 → Personalize notification experience
// ─────────────────────────────────────────────────────────────────────────────

class PersonalizationFlowPage extends StatefulWidget {
  final bool isProfileMode;
  const PersonalizationFlowPage({super.key, this.isProfileMode = false});

  @override
  State<PersonalizationFlowPage> createState() =>
      _PersonalizationFlowPageState();
}

class _PersonalizationFlowPageState extends State<PersonalizationFlowPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _guidanceController = TextEditingController();
  String _selectedNotification = '';
  String _selectedCommunication = '';
  String _selectedExpressiveness = '';

  // Bubble animation
  late AnimationController _bubbleController;
  late Animation<double> _bubbleOpacity;
  late Animation<Offset> _bubbleSlide;

  // ── Thought bubble content ──────────────────────────────────────────────
  // Shown BEFORE the user makes a selection on each step
  final List<String> _hintMessages = [
    'Welcome! I am so happy you are here.', // Step 0: Welcome bubble
    'Names matter. This helps me speak to you more personally.',
    'How often I check in can shape your whole day.',
    'The way I talk to you matters as much as what I say.',
    'This decides how closely I walk with you on your journey.',
  ];

  // Shown AFTER the user makes a selection
  final List<String> _feedbackMessages = [
    '', // Step 0
    "That's a\nwonderful name. I'll\nremember it.",
    'That one feels calming - good instinct.',
    'Good choice. Sometimes words are best spoken, sometimes read',
    'Interesting choice. Not everyone chooses this — it tells me a lot about you',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isProfileMode) {
      _currentStep = 2;
    }
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bubbleOpacity = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOut,
    );
    _bubbleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOut,
    ));

    _animateBubbleIn();
  }

  void _animateBubbleIn() {
    _bubbleController.reset();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _bubbleController.forward();
    });
  }

  void _triggerSelectionBubble() {
    _bubbleController.reset();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _bubbleController.forward();
    });
  }

  void _nextStep() {
    if (_currentStep < 6) {
      setState(() => _currentStep++);
      _animateBubbleIn();
    } else {
      if (widget.isProfileMode) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  void _prevStep() {
    if (widget.isProfileMode && _currentStep == 2) {
      Navigator.pop(context);
      return;
    }
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _bubbleController.reset();
      if (_currentStep > 0) _animateBubbleIn();
    }
  }

  String get _bubbleText {
    switch (_currentStep) {
      case 0:
        return _hintMessages[0];
      case 1:
        return _nameController.text.isNotEmpty
            ? _feedbackMessages[1]
            : _hintMessages[1];
      case 2:
        return _selectedExpressiveness.isNotEmpty
            ? _feedbackMessages[2]
            : _hintMessages[2];
      case 3:
        return _selectedCommunication.isNotEmpty
            ? _feedbackMessages[3]
            : _hintMessages[3];
      case 4:
        return _selectedNotification.isNotEmpty
            ? _feedbackMessages[4]
            : _hintMessages[4];
      default:
        return '';
    }
  }

  bool get _isStepCompleted {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _nameController.text.trim().isNotEmpty;
      case 2:
        return _selectedExpressiveness.isNotEmpty;
      case 3:
        return _selectedCommunication.isNotEmpty;
      case 4:
        return _selectedNotification.isNotEmpty;
      case 5:
        return _goalsController.text.trim().isNotEmpty;
      case 6:
        return _guidanceController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _nameController.dispose();
    _goalsController.dispose();
    _guidanceController.dispose();
    super.dispose();
  }

  // ── Step Specific Configs ──────────────────────────────────────────────
  final List<String> _stepImages = [
    'assets/images/personalization.png',
    'assets/images/personalization.png',
    'assets/images/personalization.png',
    'assets/images/personalization.png',
    'assets/images/personalization.png',
  ];

  double _getStepImageHeight(int step, Size size) {
    switch (step) {
      case 0:
        return size.height * 0.38;
      case 1:
        return size.height * 0.32;
      case 2:
        return size.height * 0.18;
      case 3:
        return size.height * 0.22;
      case 4:
        return size.height * 0.26;
      default:
        return size.height * 0.20;
    }
  }

  double _getStepImageRight(int step) {
    switch (step) {
      case 0:
        return 0;
      case 1:
        return 30;
      case 2:
        return 40;
      case 3:
        return 20;
      case 4:
        return 35;
      default:
        return 40;
    }
  }

  TextStyle get _unifiedTitleStyle => GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      );

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_currentStep >= 5 && !widget.isProfileMode) {
      return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: _buildChatStep(context, size),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Character ────────────────────────────────────────────────────
          if (_currentStep < 5)
            if (_currentStep == 0)
              // Welcome: centered horizontally
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: NoorvaMascot(
                      mood: MascotMood.hello,
                      reactToTyping: true,
                      height: _getStepImageHeight(0, size),
                      fallbackAsset: _stepImages[0],
                    ),
                  ),
                ),
              )
            else
              // All other steps (1-4): right side with space
              Positioned(
                bottom: 0,
                right: _getStepImageRight(_currentStep),
                child: IgnorePointer(
                  child: NoorvaMascot(
                    mood: MascotMood.explaining,
                    reactToTyping: true,
                    height: _getStepImageHeight(_currentStep, size),
                    fallbackAsset: _stepImages[_currentStep],
                  ),
                ),
              ),

          // ── Background Dots (Different for each step) ────────────────────
          // if (_currentStep != 0) ..._buildStepDots(_currentStep, size),

          // ── Scrollable content area ──────────────────────────────────────
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button (Step 1 matching Figma)
                    if (_currentStep > 0) ...[
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, top: 12, right: 20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _prevStep,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFF1C1C1E), // Solid dark grey per Figma
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    width: 1.2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else
                      const SizedBox(height: 60),

                    // Main step card with Animated Transition
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<int>(_currentStep),
                          child: _buildCurrentStep(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Thought bubble (All steps) ───────────────────────────────────
          // ── Thought bubble (Individually defined for each step) ────────────────
          _buildStepBubble(_currentStep, size),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChatStep(BuildContext context, Size size) {
    bool isStep5 = _currentStep == 5;
    String message = isStep5 
        ? "Is there something you want to learn, a goal you want to achieve, or anything you're currently working on? Take your time - there's no rush. You can share as many things as you like"
        : "That's Wonderful! All goals and activities you mentioned will keep the body and mind fit. Do you need any guidance to learn them?";
    TextEditingController controller = isStep5 ? _goalsController : _guidanceController;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 12, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _prevStep,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                // Right side placeholder to keep the back button on the left
                const SizedBox(width: 44),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Character
                  SizedBox(
                    height: size.height * 0.45,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/blue circle_behind_oldman.png',
                          height: size.height * 0.40,
                          fit: BoxFit.contain,
                        ),
                        NoorvaMascot(
                          mood: MascotMood.explaining,
                          reactToTyping: true,
                          height: size.height * 0.45,
                          fallbackAsset: 'assets/images/white_dress_oldman.png',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message Bubble
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Input Area
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Text Field with Glowing Border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter response',
                      hintStyle: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF161618),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.blue.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.blue.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                           if (controller.text.isNotEmpty) _nextStep();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: controller.text.isNotEmpty
                                ? const Color(0xFF1C1C1E)
                                : Colors.transparent,
                            child: Icon(
                              Icons.arrow_upward, 
                              color: controller.text.isNotEmpty
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.2),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onSubmitted: (_) {
                       if (controller.text.isNotEmpty) _nextStep();
                    },
                    onChanged: (val) => setState((){}),
                  ),
                ),
                
                // Bottom Icons (Mic, Chat, Close)
                if (MediaQuery.of(context).viewInsets.bottom == 0) ...[
                   const SizedBox(height: 24),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       // Mic Icon
                       Container(
                         width: 50,
                         height: 50,
                         decoration: BoxDecoration(
                           color: Colors.white.withValues(alpha: 0.05),
                           shape: BoxShape.circle,
                           border: Border.all(
                             color: Colors.white.withValues(alpha: 0.1),
                           ),
                         ),
                         child: const Icon(Icons.mic_none, color: Colors.white),
                       ),
                       
                       // Center glowing icon
                       Container(
                         width: 60,
                         height: 60,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                           boxShadow: [
                             BoxShadow(
                               color: Colors.blue.withValues(alpha: 0.5),
                               blurRadius: 15,
                               spreadRadius: 4,
                             ),
                           ],
                         ),
                         child: const Icon(
                           Icons.chat_bubble_outline,
                           color: Colors.black,
                           size: 26,
                         ),
                       ),
                       
                       // Close Icon
                       GestureDetector(
                         onTap: () {
                           Navigator.pushReplacementNamed(context, AppRoutes.home);
                         },
                         child: Container(
                           width: 50,
                           height: 50,
                           decoration: BoxDecoration(
                             color: Colors.white.withValues(alpha: 0.05),
                             shape: BoxShape.circle,
                             border: Border.all(
                               color: Colors.white.withValues(alpha: 0.1),
                             ),
                           ),
                           child: const Icon(Icons.close, color: Colors.white),
                         ),
                       ),
                     ],
                   ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildNameStep();
      case 2:
        return _buildExpressivenessStep();

      case 3:
        return _buildCommunicationStep();
      case 4:
        return _buildNotificationStep();
      case 5:
        return _buildGoalsProfileStep();
      case 6:
        return _buildGuidanceProfileStep();

      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 0 — Welcome
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWelcomeStep() {
    return CrystalCard(
      title: 'Welcome to Noorva!!',
      titleStyle: _unifiedTitleStyle,
      description:
          'My role is to guide your productivity and wellness. To ensure my advice actually fits your reality, I need to understand a little bit about you. Shall we set up your profile?',
      child: Column(
        children: [
          const SizedBox(height: 12),
          NoorvaButton(text: 'Set up Profile', onPressed: _nextStep),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.home),
            child: Text(
              'Skip',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1 — What should I call you?
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildNameStep() {
    return CrystalCard(
      title: 'What should I call you?',
      titleStyle: _unifiedTitleStyle,
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            onChanged: (val) {
              setState(() {});
              if (val.trim().isNotEmpty) _triggerSelectionBubble();
            },
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 16,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          NoorvaButton(
            text: 'Next',
            onPressed: _isStepCompleted ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STEP 2 — Personalize notification experience
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildNotificationStep() {
    const options = ['Daily', 'Weekly', 'Whenever helpful'];
    return CrystalCard(
      title: 'Personalize notification experience',
      titleStyle: _unifiedTitleStyle,
      child: Column(
        children: [
          ...options.map((opt) => _buildSelectionItem(
                title: opt,
                isSelected: _selectedNotification == opt,
                onTap: () {
                  setState(() => _selectedNotification = opt);
                  _triggerSelectionBubble();
                },
              )),
          const SizedBox(height: 24),
          NoorvaButton(
            text: 'Next',
            onPressed: _isStepCompleted ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STEP 3 — How do you want Noorva to communicate
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCommunicationStep() {
    const options = ['Voice + Text', 'Voice Only', 'Text Only'];
    return CrystalCard(
      title: 'How do you want Noorva to communicate?',
      titleStyle: _unifiedTitleStyle,
      child: Column(
        children: [
          ...options.map((opt) => _buildSelectionItem(
                title: opt,
                isSelected: _selectedCommunication == opt,
                onTap: () {
                  setState(() => _selectedCommunication = opt);
                  _triggerSelectionBubble();
                },
              )),
          const SizedBox(height: 24),
          NoorvaButton(
            text: 'Next',
            onPressed: _isStepCompleted ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STEP 4 — Define expressiveness
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildExpressivenessStep() {
    const options = [
      ('High', 'Very interactive, expressive, frequent engagement'),
      ('Medium', 'Balanced interaction'),
      ('Default', 'Calm, minimal guidance'),
    ];
    return CrystalCard(
      title: 'Define how expressive and interactive Noorva should be?',
      titleStyle: _unifiedTitleStyle,
      child: Column(
        children: [
          ...options.map((opt) => _buildSelectionItem(
                title: opt.$1,
                subtitle: opt.$2,
                isSelected: _selectedExpressiveness == opt.$1,
                onTap: () {
                  setState(() => _selectedExpressiveness = opt.$1);
                  _triggerSelectionBubble();
                },
              )),
          const SizedBox(height: 24),
          NoorvaButton(
            text: 'Finish',
            onPressed: _isStepCompleted ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STEP 5 — Goals (Profile Preferences Flow only)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGoalsProfileStep() {
    return CrystalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const NoorvaMascot(
            mood: MascotMood.explaining,
            reactToTyping: true,
            height: 120,
            fallbackAsset: 'assets/images/personalization.png',
          ),
          const SizedBox(height: 20),
          Text(
            'Now, tell me how I can guide or assist you?\nIs there something you want to learn, a goal you want to achieve, or anything you\'re currently working on?\nTake your time - there\'s no rush. You can share as many things as you like',
            textAlign: TextAlign.start,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _goalsController,
            onChanged: (val) {
              setState(() {});
            },
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Enter your goals',
              hintStyle: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 16,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          NoorvaButton(
            text: 'Submit',
            onPressed: _isStepCompleted ? _nextStep : null,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _goalsController.clear();
              _nextStep();
            },
            child: Text(
              'Skip',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STEP 6 — Guidance (Profile Preferences Flow only)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGuidanceProfileStep() {
    return CrystalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const NoorvaMascot(
            mood: MascotMood.explaining,
            reactToTyping: true,
            height: 120,
            fallbackAsset: 'assets/images/personalization.png',
          ),
          const SizedBox(height: 20),
          Text(
            'That\'s Wonderful! All goals and activities you mentioned will keep the body and mind fit. Do you need any guidance to learn them?',
            textAlign: TextAlign.start,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _guidanceController,
            onChanged: (val) {
              setState(() {});
            },
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Enter response',
              hintStyle: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 16,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          NoorvaButton(
            text: 'Finish',
            onPressed: _isStepCompleted ? _nextStep : null,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _guidanceController.clear();
              _nextStep();
            },
            child: Text(
              'Skip',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Shared Selection Item Widget — Matches Premium Figma Feel
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSelectionItem({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 5,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      maxLines: 5,
                      subtitle,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            RadioDot(selected: isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBubble(int step, Size size) {
    if (_bubbleText.isEmpty || step == 0) return const SizedBox.shrink();

    // Default values
    double left = 80;
    double bottom = _getBubbleBottom(step, size);
    ThoughtBubbleDotsAlignment dotsAlignment = ThoughtBubbleDotsAlignment.right;
    double maxWidth = size.width * 0.55;

    // ── Separate Definitions for Each Stepper ──────────────────────────────
    switch (step) {
      case 1: // Name Step
        left = 60;
        dotsAlignment = ThoughtBubbleDotsAlignment.right;
        break;
      case 2: // Notification Step
        left = 110;
        dotsAlignment = ThoughtBubbleDotsAlignment.right;
        break;
      case 3: // Communication Step
        left = 110;
        dotsAlignment = ThoughtBubbleDotsAlignment.right;
        break;
      case 4: // Expressiveness Step
        left = 90;
        dotsAlignment = ThoughtBubbleDotsAlignment.right;
        break;
    }

    return Positioned(
      bottom: bottom,
      left: left,
      child: FadeTransition(
        opacity: _bubbleOpacity,
        child: SlideTransition(
          position: _bubbleSlide,
          child: ThoughtBubble(
            text: _bubbleText,
            maxWidth: maxWidth,
            dotsAlignment: dotsAlignment,
          ),
        ),
      ),
    );
  }

  double _getBubbleBottom(int step, Size size) {
    switch (step) {
      case 0:
        return size.height * 0.30;
      case 1:
        return size.height * 0.30;
      case 2:
        return size.height * 0.20;
      case 3:
        return size.height * 0.24;
      case 4:
        return size.height * 0.28;
      default:
        return size.height * 0.20;
    }
  }
}

