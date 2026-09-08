import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../../data/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  bool _isSelectionMode = false;
  String? _lastActionResponse; // Tracks the user's action tap for testing

  List<NotificationModel> get notifications => _notifications;
  bool get isSelectionMode => _isSelectionMode;
  String? get lastActionResponse => _lastActionResponse;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefsKey = 'noorva_notifications_list';

  NotificationProvider() {
    _loadNotifications();
  }

  // Group notifications dynamically: Today (last 24 hours) vs This Week (older)
  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _notifications
        .where((n) => n.createdAt.isAfter(todayStart))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<NotificationModel> get weekNotifications {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _notifications
        .where((n) => n.createdAt.isBefore(todayStart))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void clearLastActionResponse() {
    _lastActionResponse = null;
    notifyListeners();
  }

  set isSelectionMode(bool value) {
    _isSelectionMode = value;
    if (!value) {
      for (var n in _notifications) {
        n.isSelected = false;
      }
    }
    notifyListeners();
  }

  // Initialize notifications (FCM & Local)
  Future<void> initialize() async {
    // 1. Request Notification Permissions
    await requestPermissions();

    // 2. Initialize Flutter Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('wizard_icon');

    // Setup Darwin (iOS) notification categories for actions
    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
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

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
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

    // 3. Handle FCM Callbacks
    // Foreground messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingRemoteMessage(message);
    });

    // Background messaging tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationOpen(message.data);
    });

    // Terminated state message launch
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage.data);
    }

    // Retrieve FCM Token (for console testing / backend link)
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("FCM Registration Token: $token");
    } catch (e) {
      debugPrint("Error getting FCM Token: $e");
    }
  }

  // Request runtime permissions (Android 13+ & iOS)
  Future<void> requestPermissions() async {
    // iOS Permission Request
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 13+ Local Notification Permission Request
    final androidImplementation =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation< 
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // Handle local notification tap response
  void _onDidReceiveLocalNotification(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    if (actionId != null) {
      if (actionId == 'yes_action') {
        _lastActionResponse = "You clicked 'Yes' on: $payload";
      } else if (actionId == 'no_action') {
        _lastActionResponse = "You clicked 'No' on: $payload";
      }
      notifyListeners();
    }
  }

  // Handle remote background push notifications
  void _handleIncomingRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final title = notification.title ?? 'Noorva Alert';
      final body = notification.body ?? '';
      final type = message.data['type'] ?? 'general';

      addNotification(
        title: title,
        body: body,
        type: type,
        data: message.data,
      );

      // Trigger local notification to display while app is in foreground
      _showLocalNotification(
        title: title,
        body: body,
        type: type,
        payload: title,
      );
    }
  }

  void _handleNotificationOpen(Map<String, dynamic> data) {
    debugPrint("Notification tapped with data: $data");
    // Handle routing or deep linking if needed
  }

  // Display a local heads-up notification with action buttons
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String type,
    required String payload,
  }) async {
    // Custom android notification details with buttons and large icon
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'noorva_notifications',
      'Noorva Notifications',
      channelDescription: 'Notifications for Noorva Companion',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('wizard_icon'),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'yes_action',
          'Yes',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'no_action',
          'No',
          showsUserInterface: true,
        ),
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

  // Save list to SharedPreferences
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _notifications.map((n) => n.toJson()).toList(),
    );
    await prefs.setString(_prefsKey, encoded);
  }

  // Load from SharedPreferences
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_prefsKey);
    if (encoded != null) {
      try {
        final List<dynamic> decoded = jsonDecode(encoded);
        _notifications.clear();
        _notifications.addAll(
          decoded.map((json) => NotificationModel.fromJson(json)).toList(),
        );
        notifyListeners();
      } catch (e) {
        debugPrint("Error parsing notifications: $e");
      }
    } else {
      // Seed default mockup notifications if empty to simulate first-run experience
      _seedDefaultNotifications();
    }
  }

  void _seedDefaultNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
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
    ]);
    _saveNotifications();
  }

  // Add notification to list
  void addNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) {
    final now = DateTime.now();
    final newNotif = NotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateFormat('d MMM yyyy, h:mm a').format(now),
      createdAt: now,
      isUnread: true,
      type: type,
    );

    _notifications.insert(0, newNotif);
    _saveNotifications();
    notifyListeners();
  }

  // Mark specific notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isUnread: false);
      _saveNotifications();
      notifyListeners();
    }
  }

  // Delete selected notifications
  void deleteSelectedNotifications() {
    _notifications.removeWhere((n) => n.isSelected);
    _isSelectionMode = false;
    _saveNotifications();
    notifyListeners();
  }

  // Select all notifications
  void selectAll(bool select) {
    for (var n in _notifications) {
      n.isSelected = select;
    }
    notifyListeners();
  }

  // Toggle selection for a single item
  void toggleSelection(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isSelected = !_notifications[index].isSelected;
      notifyListeners();
    }
  }

  // Simulation method to trigger Figma design notifications
  void triggerSimulatedNotification(int index) {
    String title = '';
    String body = '';
    String type = '';

    switch (index) {
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

    // Add to dynamic list
    addNotification(title: title, body: body, type: type);

    // Trigger local push display
    _showLocalNotification(
      title: title,
      body: body,
      type: type,
      payload: title,
    );
  }
}
