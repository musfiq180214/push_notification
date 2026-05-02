import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/logger.dart';
import '../../notifications/presentation/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? selectedDateTime;

  Future<void> pickDateTime() async {
    final now = DateTime.now();

    // Pick Date
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    // Pick Time
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final finalDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // ❌ Prevent past time
    if (finalDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a future time")),
      );
      return;
    }

    setState(() {
      selectedDateTime = finalDateTime;
    });
  }

  Future<void> setAlarm() async {
    if (selectedDateTime == null) return;

    final alarmId =
        DateTime.now().millisecondsSinceEpoch % 2147483647;

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: selectedDateTime!,

      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,

      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 3),
      ),

      notificationSettings: const NotificationSettings(
        title: 'Alarm',
        body: 'Your alarm is ringing',
        stopButton: 'Stop',
      ),

      androidFullScreenIntent: true,
      warningNotificationOnKill: true,
    );

    // 🔥 LOG BEFORE SET
    AppLogger.i("📅 Alarm Creating...");
    AppLogger.i(("🆔 ID: $alarmId"));
    AppLogger.i(("⏰ Time: ${selectedDateTime!}"));
    AppLogger.i(("🔊 Audio: assets/alarm.mp3"));
        AppLogger.i(("📳 Vibrate: true"));

    await Alarm.set(alarmSettings: alarmSettings);

    // 🔥 LOG AFTER SET
    AppLogger.i(("✅ Alarm Successfully Scheduled!"));
    AppLogger.i(("----------------------------------"));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Alarm Set Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Push Notification Home',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        // Remove the automatic back button if we are coming back from NotificationScreen
        automaticallyImplyLeading: false,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('notifications')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.docs.length ?? 0;

              return InkWell( // Changed to InkWell for a better visual feedback (ripple)
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  // Increase width to prevent clipping and give the badge room
                  width: 55,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none, // Ensures the badge isn't cut off
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.black87,
                        size: 28,
                      ),
                      // 🔴 Badge
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          // Adjusted to sit on the shoulder of the icon
                          top: -2,
                          // Adjusted to sit higher up
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12), // Added more spacing from the screen edge
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_outlined, size: 100, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Tap the bell to see your notifications',
              style: TextStyle(color: Colors.grey),
            ),
            const Icon(Icons.alarm, size: 100, color: Colors.blue),

            const SizedBox(height: 20),

            Text(
              selectedDateTime == null
                  ? "No time selected"
                  : selectedDateTime.toString(),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // 📅 PICK TIME BUTTON
            ElevatedButton(
              onPressed: pickDateTime,
              child: const Text("Pick Date & Time"),
            ),

            const SizedBox(height: 10),

            // ⏰ SET ALARM BUTTON
            ElevatedButton(
              onPressed: setAlarm,
              child: const Text("Set Alarm"),
            ),
          ],
        ),
      ),
    );
  }
}