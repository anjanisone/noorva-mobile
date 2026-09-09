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
