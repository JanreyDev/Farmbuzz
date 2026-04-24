import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'simple_header_card.dart';
import 'leaderboard_empty_state.dart';

class ShoutoutsTabView extends StatelessWidget {
  const ShoutoutsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthPicker(),
        const SizedBox(height: 24),
        SimpleHeaderCard(
          label: 'Community Shoutouts',
          title: 'Apr 2026 standouts',
          subtitle: 'Celebrating growth, contribution, and dedication',
          bgColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFEF3C7),
          textColor: Color(0xFF92400E),
          labelColor: Color(0xFFB45309),
        ),
        const SizedBox(height: 32),
        LeaderboardEmptyState(
          icon: Icons.auto_awesome_outlined,
          title: 'No shoutouts for this month yet',
          subtitle: 'They refresh at the start of each month — check back soon.',
        ),
        const SizedBox(height: 24),
        _buildInfoBox(),
      ],
    );
  }

  Widget _buildMonthPicker() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF158D42)),
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
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are shoutouts chosen?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Shoutouts highlight breeders who showed the most growth, helped the community, or started strong this month. It's not about having the most birds — it's about showing up for other breeders.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
