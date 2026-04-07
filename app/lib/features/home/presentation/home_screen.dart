import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _HeroSection()),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 22, 18, 12 + bottomInset),
                child: const _LandingContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: const BoxDecoration(
        color: kGoldAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 44,
              color: kGoldAccent.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'FarmBuzz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'The Breeder\'s Network',
            style: TextStyle(
              color: Color(0xFFF6EAC8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingContent extends StatelessWidget {
  const _LandingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Connect. Breed. Compete.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F2230),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.06,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'The #1 social network for gamefowl breeders in the Philippines. Track bloodlines, share results, trade birds.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF707070),
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        const _BenefitTile(
          icon: Icons.groups_2_outlined,
          title: '10,000+ Breeders',
          subtitle: 'Connect with sabongeros nationwide',
        ),
        const SizedBox(height: 12),
        const _BenefitTile(
          icon: Icons.account_tree_outlined,
          title: 'Bloodline Registry',
          subtitle: 'Track every generation digitally',
        ),
        const SizedBox(height: 12),
        const _BenefitTile(
          icon: Icons.storefront_outlined,
          title: 'Marketplace',
          subtitle: 'Buy & sell in the #1 gamefowl market',
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signup),
          style: ElevatedButton.styleFrom(
            backgroundColor: kGoldAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          icon: const Icon(Icons.bolt_rounded, size: 24),
          label: const Text('Start 60-Day Free Trial'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Full access. No credit card needed.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9C9C9C), fontSize: 13.5),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
          style: OutlinedButton.styleFrom(
            foregroundColor: kGoldAccent,
            side: const BorderSide(color: kGoldAccent, width: 1.3),
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          child: const Text('Log In'),
        ),
      ],
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E1D0)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: kGoldAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2230),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7D7D7D),
                    fontWeight: FontWeight.w500,
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
