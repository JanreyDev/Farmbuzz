import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import '../club_detail_screen.dart';

enum ClubRole { founder, member }

/// A premium club card that supports both network and local file images.
class ClubCard extends StatelessWidget {
  final String title;
  final ClubRole role;
  final int memberCount;
  final int postCount;
  final String? imageUrl;
  final String? region;
  final bool isPublic;
  final bool isJoined;

  const ClubCard({
    super.key,
    required this.title,
    required this.role,
    this.memberCount = 0,
    this.postCount = 0,
    this.imageUrl,
    this.region,
    this.isPublic = true,
    this.isJoined = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocal = imageUrl != null && !imageUrl!.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClubDetailScreen(
              title: title,
              coverUrl: imageUrl,
              memberCount: memberCount,
              postCount: postCount,
              region: region,
              isPublic: isPublic,
              role: role == ClubRole.founder ? 'founder' : 'member',
              isJoined: isJoined,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Section (Image/Gradient)
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: imageUrl != null
                    ? DecorationImage(
                        image: isLocal 
                            ? FileImage(File(imageUrl!)) as ImageProvider
                            : NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: imageUrl == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[300]!,
                          Colors.white,
                        ],
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: imageUrl != null
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.6),
                          ],
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // Role Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: role == ClubRole.founder ? AppColors.premiumGreen : Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              role == ClubRole.founder ? Icons.stars : Icons.person_outline,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              role == ClubRole.founder ? 'Founder' : 'Member',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Title
                    Positioned(
                      bottom: 12,
                      left: 20,
                      right: 20,
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: imageUrl != null ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Stats Bar (White)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  _buildStat(Icons.people_outline, memberCount.toString()),
                  const SizedBox(width: 16),
                  _buildStat(Icons.chat_bubble_outline, postCount.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
