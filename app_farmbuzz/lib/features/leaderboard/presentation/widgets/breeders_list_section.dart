import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class BreedersListSection extends StatelessWidget {
  const BreedersListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breeders at your tier',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          Text(
            'Other breeders on a similar journey',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          _buildBreederItem(
            name: 'PrimeX Ventures',
            subtitle: '0 birds',
            xp: '0 XP',
            initials: 'PV',
            initialsColor: Colors.teal,
          ),
          const Divider(height: 32, color: Color(0xFFF3F4F6)),
          _buildBreederItem(
            name: 'Chelsy De Leon',
            subtitle: '0 birds',
            xp: '140 XP',
            initials: 'CL',
            initialsColor: Colors.redAccent,
          ),
          const Divider(height: 32, color: Color(0xFFF3F4F6)),
          _buildBreederItem(
            name: 'Rhoan Manalo',
            subtitle: 'Tarlac City, Tarlac • 0 birds',
            xp: '0 XP',
            imageUrl: 'https://i.pravatar.cc/150?u=rhoan',
          ),
          const Divider(height: 32, color: Color(0xFFF3F4F6)),
          _buildBreederItem(
            name: 'Flory Ghin Oro',
            subtitle: '4 birds',
            xp: '170 XP',
            imageUrl: 'https://i.pravatar.cc/150?u=flory',
          ),
        ],
      ),
    );
  }

  Widget _buildBreederItem({
    required String name,
    required String subtitle,
    required String xp,
    String? initials,
    Color? initialsColor,
    String? imageUrl,
  }) {
    return Row(
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Newcomer',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
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
            color: AppColors.premiumGreen,
          ),
        ),
      ],
    );
  }
}
