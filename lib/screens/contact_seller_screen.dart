import 'package:flutter/material.dart';
import '../widgets/app_button.dart';

class ContactSellerScreen extends StatelessWidget {
  const ContactSellerScreen({super.key});

  void _openLink(String url) {
    // Use url_launcher in a real app to open the link.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Seller')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: 'Facebook',
              onPressed: () => _openLink('https://facebook.com'),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Telegram',
              onPressed: () => _openLink('https://t.me'),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'TikTok',
              onPressed: () => _openLink('https://tiktok.com'),
            ),
          ],
        ),
      ),
    );
  }
}
