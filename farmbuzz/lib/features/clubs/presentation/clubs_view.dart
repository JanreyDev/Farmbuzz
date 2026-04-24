import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'widgets/clubs_search_bar.dart';
import 'widgets/club_card.dart';
import 'widgets/empty_state_card.dart';

class ClubsView extends StatefulWidget {
  const ClubsView({super.key});

  @override
  State<ClubsView> createState() => _ClubsViewState();
}

class _ClubsViewState extends State<ClubsView> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Bloodline', 'Regional', 'Community', 'Education'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clubs',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Club'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premiumGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search Bar
            const ClubsSearchBar(),
            const SizedBox(height: 32),
            
            // My Clubs Section
            _buildSectionHeader(
              title: 'My Clubs',
              onSeeAll: () {},
            ),
            const SizedBox(height: 16),
            const ClubCard(
              title: 'Elite Gamefowl Breeders',
              role: ClubRole.founder,
              memberCount: 154,
              postCount: 12,
              imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?q=80&w=1000&auto=format&fit=crop',
            ),
            const ClubCard(
              title: 'Backyard Poultry PH',
              role: ClubRole.member,
              memberCount: 2450,
              postCount: 89,
              imageUrl: 'https://images.unsplash.com/photo-1516467508483-a7212febe31a?q=80&w=1000&auto=format&fit=crop',
            ),
            const ClubCard(
              title: 'Egg Production Experts',
              role: ClubRole.member,
              memberCount: 78,
              postCount: 5,
              imageUrl: 'https://images.unsplash.com/photo-1598965402089-897ce52e8355?q=80&w=1000&auto=format&fit=crop',
            ),
            const SizedBox(height: 32),
            
            // Featured Clubs Section
            _buildSectionHeader(
              title: 'Featured Clubs',
              onSeeAll: () {},
            ),
            const SizedBox(height: 16),
            const EmptyStateCard(
              icon: Icons.star_rounded,
              title: 'No featured clubs right now',
            ),
            const SizedBox(height: 32),
            
            // Discover Clubs Section
            _buildSectionHeader(
              title: 'Discover Clubs',
              onSeeAll: () {},
            ),
            const SizedBox(height: 16),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    selectedColor: AppColors.premiumGreen,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selectedCategory == cat ? Colors.white : Colors.grey[600],
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selectedCategory == cat ? Colors.transparent : Colors.grey[200]!,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            
            EmptyStateCard(
              icon: Icons.search_rounded,
              title: 'No clubs to discover',
              subtitle: 'Try a different category or browse all clubs.',
              actionLabel: 'See all clubs',
              onAction: () {},
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Row(
            children: [
              Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.premiumGreen,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 14, color: AppColors.premiumGreen),
            ],
          ),
        ),
      ],
    );
  }
}
