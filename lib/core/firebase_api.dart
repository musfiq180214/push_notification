import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notification/core/utils/logger.dart';

class FirebaseApi {
  // create instance of Firebase Messeging

  final _firebaseMesseging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMesseging.requestPermission();

    final fcmToken = await _firebaseMesseging.getToken();

    AppLogger.i("Token: $fcmToken");
  }

  // function to initialize notifactions

  // function to handle received messeges

  // function to initialize foreground and background settings
}