import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
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
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  final events = state.events;
                  if (events.isEmpty) {
                    return const Center(
                      child: Text(
                        'No events scheduled',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: events.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
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
          const Text(
            'Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Empty placeholder to balance centering of title
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final progress = event.progressPercentage;
    final progressPct = (progress * 100).toInt();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.eventDetail,
          arguments: event.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Banner with loading skeletons and error fallbacks
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                event.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: Colors.white10,
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.white30, size: 40),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Priority Pill
            _buildPriorityPill(event.priority),
            const SizedBox(height: 12),

            // Title and navigation arrow row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.north_east,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Time subtitle (italic style)
            Text(
              'In ${event.daysRemaining} days',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Sub tasks bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sub tasks',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${event.completedTasksCount}',
                          style: const TextStyle(
                            color: Color(0xFF65C466),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '/${event.tasks.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Progress bar and percentage text
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
          ],
        ),
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

    return Container(
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
    );
  }
}
