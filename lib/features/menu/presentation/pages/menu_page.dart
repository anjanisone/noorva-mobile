import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Menu Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                children: [
                  _buildMenuGroup(
                    'My Workspace',
                    [
                      _buildMenuItem('Dashboard', 'assets/icons/dashboard.png',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.dashboard)),
                      _buildMenuItem('Goals', 'assets/icons/goals.png',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.goals)),
                      _buildMenuItem('Tasks', 'assets/icons/tasks.png',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.tasks)),
                      _buildMenuItem('Events', 'assets/icons/schedules.png',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.events),
                          isLast: true),
                    ],
                  ),
                  _buildMenuGroup(
                    'Memory & Media',
                    [
                      _buildMenuItem(
                          'Chat History', 'assets/icons/chat history.png',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.chatHistory)),
                      _buildMenuItem('Ongoing Conversations',
                          'assets/icons/conversations.png',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.ongoingConversations)),
                      _buildMenuItem('Media', 'assets/icons/media_menu.png',
                          isLast: true),
                    ],
                  ),
                  _buildMenuGroup(
                    'Account & Settings',
                    [
                      _buildMenuItem('Profile', 'assets/icons/profile.png',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.profile)),
                      _buildMenuItem('Settings', 'assets/icons/settings.png',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.settings),
                          isLast: true),
                    ],
                  ),
                  _buildMenuGroup(
                    'Help & System',
                    [
                      _buildMenuItem('About Noorva', 'assets/icons/profile.png',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.aboutNoorva)),
                      _buildMenuItem('Support', 'assets/icons/profile.png',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.supportMenu)),
                      _buildMenuItem('Rate Noorva', 'assets/icons/rate.png',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.rateNoorva)),
                      _buildMenuItem('Tutorials', 'assets/icons/rate.png',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.tutorials),
                          isLast: true),
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

  static const Color _cardColor = Color(0xFF1B1B1E);

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
      decoration: BoxDecoration(
        // Soft top-lit surface, as in the design.
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF26262A), Color(0xFF202023)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String iconPath,
      {bool isLast = false, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Image.asset(
                iconPath,
                width: 19,
                height: 19,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
