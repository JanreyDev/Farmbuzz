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

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  late Map<String, dynamic> _club;

  @override
  void initState() {
    super.initState();
    _club = widget.club;
  }

  @override
  void dispose() {
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
            // Single View Content (Feed)
            Expanded(
              child: _buildFeedTab(),
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


}
