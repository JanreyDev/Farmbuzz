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

class FarmDashboardScreen extends StatelessWidget {
  const FarmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                      bgColor: Color(0xFFE8F5E9),
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.favorite_border,
                      iconColor: _kFarmPrimary,
                      text: 'Inferno x Ruby: Hatch expected Apr 15',
                      badge: 'INFO',
                      badgeColor: _kFarmPrimary,
                      bgColor: Color(0xFFEFF8F0),
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.check_circle_outline,
                      iconColor: _kFarmPrimary,
                      text: '21-Day Keep: Day 20 of 21 (Thunder)',
                      badge: 'SUCCESS',
                      badgeColor: _kFarmDark,
                      bgColor: Color(0xFFEAF6EC),
                    ),
                    const SizedBox(height: 8),
                    const _AlertRow(
                      icon: Icons.calendar_month_outlined,
                      iconColor: _kFarmPrimary,
                      text: 'Pampanga Derby in 8 days',
                      badge: 'INFO',
                      badgeColor: _kFarmPrimary,
                      bgColor: Color(0xFFEFF8F0),
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
                        color: isDark ? _kFarmCardDark : farmBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? _kFarmBorderDark
                              : colorScheme.onSurface.withValues(alpha: 0.10),
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
                              color: (isDark ? _kFarmLight : _kFarmPrimary)
                                  .withValues(alpha: 0.18),
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
        color: isDark ? _kFarmCardDark : theme.scaffoldBackgroundColor,
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
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? Color.alphaBlend(bgColor.withValues(alpha: 0.08), _kFarmCardDark)
        : bgColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? _kFarmLight : iconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.94)
                    : null,
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
            color: isDark ? _kFarmCardDark : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? _kFarmBorderDark
                  : colorScheme.onSurface.withValues(alpha: 0.10),
            ),
          ),
          child: Icon(icon, size: 20, color: isDark ? _kFarmLight : _kFarmPrimary),
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



