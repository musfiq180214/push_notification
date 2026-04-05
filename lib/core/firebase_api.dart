import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import '../main.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    _setupListeners();
  }

  void _saveToHive(RemoteMessage message) {
    final box = Hive.box('notifications_box');

    final newNotification = {
      "title": message.notification?.title ?? "No Title",
      "body": message.notification?.body ?? "No Body",
      "timestamp": DateTime.now().toIso8601String(),
      "data": message.data,
      "isRead": false
    };

    bool exists = box.values.any((n) =>
    n['title'] == newNotification['title'] &&
        n['body'] == newNotification['body']);

    if (!exists) {
      box.add(newNotification);
    }
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    _saveToHive(message);

    final screen = message.data['screen'];

    if (screen == 'notification_screen') {
      navigatorKey.currentState?.pushNamed('/notification_screen');
    }
  }
  void _setupListeners() {
    // 🔥 Foreground
    FirebaseMessaging.onMessage.listen((message) {
      _saveToHive(message);
    });

    // 🔥 Background (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}