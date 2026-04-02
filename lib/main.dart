import 'package:flutter/material.dart';
import 'package:push_notification/core/firebase_api.dart';
import 'package:push_notification/features/notifications/presentation/notification_screen.dart';
import 'package:push_notification/firebase_options.dart';
import 'features/home/presentation/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications
  await FirebaseApi().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Required for background navigation
      home: const HomeScreen(),
      routes: {
        // ADDED THE LEADING SLASH HERE TO MATCH firebase_api.dart
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
you get a token
Go to PostMan:
Create Post Method: IN Authorization: Bearer Token: input the token
In Body give this json:
{
  "message": {
    "token": "cetxhxUWRM6aw7vM0xJeTl:APA91bE6UeQ38aNg9H574F6zTkqWofnoTgncr7ZA4daIAzvB-vFSslFZ5dIQFPCZYLHy_l6D0aFMnCH9U3QJRyRCrx-I0Y49JMXgqtTy2VvMzDtH_jbJH4g",
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
 */