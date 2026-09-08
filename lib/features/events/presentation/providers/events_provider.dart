import 'package:flutter/material.dart';

enum EventPriority { high, medium, low }

class EventTask {
  final String id;
  final String name;
  final String description;
  bool isCompleted;

  EventTask({
    required this.id,
    required this.name,
    required this.description,
    this.isCompleted = false,
  });

  EventTask copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCompleted,
  }) {
    return EventTask(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final int daysRemaining;
  final String imageUrl;
  final EventPriority priority;
  final List<EventTask> tasks;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.daysRemaining,
    required this.imageUrl,
    required this.priority,
    required this.tasks,
  });

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  
  double get progressPercentage {
    if (tasks.isEmpty) return 0.0;
    return completedTasksCount / tasks.length;
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    int? daysRemaining,
    String? imageUrl,
    EventPriority? priority,
    List<EventTask>? tasks,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      tasks: tasks ?? this.tasks,
    );
  }
}

class EventsProvider extends ChangeNotifier {
  final List<Event> _events = [
    Event(
      id: 'london-trip',
      title: 'Trip to London',
      description: 'A trip to london for a business meeting in the next  10 days. Here is your checklist to prepare for the travel day',
      daysRemaining: 10,
      imageUrl: 'assets/images/event1.jpg',
      priority: EventPriority.high,
      tasks: [
        EventTask(
          id: 'lt-1',
          name: 'Task Name',
          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu. Integer tempor, ante vel rutrum dictum, leo nisl facilisis nibh, vel sagittis metus diam eget dolor. Nulla sed risus dapibus, porttitor est vitae, scelerisque ipsum. Sed pulvinar iaculis turpis id convallis. Duis at porta nisl. Etiam eget odio laoreet odio tempor finibus vitae quis tortor. Praesent suscipit vel leo non sagittis.',
          isCompleted: true,
        ),
        EventTask(
          id: 'lt-2',
          name: 'Task Name',
          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu.',
          isCompleted: true,
        ),
        EventTask(
          id: 'lt-3',
          name: 'Lorem ipsum dolo sit amet',
          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu.',
          isCompleted: false,
        ),
        EventTask(
          id: 'lt-4',
          name: 'Task Name',
          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu. Integer tempor, ante vel rutrum dictum, leo nisl facilisis nibh, vel sagittis metus diam eget dolor.',
          isCompleted: false,
        ),
        EventTask(
          id: 'lt-5',
          name: 'Task Name',
          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu.',
          isCompleted: false,
        ),
      ],
    ),
    Event(
      id: 'design-campaign',
      title: 'Plan for Global Design Campaign',
      description: 'Establish the core creative direction and cross-channel strategy for the global design campaign launch.',
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
            description: 'Determine key messaging frameworks, typography choices, and dynamic design templates for visual storytelling.',
            isCompleted: true,
          );
        } else {
          return EventTask(
            id: 'dc-$index',
            name: index == 3 ? 'Lorem ipsum dolo sit amet, conse...' : 'Task Name ${index + 1}',
            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ut magna rutrum erat pretium rutrum vel ac tellus. Phasellus malesuada convallis nisl, sit amet ultrices nisl mattis eu.',
            isCompleted: false,
          );
        }
      }),
    ),
  ];

  List<Event> get events => List.unmodifiable(_events);

  Event? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void toggleTask(String eventId, String taskId) {
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _events[eventIndex];
      final taskIndex = event.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        event.tasks[taskIndex].isCompleted = !event.tasks[taskIndex].isCompleted;
        notifyListeners();
      }
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
