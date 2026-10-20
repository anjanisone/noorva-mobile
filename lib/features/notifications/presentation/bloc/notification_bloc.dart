import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/noorva_local_store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../../data/models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  static const String _prefsKey = 'noorva_notifications_list';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationBloc() : super(const NotificationState()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationsInitializeRequested>(_onInitializeRequested);
    on<NotificationAdded>(_onNotificationAdded);
    on<NotificationSimulateRequested>(_onSimulateRequested);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
    on<NotificationSelectionModeToggled>(_onSelectionModeToggled);
    on<NotificationSelectAllToggled>(_onSelectAllToggled);
    on<NotificationSelectionToggled>(_onSelectionToggled);
    on<NotificationsDeleteSelectedRequested>(_onDeleteSelectedRequested);
    on<NotificationActionResponseCleared>(_onActionResponseCleared);
    on<NotificationLocalActionReceived>(_onLocalActionReceived);

    add(const NotificationsLoadRequested());
    add(const NotificationsInitializeRequested());
  }

  // ── Loading / persistence ────────────────────────────────────────────────

  Future<void> _onLoadRequested(NotificationsLoadRequested event, Emitter<NotificationState> emit) async {
    final String? encoded = await NoorvaLocalStore.instance.getString(_prefsKey);
    if (encoded != null) {
      try {
        final List<dynamic> decoded = jsonDecode(encoded);
        final notifications = decoded.map((json) => NotificationModel.fromJson(json)).toList();
        emit(state.copyWith(notifications: notifications));
      } catch (e) {
        debugPrint('Error parsing notifications: $e');
      }
    } else {
      final seeded = _seedDefaultNotifications();
      emit(state.copyWith(notifications: seeded));
      await _saveNotifications(seeded);
    }
  }

  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    final String encoded = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await NoorvaLocalStore.instance.setString(_prefsKey, encoded);
  }

  List<NotificationModel> _seedDefaultNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'End of workday! Check your stats',
        body: 'The day’s execution window is closing. It is time to begin the descent into rest. Save your progress.',
        timestamp: DateFormat('d MMM yyyy, h:mm a').format(now),
        createdAt: now,
        isUnread: true,
        type: 'end_workday',
      ),
      NotificationModel(
        id: '2',
        title: 'You missed a task, reschedule it now',
        body: 'An intention from earlier remains untouched. Shall we shift it to tomorrow, or release it entirely?',
        timestamp: DateFormat('d MMM yyyy, h:mm a').format(now.subtract(const Duration(hours: 3))),
        createdAt: now.subtract(const Duration(hours: 3)),
        isUnread: true,
        type: 'missed_task',
      ),
      NotificationModel(
        id: '3',
        title: 'Your morning anchor',
        body: 'The world is waking up. Your 5-minute inner peace practice is ready when you are.',
        timestamp: DateFormat('d MMM yyyy, h:mm a').format(now.subtract(const Duration(hours: 6))),
        createdAt: now.subtract(const Duration(hours: 6)),
        isUnread: true,
        type: 'general',
      ),
      NotificationModel(
        id: '4',
        title: 'Time for your reset',
        body: 'It is almost 1:30 PM. Step away from the screen, find some natural light, and clear the afternoon haze',
        timestamp: 'Yesterday',
        createdAt: now.subtract(const Duration(days: 1)),
        isUnread: true,
        type: 'break',
      ),
      NotificationModel(
        id: '5',
        title: 'Finding your rhythm again',
        body: 'I noticed we missed our morning stillness the last two days. There is no judgment here. Shall we adjust the schedule, or simply try again tomorrow?',
        timestamp: '2 days ago',
        createdAt: now.subtract(const Duration(days: 2)),
        isUnread: false,
        type: 'general',
      ),
    ];
  }

  // ── Firebase / local notification wiring ─────────────────────────────────

  Future<void> _onInitializeRequested(NotificationsInitializeRequested event, Emitter<NotificationState> emit) async {
    await _requestPermissions();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('wizard_icon');

    final List<DarwinNotificationCategory> darwinNotificationCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        'noorva_action_category',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            'yes_action',
            'Yes',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'no_action',
            'No',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
        ],
      ),
    ];

    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: darwinNotificationCategories,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveLocalNotification,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingRemoteMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationOpen(message.data);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage.data);
    }

    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("FCM Registration Token: $token");
    } catch (e) {
      debugPrint("Error getting FCM Token: $e");
    }
  }

  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    final androidImplementation = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  void _onDidReceiveLocalNotification(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    if (actionId != null) {
      if (actionId == 'yes_action') {
        add(NotificationLocalActionReceived("You clicked 'Yes' on: $payload"));
      } else if (actionId == 'no_action') {
        add(NotificationLocalActionReceived("You clicked 'No' on: $payload"));
      }
    }
  }

  void _onLocalActionReceived(NotificationLocalActionReceived event, Emitter<NotificationState> emit) {
    emit(state.copyWith(lastActionResponse: event.response));
  }

  void _handleIncomingRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final title = notification.title ?? 'Noorva Alert';
      final body = notification.body ?? '';
      final type = message.data['type'] ?? 'general';

      add(NotificationAdded(title: title, body: body, type: type, data: message.data));
      _showLocalNotification(title: title, body: body, type: type, payload: title);
    }
  }

  void _handleNotificationOpen(Map<String, dynamic> data) {
    debugPrint("Notification tapped with data: $data");
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String type,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'noorva_notifications',
      'Noorva Notifications',
      channelDescription: 'Notifications for Noorva Companion',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('wizard_icon'),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('yes_action', 'Yes', showsUserInterface: true),
        AndroidNotificationAction('no_action', 'No', showsUserInterface: true),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'noorva_action_category',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // ── List mutations ────────────────────────────────────────────────────────

  Future<void> _onNotificationAdded(NotificationAdded event, Emitter<NotificationState> emit) async {
    final now = DateTime.now();
    final newNotif = NotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: event.title,
      body: event.body,
      timestamp: DateFormat('d MMM yyyy, h:mm a').format(now),
      createdAt: now,
      isUnread: true,
      type: event.type,
    );

    final notifications = [newNotif, ...state.notifications];
    emit(state.copyWith(notifications: notifications));
    await _saveNotifications(notifications);
  }

  Future<void> _onSimulateRequested(NotificationSimulateRequested event, Emitter<NotificationState> emit) async {
    String title = '';
    String body = '';
    String type = '';

    switch (event.index) {
      case 0:
        title = 'Time for a break! Stand up!';
        body = 'Your cognitive bandwidth is naturally dipping. Step away from the glass and let your mind wander for a moment';
        type = 'break';
        break;
      case 1:
        title = 'Call with Sumanth';
        body = 'You had a call with Sumanth today at 3:00 PM. Have you done with the call?';
        type = 'call';
        break;
      case 2:
        title = 'End of workday! Check your stats';
        body = 'The day’s execution window is closing. It is time to begin the descent into rest. Save your progress.';
        type = 'end_workday';
        break;
      case 3:
        title = 'You missed a task, reschedule now';
        body = 'An intention from earlier remains untouched. Shall we shift it to tomorrow, or release it entirely?';
        type = 'missed_task';
        break;
      default:
        title = 'General Alert';
        body = 'A new notification from Noorva Companion';
        type = 'general';
    }

    await _onNotificationAdded(NotificationAdded(title: title, body: body, type: type), emit);
    await _showLocalNotification(title: title, body: body, type: type, payload: title);
  }

  Future<void> _onMarkedAsRead(NotificationMarkedAsRead event, Emitter<NotificationState> emit) async {
    final index = state.notifications.indexWhere((n) => n.id == event.id);
    if (index == -1) return;
    final notifications = List<NotificationModel>.from(state.notifications);
    notifications[index] = notifications[index].copyWith(isUnread: false);
    emit(state.copyWith(notifications: notifications));
    await _saveNotifications(notifications);
  }

  void _onSelectionModeToggled(NotificationSelectionModeToggled event, Emitter<NotificationState> emit) {
    if (!event.value) {
      final notifications = state.notifications.map((n) => n.copyWith(isSelected: false)).toList();
      emit(state.copyWith(notifications: notifications, isSelectionMode: false));
    } else {
      emit(state.copyWith(isSelectionMode: true));
    }
  }

  void _onSelectAllToggled(NotificationSelectAllToggled event, Emitter<NotificationState> emit) {
    final notifications = state.notifications.map((n) => n.copyWith(isSelected: event.select)).toList();
    emit(state.copyWith(notifications: notifications));
  }

  void _onSelectionToggled(NotificationSelectionToggled event, Emitter<NotificationState> emit) {
    final index = state.notifications.indexWhere((n) => n.id == event.id);
    if (index == -1) return;
    final notifications = List<NotificationModel>.from(state.notifications);
    notifications[index] = notifications[index].copyWith(isSelected: !notifications[index].isSelected);
    emit(state.copyWith(notifications: notifications));
  }

  Future<void> _onDeleteSelectedRequested(NotificationsDeleteSelectedRequested event, Emitter<NotificationState> emit) async {
    final notifications = state.notifications.where((n) => !n.isSelected).toList();
    emit(state.copyWith(notifications: notifications, isSelectionMode: false));
    await _saveNotifications(notifications);
  }

  void _onActionResponseCleared(NotificationActionResponseCleared event, Emitter<NotificationState> emit) {
    emit(state.copyWith(clearLastActionResponse: true));
  }
}
