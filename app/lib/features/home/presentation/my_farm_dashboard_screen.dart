import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_config.dart';

import 'my_farm_edit_screen.dart';
import '../../../../core/theme/app_colors.dart';
import 'my_farm_setup_screen.dart';
import '../data/farm_api.dart';

class MyFarmDashboardScreen extends StatefulWidget {
  final VoidCallback onReset;

  const MyFarmDashboardScreen({super.key, required this.onReset});

  @override
  State<MyFarmDashboardScreen> createState() => _MyFarmDashboardScreenState();
}

class _MyFarmDashboardScreenState extends State<MyFarmDashboardScreen> {
  final FarmApi _farmApi = FarmApi();

  String _farmName = 'Farming Farm';
  String _tagline = 'Showcase showcase';
  String _city = '';
  String _province = '';
  int _startYear = 0;
  String _coverPhotoUrl = '';
  String _avatarUrl = '';
  String _story = '';
  String _ownerName = '';
  String _mobileNumber = '';
  List<HeritageLine> _heritageLines = const <HeritageLine>[];

  bool _isLoading = true;
  bool _isHeritageLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmData();
  }

  Future<void> _loadFarmData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobileNumber =
          prefs.getString('auth_mobile_number') ??
          prefs.getString('mobile_number');
      _mobileNumber = (mobileNumber ?? '').trim();

      if (mobileNumber != null) {
        final profile = await _farmApi.fetchFarm(mobileNumber: mobileNumber);
        if (profile != null) {
          final savedCoverFromPrefs =
              (prefs.getString('farm_cover_photo_url') ?? '').trim().isNotEmpty
              ? (prefs.getString('farm_cover_photo_url') ?? '').trim()
              : (prefs.getString('farm_cover_photo') ?? '');
          final coverFromBackend = (profile.coverPhotoUrl ?? '').trim();
          setState(() {
            _farmName = profile.name.isNotEmpty ? profile.name : 'Farming Farm';
            _tagline = profile.tagline;
            _city = profile.city;
            _province = profile.province;
            _startYear = profile.startedYear ?? 0;
            _coverPhotoUrl = coverFromBackend.isNotEmpty
                ? coverFromBackend
                : savedCoverFromPrefs;
            _avatarUrl = profile.avatarUrl ?? '';
            _story = profile.story;
            _ownerName = profile.ownerName;
            _isLoading = false;
          });
          await _loadHeritageLines();
          return;
        }
      }

      // Fallback if network fails or no profile
      setState(() {
        _farmName = prefs.getString('farm_name') ?? FallbackFarmStore.farmName;
        if (_farmName.isEmpty) _farmName = 'Farming Farm';
        _tagline =
            prefs.getString('farm_tagline') ?? FallbackFarmStore.farmTagline;
        _city = prefs.getString('farm_city') ?? FallbackFarmStore.farmCity;
        _province =
            prefs.getString('farm_province') ?? FallbackFarmStore.farmProvince;
        _startYear = prefs.getInt('farm_year') ?? FallbackFarmStore.farmYear;
        _coverPhotoUrl =
            (prefs.getString('farm_cover_photo_url') ?? '').trim().isNotEmpty
            ? (prefs.getString('farm_cover_photo_url') ?? '').trim()
            : (prefs.getString('farm_cover_photo') ?? '');
        _isLoading = false;
      });
      await _loadHeritageLines();
    } catch (_) {
      setState(() {
        _farmName = FallbackFarmStore.farmName.isEmpty
            ? 'Farming Farm'
            : FallbackFarmStore.farmName;
        _tagline = FallbackFarmStore.farmTagline;
        _city = FallbackFarmStore.farmCity;
        _province = FallbackFarmStore.farmProvince;
        _startYear = FallbackFarmStore.farmYear;
        _isLoading = false;
        _isHeritageLoading = false;
      });
    }
  }

  Future<void> _loadHeritageLines() async {
    if (_mobileNumber.isEmpty) {
      if (mounted) {
        setState(() {
          _heritageLines = const <HeritageLine>[];
          _isHeritageLoading = false;
        });
      }
      return;
    }

    try {
      final lines = await _farmApi.fetchHeritageLines(
        mobileNumber: _mobileNumber,
      );
      if (!mounted) return;
      setState(() {
        _heritageLines = lines;
        _isHeritageLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _heritageLines = const <HeritageLine>[];
        _isHeritageLoading = false;
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

  ImageProvider<Object>? _resolveCoverImage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }

    if (trimmed.startsWith('/uploads/')) {
      final base = ApiConfig.baseUrl.endsWith('/')
          ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
          : ApiConfig.baseUrl;
      return NetworkImage('$base$trimmed');
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.scheme == 'file') {
      final filePath = uri.toFilePath(windows: Platform.isWindows);
      final file = File(filePath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    final file = File(trimmed);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
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

              // ── Heritage Lines ──
              _buildHeritageLinesSection(),

              const SizedBox(height: 24),

              // ── Featured Birds ──
              _buildSectionHeader('FEATURED BIRDS'),
              const SizedBox(height: 12),
              _buildFeaturedBirdsCard(),

              const SizedBox(height: 24),

              // ── Our Story ──
              _buildInfoCard(
                title: 'OUR STORY',
                body: _story.isNotEmpty
                    ? _story
                    : 'Tell visitors about your journey. Edit from Settings.',
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _avatarUrl.isNotEmpty
                              ? NetworkImage(_avatarUrl)
                              : null,
                          child: _avatarUrl.isEmpty
                              ? const Icon(
                                  LucideIcons.user,
                                  size: 16,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _ownerName.isNotEmpty ? _ownerName : _farmName,
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
                      ],
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
                body:
                    'Add birds, log updates — activity appears here once your farm is published.',
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
    final coverImage = _resolveCoverImage(_coverPhotoUrl);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: coverImage != null
            ? DecorationImage(
                image: coverImage,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.4),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: coverImage == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0C4D22), Color(0xFF147A3B)],
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
                          const SnackBar(
                            content: Text('Share functionality coming soon!'),
                          ),
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
                        ).then((result) {
                          if (result == true) {
                            _loadFarmData();
                          }
                        });
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                          SizedBox(width: 6),
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
                        if (subtitleText.isEmpty) {
                          return const SizedBox.shrink();
                        }
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
                        style: TextStyle(color: Colors.white70, fontSize: 8),
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
            SizedBox(width: 6),
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
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.egg,
                  value: '0',
                  label: 'Total Birds',
                  subtitle: 'Across all categories',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.gitFork,
                  value: '${_heritageLines.length}',
                  label: 'Heritage Lines',
                  subtitle: 'Pure & cross',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 2: Recognitions | Chicks Hatched
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.trophy,
                  value: '0',
                  label: 'Recognitions',
                  subtitle: 'Awards & shows',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.checkCircle2,
                  value: '0',
                  label: 'Chicks Hatched',
                  subtitle: 'This year',
                ),
              ),
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
            Container(width: 8, height: 2, color: AppColors.golden),
            SizedBox(width: 6),
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
          onTap: _openHeritageManager,
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

  Widget _buildHeritageLinesSection() {
    if (_isHeritageLoading) {
      return Container(
        width: double.infinity,
        height: 170,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF8F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const CircularProgressIndicator(color: AppColors.accentGreen),
      );
    }

    if (_heritageLines.isEmpty) {
      return _buildEmptyStateCard();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._heritageLines
              .take(3)
              .map(
                (line) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEDE7DD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.name,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (line.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          line.description,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          if (_heritageLines.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+${_heritageLines.length - 3} more',
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _openHeritageManager,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentGreen,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 28),
              ),
              child: const Text(
                'Manage heritage lines',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
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
            onPressed: _openHeritageManager,
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
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

  Future<void> _openHeritageManager() async {
    if (_mobileNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again to manage heritage lines.'),
        ),
      );
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) =>
            _HeritageLinesScreen(mobileNumber: _mobileNumber, api: _farmApi),
      ),
    );

    if (changed == true) {
      await _loadHeritageLines();
    }
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
            child: const Icon(
              LucideIcons.bird,
              size: 20,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Spotlight your best birds — the ones you\'re proudest of.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature birds form coming soon!'),
                ),
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
                  'Feature birds',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

  // ── Info Card (Our Story / Achievements / Recent Activity) ──────────────────
  Widget _buildInfoCard({
    required String title,
    required String body,
    Widget? footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
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
              SizedBox(width: 6),
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
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
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
                  SizedBox(width: 6),
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
          // Empty state for gallery
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.imagePlus, size: 28, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No photos uploaded yet',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
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

  // ── Promo Card ───────────────────────────────────────────────────────────────
  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4D3E), Color(0xFF0F2922)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.golden.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PREMIUM FEATURE',
                    style: TextStyle(
                      color: AppColors.golden,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get Your Farm Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Stand out in the community and unlock advanced analytics.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification application coming soon!'),
                      ),
                    );
                  },
                  child: const Text(
                    'Apply now ->',
                    style: TextStyle(
                      color: AppColors.golden,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            LucideIcons.shieldCheck,
            size: 48,
            color: AppColors.golden,
          ),
        ],
      ),
    );
  }
}

class _HeritageLinesScreen extends StatefulWidget {
  const _HeritageLinesScreen({required this.mobileNumber, required this.api});

  final String mobileNumber;
  final FarmApi api;

  @override
  State<_HeritageLinesScreen> createState() => _HeritageLinesScreenState();
}

class _HeritageLinesScreenState extends State<_HeritageLinesScreen> {
  bool _isLoading = true;
  bool _changed = false;
  List<HeritageLine> _lines = const <HeritageLine>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final lines = await widget.api.fetchHeritageLines(
        mobileNumber: widget.mobileNumber,
      );
      if (!mounted) return;
      setState(() {
        _lines = lines;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _addLine() async {
    final result = await _showLineEditor();
    if (result == null) return;
    try {
      await widget.api.addHeritageLine(
        mobileNumber: widget.mobileNumber,
        name: result.name,
        description: result.legacyDescription,
        originFocus: result.originFocus,
        traits: result.traits,
        generationsBred: result.generationsBred,
      );
      _changed = true;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _editLine(HeritageLine line) async {
    final result = await _showLineEditor(line: line);
    if (result == null) return;
    try {
      await widget.api.updateHeritageLine(
        id: line.id,
        mobileNumber: widget.mobileNumber,
        name: result.name,
        description: result.legacyDescription,
        originFocus: result.originFocus,
        traits: result.traits,
        generationsBred: result.generationsBred,
      );
      _changed = true;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _deleteLine(HeritageLine line) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Heritage Line'),
        content: Text('Delete "${line.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await widget.api.deleteHeritageLine(
        id: line.id,
        mobileNumber: widget.mobileNumber,
      );
      _changed = true;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<_HeritageLineFormData?> _showLineEditor({HeritageLine? line}) async {
    final nameController = TextEditingController(text: line?.name ?? '');
    final originController = TextEditingController(
      text: line?.originFocus ?? '',
    );
    final traitsController = TextEditingController(text: line?.traits ?? '');
    final generationsController = TextEditingController(
      text: line?.generationsBred?.toString() ?? '',
    );
    try {
      return await showDialog<_HeritageLineFormData>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFA),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4E3D6)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 26,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xFF0E6B3A), Color(0xFF1A8A4E)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.17),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.eco_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          line == null
                              ? 'Add Heritage Line'
                              : 'Edit Heritage Line',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    'Save key details of this bloodline so your team can track it across devices.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                  child: TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _heritageInputDecoration(
                      label: 'Line name',
                      hint: 'Line name (e.g. Mountain Native Line)',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: TextField(
                    controller: originController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _heritageInputDecoration(
                      label: 'Origin or focus',
                      hint: 'Origin or focus (e.g. High egg yield, hardy)',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: TextField(
                    controller: traitsController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _heritageInputDecoration(
                      label: 'Traits',
                      hint: 'Traits, comma-separated (e.g. Hardy, Calm, Heavy)',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: TextField(
                    controller: generationsController,
                    keyboardType: TextInputType.number,
                    decoration: _heritageInputDecoration(
                      label: 'Generations bred',
                      hint: 'Generations bred (optional)',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                          ),
                          onPressed: () {
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              return;
                            }
                            final parsedGen = int.tryParse(
                              generationsController.text.trim(),
                            );
                            Navigator.of(context).pop(
                              _HeritageLineFormData(
                                name: name,
                                originFocus: originController.text.trim(),
                                traits: traitsController.text.trim(),
                                generationsBred: parsedGen,
                              ),
                            );
                          },
                          child: const Text('Save'),
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
    } finally {
      nameController.dispose();
      originController.dispose();
      traitsController.dispose();
      generationsController.dispose();
    }
  }

  InputDecoration _heritageInputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8A9590), fontSize: 13),
      labelStyle: const TextStyle(
        color: Color(0xFF1F5134),
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4DDD4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_changed),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: const Text(
          'Heritage Lines',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _addLine,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentGreen),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentGreen),
            )
          : _lines.isEmpty
          ? const Center(
              child: Text(
                'No heritage lines yet.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              itemBuilder: (context, index) {
                final line = _lines[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              line.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _editLine(line),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit',
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: () => _deleteLine(line),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Color(0xFFDC2626),
                            ),
                            tooltip: 'Delete',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      if (line.description.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            line.description,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      if (line.originFocus.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Origin/Focus: ${line.originFocus}',
                            style: const TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (line.traits.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Traits: ${line.traits}',
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      if (line.generationsBred != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Generations bred: ${line.generationsBred}',
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: _lines.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLine,
        backgroundColor: AppColors.accentGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add New Line'),
      ),
    );
  }
}

class _HeritageLineFormData {
  const _HeritageLineFormData({
    required this.name,
    required this.originFocus,
    required this.traits,
    required this.generationsBred,
  });

  final String name;
  final String originFocus;
  final String traits;
  final int? generationsBred;

  String get legacyDescription {
    if (originFocus.isNotEmpty) return originFocus;
    if (traits.isNotEmpty) return traits;
    return '';
  }
}
