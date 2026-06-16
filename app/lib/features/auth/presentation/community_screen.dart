import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CommunityScreen());

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
          'Community Guidelines',
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
          _SectionHeader('FarmBuzz Community Guidelines'),
          _BodyText('Welcome to the breeder\'s network. To keep FarmBuzz a safe and welcoming space, we require all members to adhere to these guidelines:\n'),
          
          _SectionTitle('1. Be Respectful'),
          _BodyText(
            'Treat others with respect. Disagreements are fine, but harassment, hate speech, bullying, or personal attacks will not be tolerated.',
          ),
          SizedBox(height: 16),

          _SectionTitle('2. No Objectionable Content'),
          _BodyText(
            'Do not post content that is illegal, sexually explicit, graphically violent, or otherwise inappropriate. We maintain a zero-tolerance policy for such material.',
          ),
          SizedBox(height: 16),

          _SectionTitle('3. No Spam'),
          _BodyText(
            'Keep your posts relevant. Do not flood the feed with repetitive content, unsolicited advertisements, or misleading links.',
          ),
          SizedBox(height: 16),

          _SectionTitle('4. Report Bad Behavior'),
          _BodyText(
            'If you see a post or a user violating these guidelines, please use the built-in "Report Post" or "Block User" tools. Our moderation team reviews all reports promptly.',
          ),
          SizedBox(height: 32),

          _BodyText(
            'Violating these guidelines may result in content removal or permanent account suspension.',
          ),
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
