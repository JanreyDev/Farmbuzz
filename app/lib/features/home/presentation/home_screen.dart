import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
import 'package:app/app/widgets/ai_chat_button.dart';
import 'package:app/features/home/presentation/story_viewer_screen.dart';
import 'package:app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kHomeBgLight = Color(0xFFF5F5F5);
const Color _kHomeBgDark = Color(0xFF1F1F1F);
const Color _kHomeCardDark = Color(0xFF242628);
const Color _kHomeCardLight = Colors.white;
const double _kStoryCardWidth = 114;
const double _kStoryCardGap = 8;

const _kComposerAvatarUrl =
    'https://images.pexels.com/photos/18481431/pexels-photo-18481431.jpeg?auto=compress&cs=tinysrgb&w=300';
const _kCreateStoryImageUrl =
    'https://images.pexels.com/photos/19198208/pexels-photo-19198208.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kStoryImageBlackWarrior =
    'https://images.pexels.com/photos/18846336/pexels-photo-18846336.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kStoryImageRedKelso =
    'https://images.pexels.com/photos/15235677/pexels-photo-15235677.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kStoryImageGoldenHatch =
    'https://images.pexels.com/photos/13607889/pexels-photo-13607889.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kStoryAvatarBlackWarrior =
    'https://images.pexels.com/photos/2600399/pexels-photo-2600399.jpeg?auto=compress&cs=tinysrgb&w=300';
const _kStoryAvatarRedKelso =
    'https://images.pexels.com/photos/13632433/pexels-photo-13632433.jpeg?auto=compress&cs=tinysrgb&w=300';
const _kStoryAvatarGoldenHatch =
    'https://images.pexels.com/photos/13330411/pexels-photo-13330411.jpeg?auto=compress&cs=tinysrgb&w=300';
const _kPostImageOne =
    'https://images.pexels.com/photos/15235677/pexels-photo-15235677.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kPostImageTwo =
    'https://images.pexels.com/photos/13293244/pexels-photo-13293244.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kPostAvatarOne =
    'https://images.pexels.com/photos/18699978/pexels-photo-18699978.jpeg?auto=compress&cs=tinysrgb&w=300';
const _kPostAvatarTwo =
    'https://images.pexels.com/photos/25310981/pexels-photo-25310981.jpeg?auto=compress&cs=tinysrgb&w=300';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_HomeStoryData> _stories = <_HomeStoryData>[
    const _HomeStoryData(
      name: 'Black Warrior',
      imageUrl: _kStoryImageBlackWarrior,
      avatarUrl: _kStoryAvatarBlackWarrior,
    ),
    const _HomeStoryData(
      name: 'Red Kelso',
      imageUrl: _kStoryImageRedKelso,
      avatarUrl: _kStoryAvatarRedKelso,
    ),
    const _HomeStoryData(
      name: 'Golden Hatch',
      imageUrl: _kStoryImageGoldenHatch,
      avatarUrl: _kStoryAvatarGoldenHatch,
    ),
  ];
  final List<_HomePostData> _posts = <_HomePostData>[
    const _HomePostData(
      author: 'Black Warrior Farm',
      timeAgo: '1h',
      text:
          'Morning update: Black Warrior hit target weight today. Ready for conditioning this weekend.',
      likes: 47,
      imageUrl: _kPostImageOne,
      avatarUrl: _kPostAvatarOne,
      comments: ['Juan: Nice bird!', 'Mark: Good condition!'],
    ),
    const _HomePostData(
      author: 'Golden Hatch Breeders',
      timeAgo: '3h',
      text:
          'Brooder check complete. Vaccination done for 12 chicks and feed schedule updated.',
      likes: 91,
      imageUrl: _kPostImageTwo,
      avatarUrl: _kPostAvatarTwo,
      comments: ['Rico: Looking healthy!', 'Allen: Great progress.'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeBg = isDark ? _kHomeBgDark : _kHomeBgLight;

    return Scaffold(
      backgroundColor: homeBg,
      appBar: const FarmBuzzHomeAppBar(),
      drawer: const FarmBuzzAppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 10),
              children: [
                const SizedBox(height: 10),
                _ComposerRow(onTapCreatePost: _openCreatePost),
                const SizedBox(height: 10),
                _StoriesStrip(
                  stories: _stories,
                  onCreateStoryTap: _openCreateStory,
                  onStoryTap: _openStoryViewer,
                ),
                const SizedBox(height: 10),
                const _SectionDivider(),
                const SizedBox(height: 8),
                ..._buildPostFeed(),
              ],
            ),
          ),
          const _BottomNavBar(),
        ],
      ),
    );
  }

  Future<void> _openCreateStory() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.createStory);
    if (!mounted || result is! Map<String, dynamic>) {
      return;
    }

    final imageUrl = result['imageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      return;
    }

    setState(() {
      _stories.insert(
        0,
        const _HomeStoryData(
          name: 'Your Story',
          imageUrl: _kCreateStoryImageUrl,
          avatarUrl: _kComposerAvatarUrl,
        ).copyWith(imageUrl: imageUrl),
      );
    });
  }

  Future<void> _openCreatePost() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.createPost);
    if (!mounted || result is! Map<String, dynamic>) {
      return;
    }

    final text = (result['text'] as String? ?? '').trim();
    final imageUrl = result['imageUrl'] as String?;
    if (text.isEmpty && (imageUrl == null || imageUrl.isEmpty)) {
      return;
    }

    setState(() {
        _posts.insert(
          0,
          _HomePostData(
            author: 'Ricardo Santos',
            timeAgo: 'Just now',
            text: text,
            likes: 0,
            imageUrl: imageUrl,
            avatarUrl: _kComposerAvatarUrl,
            comments: const [],
          ),
        );
      });
  }

  Future<void> _openStoryViewer(int index) async {
    if (_stories.isEmpty) {
      return;
    }
    final safeIndex = index.clamp(0, _stories.length - 1);
    AiGlobalFab.isVisible.value = false;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(
          stories: _stories
              .map(
                (s) => StoryItem(
                  imageUrl: s.imageUrl,
                  username: s.name,
                  avatarUrl: s.avatarUrl,
                  timestamp: '2h ago',
                ),
              )
              .toList(),
          initialIndex: safeIndex,
        ),
      ),
    );
    AiGlobalFab.isVisible.value = true;
  }

  List<Widget> _buildPostFeed() {
    final widgets = <Widget>[];
    for (var i = 0; i < _posts.length; i++) {
      final post = _posts[i];
      widgets.add(
        _PostCard(
          key: ValueKey('${post.author}-${post.timeAgo}-${post.text.hashCode}'),
          author: post.author,
          timeAgo: post.timeAgo,
          text: post.text,
          initialLikeCount: post.likes,
          initialComments: post.comments,
          imageUrl: post.imageUrl,
          avatarUrl: post.avatarUrl,
        ),
      );
      if (i != _posts.length - 1) {
        widgets.add(const _SectionDivider());
      }
    }
    return widgets;
  }
}

class _HomeStoryData {
  const _HomeStoryData({
    required this.name,
    required this.imageUrl,
    required this.avatarUrl,
  });

  final String name;
  final String imageUrl;
  final String avatarUrl;

  _HomeStoryData copyWith({
    String? name,
    String? imageUrl,
    String? avatarUrl,
  }) {
    return _HomeStoryData(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class _HomePostData {
  const _HomePostData({
    required this.author,
    required this.timeAgo,
    required this.text,
    required this.likes,
    required this.comments,
    required this.avatarUrl,
    this.imageUrl,
  });

  final String author;
  final String timeAgo;
  final String text;
  final int likes;
  final List<String> comments;
  final String? imageUrl;
  final String avatarUrl;
}

class _ComposerRow extends StatelessWidget {
  const _ComposerRow({required this.onTapCreatePost});

  final VoidCallback onTapCreatePost;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const _Avatar(size: 42, imageUrl: _kComposerAvatarUrl),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onTapCreatePost,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? _kHomeCardDark : _kHomeCardLight,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.18),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  'What\'s happening on your farm?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.66),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTapCreatePost,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.image_outlined,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoriesStrip extends StatelessWidget {
  const _StoriesStrip({
    required this.stories,
    required this.onCreateStoryTap,
    required this.onStoryTap,
  });

  final List<_HomeStoryData> stories;
  final VoidCallback onCreateStoryTap;
  final ValueChanged<int> onStoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 206,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CreateStoryCard(onTap: onCreateStoryTap),
          ...stories.asMap().entries.map(
            (entry) => _StoryCard(
              onTap: () => onStoryTap(entry.key),
              name: entry.value.name,
              imageUrl: entry.value.imageUrl,
              avatarUrl: entry.value.avatarUrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateStoryCard extends StatelessWidget {
  const _CreateStoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: _kStoryCardWidth,
      margin: const EdgeInsets.only(right: _kStoryCardGap),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? _kHomeCardDark : _kHomeCardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: const _NetworkFeedImage(
                          imageUrl: _kCreateStoryImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _kPrimaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 10),
                      child: Text(
                        'Create Story',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w700),
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

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.onTap,
    required this.name,
    required this.imageUrl,
    required this.avatarUrl,
  });

  final VoidCallback onTap;
  final String name;
  final String imageUrl;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: _kStoryCardWidth,
        margin: const EdgeInsets.only(right: _kStoryCardGap),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _NetworkFeedImage(imageUrl: imageUrl, fit: BoxFit.cover),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kPrimaryGreen, width: 2),
                ),
                child: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
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
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({
    super.key,
    required this.author,
    required this.timeAgo,
    required this.text,
    required this.initialLikeCount,
    required this.initialComments,
    required this.avatarUrl,
    this.imageUrl,
  });

  final String author;
  final String timeAgo;
  final String text;
  final int initialLikeCount;
  final List<String> initialComments;
  final String? imageUrl;
  final String avatarUrl;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late bool _isLiked;
  bool _isFollowing = false;
  late int _likeCount;
  late List<String> _comments;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.initialLikeCount;
    _comments = List<String>.from(widget.initialComments);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sectionBg = isDark ? _kHomeBgDark : _kHomeBgLight;
    final cardBg = isDark ? _kHomeCardDark : _kHomeCardLight;

    return Container(
      color: sectionBg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(size: 42, imageUrl: widget.avatarUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const _BreederBadge(),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _toggleFollow,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 28),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: _isFollowing
                                  ? colorScheme.onSurface.withValues(alpha: 0.75)
                                  : _kPrimaryGreen,
                              backgroundColor: _isFollowing
                                  ? colorScheme.onSurface.withValues(alpha: 0.10)
                                  : _kPrimaryGreen.withValues(alpha: 0.12),
                              textStyle: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(_isFollowing ? 'Following' : 'Follow'),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.timeAgo} - Public',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.close,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.35,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? Colors.white
                    : colorScheme.onSurface.withValues(alpha: 0.92),
              ),
            ),
            if (widget.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _NetworkFeedImage(
                  imageUrl: widget.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  color: _isLiked
                      ? _kPrimaryGreen
                      : colorScheme.onSurface.withValues(alpha: 0.50),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_likeCount likes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_comments.length} comments',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.22)
                  : colorScheme.onSurface.withValues(alpha: 0.10),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PostActionButton(
                  icon: _isLiked
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  label: 'Like',
                  active: _isLiked,
                  onTap: _toggleLike,
                ),
                _PostActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: 'Comment',
                  onTap: _openComments,
                ),
                const _PostActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _toggleFollow() {
    setState(() => _isFollowing = !_isFollowing);
  }

  Future<void> _openComments() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CommentsSheet(
          initialComments: _comments,
          onCommentsChanged: (updated) {
            setState(() => _comments = updated);
          },
        );
      },
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = active
        ? _kPrimaryGreen
        : colorScheme.onSurface.withValues(alpha: 0.66);
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.initialComments,
    required this.onCommentsChanged,
  });

  final List<String> initialComments;
  final ValueChanged<List<String>> onCommentsChanged;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  late List<String> _comments;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  _CommentFilter _filter = _CommentFilter.mostRelevant;

  @override
  void initState() {
    super.initState();
    _comments = List<String>.from(widget.initialComments);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: BoxDecoration(
          color: isDark ? _kHomeCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Comments',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
                  const Spacer(),
                  PopupMenuButton<_CommentFilter>(
                    initialValue: _filter,
                    onSelected: (value) => setState(() => _filter = value),
                    itemBuilder: (context) => _CommentFilter.values
                        .map(
                          (filter) => PopupMenuItem<_CommentFilter>(
                            value: filter,
                            child: Text(filter.label),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _filter.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.onSurface.withValues(alpha: 0.10),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                itemCount: _visibleComments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final parsed = _CommentData.fromRaw(_visibleComments[index]);
                  return _CommentTile(
                    name: parsed.name,
                    message: parsed.message,
                    isMine: parsed.name.toLowerCase() == 'you',
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                10 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        isDense: true,
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF2F4F6),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: _kPrimaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _sendComment,
                      icon: const Icon(
                        Icons.send_rounded,
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
      ),
    );
  }

  void _sendComment() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _comments.add('You: $text');
      _inputController.clear();
    });
    widget.onCommentsChanged(List<String>.from(_comments));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 64,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  List<String> get _visibleComments {
    switch (_filter) {
      case _CommentFilter.all:
        return List<String>.from(_comments);
      case _CommentFilter.newest:
        return _comments.reversed.toList();
      case _CommentFilter.mostRelevant:
        final items = List<String>.from(_comments);
        items.sort((a, b) {
          final scoreA = _relevanceScore(a);
          final scoreB = _relevanceScore(b);
          return scoreB.compareTo(scoreA);
        });
        return items;
    }
  }

  int _relevanceScore(String raw) {
    final parsed = _CommentData.fromRaw(raw);
    final minePenalty = parsed.name.toLowerCase() == 'you' ? -1 : 1;
    final lengthScore = parsed.message.length > 16 ? 1 : 0;
    final emphasisScore = parsed.message.contains('!') ? 1 : 0;
    return minePenalty + lengthScore + emphasisScore;
  }
}

class _CommentData {
  const _CommentData({required this.name, required this.message});

  final String name;
  final String message;

  factory _CommentData.fromRaw(String raw) {
    final separator = raw.indexOf(':');
    if (separator <= 0 || separator == raw.length - 1) {
      return _CommentData(name: 'User', message: raw.trim());
    }
    return _CommentData(
      name: raw.substring(0, separator).trim(),
      message: raw.substring(separator + 1).trim(),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.name,
    required this.message,
    required this.isMine,
  });

  final String name;
  final String message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final initials = name.isEmpty
        ? 'U'
        : name
            .trim()
            .split(' ')
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isMine
                ? _kPrimaryGreen.withValues(alpha: 0.20)
                : const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            border: Border.all(
              color: _kPrimaryGreen.withValues(alpha: 0.35),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              color: isMine ? _kPrimaryGreen : const Color(0xFF1F2230),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _kPrimaryGreen.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isMine ? 'You' : 'Breeder',
                      style: const TextStyle(
                        color: _kPrimaryGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Just now',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _CommentFilter {
  mostRelevant('Most relevant'),
  newest('Newest'),
  all('All comments');

  const _CommentFilter(this.label);
  final String label;
}

class _BreederBadge extends StatelessWidget {
  const _BreederBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Breeder badge',
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _kPrimaryGreen.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.emoji_events_rounded,
          size: 13,
          color: _kPrimaryGreen,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.size, required this.imageUrl});

  final double size;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: _NetworkFeedImage(imageUrl: imageUrl, fit: BoxFit.cover),
    );
  }
}

class _NetworkFeedImage extends StatelessWidget {
  const _NetworkFeedImage({required this.imageUrl, this.fit = BoxFit.cover});

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (_, _, _) {
        return ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.pets_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        );
      },
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 14,
        thickness: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.22)
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      activeItem: AppBottomNavItem.home,
      onItemTap: (item) {
        if (item == AppBottomNavItem.home) {
          return;
        } else if (item == AppBottomNavItem.explore) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.farmDashboard);
        } else if (item == AppBottomNavItem.market) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.marketplace);
        } else if (item == AppBottomNavItem.create) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.groups);
        } else if (item == AppBottomNavItem.profile) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
        }
      },
    );
  }
}
