import 'package:flutter/material.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/home/data/post_api.dart';
import 'package:farmbuzz/features/home/presentation/widgets/post_card.dart';
import 'package:farmbuzz/features/profile/data/profile_api.dart';
import 'package:farmbuzz/features/profile/data/social_api.dart';
import 'package:farmbuzz/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/profile_tabs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PostApi _postApi = PostApi();
  final ProfileApi _profileApi = ProfileApi();
  final SocialApi _socialApi = SocialApi();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _hasError = false;
  bool _isUploadingAvatar = false;
  bool _isUploadingCover = false;
  List<Map<String, dynamic>> _myPosts = [];
  int _followersCount = 0;
  int _followingCount = 0;
  String? _localAvatarPath;
  String? _localCoverPath;

  @override
  void initState() {
    super.initState();
    _loadProfilePosts();
  }

  Future<void> _loadProfilePosts() async {
    try {
      final posts = await _postApi.getPosts(
        reactorName: AppSession.userName,
        authorName: AppSession.userName,
      );
      final mobileNumber = AppSession.mobileNumber;
      Map<String, dynamic> counts = const {};
      if (mobileNumber != null && mobileNumber.trim().isNotEmpty) {
        counts = await _socialApi.getCounts(mobileNumber: mobileNumber);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _myPosts = posts;
        _followersCount = ((counts['followers_count'] ?? 0) as num).toInt();
        _followingCount = ((counts['following_count'] ?? 0) as num).toInt();
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
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

  Future<void> _openEditProfile() async {
    final updatedName = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialName: AppSession.userName),
      ),
    );

    if (updatedName == null || updatedName.trim().isEmpty || !mounted) {
      return;
    }

    try {
      final mobileNumber = AppSession.mobileNumber;
      if (mobileNumber == null || mobileNumber.trim().isEmpty) {
        throw const ProfileApiException('No mobile number in session. Please login again.');
      }

      final data = await _profileApi.updateProfile(
        mobileNumber: mobileNumber,
        name: updatedName,
      );

      AppSession.setUserName(data['name'] ?? updatedName);
      AppSession.setProfileMedia(
        avatarUrl: data['avatar_url'],
        coverPhotoUrl: data['cover_photo_url'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = true;
      });
      await _loadProfilePosts();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickProfileAvatar() async {
    final picked = await _pickFromSource();
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _localAvatarPath = picked.path;
      _isUploadingAvatar = true;
    });

    try {
      final mobileNumber = AppSession.mobileNumber;
      if (mobileNumber == null || mobileNumber.trim().isEmpty) {
        throw const ProfileApiException('No mobile number in session. Please login again.');
      }

      final media = await _profileApi.updateProfileMedia(
        mobileNumber: mobileNumber,
        avatarPath: picked.path,
      );

      AppSession.setProfileMedia(
        avatarUrl: media['avatar_url'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _localAvatarPath = null;
      });
      await _loadProfilePosts();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _localAvatarPath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avatar upload failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  Future<void> _pickCoverPhoto() async {
    final picked = await _pickFromSource();
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _localCoverPath = picked.path;
      _isUploadingCover = true;
    });

    try {
      final mobileNumber = AppSession.mobileNumber;
      if (mobileNumber == null || mobileNumber.trim().isEmpty) {
        throw const ProfileApiException('No mobile number in session. Please login again.');
      }

      final media = await _profileApi.updateProfileMedia(
        mobileNumber: mobileNumber,
        coverPhotoPath: picked.path,
      );

      AppSession.setProfileMedia(
        coverPhotoUrl: media['cover_photo_url'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _localCoverPath = null;
      });
      await _loadProfilePosts();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cover photo updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _localCoverPath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cover upload failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingCover = false;
        });
      }
    }
  }

  Future<XFile?> _pickFromSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return null;
    }

    try {
      return await _imagePicker.pickImage(source: source);
    } catch (error) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open image picker: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsCount = _myPosts.length;

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
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Unable to load profile right now.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _hasError = false;
                            });
                            _loadProfilePosts();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ProfileHeader(
                            userName: AppSession.userName,
                            avatarUrl: AppSession.avatarUrlOrEmpty,
                            coverPhotoUrl: AppSession.coverPhotoUrlOrEmpty,
                            localAvatarPath: _localAvatarPath,
                            localCoverPath: _localCoverPath,
                            joinedLabel: _joinedLabel(),
                            onEditAvatar: _isUploadingAvatar ? () {} : _pickProfileAvatar,
                            onEditCover: _isUploadingCover ? () {} : _pickCoverPhoto,
                            onEditProfile: _openEditProfile,
                          ),
                          if (_isUploadingAvatar || _isUploadingCover)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  alignment: Alignment.topCenter,
                                  padding: const EdgeInsets.only(top: 90),
                                  child: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.4),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      ProfileStats(
                        followersCount: _followersCount,
                        followingCount: _followingCount,
                        postsCount: postsCount,
                        birdsCount: 0,
                      ),
                      ProfileTabs(postsCount: postsCount, birdsCount: 0),
                      const SizedBox(height: 24),
                      if (_myPosts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                          child: Text(
                            'No posts yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Column(
                          children: _myPosts.map((post) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PostCard(
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
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }
}
