import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    _setupListeners();
  }

  // 🔥 COMMON SAVE FUNCTION (USED EVERYWHERE)
  Future<void> saveToFirestore(RemoteMessage message) async {
    final firestore = FirebaseFirestore.instance;

    final messageId = message.messageId;

    // ✅ Prevent duplicate using messageId
    final existing = await firestore
        .collection('notifications')
        .where('messageId', isEqualTo: messageId)
        .get();

    if (existing.docs.isNotEmpty) {
      print("⚠️ Duplicate skipped");
      return;
    }

    final newNotification = {
      "messageId": messageId,
      "title": message.notification?.title ?? message.data['title'] ?? "No Title",
      "body": message.notification?.body ?? message.data['body'] ?? "No Body",
      "timestamp": FieldValue.serverTimestamp(),
      "data": message.data,
      "isRead": false
    };

    await firestore.collection('notifications').add(newNotification);
  }

  void _setupListeners() {
    // ✅ Foreground
    FirebaseMessaging.onMessage.listen((message) {
      saveToFirestore(message);
    });

    // ✅ Background click
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await saveToFirestore(message);

      // 🔥 THIS IS WHAT YOU ARE MISSING
      navigatorKey.currentState?.pushNamed('/notification_screen');
    });
  }
}