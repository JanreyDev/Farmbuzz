import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_farm_edit_screen.dart';
import '../../../../core/theme/app_colors.dart';
import 'my_farm_setup_screen.dart';

class MyFarmDashboardScreen extends StatefulWidget {
  final VoidCallback onReset;

  const MyFarmDashboardScreen({super.key, required this.onReset});

  @override
  State<MyFarmDashboardScreen> createState() => _MyFarmDashboardScreenState();
}

class _MyFarmDashboardScreenState extends State<MyFarmDashboardScreen> {
  String _farmName = 'Farming Farm';
  String _tagline = 'Showcase showcase';
  String _city = '';
  String _province = '';
  int _startYear = 0;
  String _coverPhotoPath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmData();
  }

  Future<void> _loadFarmData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _farmName = prefs.getString('farm_name') ?? 'Farming Farm';
        _tagline = prefs.getString('farm_tagline') ?? 'Showcase showcase';
        _city = prefs.getString('farm_city') ?? '';
        _province = prefs.getString('farm_province') ?? '';
        _startYear = prefs.getInt('farm_year') ?? 0;
        _coverPhotoPath = prefs.getString('farm_cover_photo') ?? '';
        _isLoading = false;
      });
    } catch (_) {
      // Fallback if SharedPreferences isn't compiled/linked yet
      setState(() {
        _farmName = FallbackFarmStore.farmName.isEmpty ? 'Farming Farm' : FallbackFarmStore.farmName;
        _tagline = FallbackFarmStore.farmTagline;
        _city = FallbackFarmStore.farmCity;
        _province = FallbackFarmStore.farmProvince;
        _startYear = FallbackFarmStore.farmYear;
        _isLoading = false;
      });
    }
  }

  int get _yearsOperating {
    if (_startYear <= 0) return 0;
    final currentYear = DateTime.now().year;
    final diff = currentYear - _startYear;
    return diff < 0 ? 0 : diff;
  }

  String get _location {
    if (_city.isEmpty && _province.isEmpty) return 'Location not set';
    if (_city.isEmpty) return _province;
    if (_province.isEmpty) return _city;
    return '$_city, $_province';
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Green Header Card ──
              _buildHeaderCard(),

              const SizedBox(height: 16),

              // ── Statistics Row ──
              _buildStatsRow(),

              const SizedBox(height: 24),

              // ── Section Title ──
              _buildSectionHeader('HERITAGE LINES'),

              const SizedBox(height: 12),

              // ── Heritage Lines Empty State ──
              _buildEmptyStateCard(),

              const SizedBox(height: 24),

              // ── Featured Birds ──
              _buildSectionHeader('FEATURED BIRDS'),
              const SizedBox(height: 12),
              _buildFeaturedBirdsCard(),

              const SizedBox(height: 24),

              // ── Our Story ──
              _buildInfoCard(
                title: 'OUR STORY',
                body: 'Tell visitors about your journey. Edit from Settings.',
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _farmName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Text(
                      'Founder & Breeder',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Achievements ──
              _buildInfoCard(
                title: 'ACHIEVEMENTS',
                body: 'Add your show awards and recognitions from Settings.',
              ),

              const SizedBox(height: 10),

              // ── Recent Activity ──
              _buildInfoCard(
                title: 'RECENT ACTIVITY',
                body: 'Add birds, log updates — activity appears here once your farm is published.',
              ),

              const SizedBox(height: 24),

              // ── Farm Gallery ──
              _buildFarmGalleryCard(),

              const SizedBox(height: 10),

              // ── Promo Card ──
              _buildPromoCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: _coverPhotoPath.isNotEmpty
            ? DecorationImage(
                image: FileImage(File(_coverPhotoPath)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
              )
            : null,
        gradient: _coverPhotoPath.isEmpty
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0C4D22),
                  Color(0xFF147A3B),
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content Layout
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildHeaderButton(
                      icon: LucideIcons.share2,
                      label: 'Share',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share functionality coming soon!')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildHeaderButton(
                      icon: LucideIcons.edit2,
                      label: 'Edit',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyFarmEditScreen(),
                          ),
                        ).then((_) => _loadFarmData());
                      },
                    ),
                  ],
                ),

                // Farm Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pill label
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.golden,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _farmName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Farm Name
                    Text(
                      _farmName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final subtitleParts = <String>[];
                        final loc = _location;
                        if (loc.isNotEmpty && loc != 'Location not set') {
                          subtitleParts.add(loc);
                        }
                        if (_tagline.isNotEmpty) {
                          subtitleParts.add(_tagline);
                        }
                        final subtitleText = subtitleParts.join(' · ');
                        if (subtitleText.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Followers Badge
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.users, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Followers',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Column(
      children: [
        // Row 1: Total Birds | Heritage Lines
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildStatCard(
                icon: LucideIcons.egg,
                value: '0',
                label: 'Total Birds',
                subtitle: 'Across all categories',
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(
                icon: LucideIcons.gitFork,
                value: '0',
                label: 'Heritage Lines',
                subtitle: 'Pure & cross',
              )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 2: Recognitions | Chicks Hatched
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildStatCard(
                icon: LucideIcons.trophy,
                value: '0',
                label: 'Recognitions',
                subtitle: 'Awards & shows',
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(
                icon: LucideIcons.checkCircle2,
                value: '0',
                label: 'Chicks Hatched',
                subtitle: 'This year',
              )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 3: Years Operating — full width
        _buildStatCard(
          icon: LucideIcons.calendar,
          value: '$_yearsOperating',
          label: 'Years Operating',
          subtitle: _startYear > 0 ? 'Since $_startYear' : 'Set start year',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    bool fullWidth = false,
  }) {
    final cardWidth = fullWidth 
        ? double.infinity 
        : (MediaQuery.of(context).size.width - 32 - 10) / 2;
    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFC99843), // Golden top border
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2), // Border thickness
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.accentGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 2,
              color: AppColors.golden,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Manage Heritage Lines coming soon!')),
            );
          },
          child: const Text(
            'Manage >',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.accentGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.gitFork,
              size: 20,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Showcase your signature breeding lines — the heritage your farm is known for.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add heritage line form coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add heritage lines',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Icon(LucideIcons.chevronRight, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Featured Birds ─────────────────────────────────────────────────────────
  Widget _buildFeaturedBirdsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bird, size: 20, color: AppColors.accentGreen),
          ),
          const SizedBox(height: 14),
          Text(
            'Spotlight your best birds — the ones you\'re proudest of.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature birds form coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Feature birds', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Icon(LucideIcons.chevronRight, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card (Our Story / Achievements / Recent Activity) ──────────────────
  Widget _buildInfoCard({
    required String title,
    required String body,
    Widget? footer,
  }) {
    return Container(
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
              Container(width: 8, height: 2, color: AppColors.golden),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.5),
          ),
          if (footer != null) ...[const SizedBox(height: 12), footer],
        ],
      ),
    );
  }

  // ── Farm Gallery ─────────────────────────────────────────────────────────────
  Widget _buildFarmGalleryCard() {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 2, color: AppColors.golden),
                  const SizedBox(width: 6),
                  const Text(
                    'FARM GALLERY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo upload coming soon!')),
                  );
                },
                child: const Text(
                  'Add photos >',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _DashRectPainter(color: Colors.grey.shade400),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(LucideIcons.camera, size: 24, color: Colors.grey.shade500),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload Farm Photos',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload will land next session',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Promo Card ───────────────────────────────────────────────────────────────
  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C4D22), Color(0xFF1A7A40)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.egg, size: 18, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text(
            'Quality Birds.\nTrusted Lineage.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Showcase your best birds to keepers and breeders across the community.',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

}

class _DashRectPainter extends CustomPainter {
  final Color color;

  _DashRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    
    // Draw top line
    _drawDashedLine(canvas, paint, const Offset(0, 0), Offset(size.width, 0), dashWidth, dashSpace);
    // Draw right line
    _drawDashedLine(canvas, paint, Offset(size.width, 0), Offset(size.width, size.height), dashWidth, dashSpace);
    // Draw bottom line
    _drawDashedLine(canvas, paint, Offset(size.width, size.height), Offset(0, size.height), dashWidth, dashSpace);
    // Draw left line
    _drawDashedLine(canvas, paint, Offset(0, size.height), const Offset(0, 0), dashWidth, dashSpace);
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end, double dashWidth, double dashSpace) {
    double distance = (end - start).distance;
    double currentDistance = 0;
    final direction = (end - start) / distance;
    
    while (currentDistance < distance) {
      final endDistance = (currentDistance + dashWidth).clamp(0.0, distance);
      canvas.drawLine(
        start + direction * currentDistance,
        start + direction * endDistance,
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
