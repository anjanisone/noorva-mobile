import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/noorva_button.dart';

class OnboardingSlide {
  final String title;
  final String description;
  final String image;

  OnboardingSlide({
    required this.title,
    this.description = '',
    required this.image,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'INTRO',
      description: '',
      image: 'assets/images/splash_icon.png',
    ),
    OnboardingSlide(
      title: 'Hey! I’m Noorva',
      description:
          'I’m here to guide you, understand you, and grow with you over time.',
      image: 'assets/images/noorva_onboard.png',
    ),
    OnboardingSlide(
      title: 'Your Knowledge Expert',
      description:
          'I don’t just answer - I bring you information from trusted experts. Relevant, trustworthy and personalized to you',
      image: 'assets/images/noorva_onboard.png',
    ),
    OnboardingSlide(
      title: 'Your Assistant',
      description:
          'I don’t just help you plan. Plans are easy. Execution is hard. I help you actually get things done by staying with your every step of the way',
      image: 'assets/images/noorva_onboard.png',
    ),
    OnboardingSlide(
      title: 'Your Smart Reminder',
      description:
          'I don’t just remind you. I remind you at the right time that fits your schedule. With a personalized note attached so you remember not just what to do, but why this task is important to you',
      image: 'assets/images/noorva_onboard.png',
    ),
    OnboardingSlide(
      title: 'Noorva',
      description:
          'I help you think, plan, and move forward. Whether it’s clarifying your goals, planning your day, or working through decisions, I stay with you throughout the process as a companion and assistant',
      image: 'assets/images/noorva_onboard.png',
    ),
    OnboardingSlide(
      title: 'Are you ready to experience Noorva?',
      image: 'assets/images/noorva_onboard.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Content Layer
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40), // Adjusted for card top position

                // Message Area (Card + Dots) - Hidden on Intro slide
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _currentPage == 0 ? 0.0 : 1.0,
                  child: Visibility(
                    visible: _currentPage > 0,
                    maintainState: true,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _OnboardingMessageCard(
                            title: _currentPage == 0
                                ? ''
                                : _slides[_currentPage].title,
                            description: _currentPage == 0
                                ? ''
                                : _slides[_currentPage].description,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDecorativeDots(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Character + Button Area (Stacked for Figma depth effect)
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _slides.length,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // First slide is the branding intro
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                            );
                          }
                          // Standard character slides
                          return Transform.scale(
                            scale: 1.1,
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              _slides[index].image,
                              fit: BoxFit.fitHeight,
                              alignment: Alignment.bottomCenter,
                            ),
                          );
                        },
                      ),

                      // Button placed on top of character's feet
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: NoorvaButton(
                          text: (_currentPage == 0 ||
                                  _currentPage == _slides.length - 1)
                              ? 'Get Started'
                              : 'Next',
                          onPressed: () {
                            if (_currentPage < _slides.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                              );
                            } else {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.login);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeDots() {
    return Column(
      children: [
        // Top Circle (Shifted right)
        Padding(
          padding: const EdgeInsets.only(left: 52), // More pronounced offset
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(0.5), // Rotate the gradient slant
            child: const _CrystalDot(size: 20), // Increased size
          ),
        ),
        const SizedBox(height: 6),
        // Bottom Circle (Shifted left)
        Padding(
          padding: const EdgeInsets.only(right: .5),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateZ(-0.5),
            child: const _CrystalDot(size: 12), // Increased size
          ),
        ),
      ],
    );
  }
}

class _OnboardingMessageCard extends StatelessWidget {
  final String title;
  final String description;

  const _OnboardingMessageCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFF111113),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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
      size: Size(size, size), // Circle shape
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

    // Apply the exact linear gradient requested by user
    borderPaint.shader = ui.Gradient.linear(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.6, size.height),
      [
        Colors.white.withValues(alpha: 0.4), // 4.82%
        Colors.white.withValues(alpha: 0.4), // 38.08%
        Colors.white.withValues(alpha: 0.0001), // 56.68%
        Colors.white.withValues(alpha: 0.4), // 95.1%
      ],
      [0.0482, 0.3808, 0.5668, 0.951],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawOval(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
