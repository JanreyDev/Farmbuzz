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
      drawer: const HomeDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accentGreen,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.agriculture), label: 'My Farm'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Bantay AI'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Clubs'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Rank'),
        ],
      ),
    );
  }
}
