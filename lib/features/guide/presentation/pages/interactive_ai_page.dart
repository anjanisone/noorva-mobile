import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/noorva_mascot.dart';

class InteractiveAiPage extends StatefulWidget {
  const InteractiveAiPage({super.key});

  @override
  State<InteractiveAiPage> createState() => _InteractiveAiPageState();
}

class _InteractiveAiPageState extends State<InteractiveAiPage> {
  bool _isVoiceMode = false;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white54, size: 20),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.menu),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0, top: 8, bottom: 8),
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.white54, size: 20),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE96565),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1C1C1E), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    // Avatar and Glowing Ring
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/blue circle_behind_oldman.png',
                            fit: BoxFit.contain,
                          ),
                          NoorvaMascot(
                            mood: _isVoiceMode
                                ? MascotMood.listening
                                : _focusNode.hasFocus
                                    ? MascotMood.typing
                                    : MascotMood.hello,
                            fallbackAsset: 'assets/images/white_dress_oldman.png',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Chat Bubble
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF202022),
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          _isVoiceMode
                              ? "Hey ${context.watch<AuthBloc>().state.user?.name ?? 'User'}! I've been thinking a lot about hobbies lately. My absolute favorite way to unwind is going for an evening walk. What about you?"
                              : "A beautiful way to sharpen the mind and find silence. What kind of books are you drawn to right now, ${context.watch<AuthBloc>().state.user?.name ?? 'User'}? Tell me, so I understand how you prefer to rest your mind",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text Input
                  if (!_isVoiceMode) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                          color: _focusNode.hasFocus ? const Color(0xFF4CA6FF) : Colors.white10,
                          width: _focusNode.hasFocus ? 2.0 : 1.0,
                        ),
                        boxShadow: _focusNode.hasFocus
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4CA6FF).withValues(alpha: 0.3),
                                  blurRadius: 12.0,
                                  spreadRadius: 2.0,
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Enter response',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Icon(Icons.send, color: Colors.white10.withValues(alpha: 0.1), size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVoiceMode = !_isVoiceMode;
                          });
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Center(
                            child: Image.asset(
                              _isVoiceMode ? 'assets/icons/chat history.png' : 'assets/icons/mike.png',
                              width: 24,
                              height: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Center Button
                      GestureDetector(
                        onTap: () {
                          // Action for center button
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CA6FF).withValues(alpha: 0.6),
                                blurRadius: 24.0,
                                spreadRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              _isVoiceMode ? 'assets/icons/mike.png' : 'assets/icons/chat history.png',
                              width: 28,
                              height: 28,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      // Right Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
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
      ),
    );
  }
}
