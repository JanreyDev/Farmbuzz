import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Full Terms of Service / EULA screen.
/// Apple App Store Review Guideline 1.2 (UGC) requires apps to state
/// clearly that they have "no tolerance for objectionable content or
/// abusive users." This screen satisfies that requirement.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const TermsScreen());

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
          'Terms of Service',
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
          _SectionHeader('FarmBuzz Terms of Service'),
          _BodyText('Last updated: June 2026\n'),
          _BodyText(
            'Welcome to FarmBuzz — the breeder\'s network. By creating an account or using '
            'our platform, you agree to the following Terms of Service. Please read them carefully.',
          ),
          SizedBox(height: 20),

          // ── 1. Eligibility ──────────────────────────────────────────────
          _SectionTitle('1. Eligibility'),
          _BodyText(
            'You must be at least 18 years of age to use FarmBuzz. By registering, you '
            'confirm that you meet this requirement.',
          ),
          SizedBox(height: 16),

          // ── 2. User-Generated Content (UGC) ─────────────────────────────
          _SectionTitle('2. User-Generated Content'),
          _BodyText(
            'FarmBuzz is a community platform where users can post text, images, and other '
            'media. You are solely responsible for any content you create.',
          ),
          SizedBox(height: 8),
          _BulletPoint('You must not post content that is illegal, harmful, threatening, abusive, harassing, defamatory, obscene, or otherwise objectionable.'),
          _BulletPoint('You must not impersonate another person or organization.'),
          _BulletPoint('You must not post spam, misleading information, or unsolicited commercial messages.'),
          _BulletPoint('You must not upload content that infringes on the intellectual property rights of others.'),
          SizedBox(height: 8),
          _EULACallout(
            '⚠️ Zero-Tolerance Policy: FarmBuzz has absolutely no tolerance for objectionable '
            'content or abusive users. Any user found to be posting harmful, hateful, or '
            'inappropriate content will be permanently removed from the platform without notice.',
          ),
          SizedBox(height: 16),

          // ── 3. Reporting & Moderation ────────────────────────────────────
          _SectionTitle('3. Reporting & Moderation'),
          _BodyText(
            'FarmBuzz provides built-in tools to help keep the community safe:',
          ),
          SizedBox(height: 8),
          _BulletPoint('Report Post — You can report any post for spam, inappropriate content, harassment, or other violations using the "⋯" menu on every post. Reports are reviewed by our moderation team.'),
          _BulletPoint('Block User — You can block any user from your feed at any time. Blocked users will not be notified.'),
          _BulletPoint('Hide Post — You can hide any post you do not want to see.'),
          SizedBox(height: 8),
          _BodyText(
            'Violations of these Terms may result in content removal, account suspension, '
            'or permanent account deletion.',
          ),
          SizedBox(height: 16),

          // ── 4. Account Deletion ──────────────────────────────────────────
          _SectionTitle('4. Account Deletion'),
          _BodyText(
            'You may delete your FarmBuzz account at any time by navigating to the main '
            'menu (☰) and tapping "Delete Account." Deletion is permanent and irreversible. '
            'All your posts, farm data, and club memberships will be removed.',
          ),
          SizedBox(height: 16),

          // ── 5. Privacy ───────────────────────────────────────────────────
          _SectionTitle('5. Privacy'),
          _BodyText(
            'Your mobile number is used for authentication only and is never shared with '
            'third parties or displayed publicly. Please refer to our Privacy Policy for '
            'full details on how your data is collected and used.',
          ),
          SizedBox(height: 16),

          // ── 6. Intellectual Property ─────────────────────────────────────
          _SectionTitle('6. Intellectual Property'),
          _BodyText(
            'By posting content on FarmBuzz, you grant FarmBuzz a non-exclusive, royalty-free '
            'license to display and distribute that content within the platform. You retain '
            'ownership of your content.',
          ),
          SizedBox(height: 16),

          // ── 7. Disclaimer ────────────────────────────────────────────────
          _SectionTitle('7. Disclaimer of Warranties'),
          _BodyText(
            'FarmBuzz is provided "as is" without warranties of any kind. We do not guarantee '
            'uninterrupted service or that the platform will be error-free.',
          ),
          SizedBox(height: 16),

          // ── 8. Changes ───────────────────────────────────────────────────
          _SectionTitle('8. Changes to These Terms'),
          _BodyText(
            'FarmBuzz reserves the right to update these Terms at any time. Continued use '
            'of the platform after changes are posted constitutes your acceptance of the '
            'revised Terms.',
          ),
          SizedBox(height: 16),

          // ── 9. Contact ───────────────────────────────────────────────────
          _SectionTitle('9. Contact Us'),
          _BodyText(
            'If you have questions about these Terms or need to report a serious violation, '
            'please contact our team via the in-app Safety reporting tools or reach out '
            'through our official channels.',
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

class _EULACallout extends StatelessWidget {
  const _EULACallout(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          color: Colors.red.shade800,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }
}
