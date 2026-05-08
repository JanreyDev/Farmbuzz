import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.coverPhotoUrl,
    required this.localAvatarPath,
    required this.localCoverPath,
    required this.joinedLabel,
    required this.onEditAvatar,
    required this.onEditCover,
    required this.onEditProfile,
  });

  final String userName;
  final String avatarUrl;
  final String coverPhotoUrl;
  final String? localAvatarPath;
  final String? localCoverPath;
  final String joinedLabel;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditCover;
  final VoidCallback onEditProfile;

  bool _hasValidAvatarUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _initial() {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalAvatar = (localAvatarPath ?? '').trim().isNotEmpty;
    final hasAvatar = _hasValidAvatarUrl(avatarUrl);
    final hasLocalCover = (localCoverPath ?? '').trim().isNotEmpty;
    final hasCover = _hasValidAvatarUrl(coverPhotoUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                image: DecorationImage(
                  image: hasLocalCover
                      ? FileImage(File(localCoverPath!)) as ImageProvider
                      : (hasCover
                            ? NetworkImage(coverPhotoUrl)
                            : const AssetImage('assets/images/cover_photo.png') as ImageProvider),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: -40,
              child: GestureDetector(
                onTap: onEditAvatar,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: hasLocalAvatar
                            ? FileImage(File(localAvatarPath!))
                            : (hasAvatar ? NetworkImage(avatarUrl) : null),
                        child: (hasLocalAvatar || hasAvatar)
                            ? null
                            : Text(
                                _initial(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                ),
                              ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: GestureDetector(
                onTap: onEditCover,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Edit cover photo',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 45),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildIconButton(
                Icons.edit_outlined,
                color: AppColors.premiumGreen,
                iconColor: Colors.white,
                onTap: onEditProfile,
              ),
              const SizedBox(width: 8),
              _buildIconButton(Icons.agriculture_outlined),
              const SizedBox(width: 8),
              _buildIconButton(Icons.more_horiz),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_outlined, size: 12, color: Colors.orangeAccent),
                        const SizedBox(width: 4),
                        Text(
                          'NEWCOMER',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '@${userName.toLowerCase().replaceAll(' ', '')}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    joinedLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    Color? color,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: color == null ? Border.all(color: Colors.grey[200]!) : null,
          boxShadow: [
            if (color != null)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.black87),
      ),
    );
  }
}