import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;

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
        body: Column(
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
        ),
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
  final List<String> _reactions = const [
    '\u{1F44D}',
    '\u{2764}\u{FE0F}',
    '\u{1F602}',
    '\u{1F62E}',
    '\u{1F622}',
    '\u{1F621}',
  ];

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
                      child: _PostAction(
                        icon: Icons.chat_bubble_outline,
                        label: 'Comment',
                        color: Colors.grey[700],
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
            Icon(icon, size: 18, color: color ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
  static const double _emojiSize = 15;

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
          if (i != reactions.length - 1) const SizedBox(width: 3),
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

    return Text(reaction, style: TextStyle(fontSize: size));
  }
}
