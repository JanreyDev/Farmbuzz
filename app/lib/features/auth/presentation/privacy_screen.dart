import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const PrivacyScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: const [
          _SectionHeader('FarmBuzz Privacy Policy'),
          _BodyText('Last updated: June 2026\n'),
          _BodyText(
            'Your privacy is critically important to us. At FarmBuzz, we have a few fundamental principles:',
          ),
          SizedBox(height: 16),

          _SectionTitle('1. What Data We Collect'),
          _BulletPoint('Mobile Number: Used exclusively for authentication and account recovery via OTP. It is never displayed publicly.'),
          _BulletPoint('Profile Data: Your display name, avatar, and any farm details you provide.'),
          _BulletPoint('User-Generated Content: Posts, images, comments, and interactions on the platform.'),
          SizedBox(height: 16),

          _SectionTitle('2. How We Use Your Data'),
          _BodyText(
            'We use your information solely to provide, secure, and improve the FarmBuzz platform. We do not sell your personal data to third parties.',
          ),
          SizedBox(height: 16),

          _SectionTitle('3. Data Deletion'),
          _BodyText(
            'You have the right to request the deletion of your data. You can delete your account entirely at any time from the app menu. This will permanently erase your profile, posts, and associated data from our active servers.',
          ),
          SizedBox(height: 16),

          _SectionTitle('4. App Permissions'),
          _BulletPoint('Camera & Photos: Required only when you choose to upload a picture for a post or your profile.'),
          _BulletPoint('Microphone: Required only if you choose to record video with audio.'),
          SizedBox(height: 32),

          _BodyText(
            '© 2026 FarmBuzz. All rights reserved.',
            isFooter: true,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.accentGreen,
          height: 1.3,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A2E1E),
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text, {this.isFooter = false});
  final String text;
  final bool isFooter;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isFooter ? 12 : 14,
        color: isFooter ? Colors.grey : const Color(0xFF4A5A4F),
        height: 1.6,
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, color: AppColors.accentGreen, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF4A5A4F), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
