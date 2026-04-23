import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

import 'create_farm_view.dart';
import 'my_farm/farm_common_widgets.dart';
import 'my_farm/settings_view.dart';

class MyFarmView extends StatefulWidget {
  const MyFarmView({super.key});

  @override
  State<MyFarmView> createState() => _MyFarmViewState();
}

class _MyFarmViewState extends State<MyFarmView> {
  bool _isCreatingFarm = false;
  bool _hasFarm = false; // Set to true after creation to show dashboard

  @override
  Widget build(BuildContext context) {
    if (_isCreatingFarm) {
      return CreateFarmView(
        onBack: () => setState(() => _isCreatingFarm = false),
        onCreated: () => setState(() {
          _isCreatingFarm = false;
          _hasFarm = true;
        }),
      );
    }

    if (_hasFarm) {
      return _DashboardView();
    }

    return Container(
      color: AppColors.backgroundLight,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroBanner(),
            _FeaturesSection(onCreateRequested: () => setState(() => _isCreatingFarm = true)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _DashboardBanner(),
            const SizedBox(height: 12),
            _DashboardTabs(
              selectedIndex: _selectedTabIndex,
              onChanged: (index) => setState(() {
                _selectedTabIndex = index;
                _selectedSubTabIndex = 0; // Reset sub-tab when main tab changes
              }),
              hasSettings: true,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  int _selectedSubTabIndex = 0;

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return Column(
          children: const [
            _GetStartedCard(),
            SizedBox(height: 24),
            _PerformanceSection(),
            SizedBox(height: 24),
            _LifecycleSection(),
            SizedBox(height: 24),
            _QualitySection(),
            SizedBox(height: 24),
            _HealthSection(),
            SizedBox(height: 32),
          ],
        );
      case 1:
        return const _BreedingView();
      case 2:
        return const _FlockView();
      case 3:
        return const _TeamView();
      case 4:
        return const _ReportsView();
      case 5:
        return const FarmSettingsView();
      default:
        return const SizedBox.shrink();
    }
  }
}



class _BreedingView extends StatefulWidget {
  const _BreedingView();

  @override
  State<_BreedingView> createState() => _BreedingViewState();
}

class _BreedingViewState extends State<_BreedingView> {
  int _subTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Breeding Stats
        const _BreedingStats(),
        const SizedBox(height: 24),
        
        // Timeline
        const _BreedingTimeline(),
        const SizedBox(height: 24),

        // Sub-tabs: Full-width with Gaps
        Row(
          children: [
            Expanded(
              child: _SubTabItem(
                label: 'Collection',
                icon: Icons.inventory_2_outlined,
                count: 4,
                isActive: _subTabIndex == 0,
                onTap: () => setState(() => _subTabIndex = 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SubTabItem(
                label: 'Incubating',
                icon: Icons.timer_outlined,
                isActive: _subTabIndex == 1,
                onTap: () => setState(() => _subTabIndex = 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SubTabItem(
                label: 'Archive',
                icon: Icons.archive_outlined,
                isActive: _subTabIndex == 2,
                onTap: () => setState(() => _subTabIndex = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Action bar: Full-width
        if (_subTabIndex != 2) ...[
          Row(
            children: [
              const _ViewToggle(),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: _subTabIndex == 0 ? 'Collect eggs' : 'Start incubating',
                  icon: Icons.add,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Sub-tab Content
        if (_subTabIndex == 0) const _CollectionGrid(),
        if (_subTabIndex == 1) const _IncubatingGrid(),
        if (_subTabIndex == 2) const _ArchiveView(),
        
        const SizedBox(height: 32),
      ],
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmSectionHeader(
          label: 'BREEDING PERFORMANCE',
          title: 'Are your cycles working?',
          subtitle: 'Every 21-day cycle tells you which pairs produce and which don\'t.',
          actionLabel: 'Go to Breeding',
          onAction: () {},
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: const [
            FarmStatCard(
              title: 'FERTILITY RATE',
              value: '32%',
              icon: Icons.egg_outlined,
              color: Color(0xFF16A34A),
              iconBg: Color(0xFFE9F6EE),
              description: 'Well below average — troubleshoot.',
            ),
            FarmStatCard(
              title: 'HATCH RATE',
              value: '—',
              icon: Icons.auto_awesome_rounded,
              color: Color(0xFF16A34A),
              iconBg: Color(0xFFE9F6EE),
              description: 'Complete a full 21-day cycle to see.',
            ),
            FarmStatCard(
              title: 'SETTLING LOSS',
              value: '—',
              icon: Icons.favorite_border_rounded,
              color: Color(0xFF16A34A),
              iconBg: Color(0xFFE9F6EE),
              description: 'Needs one completed cycle with candling.',
            ),
          ],
        ),
      ],
    );
  }
}

class _LifecycleSection extends StatelessWidget {
  const _LifecycleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmSectionHeader(
          label: 'FLOCK LIFECYCLE',
          title: 'Who makes it to the next stage?',
          subtitle: 'The first 8 weeks are the deadliest. After that, most deaths are preventable.',
          actionLabel: 'Go to Flock',
          onAction: () {},
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: const [
            FarmStatCard(
              title: 'BROODING MORTALITY',
              value: '—',
              icon: Icons.home_outlined,
              color: Color(0xFF9A3412),
              iconBg: Color(0xFFFFF7ED),
              description: 'Record first chick cohort to see.',
            ),
            FarmStatCard(
              title: 'STAGE SURVIVAL',
              value: '—',
              icon: Icons.show_chart_rounded,
              color: Color(0xFF1E40AF),
              iconBg: Color(0xFFEFF6FF),
              description: 'Log your first stage transition.',
            ),
            FarmStatCard(
              title: 'CULL RATE',
              value: '—',
              icon: Icons.content_cut_rounded,
              color: Color(0xFF854D0E),
              iconBg: Color(0xFFFEFCE8),
              description: 'Needs birds to reach assessment.',
            ),
            FarmStatCard(
              title: 'TIME TO MATURITY',
              value: '—',
              icon: Icons.timer_outlined,
              color: Color(0xFF475569),
              iconBg: Color(0xFFF1F5F9),
              description: 'Needs full lifecycle completion.',
            ),
          ],
        ),
      ],
    );
  }
}

class _QualitySection extends StatelessWidget {
  const _QualitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmSectionHeader(
          label: 'QUALITY & SELECTION',
          title: 'How good is your breeding program?',
          subtitle: 'The real test isn\'t how many you raise — it\'s how many make the cut.',
          actionLabel: 'Go to Flock',
          onAction: () {},
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: const [
            FarmStatCard(
              title: 'BULL STAG RATE',
              value: '—',
              icon: Icons.military_tech_outlined,
              color: Color(0xFFB48634),
              iconBg: Color(0xFFFEFCE8),
              description: 'Needs stags graded in your farm.',
            ),
            FarmStatCard(
              title: 'BROOD PROMOTION RATE',
              value: '—',
              icon: Icons.workspace_premium_outlined,
              color: Color(0xFFB48634),
              iconBg: Color(0xFFFEFCE8),
              description: 'Needs birds promoted to brood.',
            ),
          ],
        ),
      ],
    );
  }
}

class _HealthSection extends StatelessWidget {
  const _HealthSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmSectionHeader(
          label: 'HEALTH & COMPLIANCE',
          title: 'Is the flock protected?',
          subtitle: 'Vaccination discipline and early disease detection keep your brooding mortality low.',
          actionLabel: 'See in Reports',
          onAction: () {},
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: const [
            FarmStatCard(
              title: 'VACCINATION RATE',
              value: '—',
              icon: Icons.medical_services_outlined,
              color: Color(0xFF16A34A),
              iconBg: Color(0xFFE9F6EE),
              description: 'Log a vaccination event to see.',
            ),
            FarmStatCard(
              title: 'DISEASE INCIDENCE',
              value: '—',
              icon: Icons.bug_report_outlined,
              color: Color(0xFF16A34A),
              iconBg: Color(0xFFE9F6EE),
              description: 'Log first health event to track.',
            ),
            FarmStatCard(
              title: 'AVG WEIGHT GAIN',
              value: '—',
              icon: Icons.fitness_center_outlined,
              color: Color(0xFF16A34A),
              iconBg: Color(0xFFE9F6EE),
              description: 'Log weight events to see the curve.',
            ),
          ],
        ),
      ],
    );
  }
}

class _BreedingStats extends StatelessWidget {
  const _BreedingStats();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: const [
        FarmStatCard(
          title: 'EGGS INCUBATING',
          value: '71',
          icon: Icons.egg_outlined,
          color: Color(0xFF9A3412),
          iconBg: Color(0xFFFFF7ED),
          description: '71 at stake across active cycles',
        ),
        FarmStatCard(
          title: 'AVG FERTILITY',
          value: '32%',
          icon: Icons.analytics_outlined,
          color: Color(0xFF475569),
          iconBg: Color(0xFFF1F5F9),
          description: 'Well below average — troubleshoot.',
        ),
        FarmStatCard(
          title: 'AVG YIELD',
          value: '—',
          icon: Icons.auto_awesome_rounded,
          color: Color(0xFF475569),
          iconBg: Color(0xFFF1F5F9),
          description: 'Log a hatch to see yield.',
        ),
        FarmStatCard(
          title: 'CHICK QUALITY',
          value: '—',
          icon: Icons.star_outline_rounded,
          color: Color(0xFF475569),
          iconBg: Color(0xFFF1F5F9),
          description: 'Log hatch outcomes to see quality.',
        ),
      ],
    );
  }
}

class _BreedingTimeline extends StatelessWidget {
  const _BreedingTimeline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Background Line
          Positioned(
            top: 6,
            left: 40,
            right: 40,
            child: Container(
              height: 1.5,
              color: Colors.grey[200],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _TimelineStep(
                label: 'Candling',
                days: 'DAY 1-10',
                icon: Icons.lightbulb_outline_rounded,
                color: Color(0xFFFB923C),
                iconBg: Color(0xFFFFF7ED),
              ),
              _TimelineStep(
                label: 'Settling',
                days: 'DAY 11-18',
                icon: Icons.settings_input_component_rounded,
                color: Color(0xFF475569),
                iconBg: Color(0xFFF1F5F9),
              ),
              _TimelineStep(
                label: 'Hatch',
                days: 'DAY 19-21',
                icon: Icons.egg_outlined,
                color: Color(0xFF16A34A),
                iconBg: Color(0xFFF0FDF4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.days,
    required this.icon,
    required this.color,
    required this.iconBg,
    this.isLast = false,
  });

  final String label;
  final String days;
  final IconData icon;
  final Color color;
  final Color iconBg;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hollow Circle on Line
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
          ),
        ),
        const SizedBox(height: 16),
        // Label Section below
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 10, color: color),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Text(
                  days,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.info_outline_rounded, size: 10, color: Colors.grey[300]),
          ],
        ),
      ],
    );
  }
}

class _SubTabItem extends StatelessWidget {
  const _SubTabItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.count,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.premiumGreen : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.premiumGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : Colors.grey[500],
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _ToggleItem(icon: Icons.grid_view_rounded, isActive: true),
          _ToggleItem(icon: Icons.list_rounded, isActive: false),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({required this.icon, required this.isActive});
  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive ? Colors.grey[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: isActive ? Colors.black : Colors.grey[400]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF15803D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
        label: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _CollectionGrid extends StatelessWidget {
  const _CollectionGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _CollectionCard(
          title: 'Female',
          count: 21,
          date: 'Apr 23',
          age: '0d old',
          note: '—',
        ),
        SizedBox(height: 12),
        _CollectionCard(
          title: 'Lalaki',
          count: 9,
          date: 'Apr 23',
          age: '0d old',
          note: '—',
        ),
        SizedBox(height: 12),
        _CollectionCard(
          title: 'Stag × Pullet',
          count: 10,
          date: 'Apr 23',
          age: '0d old',
          note: '2nd batch',
        ),
        SizedBox(height: 12),
        _CollectionCard(
          title: 'Cock × Hen',
          count: 21,
          date: 'Apr 23',
          age: '0d old',
          note: 'this is just a test',
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.title,
    required this.count,
    required this.date,
    required this.age,
    this.note,
  });

  final String title;
  final int count;
  final String date;
  final String age;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Egg Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FRESH',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: AppColors.premiumGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      count.toString(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'EGGS',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[400],
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Middle Section: Metadata (Cream background)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F4),
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.grey[100]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Collected $date • $age',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        'NOTE',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note ?? '—',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer: Flush Action Blocks
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          IntrinsicHeight(
            child: Row(
              children: [
                _FooterIconButton(
                  icon: Icons.edit_outlined,
                  onTap: () {},
                ),
                _FooterIconButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: () {},
                ),
                Expanded(
                  child: Material(
                    color: AppColors.premiumGreen,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Incubate $count eggs',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _FooterIconButton extends StatelessWidget {
  const _FooterIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: 18, color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}



class _GetStartedCard extends StatelessWidget {
  const _GetStartedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF0FDF4).withOpacity(0.8),
            Colors.white,
            const Color(0xFFFFF7ED).withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient top bar
          Container(
            height: 4,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF16A34A), Color(0xFFFB923C)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Get Started Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tag_rounded, size: 10, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text(
                        'GET STARTED',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.premiumGreen,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Bring your farm to life in four steps',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Each step unlocks a layer of the dashboard — vitals, Bantay AI recommendations, milestones, and benchmarks all feed off this foundation.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '0 / 4 • 0%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Steps List
                const _OnboardingStep(
                  icon: Icons.egg_rounded,
                  color: Color(0xFFB48634),
                  title: 'Start a breeding cycle',
                  description: 'Track 21 days of candling, settling, and hatch rates from a single timeline.',
                ),
                const SizedBox(height: 12),
                const _OnboardingStep(
                  icon: Icons.eco_rounded,
                  color: Color(0xFF16A34A),
                  title: 'Add your first bird',
                  description: 'Vitals, lifecycle pyramid, and flock highlights come alive once your first bird is logged.',
                ),
                const SizedBox(height: 12),
                const _OnboardingStep(
                  icon: Icons.people_rounded,
                  color: Color(0xFF475569),
                  title: 'Invite your team',
                  description: 'Your hands can log health and feed events from their phones. Every action is audited.',
                ),
                const SizedBox(height: 12),
                const _OnboardingStep(
                  icon: Icons.assignment_ind_rounded,
                  color: Color(0xFF9A3412),
                  title: 'Complete your farm profile',
                  description: 'Add a bio and registration numbers (NIPIC, BAI, LGU) for buyer-facing trust.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Completion Indicator (Circle)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.arrow_forward_rounded, color: Color(0xFF16A34A), size: 16),
        ],
      ),
    );
  }
}

class _DashboardBanner extends StatelessWidget {
  const _DashboardBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF3F1E7),
            const Color(0xFFF0FDF4).withOpacity(0.5),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FARMBUZZ - MY FARM',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Farm Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.premiumGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'T',
                          style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Test',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Greeting
          RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
              children: [
                const TextSpan(text: 'Magandang hapon, '),
                TextSpan(
                  text: 'asdad.',
                  style: TextStyle(color: AppColors.accentGreen),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thursday, April 23 • Week 17',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Info Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _BannerChip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Gamefowl',
                  color: const Color(0xFFFB923C).withOpacity(0.1),
                  iconColor: const Color(0xFFFB923C),
                ),
                const SizedBox(width: 8),
                _BannerChip(
                  icon: Icons.location_on_rounded,
                  label: 'Palawan',
                  color: Colors.grey[100]!,
                  iconColor: Colors.grey[400]!,
                ),
                const SizedBox(width: 8),
                _BannerChip(
                  icon: Icons.wb_sunny_rounded,
                  label: '29°C',
                  color: Colors.transparent,
                  iconColor: const Color(0xFFF59E0B),
                  hasBorder: false,
                ),
                const SizedBox(width: 4),
                _BannerChip(
                  icon: Icons.water_drop_rounded,
                  label: '78%',
                  color: Colors.transparent,
                  iconColor: const Color(0xFF3B82F6),
                  hasBorder: false,
                ),
                const SizedBox(width: 4),
                _BannerChip(
                  icon: Icons.air_rounded,
                  label: '73%',
                  color: Colors.transparent,
                  iconColor: const Color(0xFF6B7280),
                  hasBorder: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerChip extends StatelessWidget {
  const _BannerChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    this.hasBorder = true,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: hasBorder ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTabs extends StatelessWidget {
  const _DashboardTabs({
    required this.selectedIndex,
    required this.onChanged,
    this.hasSettings = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool hasSettings;

  final List<Map<String, dynamic>> tabs = const [
    {'label': 'Home', 'icon': Icons.home_filled},
    {'label': 'Breeding', 'icon': Icons.egg_rounded},
    {'label': 'Flock', 'icon': Icons.flutter_dash_rounded},
    {'label': 'Team', 'icon': Icons.people_alt_rounded},
    {'label': 'Reports', 'icon': Icons.bar_chart_rounded},
    {'label': 'Settings', 'icon': Icons.settings_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.premiumGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      tabs[index]['icon'],
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabs[index]['label'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.onCreateRequested});

  final VoidCallback onCreateRequested;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything you need to run a serious farm',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Full width Breeding cycles
          const _FeatureCard(
            title: 'Breeding cycles',
            description: '21-day candling, settling, hatching. Per batch and per pair fertility.',
            icon: Icons.egg_outlined,
            badge: '21-DAY',
            isFullWidth: true,
          ),
          const SizedBox(height: 12),
          
          // Grid-like layout for the rest
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: const _FeatureCard(
                    title: 'Flock management',
                    description: 'Track every bird individually, or by cohort.',
                    icon: Icons.flutter_dash_outlined,
                    badge: 'PER BIRD',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const _FeatureCard(
                    title: 'Health records',
                    description: 'Vaccinations, deworming, illness.',
                    icon: Icons.favorite_border_rounded,
                    badge: 'BAI-ALIGNED',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: const _FeatureCard(
                    title: 'Wellness programs',
                    description: '21-day conditioning plans for pre-show.',
                    icon: Icons.auto_awesome_outlined,
                    badge: '21-DAY',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const _FeatureCard(
                    title: 'QR certificates',
                    description: 'Scannable proof of lineage and health.',
                    icon: Icons.qr_code_scanner_rounded,
                    badge: 'SCANNABLE',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: const _FeatureCard(
                    title: 'Team access',
                    description: 'Invite your hands by phone.',
                    icon: Icons.people_outline_rounded,
                    badge: 'FOR YOUR TEAM',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const _FeatureCard(
                    title: 'Statistical reports',
                    description: 'Fertility, survivability, economics.',
                    icon: Icons.bar_chart_rounded,
                    badge: 'BENCHMARKS',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _CommitmentSection(onCreateRequested: onCreateRequested),
        ],
      ),
    );
  }
}

class _CommitmentSection extends StatefulWidget {
  const _CommitmentSection({required this.onCreateRequested});

  final VoidCallback onCreateRequested;

  @override
  State<_CommitmentSection> createState() => _CommitmentSectionState();
}

class _CommitmentSectionState extends State<_CommitmentSection> {
  bool _isTicked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Gradient top bar
          Container(
            height: 4,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                colors: [AppColors.accentGreen, AppColors.golden],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUR COMMITMENT',
                  style: GoogleFonts.inter(
                    color: AppColors.accentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Before you log a single bird, here's the deal",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Sub cards
                _CommitmentItem(
                  title: 'This is binding, not a demo',
                  description: 'The birds, cycles, and finances you log here are your real operation.',
                  icon: Icons.eco_outlined,
                ),
                const SizedBox(height: 12),
                _CommitmentItem(
                  title: 'Your data is always yours',
                  description: 'Export everything or delete everything, whenever you want. No exit fee.',
                  icon: Icons.lock_open_rounded,
                ),
                
                const SizedBox(height: 24),
                
                // Checkbox container
                GestureDetector(
                  onTap: () => setState(() => _isTicked = !_isTicked),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isTicked ? AppColors.accentGreen.withOpacity(0.05) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isTicked ? AppColors.accentGreen : Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _isTicked ? AppColors.accentGreen : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isTicked ? AppColors.accentGreen : Colors.grey[300]!,
                            ),
                          ),
                          child: _isTicked 
                            ? const Icon(Icons.check, size: 16, color: Colors.white) 
                            : null,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'I manage a real farm and I understand the above.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Button
                GestureDetector(
                  onTap: _isTicked ? widget.onCreateRequested : null,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _isTicked 
                        ? const LinearGradient(
                            colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                      color: _isTicked ? null : Colors.grey[200],
                      boxShadow: [
                        if (_isTicked)
                          BoxShadow(
                            color: AppColors.accentGreen.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create my first farm',
                            style: GoogleFonts.plusJakartaSans(
                              color: _isTicked ? Colors.white : Colors.grey[400],
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: _isTicked ? Colors.white : Colors.grey[400],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[500], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Takes about 2 minutes.',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Community only? Skip for now',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

class _CommitmentItem extends StatelessWidget {
  const _CommitmentItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    height: 1.4,
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.badge,
    this.isFullWidth = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String badge;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentGreen.withOpacity(0.2), width: 0.5),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: isFullWidth ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F261B),
            Color(0xFF040D08),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.02),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FARMBUZZ - MY FARM',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                ),
                const SizedBox(height: 24),
                
                // Headline
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: 'Run your farm with the precision '),
                      TextSpan(
                        text: 'your bloodlines',
                        style: TextStyle(color: AppColors.golden.withOpacity(0.9)),
                      ),
                      const TextSpan(text: ' deserve.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Subtext
                Text(
                  'The serious side of FarmBuzz. Record every cycle, trace every bloodline, measure every outcome — in one private record you actually own.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.5,
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

class _IncubatingGrid extends StatelessWidget {
  const _IncubatingGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _IncubatingCard(
          batchName: 'Apr 2026 • Barako × Inahin',
          subLabel: 'Barako × Inahin',
          day: 1,
          totalDays: 21,
          setCount: 31,
          fertileCount: 10,
          fertilePercent: '32%',
          hatchedCount: 0,
          status: 'CANDLING WINDOW',
          statusColor: Color(0xFFFB923C),
        ),
        SizedBox(height: 16),
        _IncubatingCard(
          batchName: 'Apr 2026 • Lalaki',
          subLabel: 'Lalaki',
          day: 1,
          totalDays: 21,
          setCount: 9,
          fertileCount: 0,
          hatchedCount: 0,
          status: 'CANDLING WINDOW',
          statusColor: Color(0xFFFB923C),
        ),
        SizedBox(height: 16),
        _IncubatingCard(
          batchName: 'Apr 2026 • Stag × Pullet',
          subLabel: 'Stag × Pullet',
          day: 1,
          totalDays: 21,
          setCount: 10,
          fertileCount: 0,
          hatchedCount: 0,
          status: 'CANDLING WINDOW',
          statusColor: Color(0xFFFB923C),
        ),
      ],
    );
  }
}
class _IncubatingCard extends StatelessWidget {
  const _IncubatingCard({
    required this.batchName,
    required this.subLabel,
    required this.day,
    required this.totalDays,
    required this.setCount,
    required this.fertileCount,
    required this.hatchedCount,
    this.fertilePercent,
    required this.status,
    required this.statusColor,
  });

  final String batchName;
  final String subLabel;
  final int day;
  final int totalDays;
  final int setCount;
  final int fertileCount;
  final String? fertilePercent;
  final int hatchedCount;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          // Header Section: Gradient Background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFAF8F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fireplace_rounded, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        batchName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subLabel,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: day.toString(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '/$totalDays',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${totalDays - day}d to hatch',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey[300]),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar: Thick Blocks
                Row(
                  children: List.generate(totalDays, (index) {
                    final bool isPassed = index < day;
                    final bool isLastStage = index >= 18;
                    
                    Color blockColor = Colors.grey[100]!;
                    if (isPassed) {
                      blockColor = statusColor;
                    } else if (isLastStage) {
                      blockColor = const Color(0xFFDCFCE7); // Light green
                    } else {
                      blockColor = const Color(0xFFFEF3C7).withOpacity(0.5); // Light orange/yellow
                    }

                    return Expanded(
                      child: Container(
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: blockColor,
                          borderRadius: BorderRadius.circular(4),
                          border: isPassed ? null : Border.all(color: Colors.grey[50]!),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                // Stats Row: Bordered Blocks
                Row(
                  children: [
                    _IncStat(label: 'SET', value: setCount.toString(), unit: 'eggs'),
                    const SizedBox(width: 10),
                    _IncStat(
                      label: 'FERTILE',
                      value: fertileCount.toString(),
                      subValue: fertilePercent,
                    ),
                    const SizedBox(width: 10),
                    _IncStat(label: 'HATCHED', value: hatchedCount.toString(), subValue: '—'),
                  ],
                ),
                const SizedBox(height: 20),
                // Action Buttons: Bordered
                Row(
                  children: [
                    _IncAction(icon: Icons.lightbulb_outline_rounded, label: 'Candle'),
                    const SizedBox(width: 8),
                    _IncAction(icon: Icons.thermostat_rounded, label: 'Env'),
                    const SizedBox(width: 8),
                    _IncAction(icon: Icons.auto_awesome_rounded, label: 'Hatch', isDisabled: true),
                    const Spacer(),
                    _IncAction(icon: Icons.visibility_outlined, label: 'Details', isPrimary: true),
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

class _IncStat extends StatelessWidget {
  const _IncStat({
    required this.label,
    required this.value,
    this.unit,
    this.subValue,
  });

  final String label;
  final String value;
  final String? unit;
  final String? subValue;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit!,
                      style: TextStyle(fontSize: 9, color: Colors.grey[400], fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                if (subValue != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      subValue!,
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IncAction extends StatelessWidget {
  const _IncAction({
    required this.icon,
    required this.label,
    this.isDisabled = false,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final bool isDisabled;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final Color color = isDisabled ? Colors.grey[300]! : (isPrimary ? Colors.black : Colors.grey[700]!);

    return Container(
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPrimary ? Colors.grey[200]! : (isDisabled ? Colors.grey[100]! : Colors.grey[200]!),
        ),
      ),
      child: InkWell(
        onTap: isDisabled ? null : () {},
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _ArchiveView extends StatelessWidget {
  const _ArchiveView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No archived batches yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Moved-to-brooder and cancelled cycles land here. They keep the full paper trail so you can compare seasons.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


class _FlockView extends StatefulWidget {
  const _FlockView();

  @override
  State<_FlockView> createState() => _FlockViewState();
}

class _FlockViewState extends State<_FlockView> {
  int _categoryTabIndex = 0;
  int _stageTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Flock Stats
        const _FlockStats(),
        const SizedBox(height: 24),

        // Lifecycle Timeline
        const _FlockTimeline(),
        const SizedBox(height: 24),

        // Category Sub-tabs
        Row(
          children: [
            Expanded(
              child: _SubTabItem(
                label: 'Batch',
                icon: Icons.layers_outlined,
                count: 0,
                isActive: _categoryTabIndex == 0,
                onTap: () => setState(() => _categoryTabIndex = 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SubTabItem(
                label: 'Stag / Cock',
                icon: Icons.military_tech_outlined,
                count: 0,
                isActive: _categoryTabIndex == 1,
                onTap: () => setState(() => _categoryTabIndex = 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SubTabItem(
                label: 'Pullet / Hen',
                icon: Icons.female_rounded,
                count: 0,
                isActive: _categoryTabIndex == 2,
                onTap: () => setState(() => _categoryTabIndex = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stage Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StageFilter(
                label: 'Brooder',
                icon: Icons.fireplace_rounded,
                count: 0,
                isActive: _stageTabIndex == 0,
                onTap: () => setState(() => _stageTabIndex = 0),
              ),
              const SizedBox(width: 8),
              _StageFilter(
                label: 'Range',
                icon: Icons.terrain_rounded,
                count: 0,
                isActive: _stageTabIndex == 1,
                onTap: () => setState(() => _stageTabIndex = 1),
              ),
              const SizedBox(width: 8),
              _StageFilter(
                label: 'Archive',
                icon: Icons.inventory_2_rounded,
                count: 0,
                isActive: _stageTabIndex == 2,
                onTap: () => setState(() => _stageTabIndex = 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Bar
        Row(
          children: [
            const _ViewToggle(),
            const Spacer(),
            _ActionButton(
              label: 'Add batch',
              icon: Icons.add,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Empty State
        const _FlockEmptyState(),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _FlockStats extends StatelessWidget {
  const _FlockStats();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: const [
        FarmStatCard(
          title: 'MY FLOCK',
          value: '0',
          icon: Icons.groups_rounded,
          color: Color(0xFF16A34A),
          iconBg: Color(0xFFF0FDF4),
          description: 'no birds yet',
        ),
        FarmStatCard(
          title: 'SURVIVABILITY (30D)',
          value: '—',
          icon: Icons.shield_outlined,
          color: Color(0xFF16A34A),
          iconBg: Color(0xFFF0FDF4),
          description: 'add birds to start tracking',
        ),
        FarmStatCard(
          title: 'MORTALITY (30D)',
          value: '—',
          icon: Icons.show_chart_rounded,
          color: Color(0xFF64748B),
          iconBg: Color(0xFFF8FAFC),
          description: 'nothing to measure yet',
        ),
      ],
    );
  }
}

class _FlockTimeline extends StatelessWidget {
  const _FlockTimeline();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 6,
              left: 20,
              right: 20,
              child: Container(height: 1.5, color: Colors.grey[200]),
            ),
            Row(
              children: const [
                _TimelineStep(
                  label: 'Brooder',
                  days: 'DAY 1 - 6 WKS',
                  icon: Icons.fireplace_rounded,
                  color: Color(0xFFFB923C),
                  iconBg: Color(0xFFFFF7ED),
                ),
                SizedBox(width: 40),
                _TimelineStep(
                  label: 'Range',
                  days: '6 WKS - 4 MOS',
                  icon: Icons.terrain_rounded,
                  color: Color(0xFF16A34A),
                  iconBg: Color(0xFFF0FDF4),
                ),
                SizedBox(width: 40),
                _TimelineStep(
                  label: 'Cording',
                  days: '4 MOS +',
                  icon: Icons.bolt_rounded,
                  color: Color(0xFF3B82F6),
                  iconBg: Color(0xFFEFF6FF),
                ),
                SizedBox(width: 40),
                _TimelineStep(
                  label: 'Stag',
                  days: '9 - 23 MOS',
                  icon: Icons.insights_rounded,
                  color: Color(0xFF3B82F6),
                  iconBg: Color(0xFFEFF6FF),
                ),
                SizedBox(width: 40),
                _TimelineStep(
                  label: 'Cock',
                  days: '2 - 4 YRS +',
                  icon: Icons.workspace_premium_rounded,
                  color: Color(0xFF1E3A8A),
                  iconBg: Color(0xFFEEF2FF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageFilter extends StatelessWidget {
  const _StageFilter({
    required this.label,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.premiumGreen.withOpacity(0.2) : Colors.grey[200]!,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: AppColors.premiumGreen.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.premiumGreen : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? AppColors.premiumGreen : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.premiumGreen.withOpacity(0.1) : Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isActive ? AppColors.premiumGreen : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlockEmptyState extends StatelessWidget {
  const _FlockEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_work_outlined,
              size: 32,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No brooder batches',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'New hatches land here as brooder batches, day 1 to 6 weeks.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamView extends StatelessWidget {
  const _TeamView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Team Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFAF5), Color(0xFFFFF4EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFE4D1)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFB923C).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBD805F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDD5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TEAM MANAGEMENT',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF64748B),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Just you for now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Invite by phone — we SMS them a join link. No email needed.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    label: 'Invite member',
                    icon: Icons.add_circle_outline_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Members Section
        Text(
          'Members',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Invite hands, your manager, and your vet. SMS-first — no email required.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Empty State
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  size: 32,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Invite your first teammate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hand keepers log daily food. Managers run the farm. Your vet writes health records. An accountant sees only the numbers. Each role sees only what they need.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              _ActionButton(
                label: 'Send first invite',
                icon: Icons.send_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Permission Matrix
        Text(
          'Permission matrix',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What each role can do. Tap any cell to see the rule.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 24),
        
        // Matrix Table
        const _MatrixHeader(),
        const _MatrixRow(label: 'SCOPE', values: ['OWNER', 'MANAGER', 'CARETAKER', 'VETERINARIAN', 'VIEWER'], isHeader: true),
        const Divider(height: 1),
        const _MatrixRow(label: 'Farm Settings', values: ['Full', 'Full', 'None', 'None', 'Read']),
        const _MatrixRow(label: 'Breeding Logic', values: ['Full', 'Full', 'Read', 'None', 'Read']),
        const _MatrixRow(label: 'Flock Records', values: ['Full', 'Full', 'Full', 'Read', 'Read']),
        const _MatrixRow(label: 'Health Logs', values: ['Full', 'Full', 'Full', 'Full', 'Read']),
        const _MatrixRow(label: 'Financials', values: ['Full', 'Read', 'None', 'None', 'Read']),
        const _MatrixRow(label: 'Team Mgmt', values: ['Full', 'None', 'None', 'None', 'None']),
        const SizedBox(height: 40),

        // Recent Activity
        Text(
          'Recent activity',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Every change on this farm, traceable to a person.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 24),

        // Activity Groups
        const _ActivityGroupHeader(label: 'TODAY'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            children: const [
              _ActivityItem(
                userName: 'Janrey',
                action: 'created a hatch batch',
                time: '2:21 PM',
                icon: Icons.access_time_rounded,
                isGreen: true,
              ),
              Divider(height: 1),
              _ActivityItem(
                userName: 'Janrey',
                action: 'candled a hatch batch',
                time: '2:00 PM',
                icon: Icons.access_time_rounded,
                isGreen: true,
              ),
              Divider(height: 1),
              _ActivityItem(
                userName: 'Janrey',
                action: 'collection logged',
                time: '1:58 PM',
                icon: Icons.access_time_rounded,
              ),
              Divider(height: 1),
              _ActivityItem(
                userName: 'Janrey',
                action: 'collection logged',
                time: '1:31 PM',
                icon: Icons.access_time_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const _ActivityGroupHeader(label: 'YESTERDAY'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: const _ActivityItem(
            userName: 'Janrey',
            action: 'created the farm',
            time: '11:48 AM',
            icon: Icons.access_time_rounded,
          ),
        ),
        const SizedBox(height: 32),

        // Audit Trail Banner
        const _AuditTrailBanner(),
        
        const SizedBox(height: 60),
      ],
    );
  }
}

class _ActivityGroupHeader extends StatelessWidget {
  const _ActivityGroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.grey[400],
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.userName,
    required this.action,
    required this.time,
    required this.icon,
    this.isGreen = false,
  });

  final String userName;
  final String action;
  final String time;
  final IconData icon;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isGreen ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: isGreen ? AppColors.premiumGreen : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: '$userName ',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: action,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[400],
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

class _AuditTrailBanner extends StatelessWidget {
  const _AuditTrailBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The audit trail is tamper-proof',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'When you remove a team member, their access revokes immediately. Everything they logged before removal stays — you can\'t delete history. That\'s what makes the record trustworthy to vets, buyers, and registries.',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF15803D).withOpacity(0.8),
                    height: 1.5,
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


class _MatrixHeader extends StatelessWidget {
  const _MatrixHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            'ROLE PERMISSIONS',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.grey[400],
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatrixRow extends StatelessWidget {
  const _MatrixRow({
    required this.label,
    required this.values,
    this.isHeader = false,
  });

  final String label;
  final List<String> values;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isHeader ? Colors.white : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isHeader ? FontWeight.w900 : FontWeight.w700,
                color: isHeader ? Colors.grey[400] : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: values.map((v) => _MatrixCell(value: v, isHeader: isHeader)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatrixCell extends StatelessWidget {
  const _MatrixCell({required this.value, required this.isHeader});
  final String value;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final bool isFull = value == 'Full';
    final bool isNone = value == 'None';
    
    return Container(
      width: 100,
      alignment: Alignment.center,
      child: isHeader 
        ? Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E40AF),
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isFull ? const Color(0xFFF0FDF4) : (isNone ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isFull ? AppColors.premiumGreen : (isNone ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
              ),
            ),
          ),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  int _categoryIndex = 0;
  int _scopeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reports Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFAF5), Color(0xFFFFF4EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFE4D1)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFB923C).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBD805F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDD5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'YOUR FARM IN NUMBERS',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFBD805F),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Farm name · Gamefowl metrics',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Every number updates as you log. PH benchmarks shown where available.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    label: 'Yearbook PDF',
                    icon: Icons.description_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Category Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _MetricFilterChip(
                label: 'Production',
                count: 6,
                icon: Icons.auto_awesome_rounded,
                isActive: _categoryIndex == 0,
                onTap: () => setState(() => _categoryIndex = 0),
              ),
              const SizedBox(width: 8),
              _MetricFilterChip(
                label: 'Efficiency',
                count: 3,
                icon: Icons.speed_rounded,
                isActive: _categoryIndex == 1,
                onTap: () => setState(() => _categoryIndex = 1),
              ),
              const SizedBox(width: 8),
              _MetricFilterChip(
                label: 'Risk',
                count: 5,
                icon: Icons.warning_amber_rounded,
                isActive: _categoryIndex == 2,
                onTap: () => setState(() => _categoryIndex = 2),
              ),
              const SizedBox(width: 8),
              _MetricFilterChip(
                label: 'Economics',
                count: 3,
                icon: Icons.payments_rounded,
                isActive: _categoryIndex == 3,
                onTap: () => setState(() => _categoryIndex = 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Scope Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                'SCOPE',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[400],
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 16),
              _ScopeChip(label: 'All', count: 6, isActive: _scopeIndex == 0, onTap: () => setState(() => _scopeIndex = 0)),
              const SizedBox(width: 8),
              _ScopeChip(label: 'Farm', count: 4, isActive: _scopeIndex == 1, onTap: () => setState(() => _scopeIndex = 1)),
              const SizedBox(width: 8),
              _ScopeChip(label: 'Batch', count: 2, isActive: _scopeIndex == 2, onTap: () => setState(() => _scopeIndex = 2)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Category Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDCFCE7)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Production · 6 metrics',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                    ),
                  ),
                  Text(
                    'What your farm produces — birds, eggs, hatches.',
                    style: TextStyle(fontSize: 11, color: const Color(0xFF15803D).withOpacity(0.8)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Metric Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: const [
            _MetricCard(
              title: 'FERTILITY RATE',
              badge: 'FARM',
              formula: 'Fertile eggs ÷ eggs set',
            ),
            _MetricCard(
              title: 'HATCH RATE',
              badge: 'BATCH',
              formula: 'Chicks hatched ÷ fertile eggs',
            ),
            _MetricCard(
              title: 'CHICK SURVIVAL (8WK)',
              badge: 'BATCH',
              formula: 'Chicks surviving to 8 weeks',
            ),
            _MetricCard(
              title: 'STAG → COCK RATE',
              badge: 'FARM',
              formula: 'Stags reaching cock / brood-cock selection',
            ),
            _MetricCard(
              title: 'PEDIGREE DEPTH',
              badge: 'FARM',
              formula: 'Average documented generations',
            ),
            _MetricCard(
              title: 'AUTHENTICATED FLOCK',
              badge: 'FARM',
              formula: 'Birds with active QR certificates',
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        // PH Benchmarks Header
        Text(
          'PH benchmarks',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Private, opt-in comparison to anonymized peer farms of your type + region.',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        const SizedBox(height: 20),

        // Benchmark Feature Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCFCE7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.premiumGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Know where you stand among PH breeders',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We aggregate numbers across PH farms of your type and share anonymized percentile comparisons. Your individual numbers are never shared — only medians and top-10% bands. Opt out anytime from Settings.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FarmBenchmarkAction(
                      label: 'Download card',
                      icon: Icons.file_download_outlined,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FarmBenchmarkAction(
                      label: 'Share profile',
                      icon: Icons.share_rounded,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}

class _MetricFilterChip extends StatelessWidget {
  const _MetricFilterChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.premiumGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.transparent : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : Colors.grey[500]),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.2) : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.premiumGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.transparent : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.white : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.badge,
    required this.formula,
    this.value = '—',
  });

  final String title;
  final String badge;
  final String formula;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: AppColors.premiumGreen),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[400],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              badge,
                              style: GoogleFonts.inter(
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.info_outline_rounded, size: 8, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formula,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '— 30d',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Not enough data for a trend yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


