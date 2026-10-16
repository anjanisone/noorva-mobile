import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/thought_bubble.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/noorva_mascot.dart';

// ─── Data model ────────────────────────────────────────────────────────────────

class TaskItem {
  final String id;
  final String title;
  final String goal;
  final String timeText;
  final String priority; // 'high' | 'medium' | 'low'
  bool isCompleted;
  final bool isProject;
  final String detailType; // 'steps' | 'project'
  final String taskCategory; // 'goal' | 'event' | 'task'
  final String? linkedId;

  TaskItem({
    required this.id,
    required this.title,
    required this.goal,
    required this.timeText,
    required this.priority,
    this.isCompleted = false,
    this.isProject = false,
    this.detailType = 'steps',
    this.taskCategory = 'task',
    this.linkedId,
  });
}

// ─── Page ──────────────────────────────────────────────────────────────────────

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Demo "today"
  static final DateTime _today = DateTime(2026, 4, 24);

  // Calendar state
  late DateTime _selectedDate;
  late int _viewYear;
  late int _viewMonth;

  bool _showCompletionOverlay = false;

  // Scroll controller for the date strip
  final ScrollController _dateScrollController = ScrollController();

  // Width of each day pill (must match the layout)
  static const double _dayPillWidth = 52.0;
  static const double _dayPillSpacing = 4.0;

  // ─── Task database ─────────────────────────────────────────────────────────

  late final Map<String, List<TaskItem>> _tasksData;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<TaskItem> get _dayTasks => _tasksData[_dateKey(_selectedDate)] ?? [];

  bool get _isUpcomingDate => _selectedDate.isAfter(_today);

  int get _daysInMonth => DateUtils.getDaysInMonth(_viewYear, _viewMonth);

  String get _monthYearLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[_viewMonth - 1]} $_viewYear';
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _viewYear = _today.year;
    _viewMonth = _today.month;

    _tasksData = {
      '2026-04-20': [
        TaskItem(
          id: 't-20-1',
          title: 'Review goals roadmap',
          goal: 'Goal - Cultivate inner peace',
          timeText: '20 Apr | 8:00AM - 8:30 AM',
          priority: 'medium',
          isCompleted: true,
          taskCategory: 'goal',
          linkedId: 'goal-1',
        ),
      ],
      '2026-04-21': [
        TaskItem(
          id: 't-21-1',
          title: 'Morning reflection & journaling',
          goal: 'Goal - Meditate for inner peace',
          timeText: '21 Apr | 7:00AM - 7:30 AM',
          priority: 'high',
          isCompleted: true,
          taskCategory: 'goal',
          linkedId: 'goal-2',
        ),
      ],
      '2026-04-22': [
        TaskItem(
          id: 't-22-1',
          title: 'Prepare design assets',
          goal: 'Event - Global Design Community',
          timeText: '22 Apr | 10:00AM - 12:00 PM',
          priority: 'high',
          isCompleted: true,
          taskCategory: 'event',
          linkedId: 'event-1',
        ),
      ],
      '2026-04-23': [
        TaskItem(
          id: 't-23-1',
          title: 'Cardio training & stretching',
          goal: 'Goal - Master marathon prep',
          timeText: '23 Apr | 6:00PM - 7:00 PM',
          priority: 'low',
          isCompleted: true,
          taskCategory: 'goal',
          linkedId: 'goal-3',
        ),
      ],
      '2026-04-24': [
        TaskItem(
          id: 't-24-1',
          title: 'Day 1 - Practicing stillness',
          goal: 'Goal - Meditate for inner peace',
          timeText: 'Today | 7:00AM - 7:15 AM',
          priority: 'high',
          isCompleted: true,
          detailType: 'steps',
          taskCategory: 'goal',
          linkedId: 'goal-2',
        ),
        TaskItem(
          id: 't-24-2',
          title: 'Get pitch deck ready for app',
          goal: 'Event - Global Design Community',
          timeText: 'Today | 12:00 PM - 6:00 PM',
          priority: 'high',
          isCompleted: false,
          detailType: 'project',
          taskCategory: 'event',
          linkedId: 'event-1',
        ),
        TaskItem(
          id: 't-24-3',
          title: 'The afternoon energy reset',
          goal: 'Goal - The afternoon energy reset',
          timeText: 'Today | 01:30 PM - 02:00 PM',
          priority: 'medium',
          isCompleted: false,
          detailType: 'steps',
          taskCategory: 'goal',
          linkedId: 'goal-4',
        ),
        TaskItem(
          id: 't-24-4',
          title: 'Read Chapter 2 of Design of Everyday Things',
          goal: 'Goal - Finish reading 10 books',
          timeText: 'Today | 08:00 PM - 09:00 PM',
          priority: 'low',
          isCompleted: false,
          detailType: 'steps',
          taskCategory: 'goal',
          linkedId: 'goal-5',
        ),
      ],
      '2026-04-25': [
        TaskItem(
          id: 't-25-1',
          title: 'Plan trip outline & booking checklist',
          goal: 'Goal - Trip to London',
          timeText: '25 Apr | 11:00 AM - 12:30 PM',
          priority: 'high',
          isCompleted: false,
          isProject: true,
          detailType: 'project',
          taskCategory: 'goal',
          linkedId: 'goal-6',
        ),
      ],
      '2026-04-26': [
        TaskItem(
          id: 't-26-1',
          title: 'Day 1 - Practicing stillness',
          goal: 'Goal - Meditate for inner peace',
          timeText: '26 Apr | 7:00AM - 7:15 AM',
          priority: 'high',
          isCompleted: false,
          detailType: 'steps',
          taskCategory: 'goal',
          linkedId: 'goal-2',
        ),
        TaskItem(
          id: 't-26-2',
          title: 'Read Chapter 4 of Design of Everyday Things',
          goal: 'Goal - Finish reading 10 books',
          timeText: '26 Apr | 08:00PM - 09:00PM',
          priority: 'low',
          isCompleted: false,
          detailType: 'steps',
          taskCategory: 'goal',
          linkedId: 'goal-5',
        ),
      ],
    };

    // Scroll to today after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  // ── Calendar navigation ──────────────────────────────────────────────────────

  void _prevMonth() {
    setState(() {
      if (_viewMonth == 1) {
        _viewMonth = 12;
        _viewYear--;
      } else {
        _viewMonth--;
      }
      // Clamp selected date to this month
      final lastDay = DateUtils.getDaysInMonth(_viewYear, _viewMonth);
      _selectedDate =
          DateTime(_viewYear, _viewMonth, _selectedDate.day.clamp(1, lastDay));
      _checkDayCompletion();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _nextMonth() {
    setState(() {
      if (_viewMonth == 12) {
        _viewMonth = 1;
        _viewYear++;
      } else {
        _viewMonth++;
      }
      final lastDay = DateUtils.getDaysInMonth(_viewYear, _viewMonth);
      _selectedDate =
          DateTime(_viewYear, _viewMonth, _selectedDate.day.clamp(1, lastDay));
      _checkDayCompletion();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  Future<void> _showMonthYearPicker() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _MonthYearPickerDialog(
        initialYear: _viewYear,
        initialMonth: _viewMonth,
      ),
    );
    if (picked != null) {
      setState(() {
        _viewYear = picked.year;
        _viewMonth = picked.month;
        final lastDay = DateUtils.getDaysInMonth(_viewYear, _viewMonth);
        _selectedDate = DateTime(
            _viewYear, _viewMonth, _selectedDate.day.clamp(1, lastDay));
        _checkDayCompletion();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  /// Smoothly scroll the strip so the selected day pill is centred.
  void _scrollToSelected() {
    if (!_dateScrollController.hasClients) return;
    const pillWidth = _dayPillWidth + _dayPillSpacing * 2;
    final targetIndex = _selectedDate.day - 1;
    final offset = targetIndex * pillWidth;
    final viewportHalf = (_dateScrollController.position.viewportDimension) / 2;
    final centred = (offset - viewportHalf + pillWidth / 2).clamp(
      0.0,
      _dateScrollController.position.maxScrollExtent,
    );
    _dateScrollController.animateTo(
      centred,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ── Task completion ───────────────────────────────────────────────────────────

  void _toggleTaskCompletion(TaskItem task) {
    if (_isUpcomingDate) return;
    setState(() {
      task.isCompleted = !task.isCompleted;
      _checkDayCompletion();
    });
  }

  void _checkDayCompletion() {
    final tasks = _dayTasks;
    _showCompletionOverlay =
        tasks.isNotEmpty && tasks.every((t) => t.isCompleted);
  }

  Future<void> _onTaskTapped(TaskItem task) async {
    switch (task.taskCategory) {
      case 'goal':
        await Navigator.pushNamed(context, AppRoutes.goalDetail);
        break;
      case 'event':
        await Navigator.pushNamed(
          context,
          AppRoutes.eventDetail,
          arguments: task.linkedId ?? 'event-1',
        );
        break;
      default:
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.taskDetail,
          arguments: {
            'id': task.id,
            'title': task.title,
            'goal': task.goal,
            'detailType': task.detailType,
            'isCompleted': task.isCompleted,
          },
        );
        if (result != null && result is Map<String, dynamic>) {
          setState(() {
            task.isCompleted = result['isCompleted'] ?? task.isCompleted;
            _checkDayCompletion();
          });
        }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tasks = _dayTasks;
    final high = tasks.where((t) => t.priority == 'high').toList();
    final medium = tasks.where((t) => t.priority == 'medium').toList();
    final low = tasks.where((t) => t.priority == 'low').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 8),
                _buildCalendarStrip(),
                const SizedBox(height: 16),
                if (tasks.isEmpty)
                  _buildEmptyState()
                else
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      children: [
                        if (high.isNotEmpty) ...[
                          _buildPriorityHeader(
                              'High Priority', const Color(0xFF5A1E1E)),
                          const SizedBox(height: 12),
                          ...high.map(_buildTaskCard),
                          const SizedBox(height: 24),
                        ],
                        if (medium.isNotEmpty) ...[
                          _buildPriorityHeader(
                              'Medium Priority', const Color(0xFF5A411E)),
                          const SizedBox(height: 12),
                          ...medium.map(_buildTaskCard),
                          const SizedBox(height: 24),
                        ],
                        if (low.isNotEmpty) ...[
                          _buildPriorityHeader(
                              'Low Priority', const Color(0xFF1E3A5A)),
                          const SizedBox(height: 12),
                          ...low.map(_buildTaskCard),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
            if (_showCompletionOverlay) _buildMascotOverlay(),
          ],
        ),
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Center(
                child: Image.asset('assets/icons/back_arrow.png',
                    width: 20, height: 20, color: Colors.white),
              ),
            ),
          ),
          Text(
            'Tasks',
            style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Image.asset('assets/icons/edit.png',
                  width: 20, height: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Calendar strip ───────────────────────────────────────────────────────────

  Widget _buildCalendarStrip() {
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // ── Month / Year ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child:
                      Icon(Icons.chevron_left, color: Colors.white70, size: 22),
                ),
              ),
              GestureDetector(
                onTap: _showMonthYearPicker,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _monthYearLabel,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54, size: 18),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.chevron_right,
                      color: Colors.white70, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Scrollable day pills ──────────────────────────────────
          SizedBox(
            height: 68,
            child: ListView.builder(
              controller: _dateScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _daysInMonth,
              itemBuilder: (_, i) {
                final day = DateTime(_viewYear, _viewMonth, i + 1);
                final isSelected = _dateKey(day) == _dateKey(_selectedDate);
                final isToday = _dateKey(day) == _dateKey(_today);
                final isFuture = day.isAfter(_today);
                final weekdayIndex = (day.weekday - 1) % 7; // 0=Mon…6=Sun

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                      _checkDayCompletion();
                    });
                    _scrollToSelected();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _dayPillWidth,
                    margin:
                        const EdgeInsets.symmetric(horizontal: _dayPillSpacing),
                    decoration: isSelected
                        ? BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withValues(alpha: 0.09),
                          )
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day letter (Mon, Tue…)
                        Text(
                          dayNames[weekdayIndex],
                          style: GoogleFonts.outfit(
                            color: isSelected
                                ? Colors.white70
                                : isFuture
                                    ? Colors.white24
                                    : Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Day number
                        Text(
                          '${day.day}',
                          style: GoogleFonts.outfit(
                            color: isSelected
                                ? Colors.white
                                : isFuture
                                    ? Colors.white30
                                    : Colors.white70,
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        // Today dot
                        const SizedBox(height: 4),
                        if (isToday)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          )
                        else
                          const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Priority header ───────────────────────────────────────────────────────────

  Widget _buildPriorityHeader(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  // ── Task card ─────────────────────────────────────────────────────────────────

  Widget _buildTaskCard(TaskItem task) {
    final checkboxEnabled = !_isUpcomingDate;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CrystalCard(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
        borderRadius: 24,
        borderColor: AppColors.borderLight,
        child: InkWell(
          onTap: () => _onTaskTapped(task),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap:
                    checkboxEnabled ? () => _toggleTaskCompletion(task) : null,
                child: Opacity(
                  opacity: checkboxEnabled ? 1.0 : 0.38,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          task.isCompleted ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.isCompleted ? Colors.white : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.black)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.outfit(
                        color: task.isCompleted ? Colors.white38 : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(task.goal,
                        style: GoogleFonts.outfit(
                            color: Colors.white38, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(task.timeText,
                            style: GoogleFonts.outfit(
                                color: Colors.white38, fontSize: 11)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? const Color(0xFF1E3F20)
                                : const Color(0xFF1E3F5A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.isCompleted ? 'Completed' : 'Upcoming',
                            style: GoogleFonts.outfit(
                              color: task.isCompleted
                                  ? const Color(0xFF6FF074)
                                  : const Color(0xFF6FC8F0),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.north_east, color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    CrystalCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 28),
                      borderRadius: 28,
                      borderColor: AppColors.borderLight,
                      blurSigmaX: 12,
                      blurSigmaY: 12,
                      child: Center(
                        child: Text(
                          '${context.watch<AuthBloc>().state.user?.name ?? 'User'}, you have no active tasks present. '
                          "Let's together build your first goal to add tasks",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(children: [
                      _dot(10),
                      const SizedBox(height: 4),
                      _dot(7),
                    ]),
                    const SizedBox(height: 16),
                    const NoorvaMascot(
                        mood: MascotMood.explaining,
                        height: 280,
                        fallbackAsset: 'assets/images/noorva_onboard.png'),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.guide),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: Text('Go to Noorva Guide',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A2B2F),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
      );

  // ── Completion overlay ────────────────────────────────────────────────────────

  Widget _buildMascotOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showCompletionOverlay = false),
        child: Container(
          color: Colors.black.withValues(alpha: 0.75),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ThoughtBubble(
                text:
                    'Your intentions for today are fulfilled. The day is complete. Go unplug',
                dotsAlignment: ThoughtBubbleDotsAlignment.center,
                maxWidth: 240,
                minHeight: 100,
              ),
              SizedBox(height: 62),
              NoorvaMascot(
                  mood: MascotMood.success,
                  height: 280,
                  fallbackAsset: 'assets/images/noorva_onboard.png'),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Month / Year Picker Dialog ────────────────────────────────────────────────

class _MonthYearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const _MonthYearPickerDialog({
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1D21),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBtn(Icons.chevron_left, () => setState(() => _year--)),
                Text('$_year',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                _iconBtn(Icons.chevron_right, () => setState(() => _year++)),
              ],
            ),
            const SizedBox(height: 20),

            // Month grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.0,
              ),
              itemCount: 12,
              itemBuilder: (_, i) {
                final isSelected = _month == i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _month = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _months[i],
                      style: GoogleFonts.outfit(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        Text('Cancel', style: GoogleFonts.outfit(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, DateTime(_year, _month, 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text('Go',
                        style: GoogleFonts.outfit(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      );
}
