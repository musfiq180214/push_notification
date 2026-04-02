
import 'package:push_notification/core/utils/logger.dart';
import 'package:push_notification/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class FirebaseApi {
  // create instance of Firebase Messeging

  final _firebaseMesseging = FirebaseMessaging.instance;

  // function to initialize notifactions

  Future<void> initNotification() async {
    await _firebaseMesseging.requestPermission();

    final fcmToken = await _firebaseMesseging.getToken();

    AppLogger.i("Token: $fcmToken");

    initPushNotification();
  }



  // function to handle received messeges
  void handleMessege(RemoteMessage? message) {
    if (message == null) return;  // Now that we've checked for null, message is promoted to non-nullable
    navigatorKey.currentState?.pushNamed(
      '/notification_screen',
      arguments: message,
    );
  }



  // function to initialize foreground and background settings

  Future<void> initPushNotification() async {
    // handle when app was terminated, notification came and app opened

    FirebaseMessaging.instance.getInitialMessage().then(handleMessege);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessege);
  }
}