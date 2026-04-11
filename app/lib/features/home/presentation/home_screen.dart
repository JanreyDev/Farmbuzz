import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
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
      likes: '47',
      imageUrl: _kPostImageOne,
      avatarUrl: _kPostAvatarOne,
    ),
    const _HomePostData(
      author: 'Golden Hatch Breeders',
      timeAgo: '3h',
      text:
          'Brooder check complete. Vaccination done for 12 chicks and feed schedule updated.',
      likes: '91',
      imageUrl: _kPostImageTwo,
      avatarUrl: _kPostAvatarTwo,
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
          likes: '0',
          imageUrl: imageUrl,
          avatarUrl: _kComposerAvatarUrl,
        ),
      );
    });
  }

  List<Widget> _buildPostFeed() {
    final widgets = <Widget>[];
    for (var i = 0; i < _posts.length; i++) {
      final post = _posts[i];
      widgets.add(
        _PostCard(
          author: post.author,
          timeAgo: post.timeAgo,
          text: post.text,
          likes: post.likes,
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
    required this.avatarUrl,
    this.imageUrl,
  });

  final String author;
  final String timeAgo;
  final String text;
  final String likes;
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
  });

  final List<_HomeStoryData> stories;
  final VoidCallback onCreateStoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 206,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CreateStoryCard(onTap: onCreateStoryTap),
          ...stories.map(
            (story) => _StoryCard(
              name: story.name,
              imageUrl: story.imageUrl,
              avatarUrl: story.avatarUrl,
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
    required this.name,
    required this.imageUrl,
    required this.avatarUrl,
  });

  final String name;
  final String imageUrl;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.author,
    required this.timeAgo,
    required this.text,
    required this.likes,
    required this.avatarUrl,
    this.imageUrl,
  });

  final String author;
  final String timeAgo;
  final String text;
  final String likes;
  final String? imageUrl;
  final String avatarUrl;

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
                _Avatar(size: 42, imageUrl: avatarUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              author,
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
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 28),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: _kPrimaryGreen,
                              textStyle: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Follow'),
                          ),
                        ],
                      ),
                      Text(
                        '$timeAgo - Public',
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
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.35,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? Colors.white
                    : colorScheme.onSurface.withValues(alpha: 0.92),
              ),
            ),
            if (imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _NetworkFeedImage(imageUrl: imageUrl!, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.thumb_up, color: _kPrimaryGreen, size: 16),
                const SizedBox(width: 4),
                Text(
                  likes,
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
              children: const [
                _PostAction(icon: Icons.thumb_up_outlined, label: 'Like'),
                _PostAction(icon: Icons.mode_comment_outlined, label: 'Comment'),
                _PostAction(icon: Icons.share_outlined, label: 'Share'),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.66);
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: color),
      label: Text(label, style: TextStyle(color: color)),
    );
  }
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
