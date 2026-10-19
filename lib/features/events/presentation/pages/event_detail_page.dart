import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/noorva_delete_dialog.dart';
import '../../../goals/presentation/widgets/goal_ui.dart';
import '../../data/models/event_model.dart';
import '../bloc/events_bloc.dart';
import '../bloc/events_event.dart';
import '../bloc/events_state.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  // Set to store the IDs of currently expanded tasks
  final Set<String> _expandedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final event = state.getEventById(widget.eventId);
        if (event == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Event not found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final progressPct =
            (event.progressPercentage.clamp(0.0, 1.0) * 100).round();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, event),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 358 / 180,
                          child: Image.asset(
                            event.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: GoalUi.inset,
                              child: const Center(
                                child: Icon(Icons.image_outlined,
                                    color: Colors.white30, size: 44),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GoalTag(
                          label: _priorityLabel(event.priority),
                          colors: _priorityColors(event.priority),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        event.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                              child: GoalProgressBar(progress: progressPct)),
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
                      const SizedBox(height: 24),
                      const Text(
                        'Tasks List',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      const SizedBox(height: 16),
                      for (final task in event.tasks)
                        _buildTaskItem(context, event.id, task),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: GoalPillButton(
                    label: 'Chat With Noorva',
                    height: 50,
                    onTap: () {
                      // Placeholder callback
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Starting chat with Noorva...'),
                          backgroundColor: GoalUi.card,
                        ),
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

  Widget _buildAppBar(BuildContext context, Event event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GoalCircleButton(
            asset: 'assets/icons/back_arrow.png',
            size: 36,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                event.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showDeleteConfirmation(context, event.id),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GoalUi.card,
                border: Border.all(color: GoalUi.cardBorder),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: GoalUi.danger,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, String eventId, EventTask task) {
    final isExpanded = _expandedTaskIds.contains(task.id);
    void toggleDone() =>
        context.read<EventsBloc>().add(EventTaskToggled(eventId, task.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GoalUi.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3B40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedTaskIds.remove(task.id);
              } else {
                _expandedTaskIds.add(task.id);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
              child: Row(
                children: [
                  // Larger hit area than the box itself.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: toggleDone,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? const Color(0xFF6B6B70)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: task.isCompleted
                                ? const Color(0xFF6B6B70)
                                : const Color(0xFFE5E5E7),
                            width: 1.6,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Color(0xFF1A1B1E))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 24,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          task.description,
                          style: const TextStyle(
                            color: Color(0xFFE5E5E7),
                            fontSize: 16,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GoalPillButton(
                          label: task.isCompleted
                              ? 'Mark as Not Done'
                              : 'Mark as Done',
                          primary: !task.isCompleted,
                          onTap: toggleDone,
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
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

  void _showDeleteConfirmation(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (context) {
        return NoorvaDeleteDialog(
          title: 'Delete Event',
          content: 'Are you ready to lift this event from your board and release it to the void?',
          onConfirm: () {
            context.read<EventsBloc>().add(EventDeleted(eventId));
            Navigator.pop(context); // pop detail page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event deleted successfully'),
                backgroundColor: AppColors.card,
              ),
            );
          },
        );
      },
    );
  }
}
