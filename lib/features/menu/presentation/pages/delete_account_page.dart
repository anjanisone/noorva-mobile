import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  int _currentStep = 1; // Step 1: Willingness, Step 2: Reasons, Step 3: Export/Confirm, Step 4: Farewell

  // Reasons list for Step 2
  final List<Map<String, dynamic>> _reasons = [
    {
      'label': 'My natural rhythm is strong enough now without a guide',
      'selected': false,
    },
    {
      'label': 'The architecture felt too rigid for my daily life',
      'selected': false,
    },
    {
      'label': 'I am stepping away from digital routines entirely',
      'selected': false,
    },
    {
      'label': 'Experiencing issues and bugs',
      'selected': false,
    },
    {
      'label': "I don't like the app",
      'selected': false,
    },
    {
      'label': 'Privacy Concerns',
      'selected': false,
    },
    {
      'label': 'Others',
      'selected': false,
    },
  ];

  final _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    if (_currentStep == 4) {
      // Farewell auto-navigation to Login screen after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
        }
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showHeader = _currentStep < 4;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Standard Custom Header (Steps 1, 2, 3)
            if (showHeader)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _previousStep,
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
                    Expanded(
                      child: Text(
                        'Delete Account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer
                  ],
                ),
              ),

            // Active Viewport content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Willingness();
      case 2:
        return _buildStep2Reasons();
      case 3:
        return _buildStep3ExportWarning();
      case 4:
        return _buildStep4Farewell();
      default:
        return _buildStep1Willingness();
    }
  }

  // ── Step 1: Initial Dismantle Prompt ──────────────────────────────────────
  Widget _buildStep1Willingness() {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      physics: const BouncingScrollPhysics(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dismantle Card
          CrystalCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            borderRadius: 32.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24), // spacing for overlay avatar
                Text(
                  'You are choosing to dismantle your workspace. Before we sever the connection, would you share why this environment no longer serves your rhythm? Your insight helps refine the space for others',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),
                NoorvaButton(
                  text: 'Yes, I am willing',
                  onPressed: _nextStep,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    // Skip feedback and go straight to Step 3 warning
                    setState(() {
                      _currentStep = 3;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'Skip and Continue',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Peeking tiny wizard (Screenshot 1 & 2)
          Positioned(
            top: -30,
            left: 20,
            child: Image.asset(
              'assets/images/noorva_home.png',
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Multiple Choice Reasons ────────────────────────────────────────
  Widget _buildStep2Reasons() {
    final bool isOthersSelected = _reasons.last['selected'] == true;

    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      physics: const BouncingScrollPhysics(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card
          CrystalCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            borderRadius: 32.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // spacing for overlay avatar
                Text(
                  'Let me know the reason for this departure',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // Multi-select option rows
                ...List.generate(_reasons.length, (index) {
                  final reason = _reasons[index];
                  final bool isSelected = reason['selected'] == true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _reasons[index]['selected'] = !isSelected;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                                color: isSelected ? Colors.white : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isSelected
                                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                reason['label'],
                                style: GoogleFonts.outfit(
                                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Extra "Enter your reason" input if "Others" selected
                if (isOthersSelected) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _otherReasonController,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Enter your reason',
                      hintStyle: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.3)),
                      filled: true,
                      fillColor: const Color(0xFF111113),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                NoorvaButton(
                  text: 'Continue',
                  onPressed: _nextStep,
                ),
              ],
            ),
          ),

          // Peeking tiny wizard
          Positioned(
            top: -30,
            left: 20,
            child: Image.asset(
              'assets/images/noorva_home.png',
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Export Ledger & Warning ───────────────────────────────────────
  Widget _buildStep3ExportWarning() {
    return SingleChildScrollView(
      key: const ValueKey('step3'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Dialogue card
          CrystalCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            borderRadius: 32.0,
            child: Column(
              children: [
                Text(
                  'Your reasoning is noted and respected. Once you step through this door, your foundation, your established rhythms, and our entire shared dialogue will be permanently returned to the void. If there is wisdom in your memory ledger you wish to keep, take it with you now.',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                NoorvaButton(
                  text: 'Export Memory',
                  onPressed: () {
                    // Export dialog simulation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF1E1E22),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        content: Text(
                          'Exporting memory ledger safely...',
                          style: GoogleFonts.outfit(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _nextStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'Continue with account deletion',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Large sad wizard illustration centered below the warning (Screenshot 3)
          Opacity(
            opacity: 0.95,
            child: Image.asset(
              'assets/images/noorva_home.png',
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Farewell screen (Screenshot 4) ──────────────────────────────────
  Widget _buildStep4Farewell() {
    return Container(
      key: const ValueKey('step4'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20), // spacer

          // Bubble dialogue card
          CrystalCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            borderRadius: 24.0,
            child: Text(
              'The foundation is cleared. The tether is severed. May you continue to find the focus and quiet you seek in your next chapter. Farewell.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
          ),

          // Large waving wizard illustration
          Expanded(
            child: Center(
              child: Opacity(
                opacity: 0.95,
                child: Image.asset(
                  'assets/images/noorva_home.png',
                  height: 320,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Little hint showing auto redirect
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Returning to workspace gateway...',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
