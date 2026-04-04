import 'package:flutter/material.dart';
import '../../notifications/presentation/notification_screen.dart'; // Ensure this path is correct

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
          // 1. The Notification Connection
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                    Icons.notifications_none_outlined, color: Colors.black87),
                onPressed: () {
                  // Navigate to Notification Inbox
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              // 2. Optional: Red Dot indicator for "New" messages
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              )
            ],
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