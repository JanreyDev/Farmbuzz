import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentBadgesCard extends StatelessWidget {
  const RecentBadgesCard({super.key});

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
              const Icon(Icons.workspace_premium_outlined, size: 18, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Recent Badges Earned',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF), // Light blue
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0EFFF)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0EFFF)),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Color(0xFF3B82F6), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Club Founder',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                      Text(
                        'Started a breeder club',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF1E40AF).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Apr 22',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E40AF).withOpacity(0.5),
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
