import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
import 'package:app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

const Color _kFarmBgLight = Color(0xFFF5F5F5);
const Color _kFarmBgDark = Color(0xFF1F1F1F);
const Color _kFarmCardDark = Color(0xFF242628);
const Color _kFarmBorderDark = Color(0xFF35383D);
const Color _kFarmCardLight = Color(0xFFE8F5E9);
const Color _kFarmPrimary = Color(0xFF2E7D32);
const Color _kFarmDark = Color(0xFF1B5E20);
const Color _kFarmLight = Color(0xFF66BB6A);
const _kBirdImageBlackWarrior =
    'https://images.pexels.com/photos/18846336/pexels-photo-18846336.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kBirdImageRedKelso =
    'https://images.pexels.com/photos/15235677/pexels-photo-15235677.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kBirdImageGoldenHatch =
    'https://images.pexels.com/photos/13607889/pexels-photo-13607889.jpeg?auto=compress&cs=tinysrgb&w=900';

class FarmDashboardScreen extends StatelessWidget {
  const FarmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final farmBg = isDark ? _kFarmBgDark : _kFarmBgLight;

    return Scaffold(
      backgroundColor: farmBg,
      appBar: const FarmBuzzHomeAppBar(),
      drawer: const FarmBuzzAppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: farmBg,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StatsGrid(),
                    const SizedBox(height: 10),
                    const _SummaryStrip(),
                    const SizedBox(height: 14),
                    Text(
                      'Alerts',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.bolt_outlined,
                      iconColor: _kFarmDark,
                      text: 'Thunder: Deworming due tomorrow',
                      badge: 'WARNING',
                      badgeColor: _kFarmDark,
                      bgColor: _kFarmCardLight,
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.check_circle_outline,
                      iconColor: _kFarmPrimary,
                      text: '21-Day Keep: Day 20 of 21 (Thunder)',
                      badge: 'SUCCESS',
                      badgeColor: _kFarmDark,
                      bgColor: _kFarmCardLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _QuickActions(),
                    const SizedBox(height: 16),
                    const _TodayTasksCard(),
                    const SizedBox(height: 16),
                    const _MyBirdsSection(),
                    const SizedBox(height: 16),
                    const _BreedingStatusCard(),
                    const SizedBox(height: 16),
                    const _InsightCard(),
                    const SizedBox(height: 16),
                    Text(
                      'Upcoming Events',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.bolt_outlined,
                      iconColor: _kFarmDark,
                      text: 'Deworming in 3 days',
                      badge: 'UPCOMING',
                      badgeColor: _kFarmDark,
                      bgColor: _kFarmCardLight,
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.favorite_border,
                      iconColor: _kFarmPrimary,
                      text: 'Inferno x Ruby: Hatch expected Apr 15',
                      badge: 'UPCOMING',
                      badgeColor: _kFarmPrimary,
                      bgColor: _kFarmCardLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppBottomNav(
            activeItem: AppBottomNavItem.explore,
            onItemTap: (item) => _handleNav(context, item),
          ),
        ],
      ),
    );
  }

  void _handleNav(BuildContext context, AppBottomNavItem item) {
    if (item == AppBottomNavItem.home) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (item == AppBottomNavItem.explore) {
      return;
    } else if (item == AppBottomNavItem.market) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.marketplace);
    } else if (item == AppBottomNavItem.create) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.groups);
    } else if (item == AppBottomNavItem.profile) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
    }
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      children: const [
        _StatTile(
          icon: Icons.shield_outlined,
          iconColor: _kFarmDark,
          value: '24',
          label: 'Total Birds',
        ),
        _StatTile(
          icon: Icons.bolt_outlined,
          iconColor: _kFarmPrimary,
          value: '8',
          label: 'Active Fighters',
        ),
        _StatTile(
          icon: Icons.favorite_border,
          iconColor: _kFarmLight,
          value: '10',
          label: 'Brood Stock',
        ),
        _StatTile(
          icon: Icons.sports_mma_outlined,
          iconColor: _kFarmDark,
          value: '6',
          label: 'Stags',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? _kFarmBorderDark
              : colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Widget summaryItem(String value, String label, Color valueColor) {
      return Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? _kFarmBorderDark
              : colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          summaryItem('3', 'Recent Wins', _kFarmPrimary),
          Container(
            width: 1,
            height: 28,
            color: colorScheme.onSurface.withValues(alpha: 0.10),
          ),
          summaryItem('1', 'Recent Losses', _kFarmLight),
          Container(
            width: 1,
            height: 28,
            color: colorScheme.onSurface.withValues(alpha: 0.10),
          ),
          summaryItem('P13,950', 'Monthly Profit', _kFarmDark),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.badge,
    required this.badgeColor,
    required this.bgColor,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final String badge;
  final Color badgeColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? _kFarmCardDark : bgColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? _kFarmBorderDark
              : colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isDark ? _kFarmLight : iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withValues(alpha: 0.94) : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            badge,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? _kFarmLight : badgeColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _QuickAction(icon: Icons.bolt_outlined, label: 'Log Health'),
        _QuickAction(icon: Icons.add, label: 'Add Bird'),
        _QuickAction(icon: Icons.adjust, label: 'Condition'),
        _QuickAction(icon: Icons.bookmark_border, label: 'Record'),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? _kFarmCardDark : _kFarmCardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? _kFarmBorderDark
                  : colorScheme.onSurface.withValues(alpha: 0.10),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? _kFarmLight : _kFarmPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.70),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TodayTasksCard extends StatelessWidget {
  const _TodayTasksCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Widget taskItem(String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              Icons.radio_button_unchecked,
              size: 16,
              color: isDark ? _kFarmLight : _kFarmPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? _kFarmBorderDark
              : colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today\'s Tasks',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? _kFarmLight : _kFarmPrimary).withValues(
                    alpha: 0.18,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '2/5',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? _kFarmLight : _kFarmPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          taskItem('Vaccinate 3 birds'),
          taskItem('Clean coop'),
          taskItem('Feed schedule (PM)'),
        ],
      ),
    );
  }
}

enum _BirdStatus { active, sick, deceased }

enum _BirdFilter { all, active, sick, deceased }

class _BirdItem {
  const _BirdItem({
    required this.name,
    required this.bloodline,
    required this.age,
    required this.status,
    required this.imageUrl,
    this.weight,
    this.lastCheckDate,
  });

  final String name;
  final String bloodline;
  final String age;
  final _BirdStatus status;
  final String imageUrl;
  final String? weight;
  final String? lastCheckDate;
}

class _MyBirdsSection extends StatefulWidget {
  const _MyBirdsSection();

  @override
  State<_MyBirdsSection> createState() => _MyBirdsSectionState();
}

class _MyBirdsSectionState extends State<_MyBirdsSection> {
  final List<_BirdItem> _birds = const [
    _BirdItem(
      name: 'Black Warrior',
      bloodline: 'Kelso',
      age: '8 months',
      status: _BirdStatus.active,
      imageUrl: _kBirdImageBlackWarrior,
      weight: '2.3 kg',
      lastCheckDate: 'Apr 10',
    ),
    _BirdItem(
      name: 'Red Kelso',
      bloodline: 'Kelso',
      age: '7 months',
      status: _BirdStatus.sick,
      imageUrl: _kBirdImageRedKelso,
      weight: '2.1 kg',
      lastCheckDate: 'Apr 9',
    ),
    _BirdItem(
      name: 'Golden Hatch',
      bloodline: 'Hatch',
      age: '9 months',
      status: _BirdStatus.deceased,
      imageUrl: _kBirdImageGoldenHatch,
      lastCheckDate: 'Mar 28',
    ),
  ];

  String _searchQuery = '';
  _BirdFilter _filter = _BirdFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredBirds = _birds.where((bird) {
      final matchesSearch =
          bird.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bird.bloodline.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = switch (_filter) {
        _BirdFilter.all => true,
        _BirdFilter.active => bird.status == _BirdStatus.active,
        _BirdFilter.sick => bird.status == _BirdStatus.sick,
        _BirdFilter.deceased => bird.status == _BirdStatus.deceased,
      };
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Birds',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search your birds...',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            filled: true,
            fillColor: isDark ? _kFarmCardDark : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? _kFarmBorderDark
                    : _kFarmPrimary.withValues(alpha: 0.45),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? _kFarmBorderDark
                    : _kFarmPrimary.withValues(alpha: 0.45),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kFarmPrimary, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter == _BirdFilter.all,
                onTap: () => setState(() => _filter = _BirdFilter.all),
              ),
              _FilterChip(
                label: 'Active',
                selected: _filter == _BirdFilter.active,
                onTap: () => setState(() => _filter = _BirdFilter.active),
              ),
              _FilterChip(
                label: 'Sick',
                selected: _filter == _BirdFilter.sick,
                onTap: () => setState(() => _filter = _BirdFilter.sick),
              ),
              _FilterChip(
                label: 'Deceased',
                selected: _filter == _BirdFilter.deceased,
                onTap: () => setState(() => _filter = _BirdFilter.deceased),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (filteredBirds.isEmpty)
          Text(
            'No birds found for this filter.',
            style: theme.textTheme.bodySmall,
          ),
        ...filteredBirds.map((bird) => _BirdCard(bird: bird)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: (isDark ? _kFarmLight : _kFarmPrimary).withValues(
          alpha: 0.20,
        ),
        side: BorderSide.none,
      ),
    );
  }
}

class _BirdCard extends StatelessWidget {
  const _BirdCard({required this.bird});

  final _BirdItem bird;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final statusColor = switch (bird.status) {
      _BirdStatus.active => _kFarmPrimary,
      _BirdStatus.sick => const Color(0xFFF57C00),
      _BirdStatus.deceased => const Color(0xFFD32F2F),
    };
    final statusLabel = switch (bird.status) {
      _BirdStatus.active => 'Active (Ready)',
      _BirdStatus.sick => 'Sick (Needs attention)',
      _BirdStatus.deceased => 'Deceased (Archived)',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? _kFarmBorderDark
              : colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              bird.imageUrl,
              width: 74,
              height: 74,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bird.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${bird.bloodline} • ${bird.age}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (bird.weight != null || bird.lastCheckDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (bird.weight != null) 'Weight: ${bird.weight}',
                      if (bird.lastCheckDate != null)
                        'Last check: ${bird.lastCheckDate}',
                    ].join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      'Status: $statusLabel',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _kFarmPrimary,
                side: BorderSide(
                  color: isDark
                      ? _kFarmLight.withValues(alpha: 0.65)
                      : _kFarmPrimary.withValues(alpha: 0.60),
                ),
                backgroundColor: isDark
                    ? _kFarmPrimary.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.65),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreedingStatusCard extends StatelessWidget {
  const _BreedingStatusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? _kFarmBorderDark
              : colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breeding',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Active Pairings: 2',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Next Hatch: Apr 15',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.breedingPlanner),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kFarmPrimary,
                side: const BorderSide(color: _kFarmPrimary),
              ),
              child: const Text('Manage Breeding'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? _kFarmBorderDark
              : colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: isDark ? _kFarmLight : _kFarmPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your farm is performing better than last week.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
