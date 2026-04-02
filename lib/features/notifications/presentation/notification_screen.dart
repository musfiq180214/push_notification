import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safely extract the message
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    final RemoteMessage? message = args is RemoteMessage ? args : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: message == null
          ? const Center(child: Text("No notification data found"))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title: ${message.notification?.title ?? 'N/A'}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Body: ${message.notification?.body ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 40),
            const Text("Custom Data (JSON):",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message.data.toString()),
            ),
          ],
        ),
      ),
    );
  }
}