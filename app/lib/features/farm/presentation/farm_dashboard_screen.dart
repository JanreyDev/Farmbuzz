import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
import 'package:app/features/farm/presentation/bird_detail_screen.dart';
import 'package:app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

const Color _kFarmBgLight = Color(0xFFF5F5F5);
const Color _kFarmBgDark = Color(0xFF121212);
const Color _kFarmCardDark = Color(0xFF1A1A1A);
const Color _kFarmBorderDark = Color(0xFF2E2E2E);
const Color _kFarmCardLight = Colors.white;
const Color _kFarmPrimary = Color(0xFF22C55E);
const Color _kFarmAccent = Color(0xFFDCFCE7);
const Color _kFarmMuted = Color(0xFF6B7280);
const _kBirdImageBlackWarrior =
    'https://images.pexels.com/photos/18846336/pexels-photo-18846336.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kBirdImageRedKelso =
    'https://images.pexels.com/photos/15235677/pexels-photo-15235677.jpeg?auto=compress&cs=tinysrgb&w=900';
const _kBirdImageGoldenHatch =
    'https://images.pexels.com/photos/13607889/pexels-photo-13607889.jpeg?auto=compress&cs=tinysrgb&w=900';

class FarmDashboardScreen extends StatefulWidget {
  const FarmDashboardScreen({super.key});

  @override
  State<FarmDashboardScreen> createState() => _FarmDashboardScreenState();
}

class _FarmDashboardScreenState extends State<FarmDashboardScreen> {
  _BirdFilter _birdFilter = _BirdFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final farmBg = isDark ? _kFarmBgDark : _kFarmBgLight;

    return Scaffold(
      backgroundColor: farmBg,
      appBar: const FarmBuzzHomeAppBar(),
      drawer: const FarmBuzzAppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatsCarousel(
              selectedFilter: _birdFilter,
              onSelectFilter: (filter) => setState(() => _birdFilter = filter),
            ),
            const SizedBox(height: 16),
            Text(
              'Alerts',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const _AlertRow(
              icon: Icons.warning_amber_rounded,
              text: 'Thunder: Deworming due tomorrow',
              badge: 'WARNING',
              kind: _AlertKind.warning,
            ),
            const SizedBox(height: 10),
            const _AlertRow(
              icon: Icons.check_circle_outline_rounded,
              text: '21-Day Keep: Day 20 of 21 (Thunder)',
              badge: 'SUCCESS',
              kind: _AlertKind.success,
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _QuickActions(
              onLogHealth: () => _showFeatureToast(context, 'Log Health'),
              onAddBird: () => _openAddBird(context),
              onCondition: () => _showFeatureToast(context, 'Update Condition'),
              onRecord: () => _showFeatureToast(context, 'Add Record'),
            ),
            const SizedBox(height: 20),
            const _TodayTasksCard(),
            const SizedBox(height: 20),
            _MyBirdsSection(
              filter: _birdFilter,
              onFilterChanged: (filter) => setState(() => _birdFilter = filter),
            ),
            const SizedBox(height: 20),
            const _BreedingStatusCard(),
            const SizedBox(height: 16),
            const _InsightCard(),
            const SizedBox(height: 20),
            Text(
              'Upcoming Events',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const _EventCard(
              icon: Icons.event_available_rounded,
              title: 'Deworming in 3 days',
              badge: 'UPCOMING',
            ),
            const SizedBox(height: 10),
            const _EventCard(
              icon: Icons.egg_alt_outlined,
              title: 'Inferno x Ruby: Hatch expected Apr 15',
              badge: 'UPCOMING',
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        activeItem: AppBottomNavItem.explore,
        onItemTap: (item) => _handleNav(context, item),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddBird(context),
        backgroundColor: _kFarmPrimary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  Future<void> _openAddBird(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.addBird);
    if (!context.mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bird saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFeatureToast(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label tapped'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatsCarousel extends StatelessWidget {
  const _StatsCarousel({
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final _BirdFilter selectedFilter;
  final ValueChanged<_BirdFilter> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _StatTile(
            icon: Icons.grid_view_rounded,
            iconColor: _kFarmPrimary,
            value: '24',
            label: 'Total Birds',
            selected: selectedFilter == _BirdFilter.all,
            onTap: () => onSelectFilter(_BirdFilter.all),
          ),
          _StatTile(
            icon: Icons.flash_on_outlined,
            iconColor: _kFarmPrimary,
            value: '8',
            label: 'Active Fighters',
            selected: selectedFilter == _BirdFilter.active,
            onTap: () => onSelectFilter(_BirdFilter.active),
          ),
          _StatTile(
            icon: Icons.egg_alt_outlined,
            iconColor: _kFarmPrimary,
            value: '10',
            label: 'Brood Stock',
            selected: selectedFilter == _BirdFilter.active,
            onTap: () => onSelectFilter(_BirdFilter.active),
          ),
          _StatTile(
            icon: Icons.sports_mma_outlined,
            iconColor: const Color(0xFFF59E0B),
            value: '6',
            label: 'Stags',
            selected: selectedFilter == _BirdFilter.sick,
            onTap: () => onSelectFilter(_BirdFilter.sick),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = selected
        ? (isDark ? _kFarmPrimary.withValues(alpha: 0.18) : _kFarmAccent)
        : (isDark ? _kFarmCardDark : _kFarmCardLight);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 150,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? _kFarmPrimary.withValues(alpha: 0.65)
                  : (isDark
                        ? _kFarmBorderDark
                        : colorScheme.onSurface.withValues(alpha: 0.08)),
            ),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AlertKind { warning, success }

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.text,
    required this.badge,
    required this.kind,
  });

  final IconData icon;
  final String text;
  final String badge;
  final _AlertKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = switch (kind) {
      _AlertKind.warning => isDark ? const Color(0xFF2A2214) : const Color(0xFFFFF7DB),
      _AlertKind.success => isDark ? const Color(0xFF16261B) : const Color(0xFFECFDF3),
    };
    final fgColor = switch (kind) {
      _AlertKind.warning => const Color(0xFFD97706),
      _AlertKind.success => const Color(0xFF16A34A),
    };

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: fgColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onLogHealth,
    required this.onAddBird,
    required this.onCondition,
    required this.onRecord,
  });

  final VoidCallback onLogHealth;
  final VoidCallback onAddBird;
  final VoidCallback onCondition;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E2420), const Color(0xFF1A1A1A)]
              : [const Color(0xFFF7FCF8), Colors.white],
        ),
        border: Border.all(
          color: isDark ? _kFarmBorderDark : const Color(0xFFE4E9EE),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: _QuickAction(
                icon: Icons.bolt_rounded,
                label: 'Log',
                subtitle: 'Health',
                onTap: onLogHealth,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _QuickAction(
                icon: Icons.add_rounded,
                label: 'Add',
                subtitle: 'Bird',
                onTap: onAddBird,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _QuickAction(
                icon: Icons.pets_outlined,
                label: 'Update',
                subtitle: 'Condition',
                onTap: onCondition,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _QuickAction(
                icon: Icons.bar_chart_rounded,
                label: 'Add',
                subtitle: 'Record',
                onTap: onRecord,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? _kFarmPrimary.withValues(alpha: 0.18) : _kFarmAccent,
              shape: BoxShape.circle,
              boxShadow: isDark
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x13000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kFarmPrimary.withValues(alpha: 0.35)),
              ),
              child: Icon(icon, size: 22, color: _kFarmPrimary),
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label\n',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                TextSpan(
                  text: subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
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

class _TodayTasksCard extends StatefulWidget {
  const _TodayTasksCard();

  @override
  State<_TodayTasksCard> createState() => _TodayTasksCardState();
}

class _TodayTasksCardState extends State<_TodayTasksCard> {
  final List<_TaskItem> _tasks = const [
    _TaskItem('Vaccinate 3 birds'),
    _TaskItem('Clean coop'),
    _TaskItem('Feed schedule (PM)'),
    _TaskItem('Check hydration logs'),
    _TaskItem('Inspect pairing pen'),
  ];
  final Set<int> _completed = <int>{0, 2};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final done = _completed.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? _kFarmBorderDark : colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today\'s Tasks',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? _kFarmPrimary.withValues(alpha: 0.18) : _kFarmAccent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$done/${_tasks.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _kFarmPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(_tasks.length, (index) {
            final checked = _completed.contains(index);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: checked
                    ? (isDark
                          ? _kFarmPrimary.withValues(alpha: 0.10)
                          : _kFarmAccent.withValues(alpha: 0.6))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CheckboxListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                value: checked,
                activeColor: _kFarmPrimary,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  _tasks[index].label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: checked ? TextDecoration.lineThrough : null,
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    if (checked) {
                      _completed.remove(index);
                    } else {
                      _completed.add(index);
                    }
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TaskItem {
  const _TaskItem(this.label);
  final String label;
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
  const _MyBirdsSection({
    required this.filter,
    required this.onFilterChanged,
  });

  final _BirdFilter filter;
  final ValueChanged<_BirdFilter> onFilterChanged;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredBirds = _birds.where((bird) {
      final matchesSearch =
          bird.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bird.bloodline.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = switch (widget.filter) {
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
        const SizedBox(height: 10),
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search your birds...',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            filled: true,
            fillColor: isDark ? _kFarmCardDark : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? _kFarmBorderDark
                    : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? _kFarmBorderDark
                    : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kFarmPrimary, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _BirdFilterBar(
          selected: widget.filter,
          onChanged: widget.onFilterChanged,
        ),
        const SizedBox(height: 10),
        if (filteredBirds.isEmpty)
          Text(
            'No birds found for this filter.',
            style: theme.textTheme.bodySmall,
          ),
        ...filteredBirds.map(
          (bird) => _BirdCard(
            bird: bird,
            onView: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BirdDetailScreen(data: _toBirdDetailData(bird)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  BirdDetailData _toBirdDetailData(_BirdItem bird) {
    final status = switch (bird.status) {
      _BirdStatus.active => BirdDetailStatus.active,
      _BirdStatus.sick => BirdDetailStatus.sick,
      _BirdStatus.deceased => BirdDetailStatus.deceased,
    };
    final healthState = switch (bird.status) {
      _BirdStatus.active => BirdHealthState.healthy,
      _BirdStatus.sick => BirdHealthState.underTreatment,
      _BirdStatus.deceased => BirdHealthState.needsAttention,
    };

    return BirdDetailData(
      id: 'FB-${bird.name.substring(0, 2).toUpperCase()}-104',
      name: bird.name,
      breed: bird.bloodline,
      age: bird.age,
      weight: bird.weight ?? '2.2 kg',
      lastCheckDate: bird.lastCheckDate ?? 'Apr 10, 2026',
      location: 'North Coop - Pen B',
      status: status,
      headerImageUrl: bird.imageUrl,
      gallery: [
        bird.imageUrl,
        _kBirdImageBlackWarrior,
        _kBirdImageRedKelso,
        _kBirdImageGoldenHatch,
      ],
      healthState: healthState,
      healthNotes: bird.status == _BirdStatus.sick
          ? 'Minor infection observed. Continue medication and isolate for 3 days.'
          : 'Vitals stable. Appetite and hydration are normal.',
      records: const [
        BirdRecordItem(
          date: 'Apr 12, 2026',
          type: BirdRecordType.training,
          description: 'Conditioning sprint completed. Recovery was excellent.',
        ),
        BirdRecordItem(
          date: 'Apr 08, 2026',
          type: BirdRecordType.fight,
          description: 'Mock sparring: strong footwork and controlled aggression.',
        ),
      ],
      healthLogs: const [
        BirdRecordItem(
          date: 'Apr 10, 2026',
          type: BirdRecordType.checkup,
          description: 'Routine checkup performed. Temperature and weight normal.',
        ),
        BirdRecordItem(
          date: 'Apr 03, 2026',
          type: BirdRecordType.checkup,
          description: 'Vaccination updated, no adverse reaction observed.',
        ),
      ],
      notes: const [
        BirdRecordItem(
          date: 'Apr 11, 2026',
          type: BirdRecordType.note,
          description: 'Prefers early morning feeding and shorter interval hydration.',
        ),
        BirdRecordItem(
          date: 'Apr 05, 2026',
          type: BirdRecordType.note,
          description: 'Responds well to hand conditioning and calm handling.',
        ),
      ],
      partner: BirdPartnerInfo(
        name: bird.name == 'Black Warrior' ? 'Ruby Feather' : 'Inferno',
        imageUrl: _kBirdImageGoldenHatch,
        status: 'Active pairing',
        expectedHatchDate: 'Apr 15, 2026',
        eggCount: 7,
      ),
      timeline: const [
        BirdTimelineEvent(
          date: 'Aug 12, 2025',
          title: 'Hatched',
          description: 'Healthy hatch from premium bloodline pair.',
          icon: Icons.egg_alt_outlined,
        ),
        BirdTimelineEvent(
          date: 'Dec 02, 2025',
          title: 'First Training',
          description: 'Started controlled movement and endurance drills.',
          icon: Icons.fitness_center_outlined,
        ),
        BirdTimelineEvent(
          date: 'Mar 21, 2026',
          title: 'Performance Record',
          description: 'Completed first competitive spar with strong form.',
          icon: Icons.emoji_events_outlined,
        ),
        BirdTimelineEvent(
          date: 'Apr 10, 2026',
          title: 'Health Review',
          description: 'Quarterly health check completed with stable vitals.',
          icon: Icons.monitor_heart_outlined,
        ),
      ],
    );
  }
}

class _BirdFilterBar extends StatelessWidget {
  const _BirdFilterBar({
    required this.selected,
    required this.onChanged,
  });

  final _BirdFilter selected;
  final ValueChanged<_BirdFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? _kFarmBorderDark : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterSegment(
              label: 'All',
              icon: Icons.grid_view_rounded,
              selected: selected == _BirdFilter.all,
              onTap: () => onChanged(_BirdFilter.all),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _FilterSegment(
              label: 'Active',
              icon: Icons.check_circle_outline_rounded,
              selected: selected == _BirdFilter.active,
              onTap: () => onChanged(_BirdFilter.active),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _FilterSegment(
              label: 'Sick',
              icon: Icons.healing_outlined,
              selected: selected == _BirdFilter.sick,
              onTap: () => onChanged(_BirdFilter.sick),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _FilterSegment(
              label: 'Deceased',
              icon: Icons.remove_circle_outline_rounded,
              selected: selected == _BirdFilter.deceased,
              onTap: () => onChanged(_BirdFilter.deceased),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fg = selected
        ? _kFarmPrimary
        : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? _kFarmPrimary.withValues(alpha: 0.18) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? _kFarmPrimary.withValues(alpha: 0.55)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BirdCard extends StatelessWidget {
  const _BirdCard({
    required this.bird,
    required this.onView,
  });

  final _BirdItem bird;
  final VoidCallback onView;

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
      _BirdStatus.active => 'Active',
      _BirdStatus.sick => 'Sick',
      _BirdStatus.deceased => 'Deceased',
    };

    return InkWell(
      onTap: onView,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? _kFarmCardDark : _kFarmCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? _kFarmBorderDark : colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                bird.imageUrl,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bird.name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bird.bloodline} • ${bird.age}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (bird.weight != null) 'Weight ${bird.weight}',
                      if (bird.lastCheckDate != null) 'Last check ${bird.lastCheckDate}',
                    ].join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.60),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: _kFarmMuted),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? _kFarmBorderDark
              : colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breeding',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'Active Pairings: 2',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Next Hatch: April 15',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: 0.64,
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE7ECF0),
              valueColor: const AlwaysStoppedAnimation<Color>(_kFarmPrimary),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.breedingPlanner),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kFarmPrimary,
                side: BorderSide(color: _kFarmPrimary.withValues(alpha: 0.8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? _kFarmPrimary.withValues(alpha: 0.16) : _kFarmAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded, color: _kFarmPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your farm is performing better than last week.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.icon,
    required this.title,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? _kFarmCardDark : _kFarmCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _kFarmBorderDark : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark ? _kFarmPrimary.withValues(alpha: 0.18) : _kFarmAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _kFarmPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _kFarmPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: theme.textTheme.labelSmall?.copyWith(
                color: _kFarmPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

