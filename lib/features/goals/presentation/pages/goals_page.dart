import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/goal_model.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_state.dart';
import '../widgets/goal_ui.dart';

class TargetBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width < size.height ? size.width : size.height) / 2.2;

    final paintRed = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.fill;

    final paintWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw concentric circles
    canvas.drawCircle(center, maxRadius, paintRed);
    canvas.drawCircle(center, maxRadius * 0.8, paintWhite);
    canvas.drawCircle(center, maxRadius * 0.6, paintRed);
    canvas.drawCircle(center, maxRadius * 0.4, paintWhite);
    canvas.drawCircle(center, maxRadius * 0.2, paintRed);

    // Draw the stuck arrow diagonally from top-right to center
    final paintArrowShaft = Paint()
      ..color = const Color(0xFF1E1E20)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintArrowHead = Paint()
      ..color = const Color(0xFF1E1E20)
      ..style = PaintingStyle.fill;

    final paintFeathers = Paint()
      ..color = const Color(0xFFFFA726)
      ..style = PaintingStyle.fill;

    final arrowTip = Offset(center.dx - 2, center.dy + 2);
    final arrowStart = Offset(center.dx + maxRadius * 0.7, center.dy - maxRadius * 0.7);

    // Draw shaft
    canvas.drawLine(arrowStart, arrowTip, paintArrowShaft);

    // Draw Arrowhead
    final path = Path();
    path.moveTo(arrowTip.dx, arrowTip.dy);
    path.lineTo(arrowTip.dx + 16, arrowTip.dy - 4);
    path.lineTo(arrowTip.dx + 4, arrowTip.dy - 16);
    path.close();
    canvas.drawPath(path, paintArrowHead);

    // Draw tail feathers (flights) flaring out
    final featherPath = Path();
    featherPath.moveTo(arrowStart.dx, arrowStart.dy);
    featherPath.lineTo(arrowStart.dx + 12, arrowStart.dy - 20);
    featherPath.lineTo(arrowStart.dx + 28, arrowStart.dy - 12);
    featherPath.lineTo(arrowStart.dx + 16, arrowStart.dy + 4);
    featherPath.close();

    final featherPath2 = Path();
    featherPath2.moveTo(arrowStart.dx, arrowStart.dy);
    featherPath2.lineTo(arrowStart.dx + 20, arrowStart.dy - 4);
    featherPath2.lineTo(arrowStart.dx + 24, arrowStart.dy + 12);
    featherPath2.lineTo(arrowStart.dx + 4, arrowStart.dy + 16);
    featherPath2.close();

    canvas.drawPath(featherPath, paintFeathers);
    canvas.drawPath(featherPath2, paintFeathers);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  int _selectedTabIndex = 0; // 0 for Ongoing, 1 for Completed

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalsBloc, GoalsState>(
      builder: (context, state) {
        final ongoing = state.ongoingGoals;
        final completed = state.completedGoals;
        final currentGoals = _selectedTabIndex == 0 ? ongoing : completed;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                const GoalAppBar(title: 'Goals'),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GoalSegmentControl(
                    labels: const ['Ongoing', 'Completed'],
                    selectedIndex: _selectedTabIndex,
                    onChanged: (i) => setState(() => _selectedTabIndex = i),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: currentGoals.isEmpty
                        ? KeyedSubtree(
                            key: ValueKey('empty_$_selectedTabIndex'),
                            child: _buildEmptyState(),
                          )
                        : ListView.separated(
                            key: ValueKey('list_$_selectedTabIndex'),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: currentGoals.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final goal = currentGoals[index];
                              return _buildGoalCard(
                                title: goal.title,
                                description: goal.description,
                                progress: goal.progressPercentage,
                                priority: goal.priority,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.goalDetail,
                                  arguments: goal.id,
                                ),
                                bottomWidget: _buildBottomWidget(goal),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const _bottomTextStyle = GoalUi.body;

  Widget _buildBottomWidget(Goal goal) {
    if (goal.isCompleted || goal.progressPercentage == 0) {
      return Text(goal.bottomText ?? '', style: _bottomTextStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Progress',
          style: TextStyle(color: Color(0xFFA5A5A8), fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(goal.bottomText ?? '', style: _bottomTextStyle),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_goal.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            _selectedTabIndex == 0 ? 'No active goals' : 'No completed goals yet',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String description,
    required int progress,
    required Widget bottomWidget,
    String? priority,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
        decoration: GoalUi.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (priority != null) ...[
              GoalTag.priority(priority),
              const SizedBox(height: 10),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(title, style: GoalUi.cardTitle),
                ),
                const SizedBox(width: 12),
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.north_east_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoalUi.body.copyWith(height: 1.15),
            ),
            const SizedBox(height: 18),
            GoalProgressRow(progress: progress),
            const SizedBox(height: 18),
            bottomWidget,
          ],
        ),
      ),
    );
  }
}
