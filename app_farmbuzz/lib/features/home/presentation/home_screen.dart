import 'package:flutter/material.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/home_feed_view.dart';
import 'widgets/home_drawer.dart';
import 'widgets/my_farm_view.dart';
import 'widgets/bantay_ai_view.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/messages/presentation/messages_screen.dart';
import 'package:farmbuzz/features/notifications/presentation/notifications_screen.dart';
import 'package:farmbuzz/features/landing/presentation/landing_screen.dart';

import 'package:farmbuzz/features/clubs/presentation/clubs_view.dart';
import 'package:farmbuzz/features/leaderboard/presentation/leaderboard_view.dart';

import 'package:farmbuzz/features/profile/presentation/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeFeedView(),
    const MyFarmView(),
    const BantayAiView(),
    const ClubsView(),
    const LeaderboardView(),
  ];

  void _showAiMenu(BuildContext context) {
    // This replicates the history menu functionality
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    'Bantay AI Menu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _menuItem(
                    Icons.history_rounded,
                    'Conversation History',
                    'Access your past chats',
                  ),
                  _menuItem(
                    Icons.settings_suggest_outlined,
                    'AI Settings',
                    'Customize Bantay\'s persona',
                  ),
                  _menuItem(
                    Icons.info_outline_rounded,
                    'How to Use',
                    'Tips for better AI results',
                  ),
                  _menuItem(
                    Icons.delete_outline_rounded,
                    'Clear Current Chat',
                    'Start a fresh session',
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.grey[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  Future<void> _handleLogout() async {
    if (!mounted) {
      return;
    }

    AppSession.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = AppSession.avatarUrlOrEmpty;
    final hasAvatar = _hasValidAvatarUrl(avatarUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Refined light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 42,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => const Text(
            'FarmBuzz',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Badge(
              label: Text('3', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.chat_bubble_outline, color: Colors.black87),
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MessagesScreen()));
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Badge(
              label: Text('5', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.notifications_outlined, color: Colors.black87),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          InkWell(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: hasAvatar
                    ? null
                    : Text(
                        _initial(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      drawer: HomeDrawer(
        selectedIndex: _selectedIndex,
        onSelectItem: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context); // Close drawer
        },
        onLogout: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 150), _handleLogout);
        },
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 2
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _selectedIndex = 2),
              backgroundColor: const Color(0xFFD97706), // Bantay AI Amber
              elevation: 4,
              shape: const CircleBorder(),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        height: 70, // Slightly taller for better alignment
        color: Colors.white,
        shape: _selectedIndex == 2 ? null : const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(child: _bottomNavItem(0, Icons.home_filled, 'Home')),
            Expanded(child: _bottomNavItem(1, Icons.agriculture, 'My Farm')),

            // The "Normal Menu" Sparkle Button for AI View
            if (_selectedIndex == 2)
              GestureDetector(
                onTap: () => _showAiMenu(context),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF59E0B),
                        const Color(0xFFD97706),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              )
            else
              const SizedBox(width: 70),

            Expanded(child: _bottomNavItem(3, Icons.groups, 'Clubs')),
            Expanded(child: _bottomNavItem(4, Icons.leaderboard, 'Rank')),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.accentGreen : Colors.grey,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accentGreen : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasValidAvatarUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _initial() {
    final name = AppSession.userName.trim();
    if (name.isEmpty) {
      return 'U';
    }
    return name.substring(0, 1).toUpperCase();
  }
}
