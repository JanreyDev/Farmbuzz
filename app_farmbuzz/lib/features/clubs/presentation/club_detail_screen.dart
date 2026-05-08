import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/core/session/app_session.dart';

/// A premium, high-density club detail screen.
/// Features a parallax cover image, threaded feed, and comprehensive tabbed management.
class ClubDetailScreen extends StatefulWidget {
  final String title;
  final String? coverUrl;
  final int memberCount;
  final int postCount;
  final String? region;
  final bool isPublic;
  final String role;
  final bool isJoined;

  const ClubDetailScreen({
    super.key,
    required this.title,
    this.coverUrl,
    this.memberCount = 0,
    this.postCount = 0,
    this.region,
    this.isPublic = true,
    this.role = 'member',
    this.isJoined = true,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'Feed',
    'Members',
    'Chat',
    'Events',
    'Gallery',
    'Rules',
    'Leaderboard',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocal =
        widget.coverUrl != null && !widget.coverUrl!.startsWith('http');
    final bool isOwner = widget.role.toLowerCase() == 'founder';
    final String regionLabel = (widget.region ?? '').trim().isEmpty
        ? 'Region not set'
        : widget.region!.trim();
    final String visibilityLabel = widget.isPublic ? 'Public' : 'Private';
    final Color visibilityBg =
        widget.isPublic ? const Color(0xFFECFDF5) : const Color(0xFFEEF2FF);
    final Color visibilityText =
        widget.isPublic ? const Color(0xFF059669) : const Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.premiumGreen,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: widget.coverUrl != null
                            ? DecorationImage(
                                image: isLocal
                                    ? FileImage(File(widget.coverUrl!))
                                        as ImageProvider
                                    : NetworkImage(widget.coverUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        gradient: widget.coverUrl == null
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.premiumGreen,
                                  Color(0xFF059669),
                                ],
                              )
                            : null,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppColors.premiumGreen,
                                  child: Text(
                                    widget.title.characters.first.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatNumber(widget.memberCount)} members - $regionLabel',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final tags = Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildTag(
                                    visibilityLabel,
                                    visibilityBg,
                                    visibilityText,
                                  ),
                                  _buildTag(
                                    isOwner
                                        ? 'Founder'
                                        : (widget.isJoined ? 'Member' : 'Visitor'),
                                    isOwner
                                        ? const Color(0xFFFFF7ED)
                                        : const Color(0xFFF1F5F9),
                                    isOwner
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF475569),
                                  ),
                                  _buildTag(
                                    '${_formatNumber(widget.postCount)} posts',
                                    const Color(0xFFF8FAFC),
                                    const Color(0xFF334155),
                                  ),
                                ],
                              );

                              final isCompact = MediaQuery.of(context).size.width < 390;
                              if (isCompact) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeaderActions(isOwner),
                                    const SizedBox(height: 10),
                                    tags,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: tags),
                                  const SizedBox(width: 12),
                                  _buildHeaderActions(isOwner),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                title: innerBoxIsScrolled
                    ? Text(
                        widget.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
                titlePadding: const EdgeInsets.only(left: 56, bottom: 64),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppColors.premiumGreen,
                    indicatorWeight: 3,
                    labelColor: AppColors.premiumGreen,
                    unselectedLabelColor: Colors.grey[500],
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeedTab(),
            ...List.generate(
              _tabs.length - 1,
              (index) => Center(child: Text(_tabs[index + 1])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, {bool isOutlined = false}) {
    return isOutlined
        ? OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(icon, size: 16),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              backgroundColor: Colors.black.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(icon, size: 16),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
  }

  Widget _buildHeaderActions(bool isOwner) {
    final actions = isOwner
        ? const [
            ('Insights', Icons.auto_graph_rounded, true),
            ('Manage', Icons.tune_rounded, false),
          ]
        : widget.isJoined
            ? const [
                ('Joined', Icons.check_circle_outline, true),
                ('Leave', Icons.logout_rounded, false),
              ]
            : const [
                ('Join', Icons.person_add_alt_1_rounded, true),
              ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = MediaQuery.of(context).size.width < 430;
        if (isCompact) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions.map((entry) {
              return _iconActionButton(
                entry.$1,
                entry.$2,
                isOutlined: entry.$3,
              );
            }).toList(),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: actions.map((entry) {
            return _actionButton(
              entry.$1,
              entry.$2,
              isOutlined: entry.$3,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _iconActionButton(String tooltip, IconData icon, {bool isOutlined = false}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isOutlined
              ? Colors.black.withValues(alpha: 0.22)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: isOutlined
              ? Border.all(color: Colors.white.withValues(alpha: 0.45))
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isOutlined ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  Widget _buildFeedTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: AppSession.avatarUrl.isNotEmpty ? NetworkImage(AppSession.avatarUrl) : null,
                    child: AppSession.avatarUrl.isEmpty 
                      ? Text(AppSession.userName.isNotEmpty ? AppSession.userName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 12)) 
                      : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Share an update with the club...',
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 20,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.videocam_outlined,
                    size: 20,
                    color: Colors.grey[500],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[50],
                      foregroundColor: Colors.grey[400],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Post',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        const Icon(
          Icons.chat_bubble_outline_rounded,
          size: 64,
          color: Color(0xFFF3F4F6),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'No posts yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.grey[300],
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
