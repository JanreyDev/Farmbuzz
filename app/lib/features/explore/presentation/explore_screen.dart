import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';

const double _kExploreInset = 14;
const Color _kExploreBackground = Color(0xFFF1F1F1);
const Color _kExploreSurface = Colors.white;
const Color _kExploreDivider = Color(0xFFE6E9ED);
const Color _kExploreMutedText = Color(0xFF7C828C);

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kExploreBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    _SearchSection(),
                    _InsetBar(),
                    _TrendingBloodlinesSection(),
                    _InsetBar(),
                    _TopFarmsSection(),
                    _InsetBar(),
                    _UpcomingEventsSection(),
                  ],
                ),
              ),
            ),
            AppBottomNav(
              activeItem: AppBottomNavItem.explore,
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
    }
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kExploreInset,
        12,
        _kExploreInset,
        8,
      ),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E6EB)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 18, color: Color(0xFF9097A0)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search breeders, bloodlines, events...',
                style: TextStyle(fontSize: 13, color: Color(0xFF9097A0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingBloodlinesSection extends StatelessWidget {
  const _TrendingBloodlinesSection();

  @override
  Widget build(BuildContext context) {
    const items = ['Kelso', 'Sweater', 'Hatch', 'Roundhead', 'Asil'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kExploreInset,
        12,
        _kExploreInset,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Bloodlines',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2230),
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (_, index) => _TagChip(
                label: items[index],
                selected: index == 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopFarmsSection extends StatelessWidget {
  const _TopFarmsSection();

  @override
  Widget build(BuildContext context) {
    const farms = [
      _FarmData(
        initials: 'MD',
        name: 'DLC Gamefarm',
        owner: 'Mario Dela Cruz',
        isVerified: true,
      ),
      _FarmData(initials: 'JR', name: 'Triple J Farm', owner: 'Jun Reyes'),
      _FarmData(initials: 'EG', name: 'Eagle Eye Farm', owner: 'Edwin G.'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kExploreInset,
        12,
        _kExploreInset,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Top Farms'),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              const visibleCards = 2.5;
              final cardWidth =
                  (constraints.maxWidth - (spacing * 2)) / visibleCards;

              return SizedBox(
                height: 146,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: farms.length,
                  separatorBuilder: (_, index) =>
                      const SizedBox(width: spacing),
                  itemBuilder: (_, index) =>
                      _FarmCard(data: farms[index], width: cardWidth),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsSection extends StatelessWidget {
  const _UpcomingEventsSection();

  @override
  Widget build(BuildContext context) {
    const events = [
      _EventData(
        month: 'APR',
        day: '12',
        title: 'Pampanga Provincial Derby 2026',
        location: 'San Fernando, Pampanga',
        format: '4-cock derby',
        slots: '24/32 slots',
      ),
      _EventData(
        month: 'APR',
        day: '20',
        title: 'Central Luzon Grand Slam',
        location: 'Tarlac City',
        format: '6-cock derby',
        slots: '18/24 slots',
      ),
      _EventData(
        month: 'APR',
        day: '8',
        title: 'Angeles City Invitational',
        location: 'Angeles City',
        format: '3-cock hack',
        slots: '48/48 slots',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kExploreInset,
        12,
        _kExploreInset,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Upcoming Events'),
          const SizedBox(height: 10),
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EventCard(data: event),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionTitle(title: title)),
        const Text(
          'See All',
          style: TextStyle(
            fontSize: 12,
            color: kGoldAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1F2230),
        height: 1,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF6EACC) : const Color(0xFFE7EAEE),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: selected ? kGoldAccent : const Color(0xFFDEE2E8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? const Color(0xFFA57913) : const Color(0xFF6F7680),
        ),
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  const _FarmCard({required this.data, required this.width});

  final _FarmData data;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: _kExploreSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E6EB)),
        ),
        child: Column(
          children: [
            Container(
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF1E9D4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EEDB),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE4D9B7)),
                ),
                alignment: Alignment.center,
                child: Text(
                  data.initials,
                  style: const TextStyle(
                    color: Color(0xFFA67913),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            data.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2230),
                            ),
                          ),
                        ),
                        if (data.isVerified) ...[
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Color(0xFFCFA136),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.owner,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _kExploreMutedText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF2DE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Champion',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA67913),
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
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.data});

  final _EventData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kExploreSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E6EB)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  data.month,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC38F15),
                  ),
                ),
                Text(
                  data.day,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2230),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2230),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: _kExploreMutedText,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      data.location,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kExploreMutedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MetaBadge(text: data.format),
                    const SizedBox(width: 6),
                    Text(
                      data.slots,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kExploreMutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9AA1AA)),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAEE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF6F7680),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InsetBar extends StatelessWidget {
  const _InsetBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: _kExploreInset),
      child: Divider(height: 8, thickness: 7, color: _kExploreDivider),
    );
  }
}

class _FarmData {
  const _FarmData({
    required this.initials,
    required this.name,
    required this.owner,
    this.isVerified = false,
  });

  final String initials;
  final String name;
  final String owner;
  final bool isVerified;
}

class _EventData {
  const _EventData({
    required this.month,
    required this.day,
    required this.title,
    required this.location,
    required this.format,
    required this.slots,
  });

  final String month;
  final String day;
  final String title;
  final String location;
  final String format;
  final String slots;
}
