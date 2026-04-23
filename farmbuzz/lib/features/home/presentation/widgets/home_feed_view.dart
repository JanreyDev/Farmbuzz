import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class HomeFeedView extends StatelessWidget {
  const HomeFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Box
          const _StatusUpdateBox(),
          
          // Stories Section
          const _StoriesSection(),

          // Filter Tabs
          const _FilterTabs(),

          // Feed List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) => const _PostCard(),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatusUpdateBox extends StatelessWidget {
  const _StatusUpdateBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janrey'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "What's happening on your farm?",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Icon(Icons.image_outlined, color: AppColors.accentGreen, size: 20),
              const SizedBox(width: 10),
              Icon(Icons.videocam_outlined, color: Colors.blueAccent, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoriesSection extends StatelessWidget {
  const _StoriesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          _AddStoryCard(),
          _StoryCard(
            name: 'Alyssa Rose',
            time: '1 new • 10m ago',
            imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400',
            avatarUrl: 'https://i.pravatar.cc/150?u=alyssa',
          ),
          _StoryCard(
            name: 'TRIXIE',
            time: '19h ago',
            imageUrl: 'https://images.unsplash.com/photo-1516733725897-1aa73b87c8e8?w=400',
            avatarUrl: 'https://i.pravatar.cc/150?u=trixie',
          ),
          _StoryCard(
            name: 'John Doe',
            time: '2h ago',
            imageUrl: 'https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?w=400',
            avatarUrl: 'https://i.pravatar.cc/150?u=john',
          ),
        ],
      ),
    );
  }
}

class _AddStoryCard extends StatelessWidget {
  const _AddStoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B281B), Color(0xFF0A0F0A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 12,
            left: 12,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF2D4F2D),
              child: Icon(Icons.auto_awesome, color: AppColors.accentGreen, size: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Story',
                  style: GoogleFonts.instrumentSerif(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '20h ago',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.golden,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.name,
    required this.time,
    required this.imageUrl,
    required this.avatarUrl,
  });

  final String name;
  final String time;
  final String imageUrl;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 9,
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

class _FilterTabs extends StatelessWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(label: 'For You', icon: Icons.auto_awesome, isActive: true),
            _FilterChip(label: 'Following', icon: Icons.person_outline),
            _FilterChip(label: 'Reels', icon: Icons.play_circle_outline),
            _FilterChip(label: 'Trending', icon: Icons.trending_up),
            _FilterChip(label: 'Bantay', icon: Icons.security_outlined),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.accentGreen : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.2),
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
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=trixie'),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TRIXIE', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('1h • 🌎', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
              ],
            ),
          ),
          
          // Post Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'OPEN FOR BIDDING GUYS\n2 KIND OF BREEDING NARIN MGA BOSS\nGET NYO NA :>\nPM IS THE KEY',
              style: TextStyle(fontSize: 14),
            ),
          ),

          // Post Image
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Image.network(
              'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=600',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Post Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, size: 20, color: Colors.grey),
                const SizedBox(width: 4),
                const Text('24', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
                const SizedBox(width: 4),
                const Text('8', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.share_outlined, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
