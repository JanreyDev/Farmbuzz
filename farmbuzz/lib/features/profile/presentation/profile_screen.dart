import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/home/presentation/widgets/post_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/profile_tabs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),
            const ProfileStats(),
            const ProfileTabs(),
            const SizedBox(height: 24),
            
            // Post Feed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0), // PostCard handles its own horizontal margin
              child: Column(
                children: [
                  const PostCard(
                    userName: 'Janrey',
                    userAvatar: 'https://i.pravatar.cc/150?u=janrey',
                    timeAgo: '22h',
                    postText: 'Checking the environment variables for the new project setup. Everything seems to be in order! 🚀',
                    postImageUrl: 'https://images.unsplash.com/photo-1554224155-1696413565d3?q=80&w=1000',
                    likesCount: '5',
                    commentsCount: '2',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


}
