import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SupportHistoryPage extends StatefulWidget {
  const SupportHistoryPage({super.key});

  @override
  State<SupportHistoryPage> createState() => _SupportHistoryPageState();
}

class _SupportHistoryPageState extends State<SupportHistoryPage> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['All', 'In Progress', 'Closed'];

  final List<Map<String, dynamic>> _tickets = [ 
    {
      'date': '26 Apr',
      'status': 'In Progress',
      'id': 'ID #8821',
      'title': 'Login Issue',
      'description':
          'Unable to access account after password reset. The verification link is returning a 404 error repeatedly.',
    },
    {
      'date': '20 Apr',
      'status': 'Closed',
      'id': 'ID #8820',
      'title': 'Account Access',
      'description': 'Unable to access account after login.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTickets = _tickets;
    if (_selectedTabIndex == 1) {
      filteredTickets =
          _tickets.where((t) => t['status'] == 'In Progress').toList();
    } else if (_selectedTabIndex == 2) {
      filteredTickets =
          _tickets.where((t) => t['status'] == 'Closed').toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Support History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for center title
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1C1C1E)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.1))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: filteredTickets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final ticket = filteredTickets[index];
                  final isInProgress = ticket['status'] == 'In Progress';

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket['date'],
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isInProgress
                                    ? const Color(0xFFB06F23).withValues(alpha: 0.2)
                                    : const Color(0xFFD64455).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isInProgress
                                      ? const Color(0xFFB06F23).withValues(alpha: 0.5)
                                      : const Color(0xFFD64455).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                ticket['status'],
                                style: TextStyle(
                                  color: isInProgress
                                      ? const Color(0xFFFFD5A4)
                                      : const Color(0xFFFFB4BC),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket['id'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket['description'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
