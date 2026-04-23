import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

import 'create_farm_view.dart';

class MyFarmView extends StatefulWidget {
  const MyFarmView({super.key});

  @override
  State<MyFarmView> createState() => _MyFarmViewState();
}

class _MyFarmViewState extends State<MyFarmView> {
  bool _isCreatingFarm = false;

  @override
  Widget build(BuildContext context) {
    if (_isCreatingFarm) {
      return CreateFarmView(onBack: () => setState(() => _isCreatingFarm = false));
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroBanner(),
            _FeaturesSection(onCreateRequested: () => setState(() => _isCreatingFarm = true)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.onCreateRequested});

  final VoidCallback onCreateRequested;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything you need to run a serious farm',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Full width Breeding cycles
          const _FeatureCard(
            title: 'Breeding cycles',
            description: '21-day candling, settling, hatching. Per batch and per pair fertility.',
            icon: Icons.egg_outlined,
            badge: '21-DAY',
            isFullWidth: true,
          ),
          const SizedBox(height: 12),
          
          // Grid-like layout for the rest
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: const _FeatureCard(
                    title: 'Flock management',
                    description: 'Track every bird individually, or by cohort.',
                    icon: Icons.flutter_dash_outlined,
                    badge: 'PER BIRD',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const _FeatureCard(
                    title: 'Health records',
                    description: 'Vaccinations, deworming, illness.',
                    icon: Icons.favorite_border_rounded,
                    badge: 'BAI-ALIGNED',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: const _FeatureCard(
                    title: 'Wellness programs',
                    description: '21-day conditioning plans for pre-show.',
                    icon: Icons.auto_awesome_outlined,
                    badge: '21-DAY',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const _FeatureCard(
                    title: 'QR certificates',
                    description: 'Scannable proof of lineage and health.',
                    icon: Icons.qr_code_scanner_rounded,
                    badge: 'SCANNABLE',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: const _FeatureCard(
                    title: 'Team access',
                    description: 'Invite your hands by phone.',
                    icon: Icons.people_outline_rounded,
                    badge: 'FOR YOUR TEAM',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const _FeatureCard(
                    title: 'Statistical reports',
                    description: 'Fertility, survivability, economics.',
                    icon: Icons.bar_chart_rounded,
                    badge: 'BENCHMARKS',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _CommitmentSection(onCreateRequested: onCreateRequested),
        ],
      ),
    );
  }
}

class _CommitmentSection extends StatefulWidget {
  const _CommitmentSection({required this.onCreateRequested});

  final VoidCallback onCreateRequested;

  @override
  State<_CommitmentSection> createState() => _CommitmentSectionState();
}

class _CommitmentSectionState extends State<_CommitmentSection> {
  bool _isTicked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Gradient top bar
          Container(
            height: 4,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                colors: [AppColors.accentGreen, AppColors.golden],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUR COMMITMENT',
                  style: GoogleFonts.inter(
                    color: AppColors.accentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Before you log a single bird, here's the deal",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Sub cards
                _CommitmentItem(
                  title: 'This is binding, not a demo',
                  description: 'The birds, cycles, and finances you log here are your real operation.',
                  icon: Icons.eco_outlined,
                ),
                const SizedBox(height: 12),
                _CommitmentItem(
                  title: 'Your data is always yours',
                  description: 'Export everything or delete everything, whenever you want. No exit fee.',
                  icon: Icons.lock_open_rounded,
                ),
                
                const SizedBox(height: 24),
                
                // Checkbox container
                GestureDetector(
                  onTap: () => setState(() => _isTicked = !_isTicked),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isTicked ? AppColors.accentGreen.withValues(alpha: 0.05) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isTicked ? AppColors.accentGreen : Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _isTicked ? AppColors.accentGreen : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isTicked ? AppColors.accentGreen : Colors.grey[300]!,
                            ),
                          ),
                          child: _isTicked 
                            ? const Icon(Icons.check, size: 16, color: Colors.white) 
                            : null,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'I manage a real farm and I understand the above.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Button
                GestureDetector(
                  onTap: _isTicked ? widget.onCreateRequested : null,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _isTicked 
                        ? const LinearGradient(
                            colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                      color: _isTicked ? null : Colors.grey[200],
                      boxShadow: [
                        if (_isTicked)
                          BoxShadow(
                            color: AppColors.accentGreen.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create my first farm',
                            style: GoogleFonts.plusJakartaSans(
                              color: _isTicked ? Colors.white : Colors.grey[400],
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: _isTicked ? Colors.white : Colors.grey[400],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[500], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Takes about 2 minutes.',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Community only? Skip for now',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

class _CommitmentItem extends StatelessWidget {
  const _CommitmentItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    height: 1.4,
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.badge,
    this.isFullWidth = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String badge;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: isFullWidth ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F261B),
            Color(0xFF040D08),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.02),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FARMBUZZ - MY FARM',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                ),
                const SizedBox(height: 24),
                
                // Headline
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: 'Run your farm with the precision '),
                      TextSpan(
                        text: 'your bloodlines',
                        style: TextStyle(color: AppColors.golden.withValues(alpha: 0.9)),
                      ),
                      const TextSpan(text: ' deserve.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Subtext
                Text(
                  'The serious side of FarmBuzz. Record every cycle, trace every bloodline, measure every outcome — in one private record you actually own.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.5,
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
