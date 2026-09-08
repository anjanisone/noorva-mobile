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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/back_arrow.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Menu Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40.0),
                children: [
                  _buildMenuGroup(
                    'My Workspace',
                    [
                      _buildMenuItem('Dashboard', 'assets/icons/dashboard.png',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.dashboard)),
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
                          isLast: true), // try media_menu.png or media.png
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
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.tutorials),
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

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String iconPath,
      {bool isLast = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Image.asset(
              'assets/icons/forward_arrow.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
