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
 */