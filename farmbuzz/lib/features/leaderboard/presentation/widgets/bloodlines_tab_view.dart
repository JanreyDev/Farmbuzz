import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'leaderboard_empty_state.dart';

class BloodlinesTabView extends StatelessWidget {
  const BloodlinesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthPicker(),
        const SizedBox(height: 32),
        LeaderboardEmptyState(
          icon: Icons.bookmark_border,
          title: 'Bloodline leaderboards coming soon',
          subtitle: 'As breeders set their bloodline specialties, top specialists surface here.',
        ),
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
}
