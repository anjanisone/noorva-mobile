import 'package:equatable/equatable.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class EventTaskToggled extends EventsEvent {
  final String eventId;
  final String taskId;

  const EventTaskToggled(this.eventId, this.taskId);

  @override
  List<Object?> get props => [eventId, taskId];
}

class EventDeleted extends EventsEvent {
  final String eventId;

  const EventDeleted(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
