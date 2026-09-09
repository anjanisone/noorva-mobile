import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/event_model.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsState(events: _seedEvents())) {
    on<EventTaskToggled>(_onTaskToggled);
    on<EventDeleted>(_onEventDeleted);
  }

  void _onTaskToggled(EventTaskToggled event, Emitter<EventsState> emit) {
    final events = List<Event>.from(state.events);
    final eventIndex = events.indexWhere((e) => e.id == event.eventId);
    if (eventIndex == -1) return;
    final target = events[eventIndex];
    final taskIndex = target.tasks.indexWhere((t) => t.id == event.taskId);
    if (taskIndex == -1) return;

    final updatedTasks = List<EventTask>.from(target.tasks);
    updatedTasks[taskIndex] = updatedTasks[taskIndex].copyWith(
      isCompleted: !updatedTasks[taskIndex].isCompleted,
    );
    events[eventIndex] = target.copyWith(tasks: updatedTasks);

    emit(state.copyWith(events: events));
  }

  void _onEventDeleted(EventDeleted event, Emitter<EventsState> emit) {
    final events = state.events.where((e) => e.id != event.eventId).toList();
    emit(state.copyWith(events: events));
  }

  static List<Event> _seedEvents() => [
        Event(
          id: 'london-trip',
          title: 'Trip to London',
          description:
              'A trip to london for a business meeting in the next  10 days. Here is your checklist to prepare for the travel day',
          daysRemaining: 10,
          imageUrl: 'assets/images/event1.jpg',
          priority: EventPriority.high,
          tasks: [
            EventTask(
              id: 'lt-1',
              name: 'Task Name',
              description:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu. Integer tempor, ante vel rutrum dictum, leo nisl facilisis nibh, vel sagittis metus diam eget dolor. Nulla sed risus dapibus, porttitor est vitae, scelerisque ipsum. Sed pulvinar iaculis turpis id convallis. Duis at porta nisl. Etiam eget odio laoreet odio tempor finibus vitae quis tortor. Praesent suscipit vel leo non sagittis.',
              isCompleted: true,
            ),
            EventTask(
              id: 'lt-2',
              name: 'Task Name',
              description:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu.',
              isCompleted: true,
            ),
            EventTask(
              id: 'lt-3',
              name: 'Lorem ipsum dolo sit amet',
              description:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu.',
              isCompleted: false,
            ),
            EventTask(
              id: 'lt-4',
              name: 'Task Name',
              description:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu. Integer tempor, ante vel rutrum dictum, leo nisl facilisis nibh, vel sagittis metus diam eget dolor.',
              isCompleted: false,
            ),
            EventTask(
              id: 'lt-5',
              name: 'Task Name',
              description:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu.',
              isCompleted: false,
            ),
          ],
        ),
        Event(
          id: 'design-campaign',
          title: 'Plan for Global Design Campaign',
          description:
              'Establish the core creative direction and cross-channel strategy for the global design campaign launch.',
          daysRemaining: 15,
          imageUrl: 'assets/images/event2.jpg',
          priority: EventPriority.medium,
          tasks: List.generate(20, (index) {
            if (index < 3) {
              return EventTask(
                id: 'dc-$index',
                name: index == 0
                    ? 'Define campaign concept'
                    : index == 1
                        ? 'Select brand ambassadors'
                        : 'Establish design guidelines',
                description:
                    'Determine key messaging frameworks, typography choices, and dynamic design templates for visual storytelling.',
                isCompleted: true,
              );
            } else {
              return EventTask(
                id: 'dc-$index',
                name: index == 3 ? 'Lorem ipsum dolo sit amet, conse...' : 'Task Name ${index + 1}',
                description:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu.',
                isCompleted: false,
              );
            }
          }),
        ),
      ];
}
