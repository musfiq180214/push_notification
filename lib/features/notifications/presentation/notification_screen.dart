import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../home/presentation/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    // Inside build method
    final userID = FirebaseAuth.instance.currentUser?.uid;

// In StreamBuilder stream:

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false, // This removes all previous routes from the stack
            );
          },
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () async {
              final snapshot =
              await firestore.collection('notifications').get();

              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }
            },
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(

      stream: firestore
      .collection('notifications')
          .where('userID', isEqualTo: userID) // Filter by userID
          .orderBy('timestamp', descending: true)
          .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text("Your inbox is empty"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];

              // Inside ListView.builder's itemBuilder
              return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    // Add this callback to update 'isRead' in Firestore
                    onExpansionChanged: (isExpanded) {
                      if (isExpanded && data['isRead'] == false) {
                        data.reference.update({'isRead': true});
                      }
                    },
                    leading: CircleAvatar(
                      // Optional: Change color based on read status
                      backgroundColor: data['isRead'] == true
                          ? Colors.grey.shade200
                          : Colors.blue.shade50,
                      child: Icon(Icons.notifications,
                          color: data['isRead'] == true
                              ? Colors.grey.shade600
                              : Colors.blue.shade800),
                    ),
                    title: Text(
                      data['title'] ?? '',
                      style: TextStyle(
                        fontWeight: data['isRead'] == true
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      data['body'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      data.reference.delete();
                    },
                  ),

                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Text(data['body'] ?? ''),
                          const SizedBox(height: 10),
                          Text(
                            "Meta: ${data['data'].toString()}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}