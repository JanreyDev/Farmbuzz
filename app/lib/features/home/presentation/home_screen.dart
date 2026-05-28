import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../clubs/presentation/clubs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: _selectedIndex == 0 ? _buildHomeFeed() : _buildTabPlaceholder(),
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
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI shortcuts coming next.')),
                  ),
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

    final labels = <int, String>{
      1: 'My Farm',
      2: 'Bantay AI',
      4: 'Rank',
    };
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu is UI-only for now.')),
              );
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messages screen coming next.')),
              );
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: _HeaderIconWithBadge(
              icon: LucideIcons.bell,
              count: _unreadNotifications,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications screen coming next.'),
                ),
              );
            },
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
                  "What's happening on your farm?",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
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
    return Container(
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
