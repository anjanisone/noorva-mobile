import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/goal_model.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_state.dart';

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
                _buildAppBar(),
                const SizedBox(height: 16),
                _buildSegmentControl(),
                const SizedBox(height: 24),
                Expanded(
                  child: currentGoals.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: currentGoals.length,
                          itemBuilder: (context, index) {
                            final goal = currentGoals[index];
                            return Column(
                              children: [
                                _buildGoalCard(
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
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomWidget(Goal goal) {
    if (goal.isCompleted) {
      return Text(
        goal.bottomText ?? '',
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      );
    }
    
    if (goal.progressPercentage == 0) {
      return Text(
        goal.bottomText ?? '',
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Progress',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          goal.bottomText ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
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
                child: Image.asset(
                  'assets/icons/back_arrow.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Text(
            'Goals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
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

  Widget _buildSegmentControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? AppColors.borderLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Ongoing goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? AppColors.borderLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
            if (priority != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priority.toLowerCase() == 'high priority'
                      ? const Color(0x26EF5350)
                      : const Color(0x26FFA726),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priority.toLowerCase() == 'high priority'
                        ? const Color(0xFFEF5350)
                        : const Color(0xFFFFA726),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.north_east,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
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
                          color: const Color(
                              0xFF65C466), // Bright green matching the design
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
            const SizedBox(height: 20),
            bottomWidget,
          ],
        ),
      ),
    );
  }
}
