import 'package:flutter/material.dart';
import '../../notifications/presentation/notification_screen.dart'; // Ensure this path is correct
import 'package:hive_flutter/hive_flutter.dart';

// Inside HomeScreen AppBar actions:
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Push Notification Home',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        // Professional apps usually left-align titles
        backgroundColor: Colors.white,
        elevation: 0.5,

      actions: [
      ValueListenableBuilder(
      valueListenable: Hive.box('notifications_box').listenable(),
      builder: (context, Box box, _) {
        // Calculate count of unread notifications
        final unreadCount = box.values.where((item) => item['isRead'] == false).length;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
            ),
            // Only show the Red Dot if unreadCount > 0
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      },
    ),
    const SizedBox(width: 8),
    ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 100, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tap the bell to see your notifications',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}