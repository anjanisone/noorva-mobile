import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/noorva_delete_dialog.dart';

class ReportedBugsHistoryPage extends StatefulWidget {
  const ReportedBugsHistoryPage({super.key});

  @override
  State<ReportedBugsHistoryPage> createState() =>
      _ReportedBugsHistoryPageState();
}

class _ReportedBugsHistoryPageState extends State<ReportedBugsHistoryPage> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['All', 'In Progress', 'Closed'];

  final List<Map<String, dynamic>> _tickets = [
    {
      'date': '14 Apr',
      'status': 'In Progress',
      'id': 'ID #204',
      'title': 'App crashes on launch',
      'description':
          'The app closes unexpectedly when opening or fails to load properly.',
    },
    {
      'date': '10 Apr',
      'status': 'Closed',
      'id': 'ID #201',
      'title': 'Notification Delay',
      'description':
          'Notifications are delivered late or do not appear at the expected time.',
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
                        'Reported Bugs',
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
                        // Header row: date + status badge + delete
                        Row(
                          children: [
                            Text(
                              ticket['date'],
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 10),
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
                            const Spacer(),
                            // Delete button
                            GestureDetector(
                              onTap: () {
                                final ticketIndex = _tickets.indexOf(ticket);
                                showDialog(
                                  context: context,
                                  builder: (_) => NoorvaDeleteDialog(
                                    title: 'Delete Bug Report?',
                                    content:
                                        'This will permanently remove "${ticket['title']}" (${ticket['id']}) from your history.',
                                    confirmText: 'Yes, delete',
                                    onConfirm: () {
                                      setState(() {
                                        _tickets.removeAt(ticketIndex);
                                      });
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.06),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white38,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                            fontStyle: FontStyle.italic,
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
