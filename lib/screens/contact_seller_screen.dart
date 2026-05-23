import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSellerScreen extends StatelessWidget {
  const ContactSellerScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);
  static const Color softPurple = Color(0xFFF4F0FF);
  static final Uri facebookUrl =
      Uri.parse('https://www.facebook.com/share/1LUzQLDTsu/?mibextid=wwXIfr');
  static final Uri telegramUrl = Uri.parse('https://t.me/boreycomputer');
  static final Uri tiktokUrl =
      Uri.parse('https://www.tiktok.com/@boreycomputer');

  static Future<void> openPlatform(
    BuildContext context,
    Uri url,
    String platform,
  ) async {
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Could not open $platform.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Contact Seller',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 22),
              const _InfoBox(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Get in touch with the seller',
                subtitle: 'Choose your preferred platform.',
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose a platform',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _PlatformCard(
                iconText: 'f',
                iconColor: const Color(0xFF4267B2),
                title: 'Facebook',
                subtitle: 'Message us on Facebook',
                onTap: () => openPlatform(context, facebookUrl, 'Facebook'),
              ),
              const SizedBox(height: 14),
              _PlatformCard(
                icon: Icons.telegram_rounded,
                iconColor: const Color(0xFF2AABEE),
                title: 'Telegram',
                subtitle: 'Chat with us on Telegram',
                onTap: () => openPlatform(context, telegramUrl, 'Telegram'),
              ),
              const SizedBox(height: 14),
              _PlatformCard(
                iconText: '♪',
                iconColor: Colors.black,
                title: 'TikTok',
                subtitle: 'Message us on TikTok',
                onTap: () => openPlatform(context, tiktokUrl, 'TikTok'),
              ),
              const Spacer(),
              const _InfoBox(
                icon: Icons.shield_outlined,
                title: 'Your privacy is important',
                subtitle: 'Your conversations are safe with us.',
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: ContactSellerScreen.softPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFE7DEFF),
            child: Icon(
              icon,
              color: ContactSellerScreen.primaryBlue,
              size: 21,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9A9A9A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.iconText,
  });

  final IconData? icon;
  final String? iconText;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E1E1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Center(
                  child: icon != null
                      ? Icon(icon, size: 31, color: iconColor)
                      : Text(
                          iconText ?? '',
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
