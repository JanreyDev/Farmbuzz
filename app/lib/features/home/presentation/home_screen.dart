import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'widgets/story_viewer_screen.dart';
import 'widgets/post_card.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/feed_api.dart';
import '../data/farm_api.dart';
import '../data/story_api.dart';
import '../data/notification_api.dart';
import '../../clubs/presentation/clubs_screen.dart';
import '../../messages/presentation/messages_screen.dart';
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

class _ViewerProfile {
  const _ViewerProfile({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

class _ViewerProfileStore {
  _ViewerProfileStore._();
  static final _ViewerProfileStore instance = _ViewerProfileStore._();

  final ValueNotifier<_ViewerProfile> profile = ValueNotifier<_ViewerProfile>(
    const _ViewerProfile(name: '', avatarUrl: ''),
  );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name =
        (prefs.getString('auth_user_name') ??
                prefs.getString('auth_mobile_number') ??
                '')
            .trim();
    final avatar = _firstNonEmpty(<String?>[
      prefs.getString('auth_user_avatar'),
      prefs.getString('auth_user_avatar_url'),
      prefs.getString('auth_avatar'),
      prefs.getString('user_avatar'),
      prefs.getString('profile_avatar'),
      prefs.getString('profile_photo_url'),
    ]);
    profile.value = _ViewerProfile(name: name, avatarUrl: avatar);
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = (value ?? '').trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return '';
  }
}

class _FeedStore {
  _FeedStore._();
  static final _FeedStore instance = _FeedStore._();

  final FeedApi _api = FeedApi();
  final ValueNotifier<List<FeedPost>> posts = ValueNotifier<List<FeedPost>>(
    <FeedPost>[],
  );
  bool loaded = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final reactorName =
        prefs.getString('auth_user_name') ??
        prefs.getString('auth_mobile_number') ??
        '';
    final fetched = await _api.fetchPosts(reactorName: reactorName);
    posts.value = fetched;
    loaded = true;
  }

  Future<void> create({
    required String authorName,
    required String content,
    required List<FeedImageUpload> images,
    String? metaFeeling,
    String? metaLocation,
  }) async {
    final created = await _api.createPost(
      authorName: authorName,
      content: content,
      images: images,
      metaFeeling: metaFeeling,
      metaLocation: metaLocation,
    );
    posts.value = <FeedPost>[created, ...posts.value];
  }
}

class _StoryStore {
  _StoryStore._();
  static final _StoryStore instance = _StoryStore._();

  final StoryApi _api = StoryApi();
  final ValueNotifier<List<FeedStory>> stories = ValueNotifier<List<FeedStory>>(
    <FeedStory>[],
  );
  bool loaded = false;

  Future<void> load({bool force = false}) async {
    if (loaded && !force) return;
    final fetched = await _api.fetchStories();
    stories.value = fetched;
    loaded = true;
  }

  Future<void> create({
    required String mobileNumber,
    String? imagePath,
    String? textContent,
  }) async {
    final created = await _api.createStory(
      mobileNumber: mobileNumber,
      imagePath: imagePath,
      textContent: textContent,
    );
    stories.value = <FeedStory>[created, ...stories.value];
    loaded = true;
  }
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
  final FarmApi _farmApi = FarmApi();
  final NotificationApi _notifApi = NotificationApi();
  int _unreadMessages = 0;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _ViewerProfileStore.instance.load();
    _checkFarmStatus();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('auth_mobile_number') ?? prefs.getString('mobile_number');
    if (mobile != null && mobile.isNotEmpty) {
      final counts = await _notifApi.fetchCounts(mobileNumber: mobile);
      if (mounted) {
        setState(() {
          _unreadMessages = counts['messages'] ?? 0;
          _unreadNotifications = counts['notifications'] ?? 0;
        });
      }
    }
  }

  Future<void> _checkFarmStatus() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobileNumber = (prefs.getString('auth_mobile_number') ?? '').trim();
      if (mobileNumber.isNotEmpty) {
        try {
          final profile = await _farmApi.fetchFarm(mobileNumber: mobileNumber);
          final hasFarmOnBackend = profile != null;
          if (mounted) {
            setState(() {
              _hasFarm = hasFarmOnBackend;
              _isFarmLoading = false;
              _isChecking = false;
            });
          }
          if (hasFarmOnBackend) {
            await prefs.setBool('farm_created', true);
            return;
          }
        } catch (_) {
          // Fall back to local cache when backend is unavailable.
        }
      }
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
        _HomeHeader(unreadMessages: _unreadMessages, unreadNotifications: _unreadNotifications),
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
      return Column(
        children: [
          _HomeHeader(unreadMessages: _unreadMessages, unreadNotifications: _unreadNotifications),
          Expanded(child: ClubsScreen()),
        ],
      );
    }

    if (_selectedIndex == 1) {
      if (_isFarmLoading) {
        return Column(
          children: [
            _HomeHeader(unreadMessages: _unreadMessages, unreadNotifications: _unreadNotifications),
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
          _HomeHeader(unreadMessages: _unreadMessages, unreadNotifications: _unreadNotifications),
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
      return Column(
        children: [
          _HomeHeader(unreadMessages: _unreadMessages, unreadNotifications: _unreadNotifications),
          Expanded(child: RankScreen()),
        ],
      );
    }

    final labels = <int, String>{1: 'My Farm', 2: 'Bantay AI', 4: 'Rank'};
    return Column(
      children: [
        _HomeHeader(unreadMessages: _unreadMessages, unreadNotifications: _unreadNotifications),
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
  const _HomeHeader({
    super.key,
    required this.unreadMessages,
    required this.unreadNotifications,
  });

  final int unreadMessages;
  final int unreadNotifications;

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
              count: unreadMessages,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const MessagesScreen(),
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: _HeaderIconWithBadge(
              icon: LucideIcons.bell,
              count: unreadNotifications,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const _NotificationsScreen(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ValueListenableBuilder<_ViewerProfile>(
              valueListenable: _ViewerProfileStore.instance.profile,
              builder: (context, viewer, _) {
                final hasAvatar = viewer.avatarUrl.trim().isNotEmpty;
                return CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE8F5E9),
                  backgroundImage: hasAvatar
                      ? NetworkImage(viewer.avatarUrl)
                      : null,
                  onBackgroundImageError: hasAvatar
                      ? (exception, stackTrace) {}
                      : null,
                  child: hasAvatar
                      ? null
                      : Text(
                          viewer.initial,
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
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
  static final AuthApi _authApi = AuthApi();

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
                          builder: (_) => const MessagesScreen(),
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
                      final mobile = prefs.getString('auth_mobile_number');
                      try {
                        await _authApi.logout(mobileNumber: mobile);
                      } catch (_) {}
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

class _NotificationsScreen extends StatefulWidget {
  const _NotificationsScreen();

  @override
  State<_NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<_NotificationsScreen> {
  final NotificationApi _api = NotificationApi();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndMarkRead();
  }

  Future<void> _fetchAndMarkRead() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('auth_mobile_number') ?? prefs.getString('mobile_number');
    if (mobile != null && mobile.isNotEmpty) {
      final notifs = await _api.fetchNotifications(mobileNumber: mobile);
      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
      await _api.markAsRead(mobileNumber: mobile);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return 'just now';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return 'just now';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return diff.inDays.toString() + 'd ago';
    if (diff.inHours > 0) return diff.inHours.toString() + 'h ago';
    if (diff.inMinutes > 0) return diff.inMinutes.toString() + 'm ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
                : _notifications.isEmpty
                    ? const Center(child: Text('No notifications yet', style: TextStyle(color: Colors.black54)))
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 10),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 2),
                        itemBuilder: (context, index) {
                          final raw = _notifications[index];
                          final data = raw['data'] as Map<String, dynamic>? ?? {};
                          final type = raw['type'] as String? ?? '';
                          
                          IconData typeIcon = Icons.notifications_rounded;
                          Color iconColor = const Color(0xFF6B7280);
                          
                          if (type == 'like') {
                            typeIcon = Icons.thumb_up_alt_rounded;
                            iconColor = const Color(0xFF16A34A);
                          } else if (type == 'comment') {
                            typeIcon = Icons.comment_rounded;
                            iconColor = const Color(0xFFD97706);
                          } else if (type == 'follow') {
                            typeIcon = Icons.person_add_rounded;
                            iconColor = const Color(0xFF2563EB);
                          } else if (type == 'message') {
                            typeIcon = Icons.chat_bubble_rounded;
                            iconColor = const Color(0xFF0891B2);
                          }

                          final actor = data['actor_name']?.toString() ?? 'Someone';
                          final msg = data['message']?.toString() ?? 'interacted with you';
                          final title = '$actor $msg';
                          
                          final n = _NotifItem(
                            title: title,
                            subtitle: '',
                            time: _formatTime(raw['created_at'] as String?),
                            unread: raw['read_at'] == null,
                            typeIcon: typeIcon,
                            iconColor: iconColor,
                          );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          ValueListenableBuilder<_ViewerProfile>(
            valueListenable: _ViewerProfileStore.instance.profile,
            builder: (context, viewer, _) {
              final hasAvatar = viewer.avatarUrl.trim().isNotEmpty;
              return CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE8F5E9),
                backgroundImage: hasAvatar
                    ? NetworkImage(viewer.avatarUrl)
                    : null,
                onBackgroundImageError: hasAvatar
                    ? (exception, stackTrace) {}
                    : null,
                child: hasAvatar
                    ? null
                    : Text(
                        viewer.initial,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              );
            },
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
  static const int _maxImageBytes = 20 * 1024 * 1024; // 20MB (matches backend)
  static const int _maxTotalImageBytes =
      18 * 1024 * 1024; // keep below server limits
  final TextEditingController _postController = TextEditingController();
  final List<String> _imagePaths = [];
  final List<FeedImageUpload> _imageUploads = [];
  final List<String> _videoPaths = [];
  String? _selectedFeeling;
  String? _selectedLocation;
  bool _isPosting = false;

  bool _isSupportedImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp');
  }

  String _extensionFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '.jpg';
    return name.substring(dot).toLowerCase();
  }

  MediaType _mediaTypeForExt(String ext) {
    switch (ext) {
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      case '.gif':
        return MediaType('image', 'gif');
      case '.bmp':
        return MediaType('image', 'bmp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Future<String?> _resolveUsableImagePath(PlatformFile file) async {
    final path = file.path;
    if (path != null && path.isNotEmpty) {
      final diskFile = File(path);
      if (await diskFile.exists()) return path;
    }

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return null;

    final ext = _extensionFromName(file.name);
    final tempDir = Directory.systemTemp;
    final tempPath =
        '${tempDir.path}${Platform.pathSeparator}farmbuzz_${DateTime.now().microsecondsSinceEpoch}$ext';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile.path;
  }

  Future<int> _currentTotalImageBytes() async {
    var total = 0;
    for (final upload in _imageUploads) {
      final bytes = upload.bytes;
      if (bytes != null && bytes.isNotEmpty) {
        total += bytes.length;
        continue;
      }
      final path = upload.path;
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (await file.exists()) {
        total += await file.length();
      }
    }
    return total;
  }

  Future<void> _pickImage() async {
    try {
      FocusScope.of(context).unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (!mounted || result == null) return;
      final picked = result.files;
      if (picked.isEmpty) return;

      final valid = <String>[];
      final validUploads = <FeedImageUpload>[];
      var invalidTypeCount = 0;
      var invalidSizeCount = 0;
      var missingFileCount = 0;
      var overTotalLimitCount = 0;
      var runningTotal = await _currentTotalImageBytes();

      for (final pickedFile in picked) {
        final path = await _resolveUsableImagePath(pickedFile);
        if (path == null) {
          missingFileCount++;
          continue;
        }
        if (!_isSupportedImagePath(path)) {
          invalidTypeCount++;
          continue;
        }
        final file = File(path);
        if (!await file.exists()) {
          missingFileCount++;
          continue;
        }
        final size = await file.length();
        if (size <= 0 || size > _maxImageBytes) {
          invalidSizeCount++;
          continue;
        }
        if (runningTotal + size > _maxTotalImageBytes) {
          overTotalLimitCount++;
          continue;
        }
        runningTotal += size;
        valid.add(path);
        final ext = _extensionFromName(
          pickedFile.name.isEmpty ? path : pickedFile.name,
        );
        validUploads.add(
          FeedImageUpload(
            path: path,
            bytes: (pickedFile.bytes != null && pickedFile.bytes!.isNotEmpty)
                ? pickedFile.bytes
                : null,
            fileName: pickedFile.name.isNotEmpty
                ? pickedFile.name
                : path.split(Platform.pathSeparator).last,
            contentType: _mediaTypeForExt(ext),
          ),
        );
      }

      if (valid.isNotEmpty) {
        setState(() {
          _imagePaths.addAll(valid);
          _imageUploads.addAll(validUploads);
        });
      }

      final skipped = invalidTypeCount + invalidSizeCount + missingFileCount;
      final skippedTotal = skipped + overTotalLimitCount;
      if (skippedTotal > 0 && mounted) {
        final details = <String>[];
        if (invalidTypeCount > 0) details.add('$invalidTypeCount unsupported');
        if (invalidSizeCount > 0) details.add('$invalidSizeCount invalid size');
        if (missingFileCount > 0) details.add('$missingFileCount unreadable');
        if (overTotalLimitCount > 0) {
          details.add('$overTotalLimitCount over total limit');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$skippedTotal image(s) skipped (${details.join(', ')}). Limit: 20MB each, 18MB total per post.',
            ),
          ),
        );
      }
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
                                _imageUploads.clear();
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
                    GestureDetector(
                      onTap: (!isEnabled || _isPosting) ? null : _submitPost,
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (isEnabled && !_isPosting)
                              ? const Color(0xFF15A352)
                              : const Color(0xFFE8EBEF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isPosting ? 'Posting...' : 'Post',
                          style: TextStyle(
                            color: (isEnabled && !_isPosting)
                                ? Colors.white
                                : const Color(0xFFB8BEC5),
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
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
      ),
    );
  }

  Future<void> _submitPost() async {
    if (_isPosting) return;
    setState(() => _isPosting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final name =
          prefs.getString('auth_user_name') ??
          prefs.getString('auth_mobile_number') ??
          'FarmBuzz User';
      await _FeedStore.instance.create(
        authorName: name,
        content: _postController.text.trim(),
        images: _imageUploads,
        metaFeeling: _selectedFeeling,
        metaLocation: _selectedLocation,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      _showBottomToast(context, 'Post created.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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
              onTap: () => setState(() {
                final index = _imagePaths.indexOf(path);
                if (index >= 0) {
                  _imagePaths.removeAt(index);
                  if (index < _imageUploads.length) {
                    _imageUploads.removeAt(index);
                  }
                }
              }),
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
    'Loved': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â',
    'In Love': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â¥Ãƒâ€šÃ‚Â°',
    'Blessed': 'ÃƒÆ’Ã‚Â¢Ãƒâ€¦Ã¢â‚¬Å“Ãƒâ€šÃ‚Â¨',
    'Grateful': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢Ãƒâ€šÃ‚Â',
    'Thankful': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â¤ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â',
    'Happy': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¹Ã…â€œÃƒâ€¦Ã‚Â ',
    'Cheerful': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¹Ã…â€œÃƒâ€šÃ‚Â',
    'Excited': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â¤Ãƒâ€šÃ‚Â©',
    'Celebrating': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â¥Ãƒâ€šÃ‚Â³',
    'Joyful': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¹Ã…â€œÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾',
    'Content': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¹Ã…â€œÃƒâ€¦Ã¢â‚¬â„¢',
    'Proud': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¹Ã…â€œÃƒâ€šÃ‚Â',
    'Accomplished': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚ÂÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ',
    'Motivated': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢Ãƒâ€šÃ‚Âª',
    'Determined': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€šÃ‚Â§Ãƒâ€šÃ‚Â',
    'Confident': 'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸Ãƒâ€¹Ã…â€œÃƒâ€¦Ã‚Â½',
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
                            emoji:
                                _emojiByFeeling[left] ??
                                'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡',
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
                                  emoji:
                                      _emojiByFeeling[right] ??
                                      'ÃƒÆ’Ã‚Â°Ãƒâ€¦Ã‚Â¸ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡',
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
    (city: 'Aborlan', region: 'Palawan ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· MIMAROPA Region'),
    (
      city: 'Abra De Ilog',
      region: 'Occidental Mindoro ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· MIMAROPA Region',
    ),
    (
      city: 'Abucay',
      region: 'Bataan ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· Region III (Central Luzon)',
    ),
    (
      city: 'Abulug',
      region: 'Cagayan ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· Region II (Cagayan Valley)',
    ),
    (
      city: 'Abuyog',
      region: 'Leyte ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· Region VIII (Eastern Visayas)',
    ),
    (
      city: 'Bacoor',
      region: 'Cavite ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· Region IV-A (CALABARZON)',
    ),
    (
      city: 'Cebu City',
      region: 'Cebu ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· Region VII (Central Visayas)',
    ),
    (
      city: 'Davao City',
      region: 'Davao del Sur ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· Region XI (Davao Region)',
    ),
    (
      city: 'Iloilo City',
      region: 'Iloilo ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· Region VI (Western Visayas)',
    ),
    (city: 'Quezon City', region: 'Metro Manila ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· NCR'),
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
                    final locationLabel =
                        '${item.city} ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· ${item.region}';
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

class _StoriesSection extends StatefulWidget {
  const _StoriesSection();

  @override
  State<_StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<_StoriesSection> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    try {
      await _StoryStore.instance.load();
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ValueListenableBuilder<List<FeedStory>>(
        valueListenable: _StoryStore.instance.stories,
        builder: (context, stories, _) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            const _CreateStoryCard(),
            if (_isLoading)
              const SizedBox(
                width: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ...List.generate(stories.length, (index) {
              final story = stories[index];
              return _StoryCard(
                name: story.name,
                time: story.timeAgo,
                imageUrl: story.imageUrl,
                avatarUrl: story.avatarUrl,
                textContent: story.textContent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StoryViewerScreen(
                        stories: stories,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CreateStoryCard extends StatelessWidget {
  const _CreateStoryCard();

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
              child: ValueListenableBuilder<_ViewerProfile>(
                valueListenable: _ViewerProfileStore.instance.profile,
                builder: (context, viewer, _) {
                  final hasAvatar = viewer.avatarUrl.trim().isNotEmpty;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      image: hasAvatar
                          ? DecorationImage(
                              image: NetworkImage(viewer.avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: const Color(0xFFE8F5E9),
                    ),
                    child: hasAvatar
                        ? null
                        : Center(
                            child: Text(
                              viewer.initial,
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w800,
                                fontSize: 34,
                              ),
                            ),
                          ),
                  );
                },
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
                        onTap: () {
                          // Pop the bottom sheet first, then open the editor fullscreen
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _TextStoryEditorSheet(),
                            ),
                          );
                        },
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

class _StorySharePreviewSheet extends StatefulWidget {
  const _StorySharePreviewSheet({required this.paths});

  final List<String> paths;

  @override
  State<_StorySharePreviewSheet> createState() =>
      _StorySharePreviewSheetState();
}

class _StorySharePreviewSheetState extends State<_StorySharePreviewSheet> {
  final TextEditingController _textController = TextEditingController();
  bool _isSharing = false;

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

  Future<void> _shareStory() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = (prefs.getString('auth_mobile_number') ?? '').trim();
      if (mobile.isEmpty) {
        throw Exception('Please login again before creating a story.');
      }

      final firstImage = widget.paths.firstWhere(_isImage, orElse: () => '');
      if (firstImage.isEmpty && _textController.text.trim().isEmpty) {
        throw Exception('Please select an image or add text content.');
      }

      await _StoryStore.instance.create(
        mobileNumber: mobile,
        imagePath: firstImage.isEmpty ? null : firstImage,
        textContent: _textController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Story shared')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstPath = widget.paths.first;

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
                      widget.paths.length == 1
                          ? '1 media selected'
                          : '${widget.paths.length} media selected',
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
                    TextField(
                      controller: _textController,
                      minLines: 2,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Add a caption (optional)',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFD1D5DB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFD1D5DB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.paths.length > 1)
                      Text(
                        '+${widget.paths.length - 1} more selected (only first image is used)',
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
                      onPressed: _isSharing ? null : _shareStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isSharing ? 'Sharing...' : 'Share',
                        style: const TextStyle(
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
    required this.avatarUrl,
    required this.textContent,
    this.onTap,
  });

  final VoidCallback? onTap;

  final String name;
  final String time;
  final String imageUrl;
  final String avatarUrl;
  final String textContent;

  String _initial() {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;
    final hasAvatar = avatarUrl.trim().isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: hasImage ? null : const Color(0xFF14532D),
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
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
                  backgroundColor: const Color(0xFFE8F5E9),
                  backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                  onBackgroundImageError: hasAvatar ? (_, _) {} : null,
                  child: hasAvatar
                      ? null
                      : Text(
                          _initial(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
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
                  if (!hasImage && textContent.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      textContent.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

class _PostsSection extends StatefulWidget {
  const _PostsSection();

  @override
  State<_PostsSection> createState() => _PostsSectionState();
}

class _PostsSectionState extends State<_PostsSection> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (!_FeedStore.instance.loaded) {
        await _FeedStore.instance.load();
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen),
        ),
      );
    }

    return ValueListenableBuilder<List<FeedPost>>(
      valueListenable: _FeedStore.instance.posts,
      builder: (context, posts, _) => Column(
        children: [
          for (final post in posts)
            PostCard(
              postId: post.id,
              userName: post.userName,
              userAvatar: post.userAvatar,
              timeAgo: post.timeAgo,
              postText: post.postText,
              metaEmoji: post.metaEmoji,
              metaFeeling: post.metaFeeling,
              metaLocation: post.metaLocation,
              userReaction: post.userReaction,
              likesCount: post.likesCount,
              commentsCount: post.commentsCount,
              topReactions: post.topReactions,
              imageUrls: post.imageUrls,
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TextStoryEditorSheet extends StatefulWidget {
  const _TextStoryEditorSheet();

  @override
  State<_TextStoryEditorSheet> createState() => _TextStoryEditorSheetState();
}

class _TextStoryEditorSheetState extends State<_TextStoryEditorSheet> {
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Color> _bgColors = const [
    Color(0xFF000000),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF795548),
  ];

  final List<Color> _textColors = const [
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFF44336),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFFEB3B),
  ];

  int _bgIndex = 3; // default blue
  int _textIndex = 0; // default white

  String _text = '';
  bool _isEditing = true;
  bool _isSharing = false;

  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _isEditing = false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_isEditing) return;
    _initialFocalPoint = details.focalPoint;
    _sessionOffset = _offset;
    _initialScale = _scale;
    _initialRotation = _rotation;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isEditing) return;
    setState(() {
      _offset = _sessionOffset + (details.focalPoint - _initialFocalPoint);
      _scale = (_initialScale * details.scale).clamp(0.2, 5.0);
      _rotation = _initialRotation + details.rotation;
    });
  }

  Future<void> _shareStory() async {
    if (_isSharing) return;
    if (_text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text to your story.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSharing = true;
      _isEditing = false;
    });
    // wait for keyboard to close and layout to settle so text paints in RepaintBoundary
    await Future<void>.delayed(const Duration(milliseconds: 600));

    try {
      final boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Unable to capture story.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/text_story_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      final prefs = await SharedPreferences.getInstance();
      final mobile = (prefs.getString('auth_mobile_number') ?? '').trim();
      if (mobile.isEmpty) {
        throw Exception('Please login again before creating a story.');
      }

      await _StoryStore.instance.create(
        mobileNumber: mobile,
        imagePath: file.path,
        textContent: _text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(); // pop this editor
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Story shared')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // The Canvas that gets captured
            Positioned.fill(
              child: RepaintBoundary(
                key: _globalKey,
                child: GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onTap: () {
                    if (_isEditing) {
                      _focusNode.unfocus();
                    } else if (_text.isEmpty) {
                      _focusNode.requestFocus();
                      setState(() => _isEditing = true);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(color: _bgColors[_bgIndex]),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_isEditing && _text.isNotEmpty)
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translateByDouble(
                                _offset.dx,
                                _offset.dy,
                                0.0,
                                1.0,
                              )
                              ..scaleByDouble(_scale, _scale, 1.0, 1.0)
                              ..rotateZ(_rotation),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isEditing = true);
                                _focusNode.requestFocus();
                              },
                              child: Text(
                                _text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _textColors[_textIndex],
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top Controls (Color Pickers & Close)
            if (!_isEditing)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(
                        () =>
                            _textIndex = (_textIndex + 1) % _textColors.length,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.text_format,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _textColors[_textIndex],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(
                        () => _bgIndex = (_bgIndex + 1) % _bgColors.length,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.format_color_fill,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _bgColors[_bgIndex],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Text Editing Overlay
            if (_isEditing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLines: null,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textColors[_textIndex],
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type something...",
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 32,
                        ),
                      ),
                      onChanged: (val) => setState(() => _text = val),
                    ),
                  ),
                ),
              ),

            // Top Done Button (Only when editing)
            if (_isEditing)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => _focusNode.unfocus(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Share Button
            if (!_isEditing)
              Positioned(
                bottom: 24,
                right: 24,
                child: GestureDetector(
                  onTap: _shareStory,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isSharing ? 'Sharing...' : 'Share to Story',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (!_isSharing) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.black,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
