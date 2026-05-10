import 'package:flutter/material.dart';
import 'package:push_notification/core/firebase_api.dart';
import 'package:push_notification/features/notifications/presentation/alarm_file.dart';
import 'package:push_notification/features/notifications/presentation/notification_screen.dart';
import 'package:push_notification/firebase_options.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/registration_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // 🔥 Reuse same logic
  await FirebaseApi().saveToFirestore(message);
  await FirebaseApi().showAwesomeNotification(message);
}

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // This triggers the alarm screen immediately when the notification is received
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/alarm_screen',
          (route) => route.isFirst,
    );
  }


  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // If the user clicks the notification itself
    navigatorKey.currentState?.pushNamed('/notification_screen');
  }
}

final navigatorKey = GlobalKey<NavigatorState>();

RemoteMessage? initialMessage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AwesomeNotifications().initialize(
    null, // Default icon
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50BB),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        criticalAlerts: true,
        playSound: true,
        soundSource: 'resource://raw/alarm',
      )
    ],
  );

  List<NotificationPermission> requestedPermissions = [
    NotificationPermission.FullScreenIntent,
    NotificationPermission.Alert,
    NotificationPermission.CriticalAlert,
  ];

  List<NotificationPermission> permissionsAllowed = await AwesomeNotifications().checkPermissionList(
      channelKey: 'basic_channel',
      permissions: requestedPermissions
  );

  if (permissionsAllowed.length < requestedPermissions.length) {
    // This will take the user to the settings page to enable it
    await AwesomeNotifications().requestPermissionToSendNotifications(
      channelKey: 'basic_channel',
      permissions: requestedPermissions,
    );
  }


  AwesomeNotifications().setListeners(
    onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
  );



  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


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
      // ✅ SAVE TO FIRESTORE (NOT Hive, NOT handleMessage)
      await FirebaseApi().saveToFirestore(initialMessage!);

      await Future.delayed(const Duration(seconds: 1));

      navigatorKey.currentState?.pushNamed('/notification_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      // REMOVE home: const HomeScreen(), <--- Remove this line

      routes: {
        '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Show a loader while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            // If user is logged in, go to Home, otherwise go to Login
            if (snapshot.hasData) return const HomeScreen();
            return LoginScreen();
          },
        ),
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/notification_screen': (context) => const NotificationScreen(),
        '/alarm_screen': (context) => const AlarmScreen()
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

From Firebase
Go to PostMan:
Create Post Method: https://fcm.googleapis.com/v1/projects/pushnotification-e343e/messages:send

IN Authorization: Bearer Token: input the gcloud access token
In Body give this json:
{
  "message": {
    "token": "fcm_token",
    "android": {
      "priority": "high"
    },
    "data": {
      "notification_id": "0",
      "title": "New Order Alert 1000",
      "body": "You have a new delivery request",
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "status": "delivered",
      "screen": "notification_screen"
    }
  }
}

Notification will be sent to this app and continuously shown as a call

and if clicked Notification Screen will be opened even if the app is closed

We are saving the notifications in Hive and shown in Notification Screen

We have setup to handle three situation notification: foreground, background and terminated
 */

/*
musfiq677@gmail.com
11111111
 */