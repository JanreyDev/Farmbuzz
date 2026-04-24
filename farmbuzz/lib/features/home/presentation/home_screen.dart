import 'package:flutter/material.dart';
import 'widgets/home_feed_view.dart';
import 'widgets/home_drawer.dart';
import 'widgets/my_farm_view.dart';
import 'widgets/bantay_ai_view.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/messages/presentation/messages_screen.dart';
import 'package:farmbuzz/features/notifications/presentation/notifications_screen.dart';

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

  @override
  Widget build(BuildContext context) {
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MessagesScreen()),
              );
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=janrey'),
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
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
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
              colors: [
                const Color(0xFFF59E0B),
                const Color(0xFFD97706),
              ],
            ),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        height: 65,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(child: _bottomNavItem(0, Icons.home_filled, 'Home')),
            Expanded(child: _bottomNavItem(1, Icons.agriculture, 'My Farm')),
            const SizedBox(width: 70), // Increased space for the large FAB
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
}
