import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Standard AppBar for controls
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.premiumGreen,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white), onPressed: () {}),
                IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
              ],
              title: innerBoxIsScrolled ? Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)) : null,
            ),
            
            // The Scrollable Header Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Photo & Logo Stack
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Cover Image
                      Image.network(
                        widget.coverUrl ?? 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1000',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Floating Logo
                      Positioned(
                        bottom: -40,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.premiumGreen,
                            child: Text(
                              widget.title.characters.first.toUpperCase(),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Club Info Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Actions Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _actionButton('Leave', Icons.logout_rounded, isOutlined: true),
                            const SizedBox(width: 8),
                            _actionButton('Manage', Icons.edit_outlined),
                          ],
                        ),
                        const SizedBox(height: 24), // Space for overlapping logo above
                        
                        // Title & Tags
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            _buildTag('BLOODLINE', const Color(0xFFF3F4F6), Colors.grey[700]!),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1,254 members • Region XIII - Caraga',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
            ),

            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
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
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Color(0xFFFEE2E2)),
            backgroundColor: const Color(0xFFFEF2F2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )
      : ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F2937),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janrey')),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Share an update with the club...', style: TextStyle(color: Colors.grey[500], fontSize: 14))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.photo_library_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 16),
                  Icon(Icons.videocam_outlined, size: 20, color: Colors.grey[600]),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[400],
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Color(0xFFE5E7EB)),
        const SizedBox(height: 16),
        Center(child: Text('No posts yet', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87))),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
