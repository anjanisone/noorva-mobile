import 'package:equatable/equatable.dart';
import '../../data/models/goal_model.dart';

class GoalsState extends Equatable {
  final List<Goal> goals;

  const GoalsState({this.goals = const []});

  GoalsState copyWith({List<Goal>? goals}) {
    return GoalsState(goals: goals ?? this.goals);
  }

  List<Goal> get ongoingGoals => goals.where((g) => !g.isCompleted).toList();
  List<Goal> get completedGoals => goals.where((g) => g.isCompleted).toList();

  Goal? getGoalById(String id) {
    try {
      return goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [goals];
}
