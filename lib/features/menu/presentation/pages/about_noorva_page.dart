import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/crystal_card.dart';

class AboutNoorvaPage extends StatelessWidget {
  const AboutNoorvaPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Expanded(child: SizedBox()),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/splash_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Noorva',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your AI companion for clarity,\nproductivity and peace of mind.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Menu Card
                    CrystalCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildAboutItem(context, 'What is Noorva', Icons.auto_awesome_outlined),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildAboutItem(context, 'What Noorva can do?', Icons.bolt_outlined),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildAboutItem(context, 'Wise Old Man Philosophy', Icons.lightbulb_outline),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildAboutItem(context, 'Privacy Policy', Icons.description_outlined),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildAboutItem(context, 'Terms & Conditions', Icons.description_outlined, isLast: true),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    Text(
                      'Version 1.0',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutItem(BuildContext context, String title, IconData icon, {bool isLast = false}) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.aboutDetail,
        arguments: title,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.4), size: 24),
          ],
        ),
      ),
    );
  }
}
