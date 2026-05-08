import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'simple_header_card.dart';
import 'leaderboard_empty_state.dart';

class AwardsTabView extends StatelessWidget {
  const AwardsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthPicker(),
        const SizedBox(height: 24),
        SimpleHeaderCard(
          label: 'Monthly Awards',
          title: 'Apr 2026 Category Leaders',
          subtitle: 'Every breeder can excel in different areas',
          bgColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFDBEAFE),
          textColor: Color(0xFF1E40AF),
          labelColor: Color(0xFF2563EB),
        ),
        const SizedBox(height: 32),
        LeaderboardEmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'No awards yet for this month',
          subtitle: 'Category winners are picked once monthly activity accumulates.',
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
