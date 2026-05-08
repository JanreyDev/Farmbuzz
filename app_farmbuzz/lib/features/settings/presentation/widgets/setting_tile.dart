import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? tag;
  final Widget? trailing;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final bool isLast;
  final Widget? leading;

  const SettingTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.trailing,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
    this.isLast = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSwitchChanged != null ? () => onSwitchChanged!(!switchValue!) : onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (tag != null)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                      ),
                    ),
                  ),
                if (switchValue != null)
                  Switch(
                    value: switchValue!,
                    onChanged: onSwitchChanged,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green,
                  )
                else if (trailing != null)
                  trailing!
                else
                  Icon(Icons.chevron_right, size: 20, color: Colors.grey[300]),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }
}
