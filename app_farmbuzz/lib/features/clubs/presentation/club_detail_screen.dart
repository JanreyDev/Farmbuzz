import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

/// A premium, high-density club detail screen.
/// Features a parallax cover image, threaded feed, and comprehensive tabbed management.
class ClubDetailScreen extends StatefulWidget {
  final String title;
  final String? coverUrl;

  const ClubDetailScreen({
    super.key,
    required this.title,
    this.coverUrl,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Feed', 'Members', 'Chat', 'Events', 'Gallery', 'Rules', 'Leaderboard'];

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
    final bool isLocal = widget.coverUrl != null && !widget.coverUrl!.startsWith('http');

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
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white), onPressed: () {}),
                IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Image
                    Container(
                      decoration: BoxDecoration(
                        image: widget.coverUrl != null
                            ? DecorationImage(
                                image: isLocal 
                                    ? FileImage(File(widget.coverUrl!)) as ImageProvider
                                    : NetworkImage(widget.coverUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        gradient: widget.coverUrl == null
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.premiumGreen, Color(0xFF059669)],
                              )
                            : null,
                      ),
                    ),
                    // Gradients
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    // Club Info Overlay
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
                                      color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _actionButton('Leave', Icons.logout_rounded, isOutlined: true),
                              const SizedBox(width: 8),
                              _actionButton('Manage', Icons.edit_outlined),
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
                            '1,254 members • Region XIII - Caraga',
                            style: GoogleFonts.inter(
                              fontSize: 13, 
                              color: Colors.white.withOpacity(0.9), 
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildTag('Public', const Color(0xFFECFDF5), const Color(0xFF059669)),
                              _buildTag('Founder', const Color(0xFFFFF7ED), const Color(0xFFD97706)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                title: innerBoxIsScrolled 
                    ? Text(widget.title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)) 
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
                    labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
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
            ...List.generate(_tabs.length - 1, (index) => Center(child: Text(_tabs[index + 1]))),
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
            side: BorderSide(color: Colors.white.withOpacity(0.5)),
            backgroundColor: Colors.black.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
  }

  Widget _buildTag(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.inter(color: text, fontSize: 11, fontWeight: FontWeight.w800)),
    );
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
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janrey')),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Share an update with the club...', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.photo_library_outlined, size: 20, color: Colors.grey[500]),
                  const SizedBox(width: 16),
                  Icon(Icons.videocam_outlined, size: 20, color: Colors.grey[500]),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[50],
                      foregroundColor: Colors.grey[400],
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Post', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Color(0xFFF3F4F6)),
        const SizedBox(height: 16),
        Center(child: Text('No posts yet', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.grey[300]))),
        const SizedBox(height: 100),
      ],
    );
  }
}
