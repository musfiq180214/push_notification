import 'package:flutter/material.dart';
import 'package:push_notification/core/firebase_api.dart';
import 'package:push_notification/features/notifications/presentation/notification_screen.dart';
import 'package:push_notification/firebase_options.dart';
import 'features/home/presentation/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final navigatorKey = GlobalKey<NavigatorState>();

RemoteMessage? initialMessage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ INIT HIVE FIRST (VERY IMPORTANT)
  await Hive.initFlutter();
  await Hive.openBox('notifications_box');

  // ✅ GET TERMINATED MESSAGE
  initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  // ✅ INIT FCM AFTER HIVE
  await FirebaseApi().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    _handleInitialMessage();
  }

  void _handleInitialMessage() async {
    if (initialMessage != null) {
      // ✅ SAVE TO HIVE
      FirebaseApi().handleMessage(initialMessage);

      await Future.delayed(const Duration(milliseconds: 500));

      navigatorKey.currentState?.pushNamed('/notification_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const HomeScreen(),
      routes: {
        '/notification_screen': (context) => const NotificationScreen(),
      },
    );
  }
}

/*
Go to Firebase Console: Project Shortcut: Messaging: Create Campaign , Compose Notification: Input title and text, Hit Send test message
This will send notification even if app is terminated
 */

/*
run this in base terminal:
gcloud auth application-default print-access-token
you get a gcloud access token
Go to PostMan:
Create Post Method: https://fcm.googleapis.com/v1/projects/pushnotification-e343e/messages:send

IN Authorization: Bearer Token: input the gcloud access token
In Body give this json:
{
  "message": {
    "token": fcm token found in terminal,
    "notification": {
      "title": "Postman Test 100",
      "body": "This was sent via the REST API!"
    },
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "status": "delivered",
      "screen": "notification_screen"
    }
  }
}

Notification will be sent to this app

and if clicked Notification Screen will be opened even if the app is closed

We are saving the notifications in Hive and shown in Notification Screen

We have setup to handle three situation notification: foreground, background and terminated
 */