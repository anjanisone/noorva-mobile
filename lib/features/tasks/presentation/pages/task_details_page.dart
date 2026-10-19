import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/crystal_card.dart';

class SubTask {
  final String title;
  bool isCompleted;

  SubTask(this.title, {this.isCompleted = false});
}

class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> taskArgs;

  const TaskDetailPage({super.key, required this.taskArgs});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late bool _isTaskCompleted;
  late String _detailType;

  // Mock list of subtasks for Layout B (Project view)
  late List<SubTask> _subtasks;

  @override
  void initState() {
    super.initState();
    _isTaskCompleted = widget.taskArgs['isCompleted'] ?? false;
    _detailType = widget.taskArgs['detailType'] ?? 'steps';

    // Populate mock subtasks
    _subtasks = [
      SubTask('Get visa application filed', isCompleted: true),
      SubTask('Book flight tickets', isCompleted: true),
      SubTask('Reserve accommodation', isCompleted: false),
      SubTask('Create packing list', isCompleted: false),
      SubTask('Plan itinerary', isCompleted: false),
    ];
  }

  double get _completionPercentage {
    if (_subtasks.isEmpty) return 0.0;
    final completedCount = _subtasks.where((t) => t.isCompleted).length;
    return (completedCount / _subtasks.length) * 100.0;
  }

  void _toggleSubtask(int index) {
    setState(() {
      _subtasks[index].isCompleted = !_subtasks[index].isCompleted;
      // If all subtasks are completed, mark the parent task completed
      _isTaskCompleted = _subtasks.every((t) => t.isCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _detailType == 'project'
                  ? _buildProjectLayout()
                  : _buildStepsLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context, {'isCompleted': _isTaskCompleted});
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/back_arrow.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (_detailType == 'steps')
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/edit.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  // Layout A: Step-by-step details (e.g. Meditation / Stillness)
  Widget _buildStepsLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 12),
                Text(
                  widget.taskArgs['title'] ?? 'Task Details',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.taskArgs['goal'] ?? '',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'The sudden contrast between a busy life and absolute stillness can feel uncomfortable at first. Today is not about achieving perfect silence; it is simply about practicing the art of the pause.\n\n'
                  'Step 1: The physical setup\nYou do not need a perfect meditation cushion. Sit on the edge of your bed or in a supportive chair. Plant both feet flat on the floor to feel grounded. Let your hands rest naturally in your lap.\n\n'
                  'Step 2: The expectation\nThe moment you close your eyes, your brain will likely remind you of three urgent things you need to do today. This is not a failure; it is just your mind emptying its inbox.\n\n'
                  'Step 3: The mental shift\nDo not fight the thoughts. Today is simply about noticing the urge to move, and choosing to sit still for just 5 minutes anyway. Let your shoulders drop and simply breathe.',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          _buildStepsBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildStepsBottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
      child: Column(
        children: [
          // Mark as Done button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isTaskCompleted = true;
              });
              Navigator.pop(context, {'isCompleted': true});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            child: Text(
              _isTaskCompleted ? 'Completed' : 'Mark as done',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Chat with Noorva button
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.guide);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF262729),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            child: Text(
              'Chat With Noorva',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Layout B: Project tracker details (e.g. Trip to London)
  Widget _buildProjectLayout() {
    final pct = _completionPercentage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                // Cover Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/forgot_password.png', // The wizard mascot background, or could use any premium asset
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                // Title and Priority Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trip to London',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'In 10 days',
                            style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'High Priority',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: pct / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${pct.toInt()}%',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Subtasks section
                Text(
                  'Tasks List',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ..._subtasks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final sub = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CrystalCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      borderRadius: 16,
                      borderColor: AppColors.borderLight,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleSubtask(idx),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: sub.isCompleted
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: sub.isCompleted
                                      ? Colors.white
                                      : Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                              child: sub.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              sub.title,
                              style: GoogleFonts.outfit(
                                color: sub.isCompleted
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 15,
                                decoration: sub.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: sub.isCompleted
                                  ? const Color(0xFF1E3F20)
                                  : const Color(0xFF3F361E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sub.isCompleted ? 'Completed' : 'Pending',
                              style: GoogleFonts.outfit(
                                color: sub.isCompleted
                                    ? const Color(0xFF6FF074)
                                    : const Color(0xFFF0BD6F),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
          _buildProjectBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProjectBottomButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.guide);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
        ),
        child: Text(
          'Chat With Noorva',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
