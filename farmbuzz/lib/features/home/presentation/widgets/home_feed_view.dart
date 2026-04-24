import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'post_card.dart';
import 'story_view_screen.dart';
import 'create_story_modal.dart';

class HomeFeedView extends StatefulWidget {
  const HomeFeedView({super.key});

  @override
  State<HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<HomeFeedView> {
  final List<Map<String, String>> _posts = const [
    {
      'userName': 'TRIXIE',
      'userAvatar': 'https://i.pravatar.cc/150?u=trixie',
      'timeAgo': '1h',
      'postText': 'OPEN FOR BIDDING GUYS\n2 KIND OF BREEDING NARIN MGA BOSS\nGET NYO NA :>\nPM IS THE KEY',
      'postImageUrl': 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=600',
      'likesCount': '12',
      'commentsCount': '4',
    },
    {
      'userName': 'ALYSSA ROSE',
      'userAvatar': 'https://i.pravatar.cc/150?u=alyssa',
      'timeAgo': '2h',
      'postText': 'New batch of chicks just arrived! 🐥 Everything looks healthy so far.',
      'postImageUrl': 'https://images.unsplash.com/photo-1516733725897-1aa73b87c8e8?w=600',
      'likesCount': '24',
      'commentsCount': '8',
    },
    {
      'userName': 'JOHN DEE',
      'userAvatar': 'https://i.pravatar.cc/150?u=john',
      'timeAgo': '5h',
      'postText': 'Checking the fertility rate of the current batch. Bantay AI says we are at 85%!🔥',
      'postImageUrl': 'https://images.unsplash.com/photo-1582515073490-39981397c445?w=600',
      'likesCount': '45',
      'commentsCount': '15',
    },
    {
      'userName': 'FARM MASTER',
      'userAvatar': 'https://i.pravatar.cc/150?u=master',
      'timeAgo': '1d',
      'postText': 'Anyone else seeing a dip in egg production with the recent weather change?',
      'postImageUrl': 'https://images.unsplash.com/photo-1569254994521-ddbb54af5ae8?w=600',
      'likesCount': '89',
      'commentsCount': '32',
    },
  ];

  // Dynamic stories state
  final List<Map<String, String>> _dynamicStories = [];

  void _addNewStory(String imagePath) {
    setState(() {
      _dynamicStories.insert(0, {
        'name': 'Janrey',
        'time': 'Just now',
        'imagePath': imagePath, // Use the actual path
        'avatarUrl': 'https://i.pravatar.cc/150?u=janrey',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatusUpdateBox(),
          _StoriesSection(
            dynamicStories: _dynamicStories,
            onAddStory: _addNewStory,
          ),
          const _FilterTabs(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return PostCard(
                userName: post['userName']!,
                userAvatar: post['userAvatar']!,
                timeAgo: post['timeAgo']!,
                postText: post['postText']!,
                postImageUrl: post['postImageUrl']!,
                likesCount: post['likesCount']!,
                commentsCount: post['commentsCount']!,
              );
            },
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
            color: Colors.black.withOpacity(0.05),
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
  const _StoriesSection({
    required this.dynamicStories,
    required this.onAddStory,
  });

  final List<Map<String, String>> dynamicStories;
  final ValueChanged<String> onAddStory;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _AddStoryCard(onAddStory: onAddStory),
          ...dynamicStories.map((story) => _StoryCard(
                name: story['name']!,
                time: story['time']!,
                imageUrl: story['imagePath']!, // Passing path here
                avatarUrl: story['avatarUrl']!,
                isNew: true,
                isLocal: true,
              )),
          const _StoryCard(
            name: 'Alyssa Rose',
            time: '1 new • 10m ago',
            imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400',
            avatarUrl: 'https://i.pravatar.cc/150?u=alyssa',
          ),
          const _StoryCard(
            name: 'TRIXIE',
            time: '19h ago',
            imageUrl: 'https://images.unsplash.com/photo-1516733725897-1aa73b87c8e8?w=400',
            avatarUrl: 'https://i.pravatar.cc/150?u=trixie',
          ),
          const _StoryCard(
            name: 'John Doe',
            time: '2h ago',
            imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400',
            avatarUrl: 'https://i.pravatar.cc/150?u=john',
          ),
        ],
      ),
    );
  }
}

class _AddStoryCard extends StatelessWidget {
  const _AddStoryCard({required this.onAddStory});

  final ValueChanged<String> onAddStory;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => CreateStoryModal.show(context, onStoryCreated: onAddStory),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?u=janrey'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 12),
                        Text(
                          'Create story',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    this.isNew = false,
    this.isLocal = false,
  });

  final String name;
  final String time;
  final String imageUrl;
  final String avatarUrl;
  final bool isNew;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryViewScreen(
              userName: name,
              avatarUrl: avatarUrl,
              imageUrl: imageUrl,
              isLocal: isLocal,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: isLocal 
              ? FileImage(File(imageUrl)) as ImageProvider
              : NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isNew ? AppColors.accentGreen : Colors.white.withOpacity(0.5),
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
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          color: isActive ? AppColors.accentGreen : Colors.grey.withOpacity(0.2),
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
    );
  }
}
