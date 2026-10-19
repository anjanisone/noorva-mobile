import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/goal_model.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../widgets/goal_ui.dart';
import '../../../guide/presentation/pages/guide_page.dart';

class GoalTrackingPage extends StatefulWidget {
  const GoalTrackingPage({super.key});

  @override
  State<GoalTrackingPage> createState() => _GoalTrackingPageState();
}

class _GoalTrackingPageState extends State<GoalTrackingPage> {
  int _selectedTabIndex = 1; // Default to Pending tasks (1) instead of Completed
  int? _expandedTaskId; // Currently expanded task ID
  bool _isVideoPlaying = false;
  bool _isVideoBuffering = false;

  @override
  Widget build(BuildContext context) {
    final goalId = ModalRoute.of(context)?.settings.arguments as String? ?? 'inner-peace';

    return BlocBuilder<GoalsBloc, GoalsState>(
      builder: (context, state) {
        final goal = state.getGoalById(goalId);

        if (goal == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Goal not found',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          );
        }

        final progress = goal.progressPercentage;
        final completedTasks = goal.tasks.where((t) => t.isCompleted).toList();
        final pendingTasks = goal.tasks.where((t) => !t.isCompleted).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                const GoalAppBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildHeader(goal, progress),
                      const SizedBox(height: 18),
                      GoalSegmentControl(
                        labels: const ['Completed tasks', 'Pending tasks'],
                        selectedIndex: _selectedTabIndex,
                        onChanged: (i) => setState(() {
                          _selectedTabIndex = i;
                          _expandedTaskId = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: KeyedSubtree(
                          key: ValueKey(_selectedTabIndex),
                          child: _selectedTabIndex == 0
                              ? _buildCompletedTasksTab(completedTasks)
                              : _buildPendingTasksTab(
                                  context, goal, pendingTasks),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Goal goal, int progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          goal.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(goal.description, style: GoalUi.body.copyWith(height: 1.35)),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text('Goal Tracking', style: GoalUi.cardTitle),
            ),
            Text(
              '$progress%',
              style: TextStyle(
                color: progress == 100 ? GoalUi.progressFill : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (progress > 0) ...[
          const SizedBox(height: 10),
          GoalProgressBar(progress: progress),
        ],
      ],
    );
  }

  /// Collapsible day card shared by both tabs.
  Widget _buildTaskCard({
    required GoalTask task,
    required List<Widget> expandedChildren,
  }) {
    final isExpanded = _expandedTaskId == task.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: GoalUi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _expandedTaskId = isExpanded ? null : task.id;
            }),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.title, style: GoalUi.cardTitle),
                        const SizedBox(height: 4),
                        Text(
                          task.subtitle,
                          style: const TextStyle(
                            color: GoalUi.textBody,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(15, 4, 15, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          task.content,
                          style: const TextStyle(
                            color: Color(0xFFE5E5E7),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        ...expandedChildren,
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksTab(List<GoalTask> completedTasks) {
    if (completedTasks.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: completedTasks.map((task) {
        return _buildTaskCard(
          task: task,
          expandedChildren: [
            const SizedBox(height: 20),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0x1A4CC35A),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0x4D4CC35A)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: GoalUi.progressFill,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: GoalUi.progressFill,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState({String message = "You haven't finished any tasks yet"}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 140,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4E3629), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -12,
                left: 40,
                right: 40,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9E9E9E),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF4E3629), width: 2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) {
                    final isChecked = index < 2;
                    final checkColor = isChecked ? const Color(0xFFB17E64) : Colors.transparent;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 4,
                                width: 45 + (index == 1 ? 15.0 : 0.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCD6CD),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 4,
                                width: 25 + (index == 0 ? 10.0 : 0.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E0D8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFB17E64),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: isChecked
                              ? Icon(
                                  Icons.check,
                                  size: 13,
                                  color: checkColor,
                                )
                              : null,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTasksTab(BuildContext context, Goal goal, List<GoalTask> pendingTasks) {
    if (pendingTasks.isEmpty) {
      return _buildEmptyState(message: "There are no pending tasks for this goal.");
    }

    return Column(
      children: pendingTasks.map((task) {
        return _buildTaskCard(
          task: task,
          expandedChildren: [
            // YouTube video mockup for Day 1 Inner Peace
            if (task.id == 1 && goal.id == 'inner-peace') ...[
              const SizedBox(height: 20),
              _buildYouTubeVideoMockup(),
              const SizedBox(height: 12),
              _buildVideoPageIndicators(),
            ],
            const SizedBox(height: 20),
            GoalPillButton(
              label: 'Mark as Done',
              onTap: () {
                context.read<GoalsBloc>().add(GoalTaskCompleted(goal.id, task.id));
                setState(() => _expandedTaskId = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          '${task.title} marked completed!',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: GoalUi.progressFill,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            GoalPillButton(
              label: 'Chat With Noorva',
              primary: false,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.guide,
                arguments: GoalChatArguments(
                  goalId: goal.id,
                  taskId: task.id,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildYouTubeVideoMockup() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video Player Box
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    'assets/images/mindful_breathing.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white10,
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.white30, size: 40),
                      ),
                    ),
                  ),
                ),

                // Play overlay
                if (!_isVideoPlaying)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVideoBuffering = true;
                        });
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          if (mounted) {
                            setState(() {
                              _isVideoBuffering = false;
                              _isVideoPlaying = true;
                            });
                          }
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: _isVideoBuffering
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      color: Colors.black54,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isVideoPlaying = false;
                              });
                            },
                            child: const Icon(Icons.pause, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: LinearProgressIndicator(
                              value: 0.15,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "0:45 / 5:00",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Metadata Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/noorva_guide.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mindful breathing in 5 minutes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Mystic World • 100K Views • 5 years ago",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.more_vert,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPageIndicators() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '●',
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
        SizedBox(width: 6),
        Text(
          '○',
          style: TextStyle(color: Colors.white38, fontSize: 10),
        ),
        SizedBox(width: 6),
        Text(
          '○',
          style: TextStyle(color: Colors.white38, fontSize: 10),
        ),
        SizedBox(width: 6),
        Text(
          '○',
          style: TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}
