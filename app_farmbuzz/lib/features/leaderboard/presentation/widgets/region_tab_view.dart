import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/core/session/app_session.dart';

class RegionTabView extends StatelessWidget {
  const RegionTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Picker Placeholder
        _buildMonthPicker(),
        const SizedBox(height: 24),
        
        // Regional Community Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCFCE7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REGIONAL COMMUNITY',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.premiumGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nationwide Breeders',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildChangeRegionButton(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '7 breeders in Apr 2026',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Breeders List
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            children: [
              _buildBreederItem(
                name: 'Ailyssa Rose Jemino',
                subtitle: 'Tarlac City, Tarlac • 1 birds',
                xp: '320 XP',
                imageUrl: 'https://i.pravatar.cc/150?u=ailyssa',
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              _buildBreederItem(
                name: 'TRIXIE',
                subtitle: 'TARLAC • 5 birds',
                xp: '300 XP',
                imageUrl: 'https://i.pravatar.cc/150?u=trixie',
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              _buildBreederItem(
                name: 'Flory Ghin Oro',
                subtitle: '4 birds',
                xp: '170 XP',
                imageUrl: 'https://i.pravatar.cc/150?u=flory',
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              _buildBreederItem(
                name: 'Chelsy De Leon',
                subtitle: '0 birds',
                xp: '140 XP',
                initials: 'CL',
                initialsColor: Colors.redAccent,
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              _buildBreederItem(
                name: AppSession.userName,
                subtitle: '1 birds',
                xp: '110 XP',
                isUser: true,
                imageUrl: AppSession.avatarUrl.isNotEmpty ? AppSession.avatarUrl : null,
                initials: AppSession.userName.isNotEmpty ? AppSession.userName[0].toUpperCase() : 'U',
                initialsColor: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.premiumGreen),
          const SizedBox(width: 8),
          Text(
            'Apr 2026',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildChangeRegionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.premiumGreen),
          const SizedBox(width: 8),
          Text(
            'Change Region',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildBreederItem({
    required String name,
    required String subtitle,
    required String xp,
    bool isUser = false,
    String? initials,
    Color? initialsColor,
    String? imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFF0FDF4) : Colors.transparent,
        borderRadius: isUser ? BorderRadius.circular(12) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: initialsColor?.withOpacity(0.1) ?? Colors.grey[100],
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: initials != null && imageUrl == null
                ? Text(
                    initials,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: initialsColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.premiumGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFFFEF3C7) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Newcomer',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isUser ? const Color(0xFFD97706) : Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isUser ? const Color(0xFF92400E).withOpacity(0.7) : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            xp,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isUser ? const Color(0xFFD97706) : AppColors.premiumGreen,
            ),
          ),
        ],
      ),
    );
  }
}
