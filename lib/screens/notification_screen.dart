import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Notification messages will appear here when connected to Firebase.'),
      ),
    );
  }
}
