import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart' hide NotificationSettings;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/notifications/presentation/notification_screen.dart';
import '../main.dart';
import '../../../core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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



  Future<void> saveToFirestore(RemoteMessage message) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final userID = user?.uid ?? "unknown"; // Identify which user this belongs to

    final messageId = message.messageId;

    // Prevent duplicate for this specific user
    final existing = await firestore
        .collection('notifications')
        .where('messageId', isEqualTo: messageId)
        .where('userID', isEqualTo: userID)
        .get();

    if (existing.docs.isNotEmpty) return;

    final newNotification = {
      "userID": userID, // Save the user's ID
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
    FirebaseMessaging.onMessage.listen((message) async {
      // _showTopMessage(message);
      showAwesomeNotification(message);
      await saveToFirestore(message);

      final now = DateTime.now();
      final alarmTime = now.add(const Duration(minutes: 1));

      final alarmId =
          DateTime.now().millisecondsSinceEpoch % 2147483647;

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: alarmTime,

        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,

        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 2),
        ),

        notificationSettings: const NotificationSettings(
          title: 'FCM Triggered Alarm',
          body: 'Alarm scheduled 1 minute later',
          stopButton: 'Stop',
        ),

        androidFullScreenIntent: true,
        warningNotificationOnKill: true,
      );

      // await Alarm.set(alarmSettings: alarmSettings);
      //
      // print("🚨 Alarm scheduled from FCM");
      // print("⏰ Will ring at: $alarmTime");

      // This will not trigger: In android alarm cannot be triggered from background
    });
    // ✅ Background click
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await saveToFirestore(message);

      // 🔥 THIS IS WHAT YOU ARE MISSING
      navigatorKey.currentState?.pushNamed('/notification_screen');
    });
  }

  Future<void> showAwesomeNotification(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.messageId.hashCode,
        channelKey: 'basic_channel',
        title: message.notification?.title ?? message.data['title'] ?? "Alarm!",
        body: message.notification?.body ?? message.data['body'] ?? "You have a new alert",
        fullScreenIntent: true, // This is the key
        wakeUpScreen: true,
        criticalAlert: true,
        category: NotificationCategory.Call,
        notificationLayout: NotificationLayout.Default,
        customSound: 'asset://assets/alarm.mp3',
        payload: Map<String, String>.from(message.data),
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'Open Alarm',
          actionType: ActionType.Default,
          color: Colors.green,
        ),
      ],
    );
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