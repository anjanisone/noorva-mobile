import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Back Button Overlay (for easily exiting dev preview)
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
            ),

            // Immersive Fullscreen Layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 60), // Spacer for header back button

                  // Glassmorphic Dialogue Card
                  CrystalCard(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    borderRadius: 32.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Oops!!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You are entirely off the grid. Sometimes, an offline environment is exactly what deep execution requires. Your schedule and daily anchors for today are safely cached. Work in peace; I will watch the horizon and reconnect us when the network returns.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Noorva Character Image (Plug-disconnect simulation)
                  Expanded(
                    child: Center(
                      child: Opacity(
                        opacity: 0.95,
                        child: Image.asset(
                          'assets/images/noorva_home.png',
                          height: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Button
                  NoorvaButton(
                    text: 'Try Again',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF1E1E22),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: Text(
                            'Retrying network connection...',
                            style: GoogleFonts.outfit(color: Colors.white),
                          ),
                        ),
                      );
                      Navigator.pop(context); // Go back once reconnected
                    },
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
