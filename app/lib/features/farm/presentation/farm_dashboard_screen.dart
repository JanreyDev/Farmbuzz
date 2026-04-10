import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/features/farm/models/bird_model.dart';
import 'package:app/features/farm/presentation/widgets/action_button.dart';
import 'package:app/features/farm/presentation/widgets/bird_card.dart';
import 'package:app/features/farm/presentation/widgets/farm_stat_card.dart';
import 'package:flutter/material.dart';

class FarmDashboardScreen extends StatelessWidget {
  const FarmDashboardScreen({super.key});

  static const List<BirdModel> _mockBirds = [
    BirdModel(
      name: 'Black Warrior',
      breed: 'Kelso',
      age: '8 months',
      status: BirdStatus.active,
      imageUrl: 'https://picsum.photos/id/1025/400/300',
    ),
    BirdModel(
      name: 'Red Champion',
      breed: 'Hatch',
      age: '10 months',
      status: BirdStatus.sick,
      imageUrl: 'https://picsum.photos/id/433/400/300',
    ),
    BirdModel(
      name: 'Golden Ace',
      breed: 'Sweater',
      age: '12 months',
      status: BirdStatus.sold,
      imageUrl: 'https://picsum.photos/id/593/400/300',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final birds = _mockBirds;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeaderSection(),
                const SizedBox(height: 18),
                const _StatsSection(),
                const SizedBox(height: 20),
                const _QuickActionsSection(),
                const SizedBox(height: 22),
                _BirdsSection(birds: birds),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Bird'),
      ),
      bottomNavigationBar: AppBottomNav(
        activeItem: AppBottomNavItem.explore,
        onItemTap: (item) => _handleNav(context, item),
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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Menu',
          color: colorScheme.onSurface,
        ),
        const SizedBox(width: 4),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.agriculture_rounded, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Farm',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your birds and track performance',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          FarmStatCard(
            icon: Icons.pets_outlined,
            value: '48',
            label: 'Total Birds',
          ),
          SizedBox(width: 10),
          FarmStatCard(
            icon: Icons.local_fire_department_outlined,
            value: '31',
            label: 'Active Birds',
          ),
          SizedBox(width: 10),
          FarmStatCard(
            icon: Icons.hub_outlined,
            value: '12',
            label: 'Breeding Pairs',
          ),
          SizedBox(width: 10),
          FarmStatCard(
            icon: Icons.trending_down_outlined,
            value: '2.1%',
            label: 'Mortality Rate',
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          children: [
            FarmActionButton(
              icon: Icons.add_rounded,
              label: 'Add Bird',
              onTap: () {},
            ),
            FarmActionButton(
              icon: Icons.biotech_outlined,
              label: 'Breeding',
              onTap: () {},
            ),
            FarmActionButton(
              icon: Icons.vaccines_outlined,
              label: 'Health Records',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _BirdsSection extends StatelessWidget {
  const _BirdsSection({required this.birds});

  final List<BirdModel> birds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Birds',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        if (birds.isEmpty)
          const _EmptyBirdState()
        else
          ListView.separated(
            itemCount: birds.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bird = birds[index];
              return BirdCard(bird: bird, onViewDetails: () {});
            },
          ),
      ],
    );
  }
}

class _EmptyBirdState extends StatelessWidget {
  const _EmptyBirdState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets_rounded,
              size: 34,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No birds yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start building your farm records today.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.70),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Add your first bird'),
          ),
        ],
      ),
    );
  }
}

