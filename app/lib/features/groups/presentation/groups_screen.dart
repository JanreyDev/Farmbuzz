import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
import 'package:app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

const double _kGroupsInset = 14;
const Color _kGroupsBg = Color(0xFFF5F5F5);
const Color _kGroupsCardBg = Color(0xFFE8F5E9);
const Color _kGroupsBgDark = Color(0xFF1F1F1F);
const Color _kGroupsCardDark = Color(0xFF242628);
const Color _kGroupsBorderDark = Color(0xFF35383D);
const Color _kGroupsMutedDark = Color(0xFFB0B8B2);
const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kLightGreen = Color(0xFF66BB6A);

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenBg = isDark ? _kGroupsBgDark : _kGroupsBg;

    const groups = [
      _GroupData(
        title: 'Kelso Breeders PH',
        subtitle:
            'For all Kelso bloodline enthusiasts. Share tips, crosses, and results.',
        members: '2,847 members',
        lastSeen: '2m ago',
        tag: 'BLOODLINE',
        icon: Icons.emoji_events_outlined,
        headerColor: Color(0xFFDCEFD8),
      ),
      _GroupData(
        title: 'Pampanga Sabongeros',
        subtitle:
            'Central Luzon breeder community. Local derbies, meetups, farm visits.',
        members: '1,523 members',
        lastSeen: '15m ago',
        tag: 'REGIONAL',
        icon: Icons.location_on_outlined,
        headerColor: Color(0xFFE2F4E3),
      ),
      _GroupData(
        title: 'Conditioning Science PH',
        subtitle:
            'Evidence-based conditioning. Nutrition, exercise science, and modern keeping methods.',
        members: '3,456 members',
        lastSeen: '5m ago',
        tag: 'GENERAL',
        icon: Icons.groups_2_outlined,
        headerColor: Color(0xFFD6EFD8),
      ),
    ];

    return Scaffold(
      backgroundColor: screenBg,
      appBar: const FarmBuzzHomeAppBar(),
      drawer: const FarmBuzzAppDrawer(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ColoredBox(
          color: screenBg,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(_kGroupsInset, 8, _kGroupsInset, 10),
                  children: [
                    const SizedBox(height: 6),
                    const _SearchBar(),
                    const SizedBox(height: 18),
                    const _FilterChips(),
                    const SizedBox(height: 40),
                    Text(
                      'My Groups',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : _kDarkGreen,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...groups.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _GroupCard(data: group),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                    'Discover Groups',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : _kDarkGreen,
                      height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                data: theme.copyWith(cardColor: screenBg),
                child: AppBottomNav(
                  activeItem: AppBottomNavItem.create,
                  onItemTap: (item) => _handleNav(context, item),
                ),
              ),
            ],
          ),
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
    } else if (item == AppBottomNavItem.profile) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F22) : const Color(0xFFEFF8F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? _kGroupsBorderDark : const Color(0xFFCFE4D1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 18,
            color: isDark ? _kGroupsMutedDark : _kPrimaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search groups...',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? _kGroupsMutedDark : const Color(0xFF5F7962),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const chips = ['All', 'Bloodline', 'Regional', 'Cockpit', 'General'];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, index) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final selected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? (isDark ? const Color(0xFF1F3B22) : const Color(0xFFE8F5E9))
                  : (isDark ? _kGroupsCardDark : const Color(0xFFDCEFD8)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? _kPrimaryGreen
                    : (isDark ? _kGroupsBorderDark : const Color(0xFFBFDABD)),
              ),
            ),
            child: Text(
              chips[index],
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? (isDark ? _kLightGreen : _kDarkGreen)
                    : (isDark ? _kGroupsMutedDark : const Color(0xFF5A6F5D)),
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.data});

  final _GroupData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? _kGroupsCardDark : _kGroupsCardBg;
    final borderColor = isDark ? _kGroupsBorderDark : const Color(0xFFCFE4D1);
    final headerBg = isDark
        ? Color.alphaBlend(data.headerColor.withValues(alpha: 0.18), _kGroupsCardDark)
        : data.headerColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              data.icon,
              size: 18,
              color: isDark ? _kLightGreen : _kPrimaryGreen,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : _kDarkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? _kGroupsMutedDark : const Color(0xFF5D7261),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.groups_2_outlined,
                      size: 12,
                      color: isDark ? _kGroupsMutedDark : const Color(0xFF6E8472),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      data.members,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? _kGroupsMutedDark : const Color(0xFF6E8472),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.watch_later_outlined,
                      size: 12,
                      color: isDark ? _kGroupsMutedDark : const Color(0xFF6E8472),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      data.lastSeen,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? _kGroupsMutedDark : const Color(0xFF6E8472),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F3B22) : const Color(0xFFDDEFD9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.tag,
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? _kLightGreen : _kDarkGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF214327) : const Color(0xFFCFECCF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'JOINED',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? _kLightGreen : _kDarkGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F3B22) : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? _kGroupsBorderDark
                              : const Color(0xFFBFDABD),
                        ),
                      ),
                      child: Text(
                        'View Group',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? _kLightGreen : _kPrimaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupData {
  const _GroupData({
    required this.title,
    required this.subtitle,
    required this.members,
    required this.lastSeen,
    required this.tag,
    required this.icon,
    required this.headerColor,
  });

  final String title;
  final String subtitle;
  final String members;
  final String lastSeen;
  final String tag;
  final IconData icon;
  final Color headerColor;
}


