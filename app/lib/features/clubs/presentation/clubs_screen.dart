import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/club_card.dart';
import 'widgets/suggested_club_card.dart';
import 'widgets/discover_club_item.dart';
import 'widgets/create_club_modal.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Clubs Title & Create Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Clubs',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  CreateClubModal.show(context);
                },
                icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                label: const Text(
                  'Create Club',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: Icon(LucideIcons.search, color: Colors.grey.shade500, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // My Clubs Section
              Row(
                children: [
                  const Text(
                    'My Clubs',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // My Clubs List
              const ClubCard(
                title: 'GIVE ME MY MONEY',
                memberCount: 7,
                commentCount: 1,
                role: 'Member',
                isFounder: false,
                imageUrl: 'https://picsum.photos/id/1025/600/300',
              ),
              const ClubCard(
                title: 'Club',
                memberCount: 3,
                commentCount: 0,
                role: 'Founder',
                isFounder: true,
                imageUrl: 'https://picsum.photos/id/237/600/300',
              ),
              const ClubCard(
                title: 'NO MONEY, NO MORE',
                memberCount: 7,
                commentCount: 1,
                role: 'Member',
                isFounder: false,
                imageUrl: 'https://picsum.photos/id/1062/600/300',
              ),
              
              const SizedBox(height: 24),
              
              // Suggested For You Section
              Row(
                children: [
                  Icon(LucideIcons.sparkles, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Suggested For You',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Suggested Clubs List
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SuggestedClubCard(
                      title: 'GIVE ME MY MONEY',
                      memberCount: 7,
                      isJoined: true,
                    ),
                    SuggestedClubCard(
                      title: 'Club',
                      memberCount: 3,
                      isJoined: true,
                    ),
                    SuggestedClubCard(
                      title: 'NO MONEY, NO MORE',
                      memberCount: 7,
                      isJoined: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Featured Clubs Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Clubs',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'See All →',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Featured Clubs Placeholder
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 8),
                    Text(
                      'No featured clubs right now',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Discover Clubs Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discover Clubs',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'See All →',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', LucideIcons.layoutGrid, true),
                    _buildFilterChip('Bloodline', LucideIcons.droplet, false),
                    _buildFilterChip('Regional', LucideIcons.map, false),
                    _buildFilterChip('Community', LucideIcons.users, false),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Discover Clubs List Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  children: [
                    DiscoverClubItem(
                      title: 'GIVE ME MY MONEY',
                      badgeText: 'Bloodline',
                      memberCount: 7,
                      location: 'Region XI - Davao',
                      isJoined: true,
                      imageUrl: 'https://picsum.photos/id/1025/150/150',
                    ),
                    DiscoverClubItem(
                      title: 'Club',
                      badgeText: 'Bloodline',
                      memberCount: 3,
                      location: 'Region XIII - Caraga',
                      isJoined: true,
                      imageUrl: 'https://picsum.photos/id/237/150/150',
                    ),
                    DiscoverClubItem(
                      title: 'Rant your thoughts',
                      badgeText: 'Community',
                      memberCount: 5,
                      location: '',
                      isJoined: false,
                      imageUrl: 'https://picsum.photos/id/1062/150/150',
                    ),
                    DiscoverClubItem(
                      title: 'Chix in Prime',
                      badgeText: 'Bloodline',
                      memberCount: 5,
                      location: 'Region III - Central Luzon',
                      isJoined: false,
                      imageUrl: 'https://picsum.photos/id/1074/150/150',
                    ),
                    DiscoverClubItem(
                      title: 'NO MONEY, NO MORE',
                      badgeText: 'Bloodline',
                      memberCount: 7,
                      location: 'Region XI - Davao',
                      isJoined: true,
                      imageUrl: 'https://picsum.photos/id/1084/150/150',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.accentGreen
                : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.accentGreen.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
