import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'widgets/my_journey_tab_view.dart';
import 'widgets/region_tab_view.dart';
import 'widgets/bloodlines_tab_view.dart';
import 'widgets/clubs_tab_view.dart';
import 'widgets/shoutouts_tab_view.dart';
import 'widgets/awards_tab_view.dart';

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
            
            // Content based on selected tab
            _buildTabContent(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 'My Journey':
        return const MyJourneyTabView();
      case 'Region':
        return const RegionTabView();
      case 'Bloodlines':
        return const BloodlinesTabView();
      case 'Clubs':
        return const ClubsTabView();
      case 'Shoutouts':
        return const ShoutoutsTabView();
      case 'Awards':
        return const AwardsTabView();
      default:
        return const MyJourneyTabView();
    }
  }
}
