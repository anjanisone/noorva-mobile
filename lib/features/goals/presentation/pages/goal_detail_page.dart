import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/noorva_delete_dialog.dart';
import '../../data/models/goal_model.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../widgets/goal_ui.dart';
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
                const GoalAppBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    physics: const BouncingScrollPhysics(),
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
                      Text(
                        goal.description,
                        style: GoalUi.body.copyWith(height: 1.35),
                      ),
                      const SizedBox(height: 18),
                      _buildGoalTrackingCard(context, goal),
                      if (goal.planTitle != null) ...[
                        const SizedBox(height: 16),
                        _buildCompletePlanCard(goal),
                      ],
                      const SizedBox(height: 16),
                      _buildTalkWithNoorvaCard(context, goal),
                      const SizedBox(height: 16),
                      _buildDeleteCard(context, goal),
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

  // ─── Goal Tracking Card ───────────────────────────────────────────────────────

  Widget _buildGoalTrackingCard(BuildContext context, Goal goal) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.goalTracking,
        arguments: goal.id,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
        decoration: GoalUi.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text('Goal Tracking', style: GoalUi.cardTitle),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GoalProgressRow(progress: goal.progressPercentage),
            const SizedBox(height: 10),
            Text(
              goal.startedOnText ?? 'Track your daily progress',
              style: GoalUi.body,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Complete Plan Card ───────────────────────────────────────────────────────

  Widget _buildCompletePlanCard(Goal goal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 8),
      decoration: GoalUi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Complete Plan', style: GoalUi.cardTitle),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: GoalUi.inset,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.planTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.planSize ?? '2MB',
                        style: const TextStyle(
                          color: GoalUi.textBody,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/icons/download.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.file_download_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Plan',
                    style: TextStyle(color: GoalUi.textBody, fontSize: 13),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.north_east_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Talk with Noorva Card ────────────────────────────────────────────────────

  Widget _buildTalkWithNoorvaCard(BuildContext context, Goal goal) {
    const mascotOverflow = 36.0;
    const mascotWidth = 120.0;

    return Container(
      decoration: GoalUi.cardDecoration(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 16, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Talk with Noorva', style: GoalUi.cardTitle),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(right: mascotWidth - 12),
                  child: Text(
                    'Last conversation is on dd/mm/yyyy hh:mm',
                    style: TextStyle(
                      color: GoalUi.textBody,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.only(right: mascotWidth - 8),
                  child: GoalPillButton(
                    label: 'Resume Chat',
                    height: 50,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.guide,
                      arguments: GoalChatArguments(
                        goalId: goal.id,
                        taskId: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Noorva peeks over the top edge; clipped at the card's bottom.
          Positioned(
            right: 0,
            bottom: 0,
            top: -mascotOverflow,
            width: mascotWidth,
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                ),
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxWidth: 260,
                  maxHeight: 340,
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: Image.asset(
                      'assets/images/white_dress_oldman.png',
                      width: 260,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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

  // ─── Delete Goal Card ─────────────────────────────────────────────────────────

  Widget _buildDeleteCard(BuildContext context, Goal goal) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDeleteDialog(context, goal),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GoalUi.cardBorder),
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
                      color: GoalUi.danger,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This is a permanent action and cannot be undone',
                    style: TextStyle(color: GoalUi.textBody, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Image.asset(
              'assets/images/delete_goal.png',
              width: 44,
              height: 44,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.delete_outline,
                color: GoalUi.danger,
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
