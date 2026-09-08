import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_delete_dialog.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  void _toggleSelectionMode(NotificationProvider provider) {
    provider.isSelectionMode = !provider.isSelectionMode;
  }

  void _selectAll(NotificationProvider provider) {
    provider.selectAll(true);
  }

  void _showDeleteConfirmation(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return NoorvaDeleteDialog(
          title: 'Delete notifications',
          content: 'This action will permanently delete the notifications from your feed',
          onConfirm: () {
            provider.deleteSelectedNotifications();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications deleted successfully'),
                backgroundColor: AppColors.card,
              ),
            );
          },
        );
      },
    );
  }

  void _showTestNotificationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Simulate Push Notifications',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Trigger Figma spec designs with custom actions & wizard icon',
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSimulateItem(0, 'Break Reminder', 'Time for a break! Stand up!'),
                _buildSimulateItem(1, 'Meeting Alert', 'Call with Sumanth'),
                _buildSimulateItem(2, 'Workday Report', 'End of workday! Check your stats'),
                _buildSimulateItem(3, 'Missed Intention', 'You missed a task, reschedule now'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimulateItem(int index, String category, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.read<NotificationProvider>().triggerSimulatedNotification(index);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF8B80F9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final today = provider.todayNotifications;
    final week = provider.weekNotifications;

    // Handle post frame actions (e.g. snackbar for action clicks)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.lastActionResponse != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.lastActionResponse!,
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF2C2C2E),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        provider.clearLastActionResponse();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(provider),
            Expanded(
              child: provider.notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        if (today.isNotEmpty) ...[
                          _buildSectionHeader('Today'),
                          ...today.map((n) => _buildNotificationCard(n, provider)),
                        ],
                        if (week.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('This Week'),
                          ...week.map((n) => _buildNotificationCard(n, provider)),
                        ],
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomSheet: provider.isSelectionMode ? _buildBottomActionSheet(provider) : null,
      floatingActionButton: !provider.isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: _showTestNotificationsBottomSheet,
              backgroundColor: const Color(0xFF8B80F9),
              icon: const Icon(Icons.bolt_rounded, color: Colors.white),
              label: Text(
                'Simulate FCM',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: Colors.white.withValues(alpha: 0.15),
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Your inbox is quiet',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Simulate notifications using the button below',
            style: GoogleFonts.outfit(
              color: Colors.white30,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NotificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          if (provider.notifications.isNotEmpty)
            GestureDetector(
              onTap: () => _toggleSelectionMode(provider),
              child: Text(
                provider.isSelectionMode ? 'Cancel' : 'Edit',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item, NotificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (provider.isSelectionMode) ...[
            GestureDetector(
              onTap: () => provider.toggleSelection(item.id),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.isSelected ? Colors.white : Colors.white24,
                    width: 2,
                  ),
                ),
                child: item.isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 16)
                    : null,
              ),
            ),
          ],
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (provider.isSelectionMode) {
                  provider.toggleSelection(item.id);
                } else {
                  provider.markAsRead(item.id);
                }
              },
              child: CrystalCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                borderColor: const Color(0xFF3B3B3B),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (item.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF8A8A),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.body,
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.timestamp,
                      style: GoogleFonts.outfit(
                        color: Colors.white24,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSheet(NotificationProvider provider) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _selectAll(provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                'Select All',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteConfirmation(provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(color: const Color(0xFFFF8A8A), fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
