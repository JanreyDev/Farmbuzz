import 'package:flutter/material.dart';
import 'tier_card.dart';
import 'achievement_banner.dart';
import 'xp_growth_chart.dart';
import 'highlights_grid.dart';
import 'badges_section.dart';
import 'recent_badges_card.dart';
import 'breeders_list_section.dart';
import 'package:google_fonts/google_fonts.dart';

class MyJourneyTabView extends StatelessWidget {
  const MyJourneyTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TierCard(),
        const SizedBox(height: 16),
        AchievementBanner(),
        const SizedBox(height: 16),
        XpGrowthChart(),
        const SizedBox(height: 16),
        HighlightsGrid(),
        const SizedBox(height: 16),
        BadgesSection(),
        const SizedBox(height: 16),
        RecentBadgesCard(),
        const SizedBox(height: 16),
        
        // Milestones Placeholder
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars, color: Colors.orangeAccent, size: 18),
              const SizedBox(width: 12),
              Text(
                'Milestones',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '0/10',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        BreedersListSection(),
        const SizedBox(height: 16),
        
        // How to Earn XP Placeholder
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              Text(
                'How to Earn XP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
            ],
          ),
        ),
      ],
    );
  }
}
