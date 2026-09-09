import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/noorva_delete_dialog.dart';
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

        final progress = event.progressPercentage;
        final progressPct = (progress * 100).toInt();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, event),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Banner Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          event.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.white10,
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.white30, size: 50),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Priority Pill
                      _buildPriorityPill(event.priority),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        event.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Progress Bar & Percent Indicator
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
                                widthFactor: progress,
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
                            '$progressPct%',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tasks List Title
                      const Text(
                        'Tasks List',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Task List items
                      ...event.tasks.map((task) => _buildTaskItem(context, event.id, task)),
                      
                      // Extra bottom padding so scroll doesn't block the floating button
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomChatButton(context),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
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
          
          // Event Title
          Expanded(
            child: Text(
              event.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Trash/Delete Button
          GestureDetector(
            onTap: () => _showDeleteConfirmation(context, event.id),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Center(
                child: Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF5350), // Premium soft red
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityPill(EventPriority priority) {
    String text;
    Color bg;
    Color textCol;

    switch (priority) {
      case EventPriority.high:
        text = 'High Priority';
        bg = const Color(0xFF381A1A);
        textCol = const Color(0xFFFF8A8A);
        break;
      case EventPriority.medium:
        text = 'Medium Priority';
        bg = const Color(0xFF382A1A);
        textCol = const Color(0xFFFFC58A);
        break;
      case EventPriority.low:
        text = 'Low Priority';
        bg = const Color(0xFF1A2A38);
        textCol = const Color(0xFF8AC5FF);
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textCol,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, String eventId, EventTask task) {
    final isExpanded = _expandedTaskIds.contains(task.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Tappable area to expand/collapse)
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedTaskIds.remove(task.id);
                } else {
                  _expandedTaskIds.add(task.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Circular/Rounded Checked State Checkbox
                  GestureDetector(
                    onTap: () {
                      context.read<EventsBloc>().add(EventTaskToggled(eventId, task.id));
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.isCompleted ? const Color(0xFF424244) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: task.isCompleted ? const Color(0xFF424244) : AppColors.borderLight,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Task Name
                  Expanded(
                    child: Text(
                      task.name,
                      style: TextStyle(
                        color: task.isCompleted ? AppColors.textTertiary : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Dynamic Arrow Icon
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white60,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Content Area
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task details text
                  Text(
                    task.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Action Button ("Done" green or "Mark as Done" white)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<EventsBloc>().add(EventTaskToggled(eventId, task.id));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: task.isCompleted ? const Color(0xFF65C466) : Colors.white,
                        foregroundColor: task.isCompleted ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        task.isCompleted ? 'Done' : 'Mark as Done',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomChatButton(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: InkWell(
          onTap: () {
            // Placeholder callback
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Starting chat with Noorva...'),
                backgroundColor: AppColors.card,
              ),
            );
          },
          borderRadius: BorderRadius.circular(27),
          child: const Center(
            child: Text(
              'Chat With Noorva',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
