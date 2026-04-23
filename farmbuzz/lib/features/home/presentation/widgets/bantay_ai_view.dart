import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class BantayAiView extends StatelessWidget {
  const BantayAiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const _AiHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const _AiHeroAvatar(),
                  const SizedBox(height: 24),
                  Text(
                    'Magandang araw, Janrey!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Your private farm assistant. Ask about flock health, breeding, feed, weather, or how to use FarmBuzz. Pick a starter below or type your own.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const _PromptGrid(),
                  const SizedBox(height: 40),
                  Text(
                    'Bantay gives farm guidance, not veterinary prescriptions. For a seriously sick bird, call your local vet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const _AiInputSection(),
        ],
      ),
    );
  }
}

class _AiHeader extends StatelessWidget {
  const _AiHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.aiAmberBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.security_rounded, color: AppColors.aiAmberIcon, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bantay AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Your personal farm assistant',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.aiGreenText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.history_rounded, size: 16),
            label: const Text('History'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[200]!),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiHeroAvatar extends StatelessWidget {
  const _AiHeroAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.aiAmberBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.aiAmberIcon.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.security_rounded, size: 40, color: AppColors.aiAmberIcon),
      ),
    );
  }
}

class _PromptGrid extends StatelessWidget {
  const _PromptGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: const [
        _PromptCard(
          icon: Icons.monitor_heart_outlined,
          title: 'Is Test thunder healthy?',
          subtitle: 'Red flags to watch + what to do next',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
        ),
        _PromptCard(
          icon: Icons.medication_outlined,
          title: 'Build a vaccine schedule',
          subtitle: 'Newcastle, pox, coryza — timed for my region',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
        ),
        _PromptCard(
          icon: Icons.grass_outlined,
          title: 'Conditioning feed for Test thunder',
          subtitle: '21-day program, ingredients + ratios',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
        ),
        _PromptCard(
          icon: Icons.egg_outlined,
          title: 'Improve hatch rate',
          subtitle: 'Fertility + incubation troubleshooting',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
          isActive: true,
        ),
        _PromptCard(
          icon: Icons.thermostat_outlined,
          title: 'Prep for this week\'s weather',
          subtitle: 'Electrolytes, shade, pen changes',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
        ),
        _PromptCard(
          icon: Icons.scale_outlined,
          title: 'Weight targets by age',
          subtitle: 'Weekly milestones, per bloodline',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.bgColor,
    this.isActive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color bgColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFFFCD34D) : Colors.grey[200]!,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInputSection extends StatelessWidget {
  const _AiInputSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.image_outlined, color: Colors.grey[400]),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ask Bantay anything about your farm...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.send_rounded, color: Colors.grey[300], size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
