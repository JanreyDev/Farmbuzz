import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/create_club_modal.dart';

class ClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> _club;

  final List<({IconData icon, String label})> _tabs = [
    (icon: LucideIcons.layoutList, label: 'Feed'),
    (icon: LucideIcons.users, label: 'Members'),
    (icon: LucideIcons.messageCircle, label: 'Chat'),
    (icon: LucideIcons.calendar, label: 'Events'),
    (icon: LucideIcons.image, label: 'Gallery'),
    (icon: LucideIcons.fileText, label: 'Rules'),
    (icon: LucideIcons.trophy, label: 'Leaderboard'),
  ];

  @override
  void initState() {
    super.initState();
    _club = widget.club;
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isFounder => (_club['role'] as String? ?? '') == 'founder';

  String get _imageUrl => (_club['imageUrl'] as String?) ?? '';

  String get _clubTitle => (_club['title'] as String?) ?? 'Club';

  int get _memberCount => (_club['memberCount'] as num?)?.toInt() ?? 0;

  String get _region => (_club['region'] as String?) ?? '';

  String get _category => (_club['category'] as String?) ?? 'Community';

  bool get _isPublic => (_club['is_public'] as bool?) ?? true;

  String get _description => (_club['description'] as String?) ?? '';

  List<String> get _focusTags {
    final tags = _club['focus_tags'];
    if (tags is List) return tags.map((e) => e.toString()).toList();
    return [];
  }

  void _openEdit() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateClubModal(initialClub: _club),
    );
    if (updated == true && mounted) {
      // Refresh would reload club data; for now, just pop back
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverHeader(innerBoxIsScrolled),
        ],
        body: Column(
          children: [
            // Club Info Card
            _buildClubInfoCard(),
            // Tab Bar
            _buildTabBar(),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedTab(),
                  _buildMembersTab(),
                  _buildComingSoonTab(LucideIcons.messageCircle, 'Club Chat', 'Chat with fellow members soon!'),
                  _buildComingSoonTab(LucideIcons.calendar, 'Events', 'Club events coming soon!'),
                  _buildComingSoonTab(LucideIcons.image, 'Gallery', 'Club gallery coming soon!'),
                  _buildRulesTab(),
                  _buildComingSoonTab(LucideIcons.trophy, 'Leaderboard', 'Member leaderboard coming soon!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.accentGreen,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        if (_isFounder)
          GestureDetector(
            onTap: _openEdit,
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.edit2, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Edit',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Photo or Gradient
            if (_imageUrl.isNotEmpty)
              Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildGradientBg(),
              )
            else
              _buildGradientBg(),
            // Bottom shadow for readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a6b3a), Color(0xFF0a3d1f)],
        ),
      ),
    );
  }

  Widget _buildClubInfoCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Club Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _clubTitle.isNotEmpty ? _clubTitle[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Club Name + Badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _clubTitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildBadge(_category, AppColors.accentGreen),
                    _buildBadge(
                      _isPublic ? 'Public' : 'Private',
                      Colors.blue.shade600,
                      icon: _isPublic ? LucideIcons.globe : LucideIcons.lock,
                    ),
                    if (_isFounder)
                      _buildBadge('Founder', Colors.orange.shade700, icon: LucideIcons.crown)
                    else
                      _buildBadge('Member', Colors.grey.shade600, icon: LucideIcons.user),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.users, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '$_memberCount member${_memberCount == 1 ? '' : 's'}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    if (_region.isNotEmpty) ...[
                      Text('  ·  ', style: TextStyle(color: Colors.grey.shade400)),
                      Icon(LucideIcons.mapPin, size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _region,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Join / Edit Button
          const SizedBox(width: 8),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_isFounder) {
      return OutlinedButton.icon(
        onPressed: _openEdit,
        icon: const Icon(LucideIcons.edit2, size: 14),
        label: const Text('Edit'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentGreen,
          side: const BorderSide(color: AppColors.accentGreen),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(LucideIcons.userCheck, size: 14),
      label: const Text('Joined'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 2),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.accentGreen,
        unselectedLabelColor: Colors.grey.shade500,
        indicatorColor: AppColors.accentGreen,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        tabs: _tabs.map((t) => Tab(
          child: Row(
            children: [
              Icon(t.icon, size: 14),
              const SizedBox(width: 6),
              Text(t.label),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ── TAB CONTENTS ──────────────────────────────────────────────────────────

  Widget _buildFeedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Description card
        if (_description.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.info, size: 16, color: AppColors.accentGreen),
                    const SizedBox(width: 8),
                    const Text(
                      'About this Club',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Stats row
        Row(
          children: [
            _buildStatCard(LucideIcons.users, '$_memberCount', 'Members', Colors.blue),
            const SizedBox(width: 12),
            _buildStatCard(LucideIcons.fileText, '${(_club['postCount'] as num?)?.toInt() ?? 0}', 'Posts', AppColors.accentGreen),
            const SizedBox(width: 12),
            _buildStatCard(
              _isPublic ? LucideIcons.globe : LucideIcons.lock,
              _isPublic ? 'Public' : 'Private',
              'Privacy',
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Bloodline tags
        if (_focusTags.isNotEmpty) ...[
          const Text(
            'Bloodline Focus',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _focusTags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Posts placeholder
        _buildEmptyFeed(),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeed() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.layoutList, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No posts yet',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Posts from club members will appear here.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Founder card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.crown, color: AppColors.accentGreen, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Founder',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87)),
                    Text('Club founder and administrator',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_memberCount member${_memberCount == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppColors.accentGreen, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(LucideIcons.users, size: 36, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Member list coming soon',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Full member directory will be available here.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesTab() {
    final minBirds = (_club['min_birds'] as num?)?.toInt() ?? 0;
    final verifiedOnly = (_club['verified_only'] as bool?) ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 18, color: AppColors.accentGreen),
                  const SizedBox(width: 8),
                  const Text('Membership Requirements',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 16),
              _buildRuleRow(
                LucideIcons.bird,
                'Minimum Birds',
                minBirds > 0 ? '$minBirds registered birds required' : 'No minimum requirement',
                minBirds > 0,
              ),
              const Divider(height: 24),
              _buildRuleRow(
                LucideIcons.badgeCheck,
                'Verified Breeders Only',
                verifiedOnly ? 'Only verified breeders can join' : 'Open to all breeders',
                verifiedOnly,
              ),
              const Divider(height: 24),
              _buildRuleRow(
                _isPublic ? LucideIcons.globe : LucideIcons.lock,
                'Visibility',
                _isPublic ? 'This club is publicly discoverable' : 'This club is private',
                !_isPublic,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleRow(IconData icon, String title, String subtitle, bool isRestricted) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isRestricted
                ? Colors.orange.shade50
                : Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isRestricted ? Colors.orange.shade600 : AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonTab(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.accentGreen.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
