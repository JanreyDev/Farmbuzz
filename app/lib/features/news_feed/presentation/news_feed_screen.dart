import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';

const double _kHorizontalInset = 14;
const EdgeInsets _kHorizontalInsetPadding = EdgeInsets.symmetric(
  horizontal: _kHorizontalInset,
);

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: const Column(
          children: [
            _HeaderSection(),
            Expanded(child: _FeedList()),
            _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: const Column(
        children: [_TopBrandRow(), _ComposerRow(), _StoriesRow()],
      ),
    );
  }
}

class _TopBrandRow extends StatelessWidget {
  const _TopBrandRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        _kHorizontalInset,
        16,
        _kHorizontalInset,
        10,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EA), width: 1)),
      ),
      child: Row(
        children: const [
          _BrandLogo(),
          SizedBox(width: 8),
          Text(
            'FarmBuzz',
            style: TextStyle(
              color: Color(0xFFB38511),
              fontWeight: FontWeight.w800,
              fontSize: 35,
              height: 1,
            ),
          ),
          Spacer(),
          _IconBadge(icon: Icons.notifications_none),
          SizedBox(width: 8),
          _IconBadge(icon: Icons.chat_bubble_outline, count: 3),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: kGoldAccent,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
    );
  }
}

class _ComposerRow extends StatelessWidget {
  const _ComposerRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kHorizontalInset,
        10,
        _kHorizontalInset,
        10,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E9D4),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE4D9B7)),
            ),
            child: const Center(
              child: Text(
                'RS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA17811),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7DBE0)),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'What\'s happening at the farm?',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8F98)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.image_outlined, color: Color(0xFF4DAA5B), size: 20),
        ],
      ),
    );
  }
}

class _StoriesRow extends StatelessWidget {
  const _StoriesRow();

  @override
  Widget build(BuildContext context) {
    final stories = <_StoryItem>[
      const _StoryItem(initials: 'YS', name: 'Your Story', isOwnStory: true),
      const _StoryItem(initials: 'MD', name: 'Mario'),
      const _StoryItem(initials: 'JR', name: 'Jun'),
      const _StoryItem(initials: 'EG', name: 'Edwin'),
      const _StoryItem(initials: 'BT', name: 'Bobby'),
    ];

    return Column(
      children: [
        const _InsetGraySeparator(verticalPadding: 0),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _kHorizontalInset,
            10,
            _kHorizontalInset,
            10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stories,
          ),
        ),
        const _InsetGraySeparator(verticalPadding: 0),
      ],
    );
  }
}

class _StoryItem extends StatelessWidget {
  const _StoryItem({
    required this.initials,
    required this.name,
    this.isOwnStory = false,
  });

  final String initials;
  final String name;
  final bool isOwnStory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EEDB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOwnStory ? const Color(0xFFE4E4E4) : kGoldAccent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFAB7E14),
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
              if (isOwnStory)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: kGoldAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF787D85),
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        children: const [
          SizedBox(height: 6),
          Padding(
            padding: _kHorizontalInsetPadding,
            child: _PostCard(
              authorInitials: 'MD',
              authorName: 'Mario Dela Cruz',
              subtitle: 'DLC Gamefarm . 2h ago',
              tag: 'TRAINING LOG',
              tagBackground: Color(0xFFD6E9FF),
              tagTextColor: Color(0xFF3D6C95),
              content:
                  'Just finished 3rd week conditioning on my Kelso cross. Weight at 2.1kg, looking solid. Sparring session tomorrow morning.',
              reactions: '247',
              metrics: '38 comments . 12 shares',
            ),
          ),
          _InsetGraySeparator(),
          Padding(
            padding: _kHorizontalInsetPadding,
            child: _PostCard(
              authorInitials: 'JR',
              authorName: 'Jun Reyes',
              subtitle: 'Triple J Farm . 5h ago',
              tag: 'DERBY RESULT',
              tagBackground: Color(0xFFD6F0D7),
              tagTextColor: Color(0xFF3F7A48),
              content:
                  'Proud day at Triple J Farm! Our Sweater-Hatch cross took 3 out of 4 fights at the Tarlac Provincial Derby. Years of careful breeding paying off.',
              showImagePlaceholder: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsetGraySeparator extends StatelessWidget {
  const _InsetGraySeparator({this.verticalPadding = 6});

  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _kHorizontalInset,
        vertical: verticalPadding,
      ),
      child: Container(height: 7, color: const Color(0xFFE6E9ED)),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.authorInitials,
    required this.authorName,
    required this.subtitle,
    required this.tag,
    required this.tagBackground,
    required this.tagTextColor,
    required this.content,
    this.reactions,
    this.metrics,
    this.showImagePlaceholder = false,
  });

  final String authorInitials;
  final String authorName;
  final String subtitle;
  final String tag;
  final Color tagBackground;
  final Color tagTextColor;
  final String content;
  final String? reactions;
  final String? metrics;
  final bool showImagePlaceholder;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1E7CD),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          authorInitials,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFA47812),
                            fontSize: 11,
                          ),
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
                                authorName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1F2230),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (authorName == 'Mario Dela Cruz') ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Color(0xFFCFA136),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8A9098),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.more_horiz,
                      color: Color(0xFF8A9098),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: tagBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: tagTextColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2E3238),
                    height: 1.45,
                  ),
                ),
                if (showImagePlaceholder) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/splash.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                if (reactions != null || metrics != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (reactions != null) ...[
                        const Icon(
                          Icons.local_fire_department,
                          size: 12,
                          color: Color(0xFFFF7043),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.emoji_events,
                          size: 12,
                          color: Color(0xFFC19A3A),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.favorite,
                          size: 12,
                          color: Color(0xFFE57373),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reactions!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7E848D),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (metrics != null)
                        Text(
                          metrics!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7E848D),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E8EC)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionText(icon: Icons.thumb_up_outlined, label: 'React'),
                _ActionText(
                  icon: Icons.mode_comment_outlined,
                  label: 'Comment',
                ),
                _ActionText(icon: Icons.share_outlined, label: 'Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionText extends StatelessWidget {
  const _ActionText({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF656A74)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF656A74),
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.count});

  final IconData icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F3F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: const Color(0xFF6E747D)),
        ),
        if (count != null)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Color(0xFFE44747),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      activeItem: AppBottomNavItem.home,
      onItemTap: (item) {
        if (item == AppBottomNavItem.explore) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.explore);
        } else if (item == AppBottomNavItem.create ||
            item == AppBottomNavItem.market) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.marketplace);
        }
      },
    );
  }
}
