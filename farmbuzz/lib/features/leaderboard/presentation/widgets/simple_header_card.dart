import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleHeaderCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final Color labelColor;

  const SimpleHeaderCard({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
