import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';
import '../../clubs/presentation/clubs_screen.dart';
import 'my_farm_setup_screen.dart';
import 'my_farm_dashboard_screen.dart';
import 'profile_screen.dart';
import 'rank_screen.dart';

void _showBottomToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 14,
      right: 14,
      bottom: 94,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future<void>.delayed(const Duration(milliseconds: 1700), () {
    entry.remove();
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;
  int _selectedIndex = 0;
  bool _hasFarm = false;
  bool _isFarmLoading = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkFarmStatus();
  }

  Future<void> _checkFarmStatus() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _hasFarm = prefs.getBool('farm_created') ?? false;
          _isFarmLoading = false;
          _isChecking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasFarm = FallbackFarmStore.farmCreated;
          _isFarmLoading = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFarmLoading) {
      _checkFarmStatus();
    }
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        drawer: _HomeDrawer(
          onNavigateTab: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
        body: _selectedIndex == 0 ? _buildHomeFeed() : _buildTabPlaceholder(),
        floatingActionButton: (_selectedIndex == 2 || isKeyboardOpen)
            ? null
            : FloatingActionButton(
                onPressed: () => setState(() => _selectedIndex = 2),
                backgroundColor: const Color(0xFFD97706),
                elevation: 4,
                shape: const CircleBorder(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
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
          height: 70,
          color: Colors.white,
          shape: _selectedIndex == 2 ? null : const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(child: _bottomNavItem(0, Icons.home_filled, 'Home')),
              Expanded(child: _bottomNavItem(1, Icons.agriculture, 'My Farm')),
              if (_selectedIndex == 2)
                GestureDetector(
                  onTap: () =>
                      _showBottomToast(context, 'AI shortcuts coming next.'),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD97706),
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
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
      ),
    );
  }

  Widget _buildHomeFeed() {
    return Column(
      children: [
        const _HomeHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _StatusComposer(),
                const _StoriesSection(),
                _FilterTabs(
                  activeIndex: _activeTab,
                  onChanged: (index) => setState(() => _activeTab = index),
                ),
                const _PostsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabPlaceholder() {
    if (_selectedIndex == 3) {
      return const Column(
        children: [
          _HomeHeader(),
          Expanded(child: ClubsScreen()),
        ],
      );
    }

    if (_selectedIndex == 1) {
      if (_isFarmLoading) {
        return const Column(
          children: [
            _HomeHeader(),
            Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accentGreen),
              ),
            ),
          ],
        );
      }
      return Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: _hasFarm
                ? MyFarmDashboardScreen(
                    onReset: () {
                      setState(() {
                        _hasFarm = false;
                      });
                    },
                  )
                : MyFarmSetupScreen(
                    onCreated: () {
                      setState(() {
                        _hasFarm = true;
                      });
                    },
                  ),
          ),
        ],
      );
    }

    if (_selectedIndex == 4) {
      return const Column(
        children: [
          _HomeHeader(),
          Expanded(child: RankScreen()),
        ],
      );
    }

    final labels = <int, String>{1: 'My Farm', 2: 'Bantay AI', 4: 'Rank'};
    return Column(
      children: [
        const _HomeHeader(),
        Expanded(
          child: Center(
            child: Text(
              '${labels[_selectedIndex] ?? 'Section'} (UI-only)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  static const String _demoAvatarUrl = 'https://i.pravatar.cc/100?img=12';
  static const int _unreadMessages = 3;
  static const int _unreadNotifications = 7;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(8, topInset + 10, 10, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          Image.asset(
            'assets/images/logo.png',
            height: 36,
            errorBuilder: (context, error, stackTrace) => const Text(
              'FarmBuzz',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: _HeaderIconWithBadge(
              icon: LucideIcons.messageCircle,
              count: _unreadMessages,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const _MessagesScreen(),
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: _HeaderIconWithBadge(
              icon: LucideIcons.bell,
              count: _unreadNotifications,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const _NotificationsScreen(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8F5E9),
              backgroundImage: const NetworkImage(_demoAvatarUrl),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconWithBadge extends StatelessWidget {
  const _HeaderIconWithBadge({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: Colors.black87, size: 24),
        if (count > 0)
          Positioned(
            top: -6,
            right: -8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.onNavigateTab});

  final ValueChanged<int> onNavigateTab;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.84,
      backgroundColor: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF374151),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'BF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ProfileScreen(onNavigateTab: onNavigateTab),
                          ),
                        );
                      },
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bueno's Farm",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'View Profile',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _MenuItemTile(
                    icon: LucideIcons.messageCircle,
                    title: 'Messages',
                    subtitle: 'Open your inbox and chats',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const _MessagesScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItemTile(
                    icon: LucideIcons.bell,
                    title: 'Notifications',
                    subtitle: 'See mentions and updates',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const _NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItemTile(
                    icon: LucideIcons.settings,
                    title: 'Settings',
                    subtitle: 'App and account preferences',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showBottomToast(context, 'Settings screen coming next.');
                    },
                  ),
                  _MenuItemTile(
                    icon: LucideIcons.user,
                    title: 'Profile',
                    subtitle: 'View and manage your profile',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ProfileScreen(onNavigateTab: onNavigateTab),
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 10, 14, 8),
                    child: Divider(height: 1),
                  ),
                  _MenuItemTile(
                    icon: LucideIcons.logOut,
                    title: 'Logout',
                    subtitle: 'Sign out from this account',
                    danger: true,
                    onTap: () async {
                      Navigator.of(context).pop();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? const Color(0xFFDC2626) : const Color(0xFF374151);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: danger ? const Color(0xFFDC2626) : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _MessagesScreen extends StatelessWidget {
  const _MessagesScreen();

  @override
  Widget build(BuildContext context) {
    final chats = <_ChatItem>[
      _ChatItem(
        name: 'Aldrin Poultry',
        message: 'Bro, available pa yung stag?',
        time: '2m',
        unread: 2,
        avatar: 'AP',
        online: true,
      ),
      _ChatItem(
        name: 'Cebu Breeders Club',
        message: 'Meeting later at 7PM.',
        time: '12m',
        unread: 0,
        avatar: 'CB',
        online: false,
      ),
      _ChatItem(
        name: 'Mika Farm',
        message: 'Salamat sa tips kahapon!',
        time: '39m',
        unread: 1,
        avatar: 'MF',
        online: true,
      ),
      _ChatItem(
        name: 'Bataan Roosters',
        message: 'Sent 3 photos',
        time: '1h',
        unread: 0,
        avatar: 'BR',
        online: false,
      ),
      _ChatItem(
        name: 'Jayson',
        message: 'Pwede pickup bukas morning.',
        time: '3h',
        unread: 0,
        avatar: 'JY',
        online: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_note, color: Color(0xFF16A34A)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search chats and messages...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    _MsgTab(label: 'All', active: true),
                    SizedBox(width: 8),
                    _MsgTab(label: 'Unread'),
                    SizedBox(width: 8),
                    _MsgTab(label: 'Groups'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final c = chats[index];
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => _ConversationScreen(chat: c),
                    ),
                  ),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFE5E7EB),
                              child: Text(
                                c.avatar,
                                style: const TextStyle(
                                  color: Color(0xFF374151),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (c.online)
                              const Positioned(
                                right: 1,
                                bottom: 1,
                                child: CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Color(0xFF22C55E),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                c.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              c.time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (c.unread > 0)
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: const Color(0xFF16A34A),
                                child: Text(
                                  '${c.unread}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MsgTab extends StatelessWidget {
  const _MsgTab({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F7EE) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChatItem {
  _ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.avatar,
    required this.online,
  });

  final String name;
  final String message;
  final String time;
  final int unread;
  final String avatar;
  final bool online;
}

class _ConversationScreen extends StatelessWidget {
  const _ConversationScreen({required this.chat});

  final _ChatItem chat;

  @override
  Widget build(BuildContext context) {
    const mockMessages = <({String text, bool mine, String time})>[
      (text: 'Hi! Available pa ba yung pair?', mine: true, time: '9:41 AM'),
      (
        text: 'Yes bro available pa. Gusto mo makita latest photos?',
        mine: false,
        time: '9:42 AM',
      ),
      (text: 'Sige patingin please.', mine: true, time: '9:42 AM'),
      (text: 'Sent. Also vaccinated na sila.', mine: false, time: '9:43 AM'),
      (text: 'Nice, magkano last price?', mine: true, time: '9:44 AM'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(
                chat.avatar,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chat.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  chat.online ? 'Active now' : 'Last seen recently',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
              itemCount: mockMessages.length,
              itemBuilder: (context, index) {
                final m = mockMessages[index];
                return Align(
                  alignment: m.mine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    decoration: BoxDecoration(
                      color: m.mine ? const Color(0xFF16A34A) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: m.mine
                          ? null
                          : Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          m.text,
                          style: TextStyle(
                            color: m.mine ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.time,
                          style: TextStyle(
                            color: m.mine
                                ? Colors.white70
                                : const Color(0xFF9CA3AF),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFF16A34A),
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

class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();

  @override
  Widget build(BuildContext context) {
    final items = <_NotifItem>[
      _NotifItem(
        title: 'Aldrin Poultry reacted to your post',
        subtitle: '“Nice lineup bro!”',
        time: '2m ago',
        unread: true,
        typeIcon: Icons.thumb_up_alt_rounded,
        iconColor: const Color(0xFF16A34A),
      ),
      _NotifItem(
        title: 'Cebu Breeders Club mentioned you',
        subtitle: 'Check announcements for tomorrow.',
        time: '14m ago',
        unread: true,
        typeIcon: Icons.alternate_email_rounded,
        iconColor: const Color(0xFF2563EB),
      ),
      _NotifItem(
        title: 'Your story got 12 views',
        subtitle: 'Keep sharing updates to grow your reach.',
        time: '1h ago',
        unread: false,
        typeIcon: Icons.visibility_rounded,
        iconColor: const Color(0xFFF59E0B),
      ),
      _NotifItem(
        title: 'Bantay AI replied to your question',
        subtitle: 'Tap to read the full response.',
        time: '3h ago',
        unread: false,
        typeIcon: Icons.smart_toy_rounded,
        iconColor: const Color(0xFF7C3AED),
      ),
      _NotifItem(
        title: 'Jayson sent you a new message',
        subtitle: '“Pwede pickup bukas morning.”',
        time: '5h ago',
        unread: false,
        typeIcon: Icons.chat_bubble_rounded,
        iconColor: const Color(0xFF0891B2),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: const Row(
              children: [
                _NotifFilterChip(label: 'All', active: true),
                SizedBox(width: 8),
                _NotifFilterChip(label: 'Unread'),
                SizedBox(width: 8),
                _NotifFilterChip(label: 'Mentions'),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final n = items[index];
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: n.iconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(n.typeIcon, color: n.iconColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: n.unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              n.subtitle,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              n.time,
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (n.unread)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifFilterChip extends StatelessWidget {
  const _NotifFilterChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F7EE) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NotifItem {
  _NotifItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unread,
    required this.typeIcon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String time;
  final bool unread;
  final IconData typeIcon;
  final Color iconColor;
}

class _StatusComposer extends StatelessWidget {
  const _StatusComposer();

  static const String _demoAvatarUrl = 'https://i.pravatar.cc/100?img=12';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8F5E9),
            backgroundImage: const NetworkImage(_demoAvatarUrl),
            onBackgroundImageError: (exception, stackTrace) {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const _CreatePostSheet(),
              ),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD0D3D6)),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What's happening ?",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.image, color: AppColors.accentGreen, size: 22),
        ],
      ),
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _postController = TextEditingController();
  final List<String> _imagePaths = [];
  final List<String> _videoPaths = [];
  String? _selectedFeeling;
  String? _selectedLocation;

  Future<void> _pickImage() async {
    try {
      FocusScope.of(context).unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (!mounted || result == null) return;
      final picked = result.paths.whereType<String>().toList();
      if (picked.isEmpty) return;
      setState(() => _imagePaths.addAll(picked));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open image picker: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      FocusScope.of(context).unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (!mounted || result == null) return;
      final pickedPath = result.files.single.path;
      if (pickedPath == null) return;
      setState(() => _videoPaths.add(pickedPath));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open video picker: $e')),
      );
    }
  }

  Future<void> _openFeelingPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _FeelingPickerSheet(selectedFeeling: _selectedFeeling),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedFeeling = selected);
  }

  Future<void> _openLocationPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _LocationPickerSheet(selectedLocation: _selectedLocation),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedLocation = selected);
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        _postController.text.trim().isNotEmpty ||
        _imagePaths.isNotEmpty ||
        _videoPaths.isNotEmpty;
    final hasAttachments = _imagePaths.isNotEmpty || _videoPaths.isNotEmpty;
    final sheetHeight =
        MediaQuery.of(context).size.height * (hasAttachments ? 0.76 : 0.68);

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(
          0,
          8,
          0,
          MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Create Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F3F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF07A45F),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'BF',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Bueno's Farm",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (_selectedFeeling != null)
                                        const WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: 4,
                                              right: 3,
                                            ),
                                            child: Icon(
                                              Icons.emoji_emotions_outlined,
                                              size: 15,
                                              color: Color(0xFFF6A623),
                                            ),
                                          ),
                                        ),
                                      if (_selectedFeeling != null)
                                        TextSpan(
                                          text: 'is feeling $_selectedFeeling',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF4B5563),
                                          ),
                                        ),
                                      if (_selectedLocation != null)
                                        const WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: 6,
                                              right: 3,
                                            ),
                                            child: Icon(
                                              Icons.location_on_outlined,
                                              size: 15,
                                              color: Color(0xFFF6A623),
                                            ),
                                          ),
                                        ),
                                      if (_selectedLocation != null)
                                        TextSpan(
                                          text: '$_selectedLocation',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF4B5563),
                                          ),
                                        ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 64,
                        child: TextField(
                          controller: _postController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                          cursorColor: Colors.black87,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: "What's happening on your farm?",
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7C7C7C),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_imagePaths.isNotEmpty || _videoPaths.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${_imagePaths.length + _videoPaths.length} / 20 photos',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() {
                                _imagePaths.clear();
                                _videoPaths.clear();
                              }),
                              child: const Text(
                                'Remove all',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_imagePaths.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildImagePreviewGrid(),
                      ],
                      if (_videoPaths.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        ..._videoPaths.map(
                          (videoPath) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFDDE3E8),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.videocam_outlined,
                                  color: Color(0xFF10A64A),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    videoPath.split('\\').last,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _videoPaths.remove(videoPath),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _MediaActionButton(
                          onTap: _pickImage,
                          icon: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF10A64A),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _MediaActionButton(
                          onTap: _pickVideo,
                          icon: const Icon(
                            Icons.videocam_outlined,
                            color: Color(0xFF10A64A),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _MediaActionButton(
                          onTap: _openFeelingPicker,
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
                            color: Color(0xFFF6A623),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        _MediaActionButton(
                          onTap: _openLocationPicker,
                          icon: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFFF6A623),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? const Color(0xFF15A352)
                            : const Color(0xFFE8EBEF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          color: isEnabled
                              ? Colors.white
                              : const Color(0xFFB8BEC5),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewGrid() {
    final count = _imagePaths.length;
    if (count == 1) {
      return _buildImageTile(
        _imagePaths[0],
        height: 180,
        width: double.infinity,
      );
    }
    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _buildImageTile(_imagePaths[0], height: 140)),
          const SizedBox(width: 8),
          Expanded(child: _buildImageTile(_imagePaths[1], height: 140)),
        ],
      );
    }
    if (count == 3) {
      return SizedBox(
        height: 180,
        child: Row(
          children: [
            Expanded(child: _buildImageTile(_imagePaths[0], height: 180)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildImageTile(_imagePaths[1], height: 86)),
                  const SizedBox(height: 8),
                  Expanded(child: _buildImageTile(_imagePaths[2], height: 86)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: count > 4 ? 4 : count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final path = _imagePaths[index];
        final extraCount = count - 4;
        return Stack(
          children: [
            _buildImageTile(
              path,
              height: double.infinity,
              width: double.infinity,
            ),
            if (index == 3 && extraCount > 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '+$extraCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImageTile(String path, {double? height, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE9EDF1),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => setState(() => _imagePaths.remove(path)),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaActionButton extends StatelessWidget {
  const _MediaActionButton({required this.onTap, required this.icon});

  final VoidCallback onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 40, height: 40, child: Center(child: icon)),
      ),
    );
  }
}

class _FeelingPickerSheet extends StatefulWidget {
  const _FeelingPickerSheet({this.selectedFeeling});

  final String? selectedFeeling;

  @override
  State<_FeelingPickerSheet> createState() => _FeelingPickerSheetState();
}

class _FeelingPickerSheetState extends State<_FeelingPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  int _activeTab = 0;
  final List<String> _feelings = const [
    'Loved',
    'In Love',
    'Blessed',
    'Grateful',
    'Thankful',
    'Happy',
    'Cheerful',
    'Excited',
    'Celebrating',
    'Joyful',
    'Content',
    'Proud',
    'Accomplished',
    'Motivated',
    'Determined',
    'Confident',
  ];

  final Map<String, String> _emojiByFeeling = const {
    'Loved': '💗',
    'In Love': '🥰',
    'Blessed': '✨',
    'Grateful': '🙏',
    'Thankful': '🤗',
    'Happy': '😊',
    'Cheerful': '😁',
    'Excited': '🤩',
    'Celebrating': '🥳',
    'Joyful': '😄',
    'Content': '😌',
    'Proud': '😍',
    'Accomplished': '🏆',
    'Motivated': '💪',
    'Determined': '🧐',
    'Confident': '😎',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchController.text.trim().toLowerCase();
    final filtered = _feelings
        .where((f) => f.toLowerCase().contains(q))
        .toList();

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Container(height: 3, color: const Color(0xFFC99843)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'How are you feeling?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _FeelingTab(
                    title: 'Feelings',
                    isActive: _activeTab == 0,
                    onTap: () => setState(() => _activeTab = 0),
                  ),
                  const SizedBox(width: 16),
                  _FeelingTab(
                    title: 'Activities',
                    isActive: _activeTab == 1,
                    onTap: () => setState(() => _activeTab = 1),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                cursorColor: Colors.black87,
                decoration: InputDecoration(
                  hintText: 'Search feelings or activities...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF7A7A7A),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFC99843)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFC99843),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                itemCount: (filtered.length / 2).ceil(),
                itemBuilder: (context, row) {
                  final leftIndex = row * 2;
                  final rightIndex = leftIndex + 1;
                  final left = filtered[leftIndex];
                  final right = rightIndex < filtered.length
                      ? filtered[rightIndex]
                      : null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FeelingItem(
                            emoji: _emojiByFeeling[left] ?? '🙂',
                            label: left,
                            isSelected: widget.selectedFeeling == left,
                            onTap: () => Navigator.of(context).pop(left),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: right == null
                              ? const SizedBox.shrink()
                              : _FeelingItem(
                                  emoji: _emojiByFeeling[right] ?? '🙂',
                                  label: right,
                                  isSelected: widget.selectedFeeling == right,
                                  onTap: () => Navigator.of(context).pop(right),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeelingTab extends StatelessWidget {
  const _FeelingTab({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isActive ? const Color(0xFF16A34A) : Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _FeelingItem extends StatelessWidget {
  const _FeelingItem({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFF3F4F6) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({this.selectedLocation});

  final String? selectedLocation;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  final List<({String city, String region})> _locations = const [
    (city: 'Aborlan', region: 'Palawan · MIMAROPA Region'),
    (city: 'Abra De Ilog', region: 'Occidental Mindoro · MIMAROPA Region'),
    (city: 'Abucay', region: 'Bataan · Region III (Central Luzon)'),
    (city: 'Abulug', region: 'Cagayan · Region II (Cagayan Valley)'),
    (city: 'Abuyog', region: 'Leyte · Region VIII (Eastern Visayas)'),
    (city: 'Bacoor', region: 'Cavite · Region IV-A (CALABARZON)'),
    (city: 'Cebu City', region: 'Cebu · Region VII (Central Visayas)'),
    (city: 'Davao City', region: 'Davao del Sur · Region XI (Davao Region)'),
    (city: 'Iloilo City', region: 'Iloilo · Region VI (Western Visayas)'),
    (city: 'Quezon City', region: 'Metro Manila · NCR'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchController.text.trim().toLowerCase();
    final filtered = _locations.where((item) {
      return item.city.toLowerCase().contains(q) ||
          item.region.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.62,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFFF06A6A),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pick your city or municipality',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search cities + municipalities',
                  hintStyle: const TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF98A2B3),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF1B2B2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFF08A8A),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9DDE3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final locationLabel = '${item.city} · ${item.region}';
                    final isSelected = widget.selectedLocation == locationLabel;
                    return Material(
                      color: isSelected
                          ? const Color(0xFFF3F4F6)
                          : Colors.white,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(locationLabel),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFF98A2B3),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.city,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.region,
                                      style: const TextStyle(
                                        color: Color(0xFF7A7A7A),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _StoriesSection extends StatelessWidget {
  const _StoriesSection();

  @override
  Widget build(BuildContext context) {
    const stories = [
      (
        name: 'FarmZzz',
        time: '5 days ago',
        imageUrl: 'https://picsum.photos/id/1025/600/900',
      ),
      (
        name: 'FarmZzz',
        time: '5 days ago',
        imageUrl: 'https://picsum.photos/id/237/600/900',
      ),
      (
        name: 'FarmZzz',
        time: '5 days ago',
        imageUrl: 'https://picsum.photos/id/1062/600/900',
      ),
    ];

    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          const _CreateStoryCard(),
          ...stories.map(
            (story) => _StoryCard(
              name: story.name,
              time: story.time,
              imageUrl: story.imageUrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateStoryCard extends StatelessWidget {
  const _CreateStoryCard();

  static const String _demoAvatarUrl = 'https://i.pravatar.cc/200?img=12';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const _CreateStoryOptionsSheet(),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: const DecorationImage(
                    image: NetworkImage(_demoAvatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Text(
                      'Create story',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateStoryOptionsSheet extends StatelessWidget {
  const _CreateStoryOptionsSheet();

  Future<void> _pickStoryMedia(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty || !context.mounted) return;

      final selectedPaths = result.paths.whereType<String>().toList();
      if (selectedPaths.isEmpty || !context.mounted) return;

      Navigator.of(context).pop(); // close Create Story options
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _StorySharePreviewSheet(paths: selectedPaths),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open media picker: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    'Create Story',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: _StoryModeCard(
                        onTap: () => _pickStoryMedia(context),
                        color: const Color(0xFF1FB54D),
                        icon: Icons.photo_camera_outlined,
                        title: 'Photo/Video',
                        subtitle: 'Share from gallery or camera',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StoryModeCard(
                        onTap: () => Navigator.of(context).pop(),
                        color: const Color(0xFF3A73E3),
                        icon: Icons.text_fields,
                        title: 'Text',
                        subtitle: 'Share a text with background',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryModeCard extends StatelessWidget {
  const _StoryModeCard({
    required this.onTap,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFE9F1FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorySharePreviewSheet extends StatelessWidget {
  const _StorySharePreviewSheet({required this.paths});

  final List<String> paths;

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.heic');
  }

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.webm');
  }

  @override
  Widget build(BuildContext context) {
    final firstPath = paths.first;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Story Preview',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paths.length == 1
                          ? '1 media selected'
                          : '${paths.length} media selected',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _isImage(firstPath)
                            ? Image.file(
                                File(firstPath),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackPreview(),
                              )
                            : _buildVideoPreview(firstPath),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (paths.length > 1)
                      Text(
                        '+${paths.length - 1} more selected',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Story shared')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview(String path) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF111827),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
          const SizedBox(height: 8),
          Text(
            _isVideo(path) ? path.split('\\').last : 'Video preview',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.grey,
        size: 42,
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.name,
    required this.time,
    required this.imageUrl,
  });

  final String name;
  final String time;
  final String imageUrl;

  static const String _demoAvatarUrl = 'https://i.pravatar.cc/100?img=12';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.20),
                  Colors.black.withValues(alpha: 0.70),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: const NetworkImage(_demoAvatarUrl),
                onBackgroundImageError: (exception, stackTrace) {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 9,
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

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.activeIndex, required this.onChanged});

  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'For You',
              icon: Icons.auto_awesome,
              isActive: activeIndex == 0,
              onTap: () => onChanged(0),
            ),
            _FilterChip(
              label: 'Following',
              icon: Icons.person_outline,
              isActive: activeIndex == 1,
              onTap: () => onChanged(1),
            ),
            _FilterChip(
              label: 'Reels',
              icon: Icons.play_circle_outline,
              isActive: activeIndex == 2,
              onTap: () => onChanged(2),
            ),
            _FilterChip(
              label: 'Trending',
              icon: Icons.trending_up,
              isActive: activeIndex == 3,
              onTap: () => onChanged(3),
            ),
            _FilterChip(
              label: 'Bantay',
              icon: Icons.security_outlined,
              isActive: activeIndex == 4,
              onTap: () => onChanged(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.accentGreen
                : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostsSection extends StatelessWidget {
  const _PostsSection();

  @override
  Widget build(BuildContext context) {
    const posts = [
      (
        userName: 'Adrian ddraig',
        timeAgo: '31 minutes ago',
        postText: 'Morning drop from the farm, all birds are healthy.',
        metaEmoji: '',
        metaFeeling: '',
        metaLocation: '',
        likes: 4,
        comments: 1,
        topReactions: <String>['\u{2764}\u{FE0F}', '\u{1F44D}', '\u{1F602}'],
        imageUrls: <String>[
          'https://picsum.photos/id/1025/1000/1000',
          'https://picsum.photos/id/237/1000/1000',
          'https://picsum.photos/id/1062/1000/1000',
        ],
      ),
      (
        userName: 'Rey rey',
        timeAgo: '2 hours ago',
        postText: 'Weekend gallery update, check all these shots.',
        metaEmoji: '\u{1F525}',
        metaFeeling: 'hyped',
        metaLocation: 'Nueva Ecija',
        likes: 12,
        comments: 6,
        topReactions: <String>['\u{1F44D}', '\u{2764}\u{FE0F}', '\u{1F62E}'],
        imageUrls: <String>[
          'https://picsum.photos/id/1025/1000/1000',
          'https://picsum.photos/id/237/1000/1000',
          'https://picsum.photos/id/1062/1000/1000',
          'https://picsum.photos/id/1074/1000/1000',
          'https://picsum.photos/id/1084/1000/1000',
          'https://picsum.photos/id/169/1000/1000',
        ],
      ),
      (
        userName: 'Kiko Bantay',
        timeAgo: '1 day ago',
        postText: 'New hatchlings this morning.',
        metaEmoji: '',
        metaFeeling: '',
        metaLocation: '',
        likes: 14,
        comments: 3,
        topReactions: <String>['\u{1F602}', '\u{1F44D}', '\u{2764}\u{FE0F}'],
        imageUrls: <String>[
          'https://picsum.photos/id/1074/1000/1000',
          'https://picsum.photos/id/169/1000/1000',
        ],
      ),
      (
        userName: 'Lara Mae',
        timeAgo: '2 days ago',
        postText:
            'No photos today, just sharing that feed schedule worked well.',
        metaEmoji: '\u{1F642}',
        metaFeeling: 'happy',
        metaLocation: 'Laguna',
        likes: 2,
        comments: 0,
        topReactions: <String>['\u{2764}\u{FE0F}', '\u{1F622}'],
        imageUrls: <String>[],
      ),
      (
        userName: 'Bong R.',
        timeAgo: '3 days ago',
        postText: 'Caption only post. Farm routine complete.',
        metaEmoji: '',
        metaFeeling: '',
        metaLocation: '',
        likes: 1,
        comments: 0,
        topReactions: <String>['\u{1F44D}'],
        imageUrls: <String>[],
      ),
    ];

    return Column(
      children: [
        for (final post in posts)
          _PostCard(
            userName: post.userName,
            timeAgo: post.timeAgo,
            postText: post.postText,
            metaEmoji: post.metaEmoji,
            metaFeeling: post.metaFeeling,
            metaLocation: post.metaLocation,
            likesCount: post.likes,
            commentsCount: post.comments,
            topReactions: post.topReactions,
            imageUrls: post.imageUrls,
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({
    required this.userName,
    required this.timeAgo,
    required this.postText,
    required this.metaEmoji,
    required this.metaFeeling,
    required this.metaLocation,
    required this.likesCount,
    required this.commentsCount,
    required this.topReactions,
    required this.imageUrls,
  });

  final String userName;
  final String timeAgo;
  final String postText;
  final String metaEmoji;
  final String metaFeeling;
  final String metaLocation;
  final int likesCount;
  final int commentsCount;
  final List<String> topReactions;
  final List<String> imageUrls;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  static const double _mediaTileGap = 2;
  bool _showReactions = false;
  String _selectedReaction = '';
  late int _currentComments;
  late List<Map<String, String>> _comments;
  final List<String> _reactions = const [
    '\u{1F44D}',
    '\u{2764}\u{FE0F}',
    '\u{1F602}',
    '\u{1F62E}',
    '\u{1F622}',
    '\u{1F621}',
  ];

  @override
  void initState() {
    super.initState();
    _currentComments = widget.commentsCount;
    _comments = [
      {
        'name': 'FarmBuzz User',
        'text': 'Nice update!',
        'time': '1h',
        'avatar': 'https://i.pravatar.cc/150?img=18',
      },
    ];
  }

  String _initial() {
    final trimmed = widget.userName.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  bool get _hasMetaLine =>
      widget.metaFeeling.trim().isNotEmpty &&
      widget.metaLocation.trim().isNotEmpty;

  String _reactionLabel(String reaction) {
    switch (reaction) {
      case '\u{1F44D}':
        return 'Like';
      case '\u{2764}\u{FE0F}':
        return 'Heart';
      case '\u{1F602}':
        return 'Haha';
      case '\u{1F62E}':
        return 'Wow';
      case '\u{1F622}':
        return 'Sad';
      case '\u{1F621}':
        return 'Angry';
      default:
        return 'Like';
    }
  }

  void _onReactionSelected(String reaction) {
    setState(() {
      _selectedReaction = reaction;
      _showReactions = false;
    });
  }

  Future<void> _openComments() async {
    await _CommentsSheet.show(
      context,
      userName: widget.userName,
      comments: _comments,
      onCommentCountChanged: (count, updatedComments) {
        if (!mounted) {
          return;
        }
        setState(() {
          _currentComments = count;
          _comments = updatedComments;
        });
      },
    );
  }

  List<String> get _displayReactions {
    final ordered = <String>[];
    if (_selectedReaction.isNotEmpty) {
      ordered.add(_selectedReaction);
    }
    for (final reaction in widget.topReactions) {
      if (!ordered.contains(reaction)) {
        ordered.add(reaction);
      }
    }
    return ordered.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFE8F5E9),
                      child: Text(
                        _initial(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF111827),
                            ),
                          ),
                          if (_hasMetaLine) ...[
                            const SizedBox(height: 1),
                            Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF374151),
                                  height: 1.15,
                                ),
                                children: [
                                  const TextSpan(text: 'is feeling '),
                                  TextSpan(text: '${widget.metaEmoji} '),
                                  TextSpan(text: '${widget.metaFeeling} at '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 3),
                                      child: Icon(
                                        Icons.location_on,
                                        size: 13,
                                        color: AppColors.accentGreen,
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: widget.metaLocation,
                                    style: const TextStyle(
                                      color: AppColors.accentGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Row(
                            children: [
                              Text(
                                widget.timeAgo,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                              const Text(
                                ' \u2022 ',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 11,
                                ),
                              ),
                              Icon(
                                Icons.public,
                                size: 10,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  widget.postText,
                  style: const TextStyle(
                    fontSize: 30 / 2,
                    height: 1.5,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _buildMediaSection(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _TopReactionsCluster(reactions: _displayReactions),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.likesCount}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '$_currentComments comments',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withValues(alpha: 0.22),
                indent: 0,
                endIndent: 0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () =>
                            setState(() => _showReactions = true),
                        onTap: () => setState(
                          () => _selectedReaction = _selectedReaction.isEmpty
                              ? '\u{1F44D}'
                              : '',
                        ),
                        child: _PostAction(
                          icon: _selectedReaction.isEmpty
                              ? Icons.thumb_up_outlined
                              : null,
                          label: _selectedReaction.isEmpty
                              ? 'Like'
                              : _reactionLabel(_selectedReaction),
                          reaction: _selectedReaction,
                          color: _selectedReaction.isEmpty
                              ? null
                              : AppColors.accentGreen,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _openComments,
                        child: _PostAction(
                          icon: Icons.chat_bubble_outline,
                          label: 'Comment',
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _PostAction(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showReactions) _buildReactionOverlay(),
        ],
      ),
    );
  }

  Widget _buildReactionOverlay() {
    return Positioned(
      bottom: 44,
      left: 0,
      right: 0,
      child: Center(
        child: _ReactionOverlay(
          reactions: _reactions,
          onSelected: _onReactionSelected,
          onDismiss: () => setState(() => _showReactions = false),
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildMediaGrid(),
      ),
    );
  }

  Widget _buildMediaGrid() {
    final count = widget.imageUrls.length;

    if (count == 1) {
      return _networkImage(widget.imageUrls[0], height: 260);
    }

    if (count == 2) {
      return SizedBox(
        height: 220,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _networkImage(widget.imageUrls[0])),
            const SizedBox(width: _mediaTileGap),
            Expanded(child: _networkImage(widget.imageUrls[1])),
          ],
        ),
      );
    }

    if (count == 3) {
      return SizedBox(
        height: 260,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 2, child: _networkImage(widget.imageUrls[0])),
            const SizedBox(width: _mediaTileGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _networkImage(widget.imageUrls[1])),
                  const SizedBox(height: _mediaTileGap),
                  Expanded(child: _networkImage(widget.imageUrls[2])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _networkImage(widget.imageUrls[0])),
                const SizedBox(width: _mediaTileGap),
                Expanded(child: _networkImage(widget.imageUrls[1])),
              ],
            ),
          ),
          const SizedBox(height: _mediaTileGap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _networkImage(widget.imageUrls[2])),
                const SizedBox(width: _mediaTileGap),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _networkImage(widget.imageUrls[3]),
                      if (count > 4)
                        Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          alignment: Alignment.center,
                          child: Text(
                            '+${count - 4}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkImage(String url, {double? height}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(color: const Color(0xFFE5E7EB));
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF1F3F5),
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: Colors.grey[500]),
        ),
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({
    this.icon,
    required this.label,
    this.reaction = '',
    required this.color,
  });

  final IconData? icon;
  final String label;
  final String reaction;
  final Color? color;
  static const Color _defaultActionColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (reaction.isNotEmpty)
            _ReactionGlyph(reaction: reaction, size: 18)
          else if (icon != null)
            Icon(icon, size: 18, color: color ?? _defaultActionColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? _defaultActionColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.userName,
    required this.comments,
    required this.onCommentCountChanged,
  });

  final String userName;
  final List<Map<String, String>> comments;
  final void Function(int count, List<Map<String, String>> comments)
  onCommentCountChanged;

  static Future<void> show(
    BuildContext context, {
    required String userName,
    required List<Map<String, String>> comments,
    required void Function(int count, List<Map<String, String>> comments)
    onCommentCountChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => _CommentsSheet(
        userName: userName,
        comments: comments,
        onCommentCountChanged: onCommentCountChanged,
      ),
    );
  }

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  late List<Map<String, String>> _comments;
  String _sortLabel = 'Most relevant';

  @override
  void initState() {
    super.initState();
    _comments = List<Map<String, String>>.from(widget.comments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _comments.insert(0, {
        'name': 'You',
        'text': text,
        'time': 'now',
        'avatar': 'https://i.pravatar.cc/150?img=12',
      });
      _commentController.clear();
    });

    widget.onCommentCountChanged(_comments.length, _comments);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final reactionPreview = widget.comments.length > 10 ? '11K' : '1.2K';

    return Container(
      height: size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFBFC5CA),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const _ReactionGlyph(reaction: '\u{1F44D}', size: 16),
                    const SizedBox(width: 2),
                    const _ReactionGlyph(
                      reaction: '\u{2764}\u{FE0F}',
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reactionPreview,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _sortLabel = _sortLabel == 'Most relevant'
                          ? 'Newest'
                          : 'Most relevant';
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  label: Text(
                    _sortLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet. Be the first to comment.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CommentItem(
                          name: (comment['name'] ?? '').toString(),
                          text: (comment['text'] ?? '').toString(),
                          time: (comment['time'] ?? 'now').toString(),
                          avatar:
                              (comment['avatar'] ??
                                      'https://i.pravatar.cc/150?u=farmbuzz-comment')
                                  .toString(),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=12',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      onSubmitted: (_) => _addComment(),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
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

class _CommentItem extends StatefulWidget {
  const _CommentItem({
    required this.name,
    required this.text,
    required this.time,
    required this.avatar,
  });

  final String name;
  final String text;
  final String time;
  final String avatar;

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final likes = (widget.text.length % 80) + 3;
    final canShowReplies = (widget.text.length % 2) == 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 17, backgroundImage: NetworkImage(widget.avatar)),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.32,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 18),
                  const _ReactionGlyph(reaction: '\u{1F44D}', size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$likes',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.thumb_up_alt_outlined,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.thumb_down_alt_outlined,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              if (canShowReplies) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _showReplies = !_showReplies),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showReplies
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 12,
                        color: const Color(0xFF374151),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _showReplies ? 'Hide replies' : 'View 2 replies',
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showReplies) ...[
                  const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 2,
                          margin: const EdgeInsets.only(left: 8, right: 10),
                          color: const Color(0xFFD1D5DB),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _ReplyItem(
                                name: 'Joe Benedict Española',
                                time: '4h',
                                text: 'Lala',
                              ),
                              SizedBox(height: 10),
                              _ReplyItem(
                                name: 'secretsh1T',
                                time: '3h',
                                text:
                                    'BrilliantNectarine8854 7 slot Ng pet 2k? Gising ka yah. Baka natutulog kaa. May mythic pet pa Yan. HAHAHAHAH',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyItem extends StatelessWidget {
  const _ReplyItem({
    required this.name,
    required this.time,
    required this.text,
  });

  final String name;
  final String time;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=22'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.thumb_up_alt_outlined,
                    size: 17,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.thumb_down_alt_outlined,
                    size: 17,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReactionOverlay extends StatelessWidget {
  const _ReactionOverlay({
    required this.reactions,
    required this.onSelected,
    required this.onDismiss,
  });

  final List<String> reactions;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions
            .map(
              (emoji) =>
                  _ReactionButton(emoji: emoji, onTap: () => onSelected(emoji)),
            )
            .toList(),
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  const _ReactionButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (val) => setState(() => _isHovered = val),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedScale(
          scale: _isHovered ? 1.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _ReactionGlyph(reaction: widget.emoji, size: 26),
          ),
        ),
      ),
    );
  }
}

class _TopReactionsCluster extends StatelessWidget {
  const _TopReactionsCluster({required this.reactions});

  final List<String> reactions;
  static const double _emojiSize = 16;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < reactions.length; i++) ...[
          _ReactionGlyph(reaction: reactions[i], size: _emojiSize),
          if (i != reactions.length - 1) const SizedBox(width: 2),
        ],
      ],
    );
  }
}

class _ReactionGlyph extends StatelessWidget {
  const _ReactionGlyph({required this.reaction, required this.size});

  final String reaction;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (reaction == '\u{2764}\u{FE0F}') {
      return Icon(Icons.favorite, color: const Color(0xFFE11D48), size: size);
    }

    return Text(
      reaction,
      style: TextStyle(fontSize: size),
      strutStyle: const StrutStyle(forceStrutHeight: true, height: 1),
    );
  }
}
