import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';

class FarmDashboardScreen extends StatelessWidget {
  const FarmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headerSurface = theme.brightness == Brightness.light
        ? Colors.white
        : theme.cardColor;

    return Scaffold(
      backgroundColor: theme.cardColor,
      body: Column(
        children: [
          ColoredBox(
            color: headerSurface,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                      child: _Header(colorScheme: colorScheme),
                    ),
                    Container(
                      height: 1,
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: theme.cardColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                      iconColor: Color(0xFFC3912E),
                      text: 'Thunder: Deworming due tomorrow',
                      badge: 'WARNING',
                      badgeColor: Color(0xFF8D6A24),
                      bgColor: Color(0xFFF8EED7),
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.favorite_border,
                      iconColor: Color(0xFF3875CC),
                      text: 'Inferno x Ruby: Hatch expected Apr 15',
                      badge: 'INFO',
                      badgeColor: Color(0xFF2F6BC1),
                      bgColor: Color(0xFFE8F1FC),
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.check_circle_outline,
                      iconColor: Color(0xFF389A4C),
                      text: '21-Day Keep: Day 20 of 21 (Thunder)',
                      badge: 'SUCCESS',
                      badgeColor: Color(0xFF2D8F41),
                      bgColor: Color(0xFFEAF6EC),
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.calendar_month_outlined,
                      iconColor: Color(0xFF3875CC),
                      text: 'Pampanga Derby in 8 days',
                      badge: 'INFO',
                      badgeColor: Color(0xFF2F6BC1),
                      bgColor: Color(0xFFE8F1FC),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Today\'s Tasks',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '2/5',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _Header extends StatelessWidget {
  const _Header({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          visualDensity: VisualDensity.compact,
          tooltip: 'Back',
        ),
        Expanded(
          child: Text(
            'Farm Dashboard',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2230),
              height: 1,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none_outlined, color: colorScheme.primary),
          visualDensity: VisualDensity.compact,
          tooltip: 'Notifications',
        ),
      ],
    );
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
          iconColor: Color(0xFFC3912E),
          value: '24',
          label: 'Total Birds',
        ),
        _StatTile(
          icon: Icons.bolt_outlined,
          iconColor: Color(0xFFDD5252),
          value: '8',
          label: 'Active Fighters',
        ),
        _StatTile(
          icon: Icons.favorite_border,
          iconColor: Color(0xFFD85A72),
          value: '10',
          label: 'Brood Stock',
        ),
        _StatTile(
          icon: Icons.sports_mma_outlined,
          iconColor: Color(0xFF3476D8),
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

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.10)),
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
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          summaryItem('3', 'Recent Wins', const Color(0xFF2E9D43)),
          Container(
            width: 1,
            height: 28,
            color: colorScheme.onSurface.withValues(alpha: 0.10),
          ),
          summaryItem('1', 'Recent Losses', const Color(0xFFD64545)),
          Container(
            width: 1,
            height: 28,
            color: colorScheme.onSurface.withValues(alpha: 0.10),
          ),
          summaryItem('P13,950', 'Monthly Profit', const Color(0xFFC3912E)),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            badge,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
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

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.10)),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
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
