import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

class NotificationState extends Equatable {
  final List<NotificationModel> notifications;
  final bool isSelectionMode;
  final String? lastActionResponse;

  const NotificationState({
    this.notifications = const [],
    this.isSelectionMode = false,
    this.lastActionResponse,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isSelectionMode,
    String? lastActionResponse,
    bool clearLastActionResponse = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      lastActionResponse:
          clearLastActionResponse ? null : (lastActionResponse ?? this.lastActionResponse),
    );
  }

  // Group notifications dynamically: Today (last 24 hours) vs This Week (older)
  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return notifications.where((n) => n.createdAt.isAfter(todayStart)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<NotificationModel> get weekNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return notifications.where((n) => n.createdAt.isBefore(todayStart)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  List<Object?> get props => [notifications, isSelectionMode, lastActionResponse];
}
