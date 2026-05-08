import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.birdsCount,
  });

  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int birdsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(followersCount.toString(), 'FOLLOWERS'),
          _buildDivider(),
          _buildStatItem(followingCount.toString(), 'FOLLOWING'),
          _buildDivider(),
          _buildStatItem(postsCount.toString(), 'POSTS'),
          _buildDivider(),
          _buildStatItem(birdsCount.toString(), 'BIRDS'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey[100],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
