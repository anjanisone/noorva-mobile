import 'package:equatable/equatable.dart';
import '../../data/models/event_model.dart';

class EventsState extends Equatable {
  final List<Event> events;

  const EventsState({this.events = const []});

  EventsState copyWith({List<Event>? events}) {
    return EventsState(events: events ?? this.events);
  }

  Event? getEventById(String id) {
    try {
      return events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [events];
}
