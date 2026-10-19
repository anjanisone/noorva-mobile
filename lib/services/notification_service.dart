import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import 'firestore_service.dart';

/// Must be a top-level function so it can run in the background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.messageId}');
}

/// FCM + local notifications. Call [initialize] once after Firebase init.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Matches the default channel id declared in AndroidManifest.xml.
  static const String channelId = 'noorva_notifications';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final FirestoreService _firestore = FirestoreService();
  final StreamController<RemoteMessage> _taps =
      StreamController<RemoteMessage>.broadcast();

  bool _initialized = false;
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<User?>? _authSub;

  /// Emits whenever the user taps a notification (app in background or terminated).
  Stream<RemoteMessage> get onNotificationTap => _taps.stream;

  /// [showForeground]: display foreground FCM messages via local notifications.
  /// Pass false if another component (e.g. NotificationBloc) already does this.
  Future<void> initialize({bool showForeground = true}) async {
    if (_initialized) return;
    _initialized = true;

    await _requestPermission();
    if (showForeground) {
      await _initLocalNotifications();
      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_taps.add);

    // App launched by tapping a notification while terminated.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _taps.add(initial);

    if (showForeground) {
      // Foreground banners are drawn by flutter_local_notifications instead.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );
    }

    _tokenSub = _messaging.onTokenRefresh.listen(_saveToken);
    // Save the token whenever a user signs in (covers first launch before login).
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) return;
      final token = await _safeGetToken();
      if (token != null) await _saveToken(token);
    });
  }

  Future<void> dispose() async {
    await _tokenSub?.cancel();
    await _authSub?.cancel();
  }

  Future<void> _requestPermission() async {
    // Covers iOS and Android 13+ (POST_NOTIFICATIONS).
    final settings = await _messaging.requestPermission();
    debugPrint('Notification permission: ${settings.authorizationStatus}');
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _local.initialize(settings);

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          channelId,
          'Noorva Notifications',
          description: 'Notifications for Noorva Companion',
          importance: Importance.high,
        ));
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;
    await _local.show(
      message.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Noorva Notifications',
          channelDescription: 'Notifications for Noorva Companion',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<String?> _safeGetToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      // On iOS the APNs token may not be ready (e.g. simulator).
      debugPrint('FCM token unavailable: $e');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore.addFcmToken(uid, token);
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }
}
