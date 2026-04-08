import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notifications/presentation/notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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