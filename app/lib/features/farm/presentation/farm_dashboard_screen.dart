import 'package:flutter/material.dart';

const Color _kFarmBg = Color(0xFFF0F2F5);
const Color _kFarmSurface = Colors.white;
const Color _kFarmBorder = Color(0xFFE2E6EB);
const Color _kFarmMuted = Color(0xFF7C828C);

class FarmDashboardScreen extends StatelessWidget {
  const FarmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF1F2230),
                  ),
                  const Expanded(
                    child: Text(
                      'Farm Dashboard',
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
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: const Color(0xFFB68512),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: _kFarmBg,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                  children: const [
                    _StatsGrid(),
                    SizedBox(height: 10),
                    _SummaryStrip(),
                    SizedBox(height: 16),
                    _SectionTitle(title: 'Alerts'),
                    SizedBox(height: 10),
                    _AlertsList(),
                    SizedBox(height: 18),
                    _SectionTitle(title: 'Quick Actions'),
                    SizedBox(height: 10),
                    _QuickActions(),
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _StatData(
        icon: Icons.shield_outlined,
        iconColor: Color(0xFFC38F15),
        value: '24',
        label: 'Total Birds',
      ),
      _StatData(
        icon: Icons.bolt_outlined,
        iconColor: Color(0xFFE25151),
        value: '8',
        label: 'Active Fighters',
      ),
      _StatData(
        icon: Icons.favorite_border,
        iconColor: Color(0xFFE24F6B),
        value: '10',
        label: 'Brood Stock',
      ),
      _StatData(
        icon: Icons.sports_mma_outlined,
        iconColor: Color(0xFF2C75FF),
        value: '6',
        label: 'Stags',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => _StatCard(data: cards[index]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kFarmSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kFarmBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 17, color: data.iconColor),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2230),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 12,
              color: _kFarmMuted,
              fontWeight: FontWeight.w600,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _kFarmSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kFarmBorder),
      ),
      child: const Row(
        children: [
          _SummaryItem(
            value: '3',
            valueColor: Color(0xFF2FA64A),
            label: 'Recent Wins',
          ),
          _VerticalDivider(),
          _SummaryItem(
            value: '1',
            valueColor: Color(0xFFD23A3A),
            label: 'Recent Losses',
          ),
          _VerticalDivider(),
          _SummaryItem(
            value: '\u20B113,950',
            valueColor: Color(0xFFC38F15),
            label: 'Monthly Profit',
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.value,
    required this.valueColor,
    required this.label,
  });

  final String value;
  final Color valueColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: _kFarmMuted),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: const Color(0xFFE8EBEF));
  }
}

class _AlertsList extends StatelessWidget {
  const _AlertsList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _AlertRow(
          icon: Icons.bolt_outlined,
          iconColor: Color(0xFFC38F15),
          text: 'Thunder: Deworming due tomorrow',
          badge: 'WARNING',
          badgeTextColor: Color(0xFF8A7A4A),
          bgColor: Color(0xFFFBF4E3),
          badgeBgColor: Color(0xFFF1E6C9),
        ),
        SizedBox(height: 8),
        _AlertRow(
          icon: Icons.favorite_border,
          iconColor: Color(0xFF2D78FF),
          text: 'Inferno x Ruby: Hatch expected Apr 15',
          badge: 'INFO',
          badgeTextColor: Color(0xFF2D78FF),
          bgColor: Color(0xFFEAF3FF),
          badgeBgColor: Color(0xFFDDEBFF),
        ),
        SizedBox(height: 8),
        _AlertRow(
          icon: Icons.check_circle_outline,
          iconColor: Color(0xFF2EA54A),
          text: '21-Day Keep: Day 20 of 21 (Thunder)',
          badge: 'SUCCESS',
          badgeTextColor: Color(0xFF2EA54A),
          bgColor: Color(0xFFEAF7EE),
          badgeBgColor: Color(0xFFDDF1E4),
        ),
        SizedBox(height: 8),
        _AlertRow(
          icon: Icons.calendar_month_outlined,
          iconColor: Color(0xFF2D78FF),
          text: 'Pampanga Derby in 8 days',
          badge: 'INFO',
          badgeTextColor: Color(0xFF2D78FF),
          bgColor: Color(0xFFEAF3FF),
          badgeBgColor: Color(0xFFDDEBFF),
        ),
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.badge,
    required this.badgeTextColor,
    required this.bgColor,
    required this.badgeBgColor,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final String badge;
  final Color badgeTextColor;
  final Color bgColor;
  final Color badgeBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2B313B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                color: badgeTextColor,
                fontWeight: FontWeight.w700,
              ),
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
    const actions = [
      _QuickActionData(icon: Icons.monitor_heart_outlined, label: 'Log Health'),
      _QuickActionData(icon: Icons.add, label: 'Add Bird'),
      _QuickActionData(icon: Icons.my_location_outlined, label: 'Condition'),
      _QuickActionData(icon: Icons.emoji_events_outlined, label: 'Record'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions
          .map((data) => _QuickActionItem(data: data))
          .toList(growable: false),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF4E3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEADDB7)),
            ),
            child: Icon(data.icon, color: const Color(0xFFB68512), size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF5E6570),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1F2230),
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
}

class _QuickActionData {
  const _QuickActionData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
