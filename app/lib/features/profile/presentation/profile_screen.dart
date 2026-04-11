import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
import 'package:app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

const double _kProfileInset = 14;
const Color _kProfileBg = Color(0xFFF5F5F5);
const Color _kProfileDivider = Color(0xFFE6E9ED);
const Color _kProfileMuted = Color(0xFF7B818A);
const Color _kProfileBgDark = Color(0xFF1F1F1F);
const Color _kProfileCardDark = Color(0xFF242628);
const Color _kProfileBorderDark = Color(0xFF35383D);
const Color _kProfileMutedDark = Color(0xFFB0B8B2);
const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kLightGreen = Color(0xFF66BB6A);
const Color _kSoftGreen = Color(0xFFE8F5E9);
const Color _kSoftGreenBorder = Color(0xFFCFE4D1);
const String _kProfileCoverUrl =
    'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80';
const String _kProfileAvatarUrl =
    'https://randomuser.me/api/portraits/men/32.jpg';
const _kPostGalleryImages = [
  'https://images.pexels.com/photos/15235677/pexels-photo-15235677.jpeg?auto=compress&cs=tinysrgb&w=900',
  'https://images.pexels.com/photos/13293244/pexels-photo-13293244.jpeg?auto=compress&cs=tinysrgb&w=900',
  'https://images.pexels.com/photos/18846336/pexels-photo-18846336.jpeg?auto=compress&cs=tinysrgb&w=900',
];
const _kBirdGalleryImages = [
  'https://images.pexels.com/photos/13607889/pexels-photo-13607889.jpeg?auto=compress&cs=tinysrgb&w=900',
  'https://images.pexels.com/photos/19198208/pexels-photo-19198208.jpeg?auto=compress&cs=tinysrgb&w=900',
  'https://images.pexels.com/photos/13632433/pexels-photo-13632433.jpeg?auto=compress&cs=tinysrgb&w=900',
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenBg = isDark ? _kProfileBgDark : _kProfileBg;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: const FarmBuzzHomeAppBar(),
      drawer: const FarmBuzzAppDrawer(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                children: [
                  const _CoverHeader(),
                  const _ProfileBody(),
                  const _InsetBar(),
                  const _AchievementsSection(),
                  const _InsetBar(),
                  const _GalleryTabsSection(),
                  const _InsetBar(),
                  const _FarmManagementSection(),
                  const _InsetBar(),
                  const _BreedingHealthSection(),
                ],
              ),
            ),
            Theme(
              data: theme.copyWith(cardColor: screenBg),
              child: AppBottomNav(
                activeItem: AppBottomNavItem.profile,
                onItemTap: (item) => _handleNav(context, item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNav(BuildContext context, AppBottomNavItem item) {
    if (item == AppBottomNavItem.home) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (item == AppBottomNavItem.explore) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.farmDashboard);
    } else if (item == AppBottomNavItem.market) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.marketplace);
    } else if (item == AppBottomNavItem.create) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.groups);
    }
  }
}

class _CoverHeader extends StatelessWidget {
  const _CoverHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: _kProfileInset),
          decoration: BoxDecoration(
            color: isDark ? _kProfileCardDark : const Color(0xFFDCEFD8),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            _kProfileCoverUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: Color(0xFFDCEFD8),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 28,
                  color: _kPrimaryGreen,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 24,
          top: 10,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0x66000000),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings, size: 17, color: Colors.white),
          ),
        ),
        Positioned(
          left: 30,
          bottom: -30,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: isDark ? _kProfileCardDark : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: Image.network(
                  _kProfileAvatarUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(
                    child: Text(
                      'RS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _kDarkGreen,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? Colors.white : const Color(0xFF1F2230);
    final muted = isDark ? _kProfileMutedDark : _kProfileMuted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kProfileInset,
        62,
        _kProfileInset,
        10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ricardo Santos',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: textMain,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 16, color: _kPrimaryGreen),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Santos Gamefarm',
            style: TextStyle(
              fontSize: 16,
              color: _kPrimaryGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: muted),
              const SizedBox(width: 2),
              Text(
                'Arayat, Pampanga',
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '🐔 3rd generation breeder. Champions since 1998. Pure Kelso\nand Sweater lines.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? _kProfileMutedDark : const Color(0xFF666C75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              _Tag(text: 'Kelso'),
              SizedBox(width: 4),
              _Tag(text: 'Sweater'),
              SizedBox(width: 4),
              _Tag(text: 'Hatch'),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            color: isDark ? _kProfileBorderDark : const Color(0xFFE3E7EC),
            height: 1,
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: '489', label: 'Posts'),
              _StatItem(value: '2,847', label: 'Followers'),
              _StatItem(value: '312', label: 'Following'),
              _StatItem(value: '79', label: 'Win Rate (%)'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: isDark ? _kProfileCardDark : _kSoftGreen,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? _kProfileBorderDark : _kSoftGreenBorder,
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.auto_awesome_outlined,
                  text: 'Level 12 Breeder',
                  darkMode: isDark,
                ),
                _InfoPill(
                  icon: Icons.bolt_outlined,
                  text: 'XP: 2,450',
                  darkMode: isDark,
                ),
                _InfoPill(
                  icon: Icons.emoji_events_outlined,
                  text: '#23 in Pampanga',
                  darkMode: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark ? _kProfileBorderDark : const Color(0xFFE3E7EC),
            height: 1,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kPrimaryGreen, width: 1.1),
              minimumSize: const Size.fromHeight(44),
              foregroundColor: _kPrimaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const achievements = [
      '2024 Pampanga Derby\nChampion',
      '2023 Luzon Grand\nSlam Winner',
      'Top Breeder Award',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(_kProfileInset, 10, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: 16,
                color: _kPrimaryGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : _kDarkGreen,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: _kPrimaryGreen,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              const visibleCards = 2.5;
              final cardWidth =
                  (constraints.maxWidth - (spacing * (visibleCards - 1))) /
                  visibleCards;

              return SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(right: _kProfileInset),
                  itemCount: achievements.length,
                  separatorBuilder: (_, index) =>
                      const SizedBox(width: spacing),
                  itemBuilder: (_, index) => _AchievementCard(
                    text: achievements[index],
                    width: cardWidth,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.text, required this.width});

  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? _kProfileCardDark : _kSoftGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? _kProfileBorderDark : _kSoftGreenBorder,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 16,
            color: _kPrimaryGreen,
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF2B313B),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    required this.darkMode,
  });

  final IconData icon;
  final String text;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF1F3B22) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: darkMode ? _kProfileBorderDark : _kSoftGreenBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kPrimaryGreen),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: darkMode ? Colors.white : const Color(0xFF1F2230),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryTabsSection extends StatefulWidget {
  const _GalleryTabsSection();

  @override
  State<_GalleryTabsSection> createState() => _GalleryTabsSectionState();
}

class _GalleryTabsSectionState extends State<_GalleryTabsSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? _kProfileCardDark : _kSoftGreen;
    final borderColor = isDark ? _kProfileBorderDark : _kSoftGreenBorder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(_kProfileInset, 10, _kProfileInset, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : _kDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            labelColor: _kPrimaryGreen,
            unselectedLabelColor: isDark ? _kProfileMutedDark : _kProfileMuted,
            indicatorColor: _kPrimaryGreen,
            tabs: const [
              Tab(text: 'Posts'),
              Tab(text: 'Birds'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 148,
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _kPostGalleryImages.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (_, index) => _GalleryCard(
                    color: cardColor,
                    borderColor: borderColor,
                    imageUrl: _kPostGalleryImages[index],
                  ),
                ),
                ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _kBirdGalleryImages.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (_, index) => _GalleryCard(
                    color: cardColor,
                    borderColor: borderColor,
                    imageUrl: _kBirdGalleryImages[index],
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

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({
    required this.color,
    required this.borderColor,
    required this.imageUrl,
  });

  final Color color;
  final Color borderColor;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 180,
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: isDark ? const Color(0xFF1F3B22) : const Color(0xFFDCEFD8),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            color: _kPrimaryGreen,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _FarmManagementSection extends StatelessWidget {
  const _FarmManagementSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionTitle = isDark ? Colors.white : _kDarkGreen;
    final itemTitle = isDark ? Colors.white : const Color(0xFF1F2230);
    final itemMuted = isDark ? _kProfileMutedDark : _kProfileMuted;

    const items = [
      _FarmManagementItem(
        title: 'Farm Dashboard',
        subtitle: 'Daily status, schedules, and farm activity',
        icon: Icons.dashboard_outlined,
        route: AppRoutes.farmDashboard,
      ),
      _FarmManagementItem(
        title: 'Bloodline Registry',
        subtitle: 'Track pairings and bloodline history',
        icon: Icons.account_tree_outlined,
        route: AppRoutes.bloodlineRegistry,
      ),
      _FarmManagementItem(
        title: 'QR Leg Bands',
        subtitle: 'Scan and identify birds instantly',
        icon: Icons.qr_code_scanner_rounded,
        route: AppRoutes.qrLegBands,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kProfileInset,
        10,
        _kProfileInset,
        14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.agriculture_outlined,
                size: 16,
                color: _kPrimaryGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'Farm Management',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: sectionTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? _kProfileCardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? _kProfileBorderDark : const Color(0xFFE2E6EB),
              ),
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.only(
                        topLeft: index == 0
                            ? const Radius.circular(12)
                            : Radius.zero,
                        topRight: index == 0
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottomLeft: index == items.length - 1
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottomRight: index == items.length - 1
                            ? const Radius.circular(12)
                            : Radius.zero,
                      ),
                      onTap: () {
                        if (item.route != null) {
                          Navigator.of(context).pushNamed(item.route!);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F3B22) : _kSoftGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.icon,
                                size: 19,
                                color: _kPrimaryGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: itemTitle,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: itemMuted,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: isDark
                                  ? _kProfileMutedDark
                                  : const Color(0xFF9AA1AA),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index != items.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? _kProfileBorderDark
                            : const Color(0xFFE9EDF1),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmManagementItem {
  const _FarmManagementItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? route;
}

class _BreedingHealthSection extends StatelessWidget {
  const _BreedingHealthSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionTitle = isDark ? Colors.white : _kDarkGreen;
    final itemTitle = isDark ? Colors.white : const Color(0xFF1F2230);
    final itemMuted = isDark ? _kProfileMutedDark : _kProfileMuted;

    const items = [
      _BreedingHealthItem(
        title: 'Health Records',
        subtitle: 'Vaccines, meds, and treatment logs',
        icon: Icons.favorite_border,
        iconColor: _kPrimaryGreen,
        iconBg: _kSoftGreen,
        cardBg: Color(0xFFF2FAF3),
        route: AppRoutes.healthRecords,
      ),
      _BreedingHealthItem(
        title: 'Weight Tracker',
        subtitle: 'Weekly growth and conditioning trends',
        icon: Icons.monitor_weight_outlined,
        iconColor: _kDarkGreen,
        iconBg: _kSoftGreen,
        cardBg: Color(0xFFF2FAF3),
        route: AppRoutes.weightTracker,
      ),
      _BreedingHealthItem(
        title: 'Breeding Planner',
        subtitle: 'Pairing plans and hatch schedules',
        icon: Icons.event_note_outlined,
        iconColor: _kLightGreen,
        iconBg: _kSoftGreen,
        cardBg: Color(0xFFF2FAF3),
        route: AppRoutes.breedingPlanner,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kProfileInset,
        10,
        _kProfileInset,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                size: 16,
                color: _kPrimaryGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'Breeding & Health',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: sectionTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (item.route != null) {
                    Navigator.of(context).pushNamed(item.route!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: isDark ? _kProfileCardDark : item.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? _kProfileBorderDark : const Color(0xFFE2E6EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F3B22) : item.iconBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: isDark ? _kLightGreen : item.iconColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: itemTitle,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: itemMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? _kProfileMutedDark : const Color(0xFF9AA1AA),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreedingHealthItem {
  const _BreedingHealthItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.cardBg,
    this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color cardBg;
  final String? route;
}

class _InsetBar extends StatelessWidget {
  const _InsetBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kProfileInset),
      child: Divider(
        height: 8,
        thickness: 7,
        color: isDark ? _kProfileBorderDark : _kProfileDivider,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F3B22) : _kSoftGreen,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isDark ? _kLightGreen : _kDarkGreen,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1F2230),
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: isDark ? _kProfileMutedDark : const Color(0xFF727881),
          ),
        ),
      ],
    );
  }
}



