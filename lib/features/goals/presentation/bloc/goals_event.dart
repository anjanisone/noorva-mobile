import 'package:equatable/equatable.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object?> get props => [];
}

class GoalTaskCompleted extends GoalsEvent {
  final String goalId;
  final int taskId;

  const GoalTaskCompleted(this.goalId, this.taskId);

  @override
  List<Object?> get props => [goalId, taskId];
}

class GoalDeleted extends GoalsEvent {
  final String goalId;

  const GoalDeleted(this.goalId);

  @override
  List<Object?> get props => [goalId];
}
