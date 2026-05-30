import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/core/network/media_proxy.dart';
import 'package:farmbuzz/features/home/data/post_api.dart';
import 'package:farmbuzz/features/home/data/story_api.dart';
import 'post_card.dart';
import 'story_view_screen.dart';
import 'create_story_modal.dart';
import 'create_post_modal.dart';

class HomeFeedView extends StatefulWidget {
  const HomeFeedView({super.key});

  @override
  State<HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<HomeFeedView> {
  final ScrollController _scrollController = ScrollController();
  final PostApi _postApi = PostApi();
  final StoryApi _storyApi = StoryApi();
  bool _isLoadingPosts = true;
  bool _hasPostLoadError = false;
  bool _hasAutoRetried = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback with a small delay to ensure
    // AppSession is fully populated after login navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _loadPosts();
          _loadStories();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Post state
  List<Map<String, dynamic>> _posts = [];

  Future<void> _loadPosts() async {
    try {
      final posts = await _postApi.getPosts(reactorName: AppSession.userName);

      if (!mounted) {
        return;
      }

      // If result is empty and we haven't retried yet, retry once after a delay.
      // This handles cases where the session data wasn't ready on the first try.
      if (posts.isEmpty && !_hasAutoRetried) {
        _hasAutoRetried = true;
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) await _loadPosts();
        return;
      }

      setState(() {
        _posts = posts;
        _hasPostLoadError = false;
        _isLoadingPosts = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      // Auto-retry once on network errors during initial load
      if (!_hasAutoRetried) {
        _hasAutoRetried = true;
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) await _loadPosts();
        return;
      }

      setState(() {
        _hasPostLoadError = true;
        _isLoadingPosts = false;
      });
    }
  }

  // Dynamic stories state
  List<Map<String, dynamic>> _dynamicStories = [];

  Future<void> _loadStories() async {
    try {
      final stories = await _storyApi.getStories();
      if (!mounted) {
        return;
      }
      setState(() {
        _dynamicStories = stories;
      });
    } catch (_) {
      // Keep UI usable even if stories fail to load
    }
  }

  Future<void> _addNewStory(String imagePath) async {
    final mobileNumber = AppSession.mobileNumber;
    if (mobileNumber == null || mobileNumber.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again to create a story.')),
      );
      return;
    }

    try {
      await _storyApi.createStory(
        mobileNumber: mobileNumber,
        imagePath: imagePath,
      );
      await _loadStories();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _addNewPost(String text, List<String> imagePaths) async {
    await _postApi.createPost(
      authorName: AppSession.userName,
      authorAvatar: AppSession.avatarUrlOrEmpty,
      content: text,
      imagePaths: imagePaths,
    );

    await _loadPosts();

    // Scroll to top to show the new post
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasPostLoadError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unable to load posts right now.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoadingPosts = true;
                    _hasPostLoadError = false;
                  });
                  _loadPosts();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _loadPosts(),
          _loadStories(),
        ]);
      },
      color: AppColors.accentGreen,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusUpdateBox(
              onTap: () =>
                  CreatePostModal.show(context, onPostCreated: _addNewPost),
            ),
            _StoriesSection(
              dynamicStories: _dynamicStories,
              onAddStory: _addNewStory,
            ),
            const _FilterTabs(),
            if (_posts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.feed_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No posts yet. Create the first one!',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  final postId = post['id'] as int?;
                  return PostCard(
                    key: ValueKey<String>(
                      postId != null ? 'post-$postId' : 'post-index-$index',
                    ),
                    postId: postId,
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
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusUpdateBox extends StatelessWidget {
  const _StatusUpdateBox({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = AppSession.avatarUrlOrEmpty;
    final proxiedAvatarUrl = resolveMediaUrl(avatarUrl);
    final hasAvatar = _hasValidAvatarUrl(proxiedAvatarUrl);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE8F5E9),
            backgroundImage: hasAvatar ? NetworkImage(proxiedAvatarUrl) : null,
            child: hasAvatar
                ? null
                : Text(
                    _initial(),
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "What's happening on your farm?",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onTap,
                child: Icon(
                  Icons.videocam_outlined,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasValidAvatarUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _initial() {
    final name = AppSession.userName.trim();
    if (name.isEmpty) {
      return 'U';
    }
    return name.substring(0, 1).toUpperCase();
  }
}

class _StoriesSection extends StatelessWidget {
  const _StoriesSection({
    required this.dynamicStories,
    required this.onAddStory,
  });

  final List<Map<String, dynamic>> dynamicStories;
  final Future<void> Function(String) onAddStory;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _AddStoryCard(onAddStory: onAddStory),
          ...dynamicStories
              .where(
                (story) =>
                    ((story['imageUrl'] ?? '').toString().trim().isNotEmpty),
              )
              .map(
                (story) => _StoryCard(
                  name: (story['name'] ?? 'Unknown').toString(),
                  time: (story['timeAgo'] ?? 'Just now').toString(),
                  imageUrl: (story['imageUrl'] ?? '').toString(),
                  avatarUrl: (story['avatarUrl'] ?? '').toString(),
                  isNew: true,
                  isLocal: false,
                ),
              ),
        ],
      ),
    );
  }
}

class _AddStoryCard extends StatelessWidget {
  const _AddStoryCard({required this.onAddStory});

  final Future<void> Function(String) onAddStory;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = AppSession.avatarUrlOrEmpty;
    final proxiedAvatarUrl = resolveMediaUrl(avatarUrl);
    final hasAvatar = _hasValidAvatarUrl(proxiedAvatarUrl);

    return InkWell(
      onTap: () => CreateStoryModal.show(context, onStoryCreated: onAddStory),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: hasAvatar
                      ? DecorationImage(
                          image: NetworkImage(proxiedAvatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasAvatar
                    ? null
                    : Center(
                        child: Text(
                          _initial(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 12),
                        Text(
                          'Create story',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
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

  bool _hasValidAvatarUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _initial() {
    final name = AppSession.userName.trim();
    if (name.isEmpty) {
      return 'U';
    }
    return name.substring(0, 1).toUpperCase();
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.name,
    required this.time,
    required this.imageUrl,
    required this.avatarUrl,
    this.isNew = false,
    this.isLocal = false,
  });

  final String name;
  final String time;
  final String imageUrl;
  final String avatarUrl;
  final bool isNew;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = resolveMediaUrl(imageUrl);
    final resolvedAvatarUrl = resolveMediaUrl(avatarUrl);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryViewScreen(
              userName: name,
              avatarUrl: resolvedAvatarUrl,
              imageUrl: resolvedImageUrl,
              isLocal: isLocal,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: isLocal
                ? FileImage(File(imageUrl)) as ImageProvider
                : NetworkImage(resolvedImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isNew
                      ? AppColors.accentGreen
                      : Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: safeNetworkImage(resolvedAvatarUrl),
                  child: safeNetworkImage(resolvedAvatarUrl) == null
                      ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 9,
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

class _FilterTabs extends StatelessWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            _FilterChip(
              label: 'For You',
              icon: Icons.auto_awesome,
              isActive: true,
            ),
            _FilterChip(label: 'Following', icon: Icons.person_outline),
            _FilterChip(label: 'Reels', icon: Icons.play_circle_outline),
            _FilterChip(label: 'Trending', icon: Icons.trending_up),
            _FilterChip(label: 'Bantay', icon: Icons.security_outlined),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.accentGreen
              : Colors.grey.withOpacity(0.2),
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
          Icon(
            icon,
            size: 16,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
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
    );
  }
}
