import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  List<FeaturedBird> _featuredBirds = const <FeaturedBird>[];

  bool _isLoading = true;
  bool _isHeritageLoading = true;
  bool _isFeaturedBirdsLoading = true;

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
          await Future.wait<void>([_loadHeritageLines(), _loadFeaturedBirds()]);
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
      await Future.wait<void>([_loadHeritageLines(), _loadFeaturedBirds()]);
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
        _isFeaturedBirdsLoading = false;
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

  Future<void> _loadFeaturedBirds() async {
    if (_mobileNumber.isEmpty) {
      if (mounted) {
        setState(() {
          _featuredBirds = const <FeaturedBird>[];
          _isFeaturedBirdsLoading = false;
        });
      }
      return;
    }

    try {
      final birds = await _farmApi.fetchFeaturedBirds(
        mobileNumber: _mobileNumber,
      );
      if (!mounted) return;
      setState(() {
        _featuredBirds = birds;
        _isFeaturedBirdsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _featuredBirds = const <FeaturedBird>[];
        _isFeaturedBirdsLoading = false;
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
              // â”€â”€ Green Header Card â”€â”€
              _buildHeaderCard(),

              const SizedBox(height: 16),

              // â”€â”€ Statistics Row â”€â”€
              _buildStatsRow(),

              const SizedBox(height: 24),

              // â”€â”€ Section Title â”€â”€
              _buildSectionHeader(
                'HERITAGE LINES',
                onManageTap: _openHeritageManager,
              ),

              const SizedBox(height: 12),

              // â”€â”€ Heritage Lines â”€â”€
              _buildHeritageLinesSection(),

              const SizedBox(height: 24),

              // â”€â”€ Featured Birds â”€â”€
              _buildSectionHeader(
                'FEATURED BIRDS',
                onManageTap: _openFeaturedBirdsManager,
              ),
              const SizedBox(height: 12),
              _buildFeaturedBirdsCard(),

              const SizedBox(height: 24),

              // â”€â”€ Our Story â”€â”€
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

              // â”€â”€ Achievements â”€â”€
              _buildInfoCard(
                title: 'ACHIEVEMENTS',
                body: 'Add your show awards and recognitions from Settings.',
              ),

              const SizedBox(height: 10),

              // â”€â”€ Recent Activity â”€â”€
              _buildInfoCard(
                title: 'RECENT ACTIVITY',
                body:
                    'Add birds, log updates â€” activity appears here once your farm is published.',
              ),

              const SizedBox(height: 24),

              // â”€â”€ Farm Gallery â”€â”€
              _buildFarmGalleryCard(),

              const SizedBox(height: 10),

              // â”€â”€ Promo Card â”€â”€
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
                        final subtitleText = subtitleParts.join(' Â· ');
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
        // Row 3: Years Operating â€” full width
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

  Widget _buildSectionHeader(
    String title, {
    required VoidCallback onManageTap,
  }) {
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
          onTap: onManageTap,
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE7DE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _heritageLines.length > 4 ? 4 : _heritageLines.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) =>
                _buildHeritagePreviewCard(_heritageLines[index]),
          ),
          if (_heritageLines.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 2),
              child: Text(
                '+${_heritageLines.length - 4} more',
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

  Widget _buildHeritagePreviewCard(HeritageLine line) {
    final traitItems = line.traits
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .take(4)
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE8DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          if (line.originFocus.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.explore_outlined,
                    size: 13,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    line.originFocus,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (traitItems.isNotEmpty) ...[
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: traitItems
                  .take(3)
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5EC),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFD2E4D4)),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF1F5134),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (line.generationsBred != null) ...[
            const SizedBox(height: 8),
            Text(
              'Generations bred: ${line.generationsBred}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
            'Showcase your signature breeding lines â€” the heritage your farm is known for.',
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

  Future<void> _openFeaturedBirdsManager() async {
    if (_mobileNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again to manage featured birds.'),
        ),
      );
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) =>
            _FeaturedBirdsScreen(mobileNumber: _mobileNumber, api: _farmApi),
      ),
    );

    if (changed == true) {
      await _loadFeaturedBirds();
    }
  }

  // â”€â”€ Featured Birds â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildFeaturedBirdsCard() {
    if (_isFeaturedBirdsLoading) {
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

    if (_featuredBirds.isEmpty) {
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
              'Spotlight your best birds - the ones you\'re proudest of.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _openFeaturedBirdsManager,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add featured birds',
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE7DE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _featuredBirds.length > 4 ? 4 : _featuredBirds.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.93,
            ),
            itemBuilder: (context, index) =>
                _buildFeaturedBirdPreview(_featuredBirds[index]),
          ),
          if (_featuredBirds.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 2),
              child: Text(
                '+${_featuredBirds.length - 4} more',
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _openFeaturedBirdsManager,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentGreen,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 28),
              ),
              child: const Text(
                'Manage featured birds',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBirdPreview(FeaturedBird bird) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE8DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F2EA),
                borderRadius: BorderRadius.circular(10),
                image: (bird.imageUrl ?? '').trim().isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(bird.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (bird.imageUrl ?? '').trim().isEmpty
                  ? const Center(
                      child: Icon(
                        LucideIcons.image,
                        size: 20,
                        color: Color(0xFF8FA39A),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bird.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (bird.heritageLine.trim().isNotEmpty)
            Text(
              bird.heritageLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  // Info Card (Our Story / Achievements / Recent Activity)
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

  // â”€â”€ Farm Gallery â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Promo Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
    if (!mounted) return;
    await Future<void>.delayed(Duration.zero);
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
    if (!mounted) return;
    await Future<void>.delayed(Duration.zero);
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
    return showDialog<_HeritageLineFormData>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _HeritageLineEditorDialog(line: line),
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
                final traitItems = line.traits
                    .split(',')
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList();
                return Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDCE7DE)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F8F3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F6B3A),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Line ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            _buildCardActionButton(
                              icon: Icons.edit_outlined,
                              tooltip: 'Edit',
                              color: const Color(0xFF0F6B3A),
                              onPressed: () => _editLine(line),
                            ),
                            const SizedBox(width: 6),
                            _buildCardActionButton(
                              icon: Icons.delete_outline,
                              tooltip: 'Delete',
                              color: const Color(0xFFDC2626),
                              onPressed: () => _deleteLine(line),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: Text(
                          line.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (line.originFocus.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.explore_outlined,
                                  size: 14,
                                  color: Color(0xFF0F6B3A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  line.originFocus,
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (traitItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: traitItems
                                .map(
                                  (item) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF7F0),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xFFD2E4D4),
                                      ),
                                    ),
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        color: Color(0xFF1F5134),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      if (line.generationsBred != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.layers_outlined,
                                  size: 14,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Generations bred: ${line.generationsBred}',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (line.description.trim().isNotEmpty &&
                          line.description.trim() != line.originFocus.trim())
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: Text(
                            line.description,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
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

  Widget _buildCardActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
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

class _HeritageLineEditorDialog extends StatefulWidget {
  const _HeritageLineEditorDialog({required this.line});

  final HeritageLine? line;

  @override
  State<_HeritageLineEditorDialog> createState() =>
      _HeritageLineEditorDialogState();
}

class _HeritageLineEditorDialogState extends State<_HeritageLineEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _originController;
  late final TextEditingController _traitsController;
  late final TextEditingController _generationsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.line?.name ?? '');
    _originController = TextEditingController(
      text: widget.line?.originFocus ?? '',
    );
    _traitsController = TextEditingController(text: widget.line?.traits ?? '');
    _generationsController = TextEditingController(
      text: widget.line?.generationsBred?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _traitsController.dispose();
    _generationsController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
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

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final parsedGen = int.tryParse(_generationsController.text.trim());
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      _HeritageLineFormData(
        name: name,
        originFocus: _originController.text.trim(),
        traits: _traitsController.text.trim(),
        generationsBred: parsedGen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
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
                      line == null ? 'Add Heritage Line' : 'Edit Heritage Line',
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
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  label: 'Line name',
                  hint: 'Line name (e.g. Mountain Native Line)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: TextField(
                controller: _originController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  label: 'Origin or focus',
                  hint: 'Origin or focus (e.g. High egg yield, hardy)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: TextField(
                controller: _traitsController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  label: 'Traits',
                  hint: 'Traits, comma-separated (e.g. Hardy, Calm, Heavy)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: TextField(
                controller: _generationsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
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
                      onPressed: _save,
                      child: const Text('Save'),
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

class _FeaturedBirdsScreen extends StatefulWidget {
  const _FeaturedBirdsScreen({required this.mobileNumber, required this.api});

  final String mobileNumber;
  final FarmApi api;

  @override
  State<_FeaturedBirdsScreen> createState() => _FeaturedBirdsScreenState();
}

class _FeaturedBirdsScreenState extends State<_FeaturedBirdsScreen> {
  bool _isLoading = true;
  bool _changed = false;
  List<FeaturedBird> _birds = const <FeaturedBird>[];

  static const List<_FeaturedOption> _sexOptions = <_FeaturedOption>[
    _FeaturedOption('male', 'Male'),
    _FeaturedOption('female', 'Female'),
    _FeaturedOption('unknown', 'Unknown'),
  ];

  static const List<_FeaturedOption> _badgeOptions = <_FeaturedOption>[
    _FeaturedOption('no_badge', 'No badge'),
    _FeaturedOption('champion_show', 'Champion of Show'),
    _FeaturedOption('breeder', 'Breeder'),
    _FeaturedOption('top_hen', 'Top Hen'),
    _FeaturedOption('rising_star', 'Rising Star'),
    _FeaturedOption('foundation', 'Foundation'),
    _FeaturedOption('signature', 'Signature'),
    _FeaturedOption('retired', 'Retired'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final birds = await widget.api.fetchFeaturedBirds(
        mobileNumber: widget.mobileNumber,
      );
      if (!mounted) return;
      setState(() {
        _birds = birds;
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

  Future<void> _addBird() async {
    final result = await _showBirdEditor();
    if (result == null) return;
    if (!mounted) return;
    await Future<void>.delayed(Duration.zero);
    try {
      await widget.api.addFeaturedBird(
        mobileNumber: widget.mobileNumber,
        name: result.name,
        heritageLine: result.heritageLine,
        ageLabel: result.ageLabel,
        sex: result.sex,
        badge: result.badge,
        image: result.imageFile,
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

  Future<void> _editBird(FeaturedBird bird) async {
    final result = await _showBirdEditor(bird: bird);
    if (result == null) return;
    if (!mounted) return;
    await Future<void>.delayed(Duration.zero);
    try {
      await widget.api.updateFeaturedBird(
        id: bird.id,
        mobileNumber: widget.mobileNumber,
        name: result.name,
        heritageLine: result.heritageLine,
        ageLabel: result.ageLabel,
        sex: result.sex,
        badge: result.badge,
        image: result.imageFile,
        removeImage: result.removeImage,
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

  Future<void> _deleteBird(FeaturedBird bird) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Featured Bird'),
        content: Text('Delete "${bird.name}"?'),
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
      await widget.api.deleteFeaturedBird(
        id: bird.id,
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

  Future<_FeaturedBirdFormData?> _showBirdEditor({FeaturedBird? bird}) {
    return showDialog<_FeaturedBirdFormData>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FeaturedBirdEditorDialog(
        bird: bird,
        sexOptions: _sexOptions,
        badgeOptions: _badgeOptions,
      ),
    );
  }

  String _badgeLabel(String value) {
    return _badgeOptions
            .firstWhere(
              (option) => option.value == value,
              orElse: () => const _FeaturedOption('', ''),
            )
            .label
            .trim()
            .isEmpty
        ? 'No badge'
        : _badgeOptions
              .firstWhere(
                (option) => option.value == value,
                orElse: () => const _FeaturedOption('no_badge', 'No badge'),
              )
              .label;
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
          'Featured Birds',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _addBird,
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
          : _birds.isEmpty
          ? const Center(
              child: Text(
                'No featured birds yet.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              itemBuilder: (context, index) {
                final bird = _birds[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCE7DE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3EB),
                          borderRadius: BorderRadius.circular(12),
                          image: (bird.imageUrl ?? '').trim().isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(bird.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (bird.imageUrl ?? '').trim().isEmpty
                            ? const Icon(
                                LucideIcons.image,
                                color: Color(0xFF8FA39A),
                                size: 20,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bird.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            if (bird.heritageLine.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  bird.heritageLine,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (bird.ageLabel.trim().isNotEmpty)
                                  _miniChip(bird.ageLabel),
                                if (bird.sex.trim().isNotEmpty)
                                  _miniChip(
                                    _sexOptions
                                        .firstWhere(
                                          (opt) => opt.value == bird.sex,
                                          orElse: () => const _FeaturedOption(
                                            'unknown',
                                            'Unknown',
                                          ),
                                        )
                                        .label,
                                  ),
                                _miniChip(_badgeLabel(bird.badge)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          _iconActionButton(
                            icon: Icons.edit_outlined,
                            color: const Color(0xFF0F6B3A),
                            tooltip: 'Edit',
                            onTap: () => _editBird(bird),
                          ),
                          const SizedBox(height: 6),
                          _iconActionButton(
                            icon: Icons.delete_outline,
                            color: const Color(0xFFDC2626),
                            tooltip: 'Delete',
                            onTap: () => _deleteBird(bird),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: _birds.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBird,
        backgroundColor: AppColors.accentGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Featured Bird'),
      ),
    );
  }

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD2E4D4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1F5134),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _iconActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _FeaturedBirdFormData {
  const _FeaturedBirdFormData({
    required this.name,
    required this.heritageLine,
    required this.ageLabel,
    required this.sex,
    required this.badge,
    required this.imageFile,
    required this.removeImage,
  });

  final String name;
  final String heritageLine;
  final String ageLabel;
  final String? sex;
  final String badge;
  final File? imageFile;
  final bool removeImage;
}

class _FeaturedOption {
  const _FeaturedOption(this.value, this.label);
  final String value;
  final String label;
}

class _FeaturedBirdEditorDialog extends StatefulWidget {
  const _FeaturedBirdEditorDialog({
    required this.bird,
    required this.sexOptions,
    required this.badgeOptions,
  });

  final FeaturedBird? bird;
  final List<_FeaturedOption> sexOptions;
  final List<_FeaturedOption> badgeOptions;

  @override
  State<_FeaturedBirdEditorDialog> createState() =>
      _FeaturedBirdEditorDialogState();
}

class _FeaturedBirdEditorDialogState extends State<_FeaturedBirdEditorDialog> {
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _heritageController;
  late final TextEditingController _ageController;

  String? _selectedSex;
  late String _selectedBadge;
  File? _selectedImage;
  bool _removeImage = false;
  bool _nameInvalid = false;

  @override
  void initState() {
    super.initState();
    final bird = widget.bird;
    _nameController = TextEditingController(text: bird?.name ?? '');
    _heritageController = TextEditingController(text: bird?.heritageLine ?? '');
    _ageController = TextEditingController(text: bird?.ageLabel ?? '');

    _selectedSex = widget.sexOptions.any((option) => option.value == bird?.sex)
        ? bird?.sex
        : null;
    _selectedBadge =
        widget.badgeOptions.any((option) => option.value == bird?.badge)
        ? (bird?.badge ?? 'no_badge')
        : 'no_badge';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heritageController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _selectedImage = File(picked.path);
      _removeImage = false;
    });
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _removeImage = true;
    });
  }

  bool get _hasExistingImage {
    return (widget.bird?.imageUrl ?? '').trim().isNotEmpty;
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameInvalid = true);
      return;
    }
    Navigator.of(context).pop(
      _FeaturedBirdFormData(
        name: name,
        heritageLine: _heritageController.text.trim(),
        ageLabel: _ageController.text.trim(),
        sex: _selectedSex,
        badge: _selectedBadge,
        imageFile: _selectedImage,
        removeImage: _removeImage,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      hintStyle: const TextStyle(color: Color(0xFF8A9590), fontSize: 13),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bird = widget.bird;
    final imageUrl = bird?.imageUrl ?? '';
    final showNetworkImage =
        _selectedImage == null && !_removeImage && imageUrl.trim().isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFCFA),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD4E3D6)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 26,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Featured Bird',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 18),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F0EA),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD8D8D8),
                      width: 1.2,
                    ),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : showNetworkImage
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null && !showNetworkImage
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.uploadCloud,
                              color: Color(0xFF6B7280),
                              size: 26,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Upload photo',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              if (_selectedImage != null || _hasExistingImage)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: TextButton.icon(
                    onPressed: _clearImage,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Remove image'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  hint: 'Name (e.g. your animal\'s name or ID)',
                  errorText: _nameInvalid ? 'Name is required' : null,
                ),
                onChanged: (_) {
                  if (_nameInvalid) setState(() => _nameInvalid = false);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _heritageController,
                decoration: _inputDecoration(
                  hint: 'Heritage line / variety (optional)',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      decoration: _inputDecoration(hint: 'Age (e.g. 2 yrs)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedSex,
                      isExpanded: true,
                      decoration: _inputDecoration(hint: 'Sex (optional)'),
                      items: widget.sexOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option.value,
                              child: Text(option.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSex = value),
                      hint: const Text('Sex (optional)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedBadge,
                isExpanded: true,
                decoration: _inputDecoration(hint: 'Badge'),
                items: widget.badgeOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.value,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedBadge = value);
                },
              ),
              const SizedBox(height: 14),
              Row(
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
                      onPressed: _save,
                      child: Text(bird == null ? 'Add bird' : 'Save changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
