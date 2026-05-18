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
import 'package:farmbuzz/features/messages/data/notification_api.dart';
import 'package:farmbuzz/features/profile/presentation/profile_screen.dart';
import 'package:farmbuzz/features/profile/data/profile_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final NotificationApi _notificationApi = NotificationApi();
  final ProfileApi _profileApi = ProfileApi();
  int _unreadMessages = 0;
  int _unreadNotifications = 0;
  bool _avatarImageFailed = false;
  String _lastAvatarUrl = '';

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeFeedView(),
      const MyFarmView(),
      const BantayAiView(),
      const ClubsView(),
      const LeaderboardView(),
    ];
    _loadCounts();
    _refreshProfileFromApi();
  }

  Future<void> _refreshProfileFromApi() async {
    final mobile = AppSession.mobileNumber;
    if (mobile == null || mobile.trim().isEmpty) {
      return;
    }

    try {
      final profile = await _profileApi.getProfile(mobileNumber: mobile);
      if (!mounted) {
        return;
      }

      final latestName = (profile['name'] ?? '').trim();
      if (latestName.isNotEmpty && latestName != AppSession.userName) {
        AppSession.setUserName(latestName);
      }
      AppSession.setProfileMedia(
        avatarUrl: profile['avatar_url'],
        coverPhotoUrl: profile['cover_photo_url'],
      );

      setState(() {});
    } catch (_) {
      // Keep current session values if profile fetch fails.
    }
  }

  Future<void> _loadCounts() async {
    final mobile = AppSession.mobileNumber;
    if (mobile == null || mobile.trim().isEmpty) return;

    try {
      final counts = await _notificationApi.getCounts(mobileNumber: mobile);
      if (mounted) {
        setState(() {
          _unreadMessages = counts['messages'] ?? 0;
          _unreadNotifications = counts['notifications'] ?? 0;
        });
      }
    } catch (_) {}
  }

  void _showAiMenu(BuildContext context) {
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
    if (!mounted) return;
    AppSession.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }

  Future<void> _handleDeleteAccount() async {
    final mobile = AppSession.mobileNumber;
    if (mobile == null || mobile.trim().isEmpty || !mounted) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This action is permanent and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    try {
      await _profileApi.deleteAccount(mobileNumber: mobile);
      if (!mounted) return;
      AppSession.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = AppSession.avatarUrlOrEmpty;
    if (_lastAvatarUrl != avatarUrl) {
      _lastAvatarUrl = avatarUrl;
      _avatarImageFailed = false;
    }
    final hasAvatar = _hasValidAvatarUrl(avatarUrl) && !_avatarImageFailed;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
            icon: Badge(
              label: Text(
                _unreadMessages.toString(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: Colors.redAccent,
              isLabelVisible: _unreadMessages > 0,
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.black87,
              ),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(builder: (_) => const MessagesScreen()),
                  )
                  .then((_) => _loadCounts());
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Badge(
              label: Text(
                _unreadNotifications.toString(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: Colors.redAccent,
              isLabelVisible: _unreadNotifications > 0,
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.black87,
              ),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  )
                  .then((_) => _loadCounts());
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
                onBackgroundImageError: hasAvatar
                    ? (Object error, StackTrace? stackTrace) {
                        if (!_avatarImageFailed && mounted) {
                          setState(() => _avatarImageFailed = true);
                        }
                      }
                    : null,
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
        unreadMessages: _unreadMessages,
        unreadNotifications: _unreadNotifications,
        onSelectItem: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        onLogout: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 150), _handleLogout);
        },
        onDeleteAccount: () {
          Navigator.pop(context);
          Future.delayed(
            const Duration(milliseconds: 150),
            _handleDeleteAccount,
          );
        },
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 2
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _selectedIndex = 2),
              backgroundColor: const Color(0xFFD97706),
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
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _initial() {
    final name = AppSession.userName.trim();
    if (name.isEmpty) return 'U';
    return name.substring(0, 1).toUpperCase();
  }
}
