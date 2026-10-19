import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../goals/presentation/widgets/goal_ui.dart';
import '../../data/models/event_model.dart';
import '../bloc/events_bloc.dart';
import '../bloc/events_state.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const GoalAppBar(title: 'Events', showEdit: false),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  final events = state.events;
                  if (events.isEmpty) {
                    return const Center(
                      child: Text(
                        'No events scheduled',
                        style: TextStyle(color: GoalUi.textBody, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    physics: const BouncingScrollPhysics(),
                    itemCount: events.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildEventCard(context, events[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final progress = event.progressPercentage.clamp(0.0, 1.0);
    final progressPct = (progress * 100).round();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.eventDetail,
          arguments: event.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
        decoration: GoalUi.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 326 / 104,
                child: Image.asset(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: GoalUi.inset,
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          color: Colors.white30, size: 36),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GoalTag(
              label: _priorityLabel(event.priority),
              colors: _priorityColors(event.priority),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Padding(
                  padding: EdgeInsets.only(top: 2, right: 4),
                  child: Icon(Icons.north_east_rounded,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'In ${event.daysRemaining} days',
              style: const TextStyle(
                color: GoalUi.textBody,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Sub tasks count
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2B2F),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Sub tasks',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: '${event.completedTasksCount}',
                          style: const TextStyle(color: GoalUi.progressFill),
                        ),
                        TextSpan(
                          text: '/${event.tasks.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(child: GoalProgressBar(progress: progressPct)),
                const SizedBox(width: 30),
                Text(
                  '$progressPct%',
                  style: const TextStyle(
                    color: GoalUi.textMuted,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _priorityLabel(EventPriority priority) => switch (priority) {
        EventPriority.high => 'High Priority',
        EventPriority.medium => 'Medium Priority',
        EventPriority.low => 'Low Priority',
      };

  (Color, Color) _priorityColors(EventPriority priority) => switch (priority) {
        EventPriority.high => GoalUi.tagRed,
        EventPriority.medium => GoalUi.tagAmber,
        EventPriority.low => GoalUi.tagBlue,
      };
}
