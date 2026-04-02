import 'package:flutter/material.dart';
import 'package:push_notification/core/firebase_api.dart';
import 'package:push_notification/firebase_options.dart';

import 'features/home/presentation/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

/*
Go to Firebase Console: Project Shortcut: Messaging: Create Campaign , Comspose Notification: Input title and text, Hit Send test notification
 */