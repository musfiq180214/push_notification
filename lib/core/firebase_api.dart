import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/notifications/presentation/notification_screen.dart';
import '../main.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    _setupListeners();
  }
  void _handleMessage() {

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
    // ✅ Foreground
    FirebaseMessaging.onMessage.listen((message) {
      _showTopMessage(message);
      saveToFirestore(message);
    });

    // ✅ Background click
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await saveToFirestore(message);

      // 🔥 THIS IS WHAT YOU ARE MISSING
      navigatorKey.currentState?.pushNamed('/notification_screen');
    });
  }

  void _showTopMessage(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? "New Notification";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 70, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}