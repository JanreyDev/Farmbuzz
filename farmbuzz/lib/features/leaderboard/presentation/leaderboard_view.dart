import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'widgets/tier_card.dart';
import 'widgets/achievement_banner.dart';
import 'widgets/xp_growth_chart.dart';
import 'widgets/highlights_grid.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  String selectedTab = 'My Journey';
  final List<String> tabs = ['My Journey', 'Region', 'Bloodlines', 'Clubs', 'Shoutouts', 'Awards'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breeder Journey',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.map((tab) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: selectedTab == tab,
                    onSelected: (selected) {
                      setState(() {
                        selectedTab = tab;
                      });
                    },
                    selectedColor: AppColors.premiumGreen,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selectedTab == tab ? Colors.white : Colors.grey[600],
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selectedTab == tab ? Colors.transparent : Colors.grey[200]!,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 32),
            
            // Content
            const TierCard(),
            const SizedBox(height: 16),
            const AchievementBanner(),
            const SizedBox(height: 16),
            const XpGrowthChart(),
            const SizedBox(height: 16),
            const HighlightsGrid(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
