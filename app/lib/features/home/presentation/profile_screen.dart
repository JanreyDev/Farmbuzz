import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import 'profile_settings_screen.dart';

import '../data/profile_api.dart';
import '../data/feed_api.dart';
import '../data/social_api.dart';
import '../../messages/data/message_api.dart';
import '../../messages/presentation/conversation_screen.dart';
import 'widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.onNavigateTab,
    this.viewUserName,
    this.viewUserAvatar,
  });

  final ValueChanged<int>? onNavigateTab;
  /// When set, shows this user's profile instead of the logged-in user's.
  final String? viewUserName;
  /// Fallback avatar if profile fails to load.
  final String? viewUserAvatar;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileApi _profileApi = ProfileApi();
  final FeedApi _feedApi = FeedApi();
  final SocialApi _socialApi = SocialApi();
  final MessageApi _messageApi = MessageApi();
  ProfileModel? _profile;
  bool _isLoading = true;
  List<FeedPost>? _userPosts;

  // Social state (for viewing other users)
  bool _isFollowing = false;
  bool _isSocialLoading = false;
  String? _myMobile;
  String? _myName;

  bool get _isOwner => widget.viewUserName == null;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _initSession();
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _myMobile = prefs.getString('auth_mobile_number') ?? prefs.getString('mobile_number');
    _myName = (prefs.getString('auth_user_name') ?? '').trim();
    if (!_isOwner && _myMobile != null && widget.viewUserName != null) {
      await _loadSocialStatus();
    }
  }

  Future<void> _loadSocialStatus() async {
    if (_myMobile == null || widget.viewUserName == null) return;
    try {
      final following = await _socialApi.isFollowing(
        myMobile: _myMobile!,
        targetName: widget.viewUserName!,
      );
      if (mounted) setState(() => _isFollowing = following);
    } catch (_) {}
  }

  Future<void> _toggleFollow() async {
    if (_myMobile == null || _isSocialLoading) return;
    setState(() => _isSocialLoading = true);
    try {
      if (_isFollowing) {
        await _socialApi.unfollow(
          myMobile: _myMobile!,
          targetName: widget.viewUserName!,
        );
      } else {
        await _socialApi.follow(
          myMobile: _myMobile!,
          targetName: widget.viewUserName!,
        );
      }
      if (mounted) {
        setState(() => _isFollowing = !_isFollowing);
        // Refresh follower count
        await _loadProfileData();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action failed. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  Future<void> _openMessage() async {
    if (_myMobile == null) return;
    try {
      final conversationId = await _messageApi.startConversation(
        mobileNumber: _myMobile!,
        targetName: widget.viewUserName!,
      );
      if (!mounted) return;
      final conversation = ConversationModel(
        id: conversationId,
        otherUserName: widget.viewUserName!,
        otherUserAvatar: _profile?.avatarUrl ?? '',
        lastMessage: '',
        lastMessageTime: '',
        isUnread: false,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ConversationScreen(conversation: conversation)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat. Try again.')),
        );
      }
    }
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      // If viewUserName is set, look up by name; otherwise use logged-in user
      if (widget.viewUserName != null && widget.viewUserName!.trim().isNotEmpty) {
        final profile = await _profileApi.fetchProfileByName(
          userName: widget.viewUserName!.trim(),
        );
        if (mounted) {
          setState(() {
            _profile = profile;
          });
          // Always load posts for this author, even if their profile is missing
          _loadPosts(widget.viewUserName!.trim());
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final mobile =
            prefs.getString('auth_mobile_number') ??
            prefs.getString('mobile_number');
        if (mobile != null) {
          final profile = await _profileApi.fetchProfile(mobileNumber: mobile);
          if (mounted) {
            setState(() {
              _profile = profile;
            });
            if (profile != null) {
              _loadPosts(profile.name);
            } else {
              if (mounted) setState(() => _userPosts = []);
            }
          }
        } else {
          if (mounted) setState(() => _userPosts = []);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _userPosts = []);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPosts(String authorName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reactorName =
          prefs.getString('auth_user_name') ??
          prefs.getString('auth_mobile_number') ??
          '';
      final posts = await _feedApi.fetchPosts(
        reactorName: reactorName,
        authorName: authorName,
      );
      if (mounted) {
        setState(() {
          _userPosts = posts;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _userPosts = [];
        });
      }
    }
  }

  String _formatStat(int? value) {
    if (value == null) return '0';
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?.name ?? widget.viewUserName ?? 'Unnamed User';
    final hasLocation = _profile?.address?.isNotEmpty == true;
    final hasYearsBreeding = _profile?.yearsBreeding?.isNotEmpty == true;

    String joinedText = 'Joined Recently';
    if (_profile?.createdAt != null) {
      try {
        final date = DateTime.parse(_profile!.createdAt!);
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        joinedText = 'Joined ${months[date.month - 1]} ${date.year}';
      } catch (_) {}
    }

    final bio = _profile?.bio?.isNotEmpty == true
        ? _profile!.bio!
        : 'This user hasn\'t written a bio yet.';

    final tags =
        _profile?.bloodlines
            ?.split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isOwner ? 'Profile' : (widget.viewUserName ?? 'Profile'),
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (hasLocation) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _profile!.address!,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Ã¢â‚¬Â¢',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ],
                    if (_profile?.createdAt != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            joinedText,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (hasYearsBreeding) ...[
                      const Text(
                        'Ã¢â‚¬Â¢',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_outlined,
                            size: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _profile!.yearsBreeding!,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  'Bio',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  bio,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) => _TagChip(t)).toList(),
                  ),
                ),
              ],
              if (_profile?.socialFb?.isNotEmpty == true ||
                  _profile?.socialIg?.isNotEmpty == true ||
                  _profile?.socialTiktok?.isNotEmpty == true ||
                  _profile?.socialYt?.isNotEmpty == true ||
                  _profile?.socialWeb?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_profile?.socialFb?.isNotEmpty == true)
                        SizedBox(
                          width: 60,
                          child: _SocialTile(
                            Icons.facebook,
                            url: _profile!.socialFb,
                          ),
                        ),
                      if (_profile?.socialIg?.isNotEmpty == true)
                        SizedBox(
                          width: 60,
                          child: _SocialTile(
                            Icons.camera_alt_outlined,
                            url: _profile!.socialIg,
                          ),
                        ),
                      if (_profile?.socialTiktok?.isNotEmpty == true)
                        SizedBox(
                          width: 60,
                          child: _SocialTile(
                            Icons.music_note,
                            url: _profile!.socialTiktok,
                          ),
                        ),
                      if (_profile?.socialYt?.isNotEmpty == true)
                        SizedBox(
                          width: 60,
                          child: _SocialTile(
                            Icons.play_arrow_rounded,
                            url: _profile!.socialYt,
                          ),
                        ),
                      if (_profile?.socialWeb?.isNotEmpty == true)
                        SizedBox(
                          width: 60,
                          child: _SocialTile(
                            Icons.language,
                            url: _profile!.socialWeb,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      _StatCell(
                        value: _formatStat(_profile?.followersCount ?? 0),
                        label: 'Followers',
                      ),
                      const _StatDivider(),
                      _StatCell(
                        value: _formatStat(_profile?.followingCount ?? 0),
                        label: 'Following',
                      ),
                      const _StatDivider(),
                      _StatCell(
                        value: _formatStat(_profile?.postsCount ?? _userPosts?.length ?? 0),
                        label: 'Posts',
                      ),
                      const _StatDivider(),
                      _StatCell(
                        value: _formatStat(_profile?.clubsCount ?? 0),
                        label: 'Clubs',
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 2, 16, 8),
                child: Text(
                  'Posts',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_userPosts == null)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentGreen,
                    ),
                  ),
                )
              else if (_userPosts!.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No posts yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    children: _userPosts!.map((post) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PostCard(
                          postId: post.id,
                          userName: post.userName,
                          userAvatar: post.userAvatar,
                          timeAgo: post.timeAgo,
                          postText: post.postText,
                          metaEmoji: post.metaEmoji,
                          metaFeeling: post.metaFeeling,
                          metaLocation: post.metaLocation,
                          userReaction: post.userReaction,
                          likesCount: post.likesCount,
                          commentsCount: post.commentsCount,
                          topReactions: post.topReactions,
                          imageUrls: post.imageUrls,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isOwner ? FloatingActionButton(
        onPressed: () {
          widget.onNavigateTab?.call(2);
          Navigator.of(context).pop();
        },
        backgroundColor: const Color(0xFFD97706),
        elevation: 4,
        shape: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _isOwner ? BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _ProfileBottomItem(
              icon: Icons.home_filled,
              label: 'Home',
              onTap: () {
                widget.onNavigateTab?.call(0);
                Navigator.of(context).pop();
              },
            ),
            _ProfileBottomItem(
              icon: Icons.agriculture,
              label: 'My Farm',
              onTap: () {
                widget.onNavigateTab?.call(1);
                Navigator.of(context).pop();
              },
            ),
            SizedBox(width: 70),
            _ProfileBottomItem(
              icon: Icons.groups,
              label: 'Clubs',
              onTap: () {
                widget.onNavigateTab?.call(3);
                Navigator.of(context).pop();
              },
            ),
            _ProfileBottomItem(
              icon: Icons.leaderboard,
              label: 'Rank',
              onTap: () {
                widget.onNavigateTab?.call(4);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ) : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_profile?.coverPhotoUrl != null &&
                  _profile!.coverPhotoUrl!.isNotEmpty)
                Image.network(_profile!.coverPhotoUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]))
              else
                Container(
                  color: Colors.white,
                  child: Center(
                    child: Image.asset('assets/images/logo.png', height: 80),
                  ),
                ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -26),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF5D18A),
                      ),
                      child:
                          (_profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty)
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    _profile!.avatarUrl!,
                                  ),
                                )
                              : (widget.viewUserAvatar != null && widget.viewUserAvatar!.isNotEmpty)
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(widget.viewUserAvatar!),
                                      onBackgroundImageError: (_, __) {},
                                    )
                                  : const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                    ),
                    // Camera icon only shown for owner
                    if (_isOwner)
                      Positioned(
                        right: -2,
                        bottom: 6,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Icon(
                            Icons.photo_camera_outlined,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                // ── OWNER BUTTONS ──
                if (_isOwner)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 26),
                        child: GestureDetector(
                          onTap: () {
                            widget.onNavigateTab?.call(1);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grass_outlined,
                                  size: 16,
                                  color: AppColors.accentGreen,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'My Farm',
                                  style: TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 26),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileSettingsScreen(),
                              ),
                            );
                          },
                          child: const _ActionBtn(
                            icon: Icons.settings_outlined,
                            filled: true,
                          ),
                        ),
                      ),
                    ],
                  )
                // ── VISITOR BUTTONS ──
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 26),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Follow / Unfollow button
                        GestureDetector(
                          onTap: _isSocialLoading ? null : _toggleFollow,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isFollowing
                                  ? const Color(0xFFF3F4F6)
                                  : AppColors.accentGreen,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isFollowing
                                    ? const Color(0xFFE5E7EB)
                                    : AppColors.accentGreen,
                              ),
                            ),
                            child: _isSocialLoading
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _isFollowing
                                          ? AppColors.accentGreen
                                          : Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isFollowing
                                            ? Icons.person_remove_outlined
                                            : Icons.person_add_outlined,
                                        size: 14,
                                        color: _isFollowing
                                            ? Colors.black87
                                            : Colors.white,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _isFollowing ? 'Following' : 'Follow',
                                        style: TextStyle(
                                          color: _isFollowing
                                              ? Colors.black87
                                              : Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Message button
                        GestureDetector(
                          onTap: _openMessage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 14, color: Colors.black87),
                                SizedBox(width: 5),
                                Text(
                                  'Message',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, this.filled = false});

  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: filled ? AppColors.accentGreen : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filled ? AppColors.accentGreen : const Color(0xFFE5E7EB),
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: filled ? Colors.white : AppColors.accentGreen,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB8E3C5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.eco_outlined,
            size: 14,
            color: AppColors.accentGreen,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile(this.icon, {this.url});

  final IconData icon;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;

    return Container(
      width: 48,
      height: 38,
      decoration: BoxDecoration(
        color: hasUrl
            ? AppColors.accentGreen.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasUrl ? AppColors.accentGreen : const Color(0xFFE5E7EB),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: hasUrl ? AppColors.accentGreen : const Color(0xFFD1D5DB),
        size: 18,
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: const Color(0xFFE5E7EB));
  }
}

class _ProfileBottomItem extends StatelessWidget {
  const _ProfileBottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? AppColors.accentGreen : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.accentGreen : Colors.grey,
                fontSize: 10,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
