class GoalTask {
  final int id;
  final String title;
  final String subtitle;
  final String content;
  bool isCompleted;

  GoalTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    this.isCompleted = false,
  });

  GoalTask copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? content,
    bool? isCompleted,
  }) {
    return GoalTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final String? priority;
  final List<GoalTask> tasks;
  final String? bottomText;
  final bool isCompleted;
  final String? startedOnText;
  final String? planTitle;
  final String? planSize;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    this.priority,
    required this.tasks,
    this.bottomText,
    this.isCompleted = false,
    this.startedOnText,
    this.planTitle,
    this.planSize,
  });

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;

  int get progressPercentage {
    if (tasks.isEmpty) return 0;
    return (completedTasksCount / tasks.length * 100).round();
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    List<GoalTask>? tasks,
    String? bottomText,
    bool? isCompleted,
    String? startedOnText,
    String? planTitle,
    String? planSize,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      tasks: tasks ?? this.tasks,
      bottomText: bottomText ?? this.bottomText,
      isCompleted: isCompleted ?? this.isCompleted,
      startedOnText: startedOnText ?? this.startedOnText,
      planTitle: planTitle ?? this.planTitle,
      planSize: planSize ?? this.planSize,
    );
  }
}
