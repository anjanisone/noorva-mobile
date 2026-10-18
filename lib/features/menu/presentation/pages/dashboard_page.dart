import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/noorva_mascot.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedPeriod = 'Today';
  bool _hasData = false;
  
  // Accordion expansion states
  bool _isTasksExpanded = false;
  bool _isActiveGoalsExpanded = false;
  bool _isUpcomingEventsExpanded = false;

  // Carousel indices
  int _activeGoalIndex = 0;
  int _eventIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildGuidanceCard(),
                    const SizedBox(height: 16),
                    _buildStatsContainer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Dashboard',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _hasData = !_hasData;
            }),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/edit.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceCard() {
    final userName = context.watch<AuthBloc>().state.user?.name ?? 'User';
    String messageText = '';
    double progressValue = 0.0;
    String progressText = '';
    String progressSubtitle = '';

    if (!_hasData) {
      messageText = 'Hey $userName, you have no active tasks for today';
      progressValue = 0.0;
      progressText = '0%';
      progressSubtitle = '';
    } else {
      if (_selectedPeriod == 'Today') {
        messageText = 'Hey $userName, half the board is clear. You are moving with excellent pace today. Guard your remaining energy.';
        progressValue = 0.5;
        progressText = '50%';
        progressSubtitle = '1/2 Tasks completed';
      } else if (_selectedPeriod == 'Weekly') {
        messageText = 'Hey $userName, half the board is clear. You are moving with excellent pace today. Guard your remaining energy.';
        progressValue = 0.5;
        progressText = '50%';
        progressSubtitle = '1/2 Tasks completed';
      } else {
        messageText = 'Hey $userName, you are maintaining a very steady pace this month. Your productivity levels are higher than usual!';
        progressValue = 0.75;
        progressText = '75%';
        progressSubtitle = '3/4 Goals on track';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CrystalCard(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NoorvaMascot(
                  height: 90,
                  width: 70,
                  fallbackAsset: 'assets/images/white_dress_oldman.png',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    messageText,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Progress',
              style: GoogleFonts.outfit(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: const Color(0xFF3A3A3D),
                      valueColor: const AlwaysStoppedAnimation<Color>(_green),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  progressText,
                  style: GoogleFonts.outfit(
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            if (progressSubtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                progressSubtitle,
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const Color _green = Color(0xFF6BD36B);
  static const Color _red = Color(0xFFF07B7B);
  static const Color _tileColor = Color(0xFF1B1B1E);

  BoxDecoration _tileDecoration({double radius = 12}) {
    return BoxDecoration(
      color: _tileColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    );
  }

  Widget _buildStatsContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      // Bottom padding comes from the last accordion's margin
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF151517),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          _buildMetricGrid(),
          const SizedBox(height: 16),
          _buildTimeSpentCard(),
          const SizedBox(height: 16),
          _buildAccordions(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _tileColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _buildPeriodTab('Today'),
          _buildPeriodTab('Weekly'),
          _buildPeriodTab('Monthly'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String period) {
    final bool isActive = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedPeriod = period;
          // Sync collapse names to selected period titles
          _isTasksExpanded = false;
          _isActiveGoalsExpanded = false;
          _isUpcomingEventsExpanded = false;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF232326) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              period,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile('Ongoing\nChats', _getOngoingChats(), hasArrow: true),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile('Total\nChats', _getTotalChats(), hasArrow: true),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                'Missed\nTasks',
                _getMissedTasks(),
                hasArrow: true,
                valueColor: _red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                'Completed\nTasks',
                _getCompletedTasks(),
                hasArrow: true,
                valueColor: _green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile('New\nGoals', '0', hasArrow: true),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile('New\nEvents', '0', hasArrow: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, {required bool hasArrow, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: _tileDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
              if (hasArrow)
                const Icon(
                  Icons.north_east,
                  color: Colors.white,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: valueColor ?? Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSpentCard() {
    final double generalRatio = _getGeneralRatio();
    final double guidedRatio = 1.0 - generalRatio;

    const generalColor = Color(0xFF55A0E6);
    const guidedColor = Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _tileDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Time spent',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _getTimeSpent(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              if (!_hasData) {
                return Container(
                  width: 14,
                  height: 36,
                  decoration: BoxDecoration(
                    color: generalColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }
              // Bars occupy ~75% of the card width, split by ratio (as in design)
              const gap = 4.0;
              final availableWidth = constraints.maxWidth * 0.75 - gap;
              return Row(
                children: [
                  Container(
                    width: availableWidth * generalRatio,
                    height: 36,
                    decoration: BoxDecoration(
                      color: generalColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Container(
                    width: availableWidth * guidedRatio,
                    height: 36,
                    decoration: BoxDecoration(
                      color: guidedColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem(generalColor, 'General'),
              const SizedBox(width: 10),
              _buildLegendItem(guidedColor, 'Guided charts'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAccordions() {
    String tasksTitle = 'Tasks';
    String tasksSubtitle = '';
    
    if (_selectedPeriod == 'Today') {
      tasksTitle = "Today's Tasks";
      tasksSubtitle = '1/2 Tasks completed';
    } else if (_selectedPeriod == 'Weekly') {
      tasksTitle = 'Weekly Tasks';
      tasksSubtitle = _hasData ? '4/16 Tasks completed' : '0/16 Tasks completed';
    } else {
      tasksTitle = 'Monthly Tasks';
      tasksSubtitle = _hasData ? '4/40 Tasks completed' : '0/40 Tasks completed';
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          _buildAccordionSection(
            title: tasksTitle,
            subtitle: tasksSubtitle,
            isExpanded: _isTasksExpanded,
            onTap: () => setState(() => _isTasksExpanded = !_isTasksExpanded),
            child: _buildTasksList(),
          ),
          _buildAccordionSection(
            title: 'Active Goals',
            subtitle: 'Track and manage your active goals',
            isExpanded: _isActiveGoalsExpanded,
            onTap: () => setState(() => _isActiveGoalsExpanded = !_isActiveGoalsExpanded),
            child: _buildActiveGoalsCarousel(),
          ),
          _buildAccordionSection(
            title: 'Upcoming Events',
            subtitle: 'Track and manage your upcoming events',
            isExpanded: _isUpcomingEventsExpanded,
            onTap: () => setState(() => _isUpcomingEventsExpanded = !_isUpcomingEventsExpanded),
            child: _buildUpcomingEventsCarousel(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _tileDecoration(radius: 20).copyWith(
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (!isExpanded) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    if (!_hasData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/complete_task.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.assignment_turned_in_outlined,
                size: 64,
                color: Colors.white30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'There are no tasks',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }
    if (_selectedPeriod == 'Today') {
      return Column(
        children: [
          _buildTaskCard(
            title: 'Day 1 - Practicing stillness',
            goal: 'Meditate for inner peace',
            time: 'Today | 7:00AM - 7:15AM',
            priority: 'High Priority',
            isChecked: true,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: 'Today | 1:30PM - 2:00PM',
            priority: 'Medium Priority',
            isChecked: false,
            isCompleted: false,
          ),
        ],
      );
    } else if (_selectedPeriod == 'Weekly') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskCard(
            title: 'Day 1 - Practicing stillness',
            goal: 'Meditate for inner peace',
            time: '04 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: true,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '04 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: true,
            isCompleted: false,
          ),
          _buildTaskCard(
            title: 'Day 2 - Task Name',
            goal: 'Meditate for inner peace',
            time: '05 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: false,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '05 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: false,
            isCompleted: false,
          ),
          _buildTaskCard(
            title: 'Day 3 - Task Name',
            goal: 'Meditate for inner peace',
            time: '06 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: false,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '06 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: false,
            isCompleted: false,
          ),
          _buildTaskCard(
            title: 'Day 4 - Task Name',
            goal: 'Meditate for inner peace',
            time: '07 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: false,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '07 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: false,
            isCompleted: false,
          ),
          _buildTaskCard(
            title: 'Day 5 - Task Name',
            goal: 'Meditate for inner peace',
            time: '08 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: false,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '08 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: false,
            isCompleted: false,
          ),
          _buildTaskCard(
            title: 'Day 6 - Task Name',
            goal: 'Meditate for inner peace',
            time: '09 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: false,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '09 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: false,
            isCompleted: false,
          ),
          _buildTaskCard(
            title: 'Day 7 - Task Name',
            goal: 'Meditate for inner peace',
            time: '10 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: false,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '10 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: false,
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View More',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.north_east,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskCard(
            title: 'Day 1 - Practicing stillness',
            goal: 'Meditate for inner peace',
            time: '04 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: true,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '04 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: true,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Day 2 - Task Name',
            goal: 'Meditate for inner peace',
            time: '05 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: true,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '05 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: true,
            isCompleted: true,
          ),
          _buildTaskCard(
            title: 'Day 3 - Task Name',
            goal: 'Meditate for inner peace',
            time: '06 Apr 2026 | 7:00AM - 7:15 AM',
            priority: 'High Priority',
            isChecked: false,
            isCompleted: false,
          ),
          _buildTaskCard(
            title: 'Afternoon Reset for energy',
            goal: 'Afternoon energy reset',
            time: '06 Apr 2026 | 1:30PM - 2:00 PM',
            priority: 'Medium Priority',
            isChecked: false,
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View More',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.north_east,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority) {
      case 'High Priority':
        return const Color(0xFF2A1515);
      case 'Medium Priority':
        return const Color(0xFF2A1F15);
      case 'Low Priority':
      default:
        return const Color(0xFF152A1C);
    }
  }

  Color _getPriorityTextColor(String priority) {
    switch (priority) {
      case 'High Priority':
        return const Color(0xFFE57373);
      case 'Medium Priority':
        return const Color(0xFFFFB74D);
      case 'Low Priority':
      default:
        return const Color(0xFF81C784);
    }
  }

  Color _getStatusBgColor(bool isCompleted) {
    return isCompleted ? const Color(0xFF152A1C) : const Color(0xFF2A1F15);
  }

  Color _getStatusTextColor(bool isCompleted) {
    return isCompleted ? const Color(0xFF81C784) : const Color(0xFFFFB74D);
  }

  Widget _buildTaskCard({
    required String title,
    required String goal,
    required String time,
    required String priority,
    bool isChecked = false,
    bool isCompleted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityBgColor(priority),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: GoogleFonts.outfit(
                    color: _getPriorityTextColor(priority),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(isCompleted),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Pending',
                  style: GoogleFonts.outfit(
                    color: _getStatusTextColor(isCompleted),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isChecked ? Colors.white : Colors.transparent,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isChecked ? Colors.white : Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check,
                        color: Color(0xFF141416), 
                        size: 14,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: isChecked ? Colors.white30 : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Goal - $goal',
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.north_east,
                color: Colors.white30,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGoalsCarousel() {
    if (!_hasData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/answer.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.track_changes,
                size: 64,
                color: Colors.white30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No active goals',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView(
            onPageChanged: (index) {
              setState(() {
                _activeGoalIndex = index;
              });
            },
            children: [
              _buildGoalCard(
                priority: 'High Priority',
                title: 'Meditate for inner peace',
                timeLeft: '19 days left',
                subtasksCompleted: 3,
                subtasksTotal: 21,
                avgTimeSpent: '3h',
              ),
              _buildGoalCard(
                priority: 'Medium Priority',
                title: 'Afternoon energy reset',
                timeLeft: '12 days left',
                subtasksCompleted: 5,
                subtasksTotal: 10,
                avgTimeSpent: '2h',
              ),
              _buildGoalCard(
                priority: 'High Priority',
                title: 'Physical wellbeing',
                timeLeft: '25 days left',
                subtasksCompleted: 12,
                subtasksTotal: 30,
                avgTimeSpent: '4h',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _activeGoalIndex == index ? Colors.white : Colors.white30,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required String priority,
    required String title,
    required String timeLeft,
    required int subtasksCompleted,
    required int subtasksTotal,
    required String avgTimeSpent,
  }) {
    final double progress = subtasksTotal > 0 ? subtasksCompleted / subtasksTotal : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityBgColor(priority),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: GoogleFonts.outfit(
                    color: _getPriorityTextColor(priority),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.north_east,
                color: Colors.white30,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeLeft,
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sub tasks',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                '$subtasksCompleted/$subtasksTotal',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF81C784),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avg. Time spent',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                avgTimeSpent,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsCarousel() {
    if (!_hasData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming events',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 290,
          child: PageView(
            onPageChanged: (index) {
              setState(() {
                _eventIndex = index;
              });
            },
            children: [
              _buildEventCard(
                imagePath: 'assets/images/event1.jpg',
                priority: 'High Priority',
                title: 'Trip to London',
                daysLeft: 'In 10 days',
                subtasksCompleted: 2,
                subtasksTotal: 5,
                progressPercent: 0.13,
              ),
              _buildEventCard(
                imagePath: 'assets/images/event2.jpg',
                priority: 'Medium Priority',
                title: 'Flutter Hackathon',
                daysLeft: 'In 3 days',
                subtasksCompleted: 1,
                subtasksTotal: 4,
                progressPercent: 0.25,
              ),
              _buildEventCard(
                imagePath: 'assets/images/mindful_breathing.png',
                priority: 'High Priority',
                title: 'Zen Meditation Retreat',
                daysLeft: 'In 15 days',
                subtasksCompleted: 4,
                subtasksTotal: 10,
                progressPercent: 0.40,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _eventIndex == index ? Colors.white : Colors.white30,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String imagePath,
    required String priority,
    required String title,
    required String daysLeft,
    required int subtasksCompleted,
    required int subtasksTotal,
    required double progressPercent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityBgColor(priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priority,
                        style: GoogleFonts.outfit(
                          color: _getPriorityTextColor(priority),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.north_east,
                      color: Colors.white30,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysLeft,
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sub tasks',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$subtasksCompleted/$subtasksTotal',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF81C784),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progressPercent * 100).toInt()}%',
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper getters for dynamic values
  String _getOngoingChats() {
    if (!_hasData) return '0';
    if (_selectedPeriod == 'Today') return '2';
    if (_selectedPeriod == 'Weekly') return '3';
    return '8';
  }

  String _getTotalChats() {
    if (!_hasData) return '0';
    if (_selectedPeriod == 'Today') return '3';
    if (_selectedPeriod == 'Weekly') return '13';
    return '56';
  }

  String _getMissedTasks() {
    if (!_hasData) return '0';
    if (_selectedPeriod == 'Today') return '0';
    if (_selectedPeriod == 'Weekly') return '0';
    return '2';
  }

  String _getCompletedTasks() {
    if (!_hasData) return '0';
    if (_selectedPeriod == 'Today') return '1';
    if (_selectedPeriod == 'Weekly') return '12';
    return '48';
  }

  String _getTimeSpent() {
    if (!_hasData) return '0hr 10m';
    if (_selectedPeriod == 'Today') return '5h 30m';
    if (_selectedPeriod == 'Weekly') return '15h 30m';
    return '45h 10m';
  }

  double _getGeneralRatio() {
    if (!_hasData) return 1.0;
    if (_selectedPeriod == 'Today') return 0.6;
    if (_selectedPeriod == 'Weekly') return 0.4;
    return 0.55;
  }
}
