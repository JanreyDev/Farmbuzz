import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';

const double _kGroupsInset = 14;
const Color _kGroupsBg = Color(0xFFF1F1F1);
const Color _kGroupsCardBg = Color(0xFFF8F8F8);

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const groups = [
      _GroupData(
        title: 'Kelso Breeders PH',
        subtitle:
            'For all Kelso bloodline enthusiasts. Share tips, crosses, and results.',
        members: '2,847 members',
        lastSeen: '2m ago',
        tag: 'BLOODLINE',
        icon: Icons.emoji_events_outlined,
        headerColor: Color(0xFFF0EDE4),
      ),
      _GroupData(
        title: 'Pampanga Sabongeros',
        subtitle:
            'Central Luzon breeder community. Local derbies, meetups, farm visits.',
        members: '1,523 members',
        lastSeen: '15m ago',
        tag: 'REGIONAL',
        icon: Icons.location_on_outlined,
        headerColor: Color(0xFFEAF1EC),
      ),
      _GroupData(
        title: 'Conditioning Science PH',
        subtitle:
            'Evidence-based conditioning. Nutrition, exercise science, and modern keeping methods.',
        members: '3,456 members',
        lastSeen: '5m ago',
        tag: 'GENERAL',
        icon: Icons.groups_2_outlined,
        headerColor: Color(0xFFF3EAE4),
      ),
    ];

    return Scaffold(
      backgroundColor: _kGroupsBg,
      body: SafeArea(
        child: ColoredBox(
          color: _kGroupsBg,
          child: Column(
            children: [
              const _GroupsHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(_kGroupsInset, 8, _kGroupsInset, 10),
                  children: [
                    const SizedBox(height: 6),
                    const _SearchBar(),
                    const SizedBox(height: 18),
                    const _FilterChips(),
                    const SizedBox(height: 40),
                    const Text(
                      'My Groups',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2230),
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
                  const Text(
                    'Discover Groups',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2230),
                      height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                data: theme.copyWith(cardColor: _kGroupsBg),
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

class _GroupsHeader extends StatelessWidget {
  const _GroupsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3240), size: 20),
          ),
          const Expanded(
            child: Text(
              'Groups',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2230),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: kGoldAccent, size: 22),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E6EB)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 18, color: Color(0xFF9097A0)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search groups...',
              style: TextStyle(fontSize: 13, color: Color(0xFF9097A0)),
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
              color: selected ? const Color(0xFFF7EFD7) : const Color(0xFFE7EAEE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? kGoldAccent : const Color(0xFFDEE2E8),
              ),
            ),
            child: Text(
              chips[index],
              style: TextStyle(
                fontSize: 11,
                color: selected ? const Color(0xFFA67913) : const Color(0xFF6F7680),
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
    return Container(
      decoration: BoxDecoration(
        color: _kGroupsCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE2E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: data.headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 18, color: const Color(0xFFB68512)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2230),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6E7480),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.groups_2_outlined, size: 12, color: Color(0xFF8A9098)),
                    const SizedBox(width: 2),
                    Text(
                      data.members,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF8A9098)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.watch_later_outlined, size: 12, color: Color(0xFF8A9098)),
                    const SizedBox(width: 2),
                    Text(
                      data.lastSeen,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF8A9098)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7EAEE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.tag,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF6F7680),
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
                        color: const Color(0xFFDDF3DE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'JOINED',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4E9A5C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8EFCF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'View Group',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAA7E14),
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
