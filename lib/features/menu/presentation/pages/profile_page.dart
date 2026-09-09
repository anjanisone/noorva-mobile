import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class UserProfileState {
  static String name = 'Noorva User';
  static String email = 'user@noorva.com';
  static String dob = 'dd-mm-yyyy';
  static String gender = 'Male';
  static String occupation = 'Designer';

  static String get initials {
    if (name.isEmpty) return 'UN';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

    // Sync static fields for backward compatibility
    if (user != null) {
      UserProfileState.name = user.name;
      UserProfileState.email = user.email;
      UserProfileState.dob = user.dob ?? 'dd-mm-yyyy';
      UserProfileState.gender = user.gender ?? 'Male';
      UserProfileState.occupation = user.occupation ?? 'Designer';
    }

    final displayName = user?.name ?? UserProfileState.name;
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
                      'Profile',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Equal balancing spacer
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

            const SizedBox(height: 16),

            // User Name Label
            Text(
              displayName,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ), 
            ),

            const SizedBox(height: 32),

            // Options List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Card 1
                    CrystalCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 24.0,
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Personal Details',
                            onTap: () async {
                              await Navigator.pushNamed(context, AppRoutes.personalDetails);
                              setState(() {}); // Refresh on return
                            },
                          ),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildMenuItem(
                            icon: Icons.tune_rounded,
                            title: 'Preferences',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.personalization,
                                arguments: {'isProfileMode': true},
                              );
                            },
                          ),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildMenuItem(
                            icon: Icons.lock_outline_rounded,
                            title: 'Change Password',
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.changePassword);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card 2
                    CrystalCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 24.0,
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.delete_outline_rounded,
                            title: 'Delete Account',
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.deleteAccount);
                            },
                          ),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            isRed: true,
                            showChevron: false,
                            onTap: () async {
                              context.read<AuthBloc>().add(const AuthLogoutRequested());
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF1E1E22),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    content: Text(
                                      'Logged out successfully.',
                                      style: GoogleFonts.outfit(color: Colors.white),
                                    ),
                                  ),
                                );
                                Navigator.pushNamedAndRemoveUntil(
                                    context, AppRoutes.login, (route) => false);
                              }
                            },
                          ),
                        ],
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isRed = false,
    bool showChevron = true,
  }) {
    final Color itemColor = isRed ? const Color(0xFFFF5252) : Colors.white;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(
        icon,
        color: isRed ? itemColor : Colors.white.withValues(alpha: 0.8),
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: itemColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: showChevron
          ? Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            )
          : null,
    );
  }
}
