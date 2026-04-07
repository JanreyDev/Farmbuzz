import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';

const double _kProfileInset = 14;
const Color _kProfileBg = Color(0xFFF1F1F1);
const Color _kProfileDivider = Color(0xFFE6E9ED);
const Color _kProfileMuted = Color(0xFF7B818A);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kProfileBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                children: const [
                  _CoverHeader(),
                  _ProfileBody(),
                  _InsetBar(),
                  _AchievementsSection(),
                  _InsetBar(),
                  _FarmManagementSection(),
                ],
              ),
            ),
            AppBottomNav(
              activeItem: AppBottomNavItem.profile,
              onItemTap: (item) => _handleNav(context, item),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNav(BuildContext context, AppBottomNavItem item) {
    if (item == AppBottomNavItem.home) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.newsFeed);
    } else if (item == AppBottomNavItem.explore) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.explore);
    } else if (item == AppBottomNavItem.market ||
        item == AppBottomNavItem.create) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.marketplace);
    }
  }
}

class _CoverHeader extends StatelessWidget {
  const _CoverHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: _kProfileInset),
          decoration: BoxDecoration(
            color: const Color(0xFFBCBEC3),
            borderRadius: BorderRadius.circular(12),
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
          bottom: -34,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F0DE),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'RS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFFAA7D13),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kProfileInset, 60, _kProfileInset, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Ricardo Santos',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2230),
                  height: 1,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.verified, size: 16, color: Color(0xFFCFA136)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Santos Gamefarm',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFB58512),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: _kProfileMuted),
              SizedBox(width: 2),
              Text(
                'Arayat, Pampanga',
                style: TextStyle(fontSize: 12, color: _kProfileMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '3rd generation breeder. Champions since 1998. Pure Kelso\nand Sweater lines.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF666C75),
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
          const Divider(color: Color(0xFFE3E7EC), height: 1),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: '489', label: 'Posts'),
              _StatItem(value: '2,847', label: 'Followers'),
              _StatItem(value: '312', label: 'Following'),
              _StatItem(value: '79%', label: 'Win Rate'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE3E7EC), height: 1),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kGoldAccent, width: 1.1),
              minimumSize: const Size.fromHeight(44),
              foregroundColor: kGoldAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          const Row(
            children: [
              Icon(Icons.emoji_events_outlined, size: 16, color: Color(0xFFB68512)),
              SizedBox(width: 4),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2230),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              const visibleCards = 2.5;
              final cardWidth =
                  (constraints.maxWidth - (spacing * (visibleCards - 1))) /
                      visibleCards;

              return SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: achievements.length,
                  separatorBuilder: (_, index) =>
                      const SizedBox(width: spacing),
                  itemBuilder: (_, index) =>
                      _AchievementCard(text: achievements[index], width: cardWidth),
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
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E6EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 16, color: Color(0xFFB68512)),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B313B),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmManagementSection extends StatelessWidget {
  const _FarmManagementSection();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FarmManagementItem(
        title: 'Farm Dashboard',
        subtitle: 'Daily status, schedules, and farm activity',
        icon: Icons.dashboard_outlined,
        route: AppRoutes.farmDashboard,
      ),
      _FarmManagementItem(
        title: 'Bloodline Registry',
        subtitle: 'Track pairings, hatch history, and lines',
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
      padding: const EdgeInsets.fromLTRB(_kProfileInset, 10, _kProfileInset, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.agriculture_outlined, size: 16, color: Color(0xFFB68512)),
              SizedBox(width: 4),
              Text(
                'Farm Management',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2230),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E6EB)),
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
                                color: const Color(0xFFFBF4E3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.icon,
                                size: 19,
                                color: const Color(0xFFB68512),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1F2230),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _kProfileMuted,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF9AA1AA),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index != items.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE9EDF1),
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

class _InsetBar extends StatelessWidget {
  const _InsetBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: _kProfileInset),
      child: Divider(height: 8, thickness: 7, color: _kProfileDivider),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2DE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB68512),
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
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2230),
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF727881)),
        ),
      ],
    );
  }
}
