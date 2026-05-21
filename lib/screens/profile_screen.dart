import 'package:flutter/material.dart';
import '../widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(radius: 52, child: Icon(Icons.person, size: 60)),
            const SizedBox(height: 24),
            const Text('User Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('user@example.com'),
            const SizedBox(height: 24),
            AppButton(label: 'Edit Profile', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
