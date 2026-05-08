import 'package:flutter/material.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/clubs/data/club_api.dart';
import 'widgets/clubs_search_bar.dart';
import 'widgets/club_card.dart';
import 'widgets/empty_state_card.dart';
import 'widgets/create_club_modal.dart';

class ClubsView extends StatefulWidget {
  const ClubsView({super.key});

  @override
  State<ClubsView> createState() => _ClubsViewState();
}

class _ClubsViewState extends State<ClubsView> {
  final ClubApi _clubApi = ClubApi();

  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Poultry', 'Regional', 'Community', 'Education'];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLoadingDiscover = true;
  List<Map<String, dynamic>> _discoverClubs = [];

  // State-managed list of my clubs
  List<Map<String, dynamic>> _myClubs = [];

  @override
  void initState() {
    super.initState();
    _loadMyClubs();
    _loadDiscoverClubs();
  }

  Future<void> _loadMyClubs() async {
    final mobile = AppSession.mobileNumber?.trim();
    if (mobile == null || mobile.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final clubs = await _clubApi.getMyClubs(mobileNumber: mobile);
      if (!mounted) {
        return;
      }
      setState(() {
        _myClubs = clubs.map(_normalizeClub).toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } on ClubApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load clubs.';
      });
    }
  }

  Future<void> _loadDiscoverClubs() async {
    final mobile = AppSession.mobileNumber?.trim();
    try {
      final clubs = await _clubApi.getDiscoverClubs(
        mobileNumber: mobile,
        category: selectedCategory,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _discoverClubs = clubs.map(_normalizeClub).toList();
        _isLoadingDiscover = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingDiscover = false;
        _discoverClubs = [];
      });
    }
  }

  void _addNewClub(Map<String, dynamic> data) {
    setState(() {
      _myClubs.insert(0, _normalizeClub(data));
    });
  }

  Map<String, dynamic> _normalizeClub(Map<String, dynamic> data) {
    final rawRole = (data['role'] ?? 'founder').toString().toLowerCase();
    final clubRole = rawRole == 'member' ? ClubRole.member : ClubRole.founder;

    return {
      'title': (data['title'] ?? '').toString(),
      'role': clubRole,
      'memberCount': (data['memberCount'] as num?)?.toInt() ?? 1,
      'postCount': (data['postCount'] as num?)?.toInt() ?? 0,
      'imageUrl': data['imageUrl'],
      'category': (data['category'] ?? '').toString(),
      'region': (data['region'] ?? '').toString(),
      'isPublic': data['is_public'] == true,
    };
  }

  Widget _buildMyClubsSection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: EmptyStateCard(
          icon: Icons.error_outline,
          title: _errorMessage!,
          actionLabel: 'Retry',
          onAction: _loadMyClubs,
        ),
      );
    }

    if (_myClubs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: EmptyStateCard(
          icon: Icons.groups_outlined,
          title: 'No clubs yet',
          subtitle: 'Create your first club to get started.',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _myClubs.length,
      itemBuilder: (context, index) {
        final club = _myClubs[index];
        return ClubCard(
          title: club['title'],
          role: club['role'],
          memberCount: club['memberCount'],
          postCount: club['postCount'],
          imageUrl: club['imageUrl'],
          region: club['region'],
          isPublic: club['isPublic'] == true,
          isJoined: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final discoverClubs = _discoverClubs.where((club) {
      if (selectedCategory == 'All') {
        return true;
      }
      return (club['category'] ?? '') == selectedCategory;
    }).toList();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clubs',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => CreateClubModal.show(context, onClubCreated: _addNewClub),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Club'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premiumGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search Bar
            const ClubsSearchBar(),
            const SizedBox(height: 32),
            
            // My Clubs Section
            _buildSectionHeader(
              title: 'My Clubs',
              onSeeAll: () {},
            ),
            const SizedBox(height: 16),
            _buildMyClubsSection(),
            const SizedBox(height: 32),
            
            // Featured Clubs Section
            _buildSectionHeader(
              title: 'Featured Clubs',
              onSeeAll: () {},
            ),
            const SizedBox(height: 16),
            const EmptyStateCard(
              icon: Icons.star_rounded,
              title: 'No featured clubs right now',
            ),
            const SizedBox(height: 32),
            
            // Discover Clubs Section
            _buildSectionHeader(
              title: 'Discover Clubs',
              onSeeAll: () {},
            ),
            const SizedBox(height: 16),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = cat;
                        _isLoadingDiscover = true;
                      });
                      _loadDiscoverClubs();
                    },
                    selectedColor: AppColors.premiumGreen,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selectedCategory == cat ? Colors.white : Colors.grey[600],
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selectedCategory == cat ? Colors.transparent : Colors.grey[200]!,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isLoadingDiscover)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (discoverClubs.isEmpty)
              EmptyStateCard(
                icon: Icons.search_rounded,
                title: 'No clubs to discover',
                subtitle: 'Try a different category or browse all clubs.',
                actionLabel: 'See all clubs',
                onAction: () {
                  setState(() {
                    selectedCategory = 'All';
                    _isLoadingDiscover = true;
                  });
                  _loadDiscoverClubs();
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: discoverClubs.length,
                itemBuilder: (context, index) {
                  final club = discoverClubs[index];
                  return ClubCard(
                    title: club['title'],
                    role: club['role'],
                    memberCount: club['memberCount'],
                    postCount: club['postCount'],
                    imageUrl: club['imageUrl'],
                    region: club['region'],
                    isPublic: club['isPublic'] == true,
                    isJoined: false,
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Row(
            children: [
              Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.premiumGreen,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 14, color: AppColors.premiumGreen),
            ],
          ),
        ),
      ],
    );
  }
}
