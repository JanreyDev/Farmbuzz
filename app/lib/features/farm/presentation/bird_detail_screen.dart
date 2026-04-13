import 'dart:ui';

import 'package:flutter/material.dart';

const Color _kBg = Color(0xFFF5F5F5);
const Color _kPrimary = Color(0xFF22C55E);

enum BirdHealthState { healthy, needsAttention, underTreatment }

enum BirdDetailStatus { active, sick, deceased }

enum BirdRecordType { fight, checkup, training, note }

class BirdRecordItem {
  const BirdRecordItem({
    required this.date,
    required this.type,
    required this.description,
  });

  final String date;
  final BirdRecordType type;
  final String description;
}

class BirdTimelineEvent {
  const BirdTimelineEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String date;
  final String title;
  final String description;
  final IconData icon;
}

class BirdPartnerInfo {
  const BirdPartnerInfo({
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.expectedHatchDate,
    required this.eggCount,
  });

  final String name;
  final String imageUrl;
  final String status;
  final String expectedHatchDate;
  final int eggCount;
}

class BirdDetailData {
  const BirdDetailData({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.weight,
    required this.lastCheckDate,
    required this.location,
    required this.status,
    required this.headerImageUrl,
    required this.gallery,
    required this.healthState,
    required this.healthNotes,
    required this.records,
    required this.healthLogs,
    required this.notes,
    required this.partner,
    required this.timeline,
  });

  final String id;
  final String name;
  final String breed;
  final String age;
  final String weight;
  final String lastCheckDate;
  final String location;
  final BirdDetailStatus status;
  final String headerImageUrl;
  final List<String> gallery;
  final BirdHealthState healthState;
  final String healthNotes;
  final List<BirdRecordItem> records;
  final List<BirdRecordItem> healthLogs;
  final List<BirdRecordItem> notes;
  final BirdPartnerInfo partner;
  final List<BirdTimelineEvent> timeline;
}

class BirdDetailScreen extends StatefulWidget {
  const BirdDetailScreen({required this.data, super.key});

  final BirdDetailData data;

  @override
  State<BirdDetailScreen> createState() => _BirdDetailScreenState();
}

class _BirdDetailScreenState extends State<BirdDetailScreen> {
  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF131715) : _kBg;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bg,
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: _kPrimary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _HeaderSection(data: data)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                  child: Column(
                    children: [
                      _QuickInfoCard(data: data),
                      const SizedBox(height: 12),
                      _ActionButtons(
                        onHealth: () => _toast(context, 'Log Health tapped'),
                        onCondition: () => _toast(context, 'Update Condition tapped'),
                        onRecord: () => _toast(context, 'Add Record tapped'),
                        onEdit: () => _toast(context, 'Edit Bird tapped'),
                      ),
                      const SizedBox(height: 12),
                      _HealthStatusCard(
                        data: data,
                        onViewHistory: () => _toast(context, 'Open health history'),
                      ),
                      const SizedBox(height: 12),
                      _RecordsTabs(data: data),
                      const SizedBox(height: 12),
                      _BreedingCard(data: data),
                      const SizedBox(height: 12),
                      _GallerySection(images: data.gallery),
                      const SizedBox(height: 12),
                      _TimelineSection(items: data.timeline),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: FilledButton.icon(
              onPressed: () => _toast(context, 'Bird marked for sale'),
              style: FilledButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.sell_outlined),
              label: const Text('Mark as For Sale'),
            ),
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.data});

  final BirdDetailData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            data.headerImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stackTrace) => const ColoredBox(color: Colors.black12),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x88000000), Colors.transparent, Color(0xB0000000)],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      _OverlayIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      _OverlayIconButton(
                        icon: Icons.more_horiz,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x70000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data.breed,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StatusBadge(status: data.status),
                      ],
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

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.black.withValues(alpha: 0.28),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BirdDetailStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BirdDetailStatus.active => ('Active', const Color(0xFF16A34A)),
      BirdDetailStatus.sick => ('Sick', const Color(0xFFF59E0B)),
      BirdDetailStatus.deceased => ('Deceased', const Color(0xFFDC2626)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 9, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  const _QuickInfoCard({required this.data});

  final BirdDetailData data;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Quick Info'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.3,
            children: [
              _InfoTile(label: 'Age', value: data.age),
              _InfoTile(label: 'Weight', value: data.weight),
              _InfoTile(label: 'Last Check', value: data.lastCheckDate),
              _InfoTile(label: 'Farm Location', value: data.location),
              _InfoTile(label: 'Tag ID', value: data.id),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B221E) : const Color(0xFFF8FBF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.onSurface.withValues(alpha: 0.62),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onHealth,
    required this.onCondition,
    required this.onRecord,
    required this.onEdit,
  });

  final VoidCallback onHealth;
  final VoidCallback onCondition;
  final VoidCallback onRecord;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Actions'),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ActionChip(icon: Icons.health_and_safety_outlined, label: 'Log Health', onTap: onHealth),
                _ActionChip(icon: Icons.pets_outlined, label: 'Update Condition', onTap: onCondition),
                _ActionChip(icon: Icons.bar_chart_rounded, label: 'Add Record', onTap: onRecord),
                _ActionChip(icon: Icons.edit_outlined, label: 'Edit Bird', onTap: onEdit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: _kPrimary.withValues(alpha: 0.14),
          foregroundColor: _kPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _HealthStatusCard extends StatelessWidget {
  const _HealthStatusCard({
    required this.data,
    required this.onViewHistory,
  });

  final BirdDetailData data;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final (status, color) = switch (data.healthState) {
      BirdHealthState.healthy => ('Healthy', const Color(0xFF16A34A)),
      BirdHealthState.needsAttention => ('Needs Attention', const Color(0xFFF59E0B)),
      BirdHealthState.underTreatment => ('Under Treatment', const Color(0xFF0EA5E9)),
    };

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Health Status'),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Last health check: ${data.lastCheckDate}'),
          const SizedBox(height: 4),
          Text(data.healthNotes),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onViewHistory,
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPrimary,
              side: BorderSide(color: _kPrimary.withValues(alpha: 0.65)),
            ),
            child: const Text('View Health History'),
          ),
        ],
      ),
    );
  }
}

class _RecordsTabs extends StatelessWidget {
  const _RecordsTabs({required this.data});

  final BirdDetailData data;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Activity'),
          const SizedBox(height: 10),
          TabBar(
            labelColor: _kPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
            indicatorColor: _kPrimary,
            tabs: const [
              Tab(text: 'Records'),
              Tab(text: 'Health Logs'),
              Tab(text: 'Notes'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: TabBarView(
              children: [
                _RecordList(items: data.records),
                _RecordList(items: data.healthLogs),
                _RecordList(items: data.notes),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  const _RecordList({required this.items});

  final List<BirdRecordItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1B221E)
                : const Color(0xFFF8FBF9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _recordTypeColor(item.type),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.date,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.64),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _recordTypeColor(BirdRecordType type) {
    return switch (type) {
      BirdRecordType.fight => const Color(0xFFDC2626),
      BirdRecordType.checkup => const Color(0xFF0EA5E9),
      BirdRecordType.training => const Color(0xFF16A34A),
      BirdRecordType.note => const Color(0xFF64748B),
    };
  }
}

class _BreedingCard extends StatelessWidget {
  const _BreedingCard({required this.data});

  final BirdDetailData data;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Breeding'),
          const SizedBox(height: 10),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  data.partner.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.partner.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.partner.status,
                      style: TextStyle(
                        color: _kPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _InfoTile(label: 'Expected Hatch', value: data.partner.expectedHatchDate)),
              const SizedBox(width: 8),
              Expanded(child: _InfoTile(label: 'Egg Count', value: '${data.partner.eggCount} eggs')),
            ],
          ),
        ],
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Image Gallery'),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => _BirdGalleryViewer(
                        images: images,
                        initialIndex: index,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(images[index], width: 120, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BirdGalleryViewer extends StatefulWidget {
  const _BirdGalleryViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_BirdGalleryViewer> createState() => _BirdGalleryViewerState();
}

class _BirdGalleryViewerState extends State<_BirdGalleryViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(widget.images[i], fit: BoxFit.contain),
                  ),
                );
              },
            ),
            Positioned(
              left: 8,
              right: 8,
              top: 8,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_index + 1}/${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
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
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.items});

  final List<BirdTimelineEvent> items;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Timeline'),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            return _TimelineItem(item: item, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.item,
    required this.isLast,
  });

  final BirdTimelineEvent item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 16, color: _kPrimary),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: c.onSurface.withValues(alpha: 0.12),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.date,
                    style: TextStyle(
                      color: c.onSurface.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(item.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1E1B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
