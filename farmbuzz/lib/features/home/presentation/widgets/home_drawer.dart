import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/profile/presentation/profile_screen.dart';
import 'package:farmbuzz/features/messages/presentation/messages_screen.dart';
import 'package:farmbuzz/features/notifications/presentation/notifications_screen.dart';
import 'package:farmbuzz/features/activity/presentation/activity_screen.dart';
import 'package:farmbuzz/features/saved/presentation/saved_screen.dart';

class HomeDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectItem;

  const HomeDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectItem,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // User Profile Section
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 60, 16, 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janrey'),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Janrey',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(context, Icons.home_outlined, 'Home', isActive: selectedIndex == 0, onTap: () => onSelectItem(0)),
                _buildNavItem(context, Icons.grid_view_outlined, 'My Farm', isActive: selectedIndex == 1, onTap: () => onSelectItem(1)),
                _buildNavItem(context, Icons.chat_bubble_outline, 'Messages', badge: '3', onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
                }),
                _buildNavItem(
                  context, 
                  Icons.auto_awesome_outlined, 
                  'Bantay AI',
                  isActive: selectedIndex == 2,
                  subtitle: 'Your farm assistant',
                  onTap: () => onSelectItem(2),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Divider(height: 1, thickness: 1),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'EXPLORE',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[400],
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                _buildNavItem(context, Icons.groups_outlined, 'Clubs', isActive: selectedIndex == 3, onTap: () => onSelectItem(3)),
                _buildNavItem(context, Icons.emoji_events_outlined, 'Leaderboard', isActive: selectedIndex == 4, onTap: () => onSelectItem(4)),
                _buildNavItem(context, Icons.notifications_none_outlined, 'Notifications', badge: '5', onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                }),
                _buildNavItem(context, Icons.analytics_outlined, 'Activity', onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen()));
                }),
                _buildNavItem(context, Icons.bookmark_border_outlined, 'Saved', onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScreen()));
                }),
                _buildNavItem(context, Icons.settings_outlined, 'Settings', onTap: () => Navigator.pop(context)),
                
                const SizedBox(height: 40),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'FarmBuzz © 2026\nThe Breeder\'s Network',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, 
    IconData icon, 
    String title, {
    String? subtitle,
    String? badge,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon, 
        color: isActive ? AppColors.accentGreen : Colors.black87,
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
          color: isActive ? AppColors.accentGreen : Colors.black87,
        ),
      ),
      subtitle: subtitle != null 
        ? Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          )
        : null,
      trailing: badge != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        : null,
      onTap: onTap ?? () {
        Navigator.pop(context);
        // Default logic
      },
    );
  }
}

