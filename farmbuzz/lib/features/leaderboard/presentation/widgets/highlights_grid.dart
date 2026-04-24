import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HighlightsGrid extends StatelessWidget {
  const HighlightsGrid({super.key});

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
              const Icon(Icons.auto_awesome, size: 18, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Text(
                "This Month's Highlights",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildHighlightCard(Icons.favorite_border, '0', 'Health records logged'),
              _buildHighlightCard(Icons.track_changes, '0', 'Breeding programs completed'),
              _buildHighlightCard(Icons.bolt, '0', 'Birds added to farm'),
              _buildHighlightCard(Icons.menu_book_outlined, '2', 'Posts shared'),
              _buildHighlightCard(Icons.local_fire_department_outlined, '0 days', 'Login streak'),
              _buildHighlightCard(Icons.photo_camera_outlined, '0', 'Farm photos uploaded'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
