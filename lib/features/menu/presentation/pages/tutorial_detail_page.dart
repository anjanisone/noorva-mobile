import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class TutorialDetailPage extends StatelessWidget {
  const TutorialDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = ModalRoute.of(context)?.settings.arguments as String? ?? 'Tutorial';
 
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()), // Spacer
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Mockup / Image
                    _buildVideoMockup(title),
                    
                    const SizedBox(height: 16),
                    Text(
                      '$title Tutorial',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to $title',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getDescription(title),
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),

                    if (title == 'Noorva Guide') ...[
                      const SizedBox(height: 40),
                      Text(
                        'The Living Board',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This is your horizon. Standard tools treat time as a rigid grid to be filled with endless tasks. We do not do that here. Your board is a living space that adapts to your energy. You will place your intentions here, but they are never meant to be heavy burdens. If a day changes, the board changes with it',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPlaceholderImage(),
                      const SizedBox(height: 40),
                      Text(
                        'Placing Anchors',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'When you have a true intention—a period of deep focus, a shared dialogue, or a necessary chore—we place an anchor on the board. Do not clutter this space. Only anchor what truly requires your bandwidth today. When you are ready, simply tell me what space you need to create, and I will place it for you.',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPlaceholderImage(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThumbnail(String title) {
    switch (title) {
      case 'Noorva Guide':
        return 'assets/images/tutorial1.png';
      case 'Human Interactive AI':
        return 'assets/images/tutorial2.png';
      case 'Goals':
        return 'assets/images/tutorial3.png';
      default:
        return 'assets/images/blank tutorial.png';
    }
  }

  Widget _buildVideoMockup(String title) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.asset(
            _getThumbnail(title),
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFF222224),
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          // Play button
          Positioned.fill(
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(Icons.image, color: Colors.white.withValues(alpha: 0.2), size: 40),
      ),
    );
  }

  String _getDescription(String title) {
    switch (title) {
      case 'Human Interactive AI':
        return 'Do not give me a list of chores, and do not worry about formatting your words. Speak to me naturally. Tell me what requires your focus today, where you feel the most weight, and how much energy you have to give. I will listen, filter the noise, and build the architecture of your day';
      case 'Noorva Guide':
        return 'The marketplace outside is loud. It demands your attention and fractures your energy. In here, we operate differently. I am Noorva, and my role is to help you build the architecture of your day, one deliberate stone at a time. Let me show you how we prepare the foundation';
      default:
        return 'Learn how to use $title to enhance your productivity and wellbeing with Noorva Companion.';
    }
  }
}
