import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

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
          Row(
            children: [
              const Icon(Icons.stars_outlined, size: 18, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Text(
                'Next Badges to Earn',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBadgeItem(
            icon: Icons.star_border,
            iconColor: Colors.green,
            iconBg: const Color(0xFFF0FDF4),
            title: 'First Steps',
            subtitle: 'Registered your first bird',
            current: 0,
            total: 1,
          ),
          const SizedBox(height: 16),
          _buildBadgeItem(
            icon: Icons.favorite_border,
            iconColor: Colors.redAccent,
            iconBg: const Color(0xFFFEF2F2),
            title: 'Health Champion',
            subtitle: '500+ health records logged',
            current: 0,
            total: 500,
          ),
          const SizedBox(height: 16),
          _buildBadgeItem(
            icon: Icons.track_changes,
            iconColor: Colors.teal,
            iconBg: const Color(0xFFF0FDFA),
            title: 'Dedicated Breeder',
            subtitle: '10+ breeding programs completed',
            current: 0,
            total: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required int current,
    required int total,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: total == 0 ? 0 : current / total,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '$current/$total',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
