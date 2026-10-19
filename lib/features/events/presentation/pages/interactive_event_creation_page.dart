import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/noorva_mascot.dart';
import '../../../../core/widgets/noorva_chat_input.dart';
import '../../../../core/widgets/perched_mascot.dart';

class InteractiveEventCreationPage extends StatefulWidget {
  const InteractiveEventCreationPage({super.key});

  @override
  State<InteractiveEventCreationPage> createState() =>
      _InteractiveEventCreationPageState();
}

class _InteractiveEventCreationPageState
    extends State<InteractiveEventCreationPage> {
  int _flowStep = 0;
  bool _showMenuOverlay = false;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Track checklist completion states
  final Map<String, bool> _checklistStates = {};

  static const List<String> _checklistItems = [
    'Establish boundaries',
    'Clear the active board',
    'Pause automated rhythms',
    'Anchor your essential documents',
    'Prepare the physical space',
    'Pack with intention',
    'Store offline guidance',
  ];

  @override
  void initState() {
    super.initState();
    _inputController.text = 'I am planning to go to London next week on Sunday';
    for (var item in _checklistItems) {
      _checklistStates[item] = false;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      if (_flowStep == 0) {
        _flowStep = 1;
        _inputController.clear();
      } else if (_flowStep == 2) {
        _flowStep = 3;
        _inputController.clear();
      }
      _focusNode.unfocus();
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child:
                      _flowStep == 0 ? _buildInitialState() : _buildChatState(),
                ),
                _buildBottomInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child:
                  const Icon(Icons.chevron_left, color: Colors.white, size: 24),
            ),
          ),
          if (_flowStep > 0)
            const Expanded(
              child: Text(
                'Trip to london next week',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Image.asset(
              'assets/icons/edit.png',
              color: Colors.white,
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Initial State (Step 0) ──────────────────────────────────────────────────

  Widget _buildInitialState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF141416),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Text(
                  'Hey ${context.watch<AuthBloc>().state.user?.name ?? 'User'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'I see that you want to create an event, tell me what type of event and how do you want me to add it to your board?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Thinking bubbles above wizard
              Positioned(
                top: 16,
                child: Column(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Same as Home: cycles idle actions, typing pose while typing.
              const NoorvaMascot(cycleIdle: true, reactToTyping: true),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Chat State (Steps 1+) ───────────────────────────────────────────────────

  Widget _buildChatState() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: _buildChatList()),
        // The chat area ends 8px above the bar (the bar's top margin).
        PerchedMascot(controller: _scrollController, gapToBar: 8),
      ],
    );
  }

  Widget _buildChatList() {
    return ListView(
      controller: _scrollController,
      // Bottom room so the latest message can always be scrolled clear of
      // Noorva standing on the input bar.
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8 + PerchedMascot.height),
      children: [
        // ── Step 1: User message + Noorva first response ──────────────────────
        if (_flowStep >= 1) ...[
          _buildUserMessage(
              'I am planning to go to London next week on Sunday'),
          _buildNoorvaMessage(
            text:
                'A change of environment often brings a shift in perspective. Before you depart for London, we must prepare the board. Tell me—is this journey for deep execution, shared dialogue, or a necessary biological reset?',
            showAvatar: true,
            showActionIcons: false,
            actionWidget: _flowStep == 1
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(
                              () => _showMenuOverlay = !_showMenuOverlay),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Respond to Noorva',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ClipRect(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            onEnd: _scrollToBottom,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, animation) {
                                final slideAnimation = Tween<Offset>(
                                  begin: const Offset(0, -0.08),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: slideAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: _showMenuOverlay
                                  ? _buildMenuOptions()
                                  : const SizedBox(
                                      key: ValueKey('menu-hidden'),
                                      width: double.infinity,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ],

        // ── Step 2: Checklist label + standalone checklist cards ──────────────
        if (_flowStep >= 2) ...[
          // Noorva message with just the label text
          _buildNoorvaMessage(
            text: 'Yes, here is your checklist....',
            showAvatar: true,
            showActionIcons: false,
          ),
          // Standalone checklist cards (NOT inside bubble)
          ..._checklistItems.map((item) => _buildChecklistCard(item)),
          // Action icons row after checklist
          _buildActionIconsRow(),
          const SizedBox(height: 8),
        ],

        // ── Step 3: User's second message + Noorva suspend/keep ───────────────
        if (_flowStep >= 3) ...[
          _buildUserMessage('I will stay in London for a week'),
          _buildNoorvaMessage(
            text:
                'You have unresolved intentions on the board. Carrying them on your journey will divide your focus. Tap to safely suspend them until your return.',
            showAvatar: true,
            showActionIcons: false,
            actionWidget: _flowStep == 3
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _flowStep = 4);
                          _scrollToBottom();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Suspend Tasks',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _flowStep = 5);
                          _scrollToBottom();
                        },
                        child: const Text(
                          'Keep Tasks',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ],

        // ── Step 4: Tasks suspended confirmation ───────────────────────────────
        if (_flowStep >= 4) ...[
          _buildNoorvaMessage(
            text:
                'I have suspended your tasks for next week, so that you could enjoy your trip without any distractions',
            showAvatar: true,
            showActionIcons: true,
          ),
        ],

        // ── Step 5: Keep tasks confirmation ───────────────────────────────────
        if (_flowStep >= 5) ...[
          _buildNoorvaMessage(
            text:
                'Understood. Your tasks will remain active while you\'re in London. I\'ll keep watch so nothing slips through the cracks. Safe travels, ${context.watch<AuthBloc>().state.user?.name ?? 'User'}.',
            showAvatar: true,
            showActionIcons: true,
          ),
        ],
      ],
    );
  }

  // ─── Message Builders ────────────────────────────────────────────────────────

  Widget _buildUserMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 10),
            child: Icon(Icons.copy_outlined, color: Colors.white38, size: 18),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 12),
            child: Image.asset(
              'assets/icons/edit.png',
              color: Colors.white38,
              width: 18,
              height: 18,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141416),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                text,
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

  Widget _buildNoorvaMessage({
    required String text,
    Widget? actionWidget,
    bool showAvatar = true,
    bool showActionIcons = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showAvatar) ...[
            // No mascot on message cards: Noorva stands on the input bar.
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.volume_up_outlined,
                  color: Colors.white38, size: 22),
            ),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                if (actionWidget != null) ...[
                  if (text.isNotEmpty) const SizedBox(height: 20),
                  actionWidget,
                ],
              ],
            ),
          ),
          if (showActionIcons) _buildActionIconsRow(),
        ],
      ),
    );
  }

  // ─── Checklist Builders ───────────────────────────────────────────────────────

  Widget _buildChecklistCard(String item) {
    final isChecked = _checklistStates[item] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => setState(() => _checklistStates[item] = !isChecked),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isChecked
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFF1A1A1C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isChecked
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isChecked ? Colors.white : Colors.white38,
                    width: 1.5,
                  ),
                  color: isChecked ? Colors.white : Colors.transparent,
                ),
                child: isChecked
                    ? const Icon(Icons.check, color: Colors.black, size: 14)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: isChecked ? Colors.white54 : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIconsRow() {
    return const Padding(
      padding: EdgeInsets.only(top: 10, right: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.copy_outlined, color: Colors.white38, size: 20),
          SizedBox(width: 18),
          Icon(Icons.refresh_outlined, color: Colors.white38, size: 20),
          SizedBox(width: 18),
          Icon(Icons.more_horiz, color: Colors.white38, size: 20),
        ],
      ),
    );
  }

  // ─── Response Menu ────────────────────────────────────────────────────────────

  Widget _buildMenuOptions() {
    const options = [
      'Anchor your essential documents',
      'Prepare the physical space',
      'Pack with intention',
      'Store offline guidance',
    ];
    return Column(
      key: const ValueKey('menu-open'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showMenuOverlay = false;
                _flowStep = 2;
                _inputController.text = 'I will stay in London for a week';
              });
              _scrollToBottom();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                option,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Bottom Input Bar ─────────────────────────────────────────────────────────

  Widget _buildBottomInput() {
    final bool isIdle = _flowStep >= 4 || _flowStep == 1;

    // Like the Guide page: send button only while there's text, otherwise
    // the mic / voice buttons.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _inputController,
      builder: (context, value, _) => NoorvaChatInput(
        controller: _inputController,
        focusNode: _focusNode,
        readOnly: isIdle,
        hintText: isIdle ? 'Ask Noorva Anything' : '',
        onSubmitted: (_) => _submitMessage(),
        showSend: !isIdle && value.text.trim().isNotEmpty,
        onSend: _submitMessage,
        pillIconAsset: 'assets/icons/schedules.png',
        pillLabel: 'Events',
        homeStyle: true,
      ),
    );
  }
}
