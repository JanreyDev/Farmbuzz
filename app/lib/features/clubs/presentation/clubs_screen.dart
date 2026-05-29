import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../data/club_api.dart';
import 'widgets/club_card.dart';
import 'widgets/suggested_club_card.dart';
import 'widgets/discover_club_item.dart';
import 'widgets/create_club_modal.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final ClubApi _clubApi = ClubApi();

  List<Map<String, dynamic>> _myClubs = [];
  List<Map<String, dynamic>> _discoverClubs = [];
  bool _loadingMyClubs = true;
  bool _loadingDiscover = true;
  String _errorMyClubs = '';
  String _errorDiscover = '';
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<String> _getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_mobile_number') ?? '';
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadMyClubs(), _loadDiscover()]);
  }

  Future<void> _loadMyClubs() async {
    setState(() {
      _loadingMyClubs = true;
      _errorMyClubs = '';
    });
    try {
      final mobile = await _getMobileNumber();
      if (mobile.isEmpty) {
        setState(() {
          _myClubs = [];
          _loadingMyClubs = false;
        });
        return;
      }
      final clubs = await _clubApi.getMyClubs(mobileNumber: mobile);
      if (mounted) setState(() => _myClubs = clubs);
    } catch (e) {
      if (mounted) setState(() => _errorMyClubs = e.toString());
    } finally {
      if (mounted) setState(() => _loadingMyClubs = false);
    }
  }

  Future<void> _loadDiscover({String? category}) async {
    setState(() {
      _loadingDiscover = true;
      _errorDiscover = '';
    });
    try {
      final mobile = await _getMobileNumber();
      final clubs = await _clubApi.discoverClubs(
        mobileNumber: mobile,
        category: category ?? _activeFilter,
      );
      if (mounted) setState(() => _discoverClubs = clubs);
    } catch (e) {
      if (mounted) setState(() => _errorDiscover = e.toString());
    } finally {
      if (mounted) setState(() => _loadingDiscover = false);
    }
  }

  Future<void> _onFilterTap(String label) async {
    setState(() => _activeFilter = label);
    await _loadDiscover(category: label);
  }

  Future<void> _openCreateClub() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateClubModal(),
    );
    if (created == true) {
      _loadMyClubs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accentGreen,
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Clubs',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openCreateClub,
                  icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                  label: const Text(
                    'Create Club',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search clubs...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: Icon(LucideIcons.search, color: Colors.grey.shade500, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── MY CLUBS ──────────────────────────────────────────────
            Row(
              children: [
                const Text(
                  'My Clubs',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _loadingMyClubs ? '…' : '${_myClubs.length}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_loadingMyClubs)
              _buildLoadingList()
            else if (_errorMyClubs.isNotEmpty)
              _buildError(_errorMyClubs, onRetry: _loadMyClubs)
            else if (_myClubs.isEmpty)
              _buildEmpty(
                icon: LucideIcons.users,
                message: "You haven't joined any clubs yet.",
                sub: 'Tap Create Club to start one!',
              )
            else
              ..._myClubs.map((club) => ClubCard(
                    title: club['title'] as String? ?? 'Unnamed Club',
                    memberCount: (club['memberCount'] as num?)?.toInt() ?? 0,
                    commentCount: (club['postCount'] as num?)?.toInt() ?? 0,
                    role: club['role'] as String? ?? 'member',
                    isFounder: (club['role'] as String? ?? '') == 'founder',
                    imageUrl: (club['imageUrl'] as String?) ?? '',
                    onEdit: () async {
                      final updated = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CreateClubModal(initialClub: club),
                      );
                      if (updated == true) {
                        _loadMyClubs();
                        _loadDiscover();
                      }
                    },
                  )),

            const SizedBox(height: 24),

            // ── SUGGESTED FOR YOU (My Clubs shown horizontally) ───────
            if (!_loadingMyClubs && _myClubs.isNotEmpty) ...[
              Row(
                children: [
                  Icon(LucideIcons.sparkles, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Clubs',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _myClubs.map((club) => SuggestedClubCard(
                        title: club['title'] as String? ?? 'Unnamed Club',
                        memberCount: (club['memberCount'] as num?)?.toInt() ?? 0,
                        isJoined: true,
                        imageUrl: (club['imageUrl'] as String?) ?? '',
                      )).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── DISCOVER CLUBS ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discover Clubs',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_discoverClubs.length} clubs',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', LucideIcons.layoutGrid),
                  _buildFilterChip('Bloodline', LucideIcons.droplet),
                  _buildFilterChip('Regional', LucideIcons.map),
                  _buildFilterChip('Community', LucideIcons.users),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_loadingDiscover)
              _buildLoadingList(count: 3)
            else if (_errorDiscover.isNotEmpty)
              _buildError(_errorDiscover, onRetry: () => _loadDiscover())
            else if (_discoverClubs.isEmpty)
              _buildEmpty(
                icon: LucideIcons.searchX,
                message: 'No clubs found.',
                sub: 'Try a different filter or create one!',
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: _discoverClubs.map((club) => DiscoverClubItem(
                        title: club['title'] as String? ?? 'Unnamed Club',
                        badgeText: club['category'] as String? ?? 'Community',
                        memberCount: (club['memberCount'] as num?)?.toInt() ?? 0,
                        location: club['region'] as String? ?? '',
                        isJoined: false,
                        imageUrl: (club['imageUrl'] as String?) ?? '',
                      )).toList(),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => _onFilterTap(label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.accentGreen : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.accentGreen.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList({int count = 2}) {
    return Column(
      children: List.generate(count, (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      )),
    );
  }

  Widget _buildError(String message, {required VoidCallback onRetry}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.alertCircle, color: Colors.red.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry', style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty({required IconData icon, required String message, required String sub}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
