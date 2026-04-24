import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.postText,
    this.postImageUrl,
    this.likesCount = '0',
    this.commentsCount = '0',
  });

  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String postText;
  final String? postImageUrl;
  final String likesCount;
  final String commentsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(userAvatar),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$timeAgo • ',
                          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11),
                        ),
                        Icon(Icons.public, size: 10, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Post Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              postText,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),

          // Post Image
          if (postImageUrl != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  postImageUrl!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          // Engagement Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.thumb_up, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Text(
                  likesCount,
                  style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '$commentsCount comments',
                  style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PostAction(icon: Icons.thumb_up_outlined, label: 'Like'),
                _PostAction(icon: Icons.chat_bubble_outline, label: 'Comment'),
                _PostAction(icon: Icons.share_outlined, label: 'Share'),
                _PostAction(icon: Icons.bookmark_outline, label: 'Save'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: Colors.grey[700]),
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
