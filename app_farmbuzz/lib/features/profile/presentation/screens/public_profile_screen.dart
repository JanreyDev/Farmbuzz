import 'package:farmbuzz/core/session/app_session.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/home/data/post_api.dart';
import 'package:farmbuzz/features/home/presentation/widgets/post_card.dart';
import 'package:farmbuzz/features/profile/data/social_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
  });

  final String userName;
  final String userAvatar;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final PostApi _postApi = PostApi();
  final SocialApi _socialApi = SocialApi();

  bool _isLoading = true;
  bool _isOwner = false;
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  int _followersCount = 0;
  int _followingCount = 0;
  List<Map<String, dynamic>> _posts = const [];

  bool _hasValidAvatarUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _joinedLabel() {
    final now = DateTime.now();
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return 'Joined ${monthNames[now.month - 1]} ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mobile = AppSession.mobileNumber;
    if (mobile == null || mobile.trim().isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      final results = await Future.wait([
        _postApi.getPosts(reactorName: AppSession.userName, authorName: widget.userName),
        _socialApi.getStatus(mobileNumber: mobile, targetName: widget.userName),
      ]);

      final posts = results[0] as List<Map<String, dynamic>>;
      final status = results[1] as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isOwner = (status['is_owner'] == true);
        _isFollowing = (status['is_following'] == true);
        _followersCount = ((status['followers_count'] ?? 0) as num).toInt();
        _followingCount = ((status['following_count'] ?? 0) as num).toInt();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_isOwner || _isFollowLoading) return;

    final mobile = AppSession.mobileNumber;
    if (mobile == null || mobile.trim().isEmpty) return;

    setState(() => _isFollowLoading = true);
    try {
      if (_isFollowing) {
        await _socialApi.unfollow(mobileNumber: mobile, targetName: widget.userName);
      } else {
        await _socialApi.follow(mobileNumber: mobile, targetName: widget.userName);
      }
      if (!mounted) return;
      setState(() {
        _isFollowing = !_isFollowing;
        _followersCount = _isFollowing ? _followersCount + 1 : (_followersCount > 0 ? _followersCount - 1 : 0);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: const Color(0xFFF5F5F5),
                        child: _hasValidAvatarUrl(widget.userAvatar)
                            ? Image.network(widget.userAvatar, fit: BoxFit.cover)
                            : Image.asset('assets/images/cover_photo.png', fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: 20,
                        bottom: -40,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _hasValidAvatarUrl(widget.userAvatar)
                                ? NetworkImage(widget.userAvatar)
                                : null,
                            child: _hasValidAvatarUrl(widget.userAvatar)
                                ? null
                                : Text(
                                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black54,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 45),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _isOwner ? null : _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOwner || _isFollowing ? Colors.grey[200] : AppColors.premiumGreen,
                            foregroundColor: _isOwner || _isFollowing ? Colors.black87 : Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _isOwner ? 'Owner' : (_isFollowLoading ? '...' : (_isFollowing ? 'Following' : 'Follow')),
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.userName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _isOwner ? 'OWNER' : 'MEMBER',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '@${widget.userName.toLowerCase().replaceAll(' ', '')}',
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _joinedLabel(),
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'FOLLOWERS', value: _followersCount.toString()),
                        _StatItem(label: 'FOLLOWING', value: _followingCount.toString()),
                        _StatItem(label: 'POSTS', value: _posts.length.toString()),
                        const _StatItem(label: 'BIRDS', value: '0'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      children: [
                        _TabPill(label: 'Posts', count: _posts.length, active: true),
                        const SizedBox(width: 8),
                        const _TabPill(label: 'Birds', count: 0, active: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No posts yet.'),
                    )
                  else
                    Column(
                      children: _posts
                          .map(
                            (post) => PostCard(
                              postId: post['id'] as int?,
                              userName: post['userName'],
                              userAvatar: post['userAvatar'],
                              timeAgo: post['timeAgo'],
                              postText: post['postText'],
                              postImageUrl: post['postImageUrl'],
                              localImagePaths: post['localImagePaths'],
                              likesCount: post['likesCount'],
                              commentsCount: post['commentsCount'],
                              userReaction: post['userReaction'] as String?,
                              topReactions: (post['topReactions'] as List?)?.cast<String>(),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.label, required this.count, required this.active});

  final String label;
  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.premiumGreen : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
