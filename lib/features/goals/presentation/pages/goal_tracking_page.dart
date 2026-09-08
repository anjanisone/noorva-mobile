import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/goals_provider.dart';
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

    return Consumer<GoalsProvider>(
      builder: (context, provider, child) {
        final goal = provider.getGoalById(goalId);

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
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildHeader(goal, progress),
                      const SizedBox(height: 24),
                      _buildSegmentControl(),
                      const SizedBox(height: 24),
                      if (_selectedTabIndex == 0)
                        _buildCompletedTasksTab(completedTasks)
                      else
                        _buildPendingTasksTab(context, goal, pendingTasks),
                      const SizedBox(height: 40),
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

  Widget _buildAppBar(BuildContext context) {
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
                child: Image.asset(
                  'assets/icons/back_arrow.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
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
          ),
        ],
      ),
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
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          goal.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Goal Tracking',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$progress%',
              style: TextStyle(
                color: progress == 100 ? const Color(0xFF65C466) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress / 100,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF65C466),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentControl() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedTabIndex = 0;
                _expandedTaskId = null;
              }),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? AppColors.borderLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedTabIndex == 0
                      ? Border.all(color: Colors.white30)
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Completed tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: _selectedTabIndex == 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedTabIndex = 1;
                _expandedTaskId = null;
              }),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? AppColors.borderLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedTabIndex == 1
                      ? Border.all(color: Colors.white30)
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Pending tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: _selectedTabIndex == 1
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
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
        final isExpanded = _expandedTaskId == task.id;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              GestureDetector(
                onTap: () => setState(() {
                  _expandedTaskId = isExpanded ? null : task.id;
                }),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 18.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.subtitle,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded content
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 16),
                      Text(
                        task.content,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Completed badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1A65C466),
                          borderRadius: BorderRadius.circular(30),
                          border:
                              Border.all(color: const Color(0x4D65C466)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFF65C466),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Completed',
                              style: TextStyle(
                                color: Color(0xFF65C466),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
        final taskId = task.id;
        final isExpanded = _expandedTaskId == taskId;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedTaskId = isExpanded ? null : taskId;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.subtitle,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              // Card Expanded Content
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 16),
                      Text(
                        task.content,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      
                      // YouTube video mockup for Day 1 Inner Peace
                      if (taskId == 1 && goal.id == 'inner-peace') ...[
                        const SizedBox(height: 20),
                        _buildYouTubeVideoMockup(),
                        const SizedBox(height: 12),
                        _buildVideoPageIndicators(),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Two stacked capsule buttons
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65C466),
                          foregroundColor: const Color(0xFF1E3D1E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          // Complete task in provider
                          Provider.of<GoalsProvider>(context, listen: false)
                              .completeTask(goal.id, task.id);
                          setState(() {
                            _expandedTaskId = null; // collapse
                          });
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
                              backgroundColor: const Color(0xFF65C466),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        },
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF262629), // Dark gray
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to /guide with GoalChatArguments
                          Navigator.pushNamed(
                            context,
                            AppRoutes.guide,
                            arguments: GoalChatArguments(
                              goalId: goal.id,
                              taskId: task.id,
                            ),
                          );
                        },
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Resume With Noorva',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
