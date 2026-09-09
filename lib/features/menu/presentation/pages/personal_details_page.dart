import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'profile_page.dart'; // To access UserProfileState fallback

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'UN';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    final displayName = user?.name ?? UserProfileState.name;
    final displayEmail = user?.email ?? UserProfileState.email;
    final displayDob = user?.dob ?? UserProfileState.dob;
    final displayGender = user?.gender ?? UserProfileState.gender;
    final displayOccupation = user?.occupation ?? UserProfileState.occupation;
    final displayInitials = user != null ? _getInitials(user.name) : UserProfileState.initials;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
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
                  Expanded(
                    child: Text(
                      'Personal Details',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(context, AppRoutes.editPersonalDetails);
                      setState(() {}); // Refresh on return
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Image.asset('assets/icons/edit.png', width: 22, height: 22, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Avatar Area
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      displayInitials,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamed(context, AppRoutes.editPersonalDetails);
                        setState(() {}); // Refresh on return
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/edit.png',
                          width: 20,
                          height: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Info details card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CrystalCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem('Full Name', displayName),
                    const SizedBox(height: 20),
                    _buildInfoItem('Email', displayEmail),
                    const SizedBox(height: 20),
                    _buildInfoItem('Date of Birth', displayDob),
                    const SizedBox(height: 20),
                    _buildInfoItem('Gender', displayGender),
                    const SizedBox(height: 20),
                    _buildInfoItem('Occupation', displayOccupation),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
