import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/noorva_delete_dialog.dart';
import '../../data/models/goal_model.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../../../guide/presentation/pages/guide_page.dart';

class GoalDetailPage extends StatelessWidget {
  const GoalDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goalId =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'inner-peace';

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

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        goal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        goal.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildGoalTrackingCard(context, goal),
                      if (goal.planTitle != null) ...[
                        const SizedBox(height: 16),
                        _buildCompletePlanCard(goal),
                      ],
                      const SizedBox(height: 16),
                      _buildTalkWithNoorvaCard(context, goal),
                      const SizedBox(height: 16),
                      _buildDeleteCard(context, goal),
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

  // ─── App Bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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

  // ─── Goal Tracking Card ───────────────────────────────────────────────────────

  Widget _buildGoalTrackingCard(BuildContext context, Goal goal) {
    final progress = goal.progressPercentage;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.goalTracking,
        arguments: goal.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goal Tracking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white54, size: 22),
              ],
            ),
            const SizedBox(height: 16),
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
                      widthFactor: progress / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF65C466),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$progress%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              goal.startedOnText ?? 'Track your daily progress',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Complete Plan Card ───────────────────────────────────────────────────────

  Widget _buildCompletePlanCard(Goal goal) {
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
          const Text(
            'Complete Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.planTitle!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.planSize ?? '2MB',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.file_download_outlined,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.north_east, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Talk with Noorva Card ────────────────────────────────────────────────────

  Widget _buildTalkWithNoorvaCard(BuildContext context, Goal goal) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left: text + button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Talk with Noorva',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Last conversation is on\ndd/mm/yyyy hh:mm',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.guide,
                      arguments: GoalChatArguments(
                        goalId: goal.id,
                        taskId: 0,
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          'Resume Chat',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right: Noorva character
          Image.asset(
            'assets/images/white_dress_ol   dman.png',
            width: 90,
            height: 160,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => const SizedBox(width: 90),
          ),
        ],
      ),
    );
  }

  // ─── Delete Goal Card ─────────────────────────────────────────────────────────

  Widget _buildDeleteCard(BuildContext context, Goal goal) {
    return GestureDetector(
      onTap: () => _showDeleteDialog(context, goal),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete Goal',
                    style: TextStyle(
                      color: Color(0xFFEF5350),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This is a permanent action and cannot be undone',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Image.asset(
              'assets/images/delete_goal.png',
              width: 34,
              height: 34,
              color: const Color(0xFFEF5350),
              errorBuilder: (_, __, ___) => const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF5350),
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Goal goal) {
    final progress = goal.progressPercentage;
    final bool isUnstarted = progress == 0;
    
    final String title = isUnstarted ? 'Delete goal?' : 'Delete active goal?';
    
    final List<String> activeGoalMessages = [
      "You are choosing to step away from this goal. This is not a failure; it is a conscious decision to return energy to your current focus. Shall we clear the horizon?",
      "This goal is currently in progress and has unfinished tasks. Deleting it will permanently remove the goal and all of its associated tasks from your workspace. This action cannot be undone",
      "Some paths are only meant to be walked partway. Releasing this intention frees your bandwidth for what truly matters today. Are you ready to let it go?",
    ];

    final String body = isUnstarted
        ? "You haven't started working on this goal yet. Removing it will permanently delete it from your workspace"
        : activeGoalMessages[DateTime.now().millisecond % activeGoalMessages.length];

    showDialog(
      context: context,
      builder: (dialogContext) => NoorvaDeleteDialog(
        title: title,
        content: body,
        topImagePath: 'assets/images/personalization.png',
        onConfirm: () {
          context.read<GoalsBloc>().add(GoalDeleted(goal.id));
          Navigator.pop(context);
        },
      ),
    );
  }
}
