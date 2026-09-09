import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationEvent {
  const NotificationsLoadRequested();
}

class NotificationsInitializeRequested extends NotificationEvent {
  const NotificationsInitializeRequested();
}

class NotificationAdded extends NotificationEvent {
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;

  const NotificationAdded({
    required this.title,
    required this.body,
    required this.type,
    this.data,
  });

  @override
  List<Object?> get props => [title, body, type, data];
}

class NotificationSimulateRequested extends NotificationEvent {
  final int index;

  const NotificationSimulateRequested(this.index);

  @override
  List<Object?> get props => [index];
}

class NotificationMarkedAsRead extends NotificationEvent {
  final String id;

  const NotificationMarkedAsRead(this.id);

  @override
  List<Object?> get props => [id];
}

class NotificationSelectionModeToggled extends NotificationEvent {
  final bool value;

  const NotificationSelectionModeToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class NotificationSelectAllToggled extends NotificationEvent {
  final bool select;

  const NotificationSelectAllToggled(this.select);

  @override
  List<Object?> get props => [select];
}

class NotificationSelectionToggled extends NotificationEvent {
  final String id;

  const NotificationSelectionToggled(this.id);

  @override
  List<Object?> get props => [id];
}

class NotificationsDeleteSelectedRequested extends NotificationEvent {
  const NotificationsDeleteSelectedRequested();
}

class NotificationActionResponseCleared extends NotificationEvent {
  const NotificationActionResponseCleared();
}

class NotificationLocalActionReceived extends NotificationEvent {
  final String response;

  const NotificationLocalActionReceived(this.response);

  @override
  List<Object?> get props => [response];
}
