import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/core/network/media_proxy.dart';
import 'package:farmbuzz/features/home/data/post_api.dart';
import 'package:farmbuzz/features/profile/presentation/profile_screen.dart';
import 'package:farmbuzz/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'comments_sheet.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    this.postId,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.postText,
    this.postImageUrl,
    this.localImagePaths,
    this.likesCount = '0',
    this.commentsCount = '0',
    this.userReaction,
    this.topReactions,
  });

  final int? postId;
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String postText;
  final String? postImageUrl;
  final List<String>? localImagePaths;
  final String likesCount;
  final String commentsCount;
  final String? userReaction;
  final List<String>? topReactions;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostApi _postApi = PostApi();
  final Map<String, Future<Uint8List?>> _networkImageFutures = {};

  bool _showReactions = false;
  bool _isLiked = false;
  bool _isLikeLoading = false;

  String _selectedReaction = '';
  late int _currentLikes;
  late int _currentComments;
  late List<String> _topReactions;

  final List<String> _reactions = const [
    '\u{1F44D}',
    '\u{2764}\u{FE0F}',
    '\u{1F602}',
    '\u{1F62E}',
    '\u{1F622}',
    '\u{1F621}',
  ];

  String _ownerInitial() {
    final name = widget.userName.trim();
    if (name.isEmpty) {
      return 'U';
    }
    return name.substring(0, 1).toUpperCase();
  }

  bool _hasValidAvatarUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _reactionLabel(String reaction) {
    switch (reaction) {
      case '\u{1F44D}':
        return 'Like';
      case '\u{2764}\u{FE0F}':
        return 'Heart';
      case '\u{1F602}':
        return 'Haha';
      case '\u{1F62E}':
        return 'Wow';
      case '\u{1F622}':
        return 'Sad';
      case '\u{1F621}':
        return 'Angry';
      default:
        return 'React';
    }
  }

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final identityChanged =
        oldWidget.postId != widget.postId ||
        oldWidget.likesCount != widget.likesCount ||
        oldWidget.commentsCount != widget.commentsCount ||
        oldWidget.userReaction != widget.userReaction ||
        oldWidget.topReactions != widget.topReactions;

    if (identityChanged) {
      _syncFromWidget();
    }
  }

  void _syncFromWidget() {
    _currentLikes = int.tryParse(widget.likesCount) ?? 0;
    _currentComments = int.tryParse(widget.commentsCount) ?? 0;
    _selectedReaction = widget.userReaction ?? '';
    _isLiked = _selectedReaction.isNotEmpty;
    _topReactions = List<String>.from(widget.topReactions ?? const <String>[]);
  }

  Future<void> _onReactionSelected(String reaction) async {
    await _setReaction(reaction);
    if (mounted) {
      setState(() => _showReactions = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading || widget.postId == null) {
      if (widget.postId == null) {
        setState(() {
          _isLiked = !_isLiked;
          _currentLikes = _isLiked
              ? _currentLikes + 1
              : (_currentLikes > 0 ? _currentLikes - 1 : 0);
          _selectedReaction = _isLiked ? '\u{1F44D}' : '';
        });
      }
      return;
    }

    try {
      if (_isLiked) {
        setState(() => _isLikeLoading = true);

        final response = await _postApi.unlikePost(
          postId: widget.postId!,
          reactorName: AppSession.userName,
        );

        final parsedLikes =
            int.tryParse((response['likesCount'] ?? '0').toString()) ??
            _currentLikes;

        if (!mounted) {
          return;
        }

        setState(() {
          _isLiked = false;
          _selectedReaction = '';
          _currentLikes = parsedLikes;
          _topReactions = List<String>.from(
            (response['topReactions'] as List?)?.whereType<String>() ??
                const <String>[],
          );
        });
      } else {
        await _setReaction('\u{1F44D}');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLikeLoading = false);
      }
    }
  }

  Future<void> _setReaction(String reaction) async {
    if (_isLikeLoading || widget.postId == null) {
      return;
    }

    setState(() => _isLikeLoading = true);

    try {
      final response = await _postApi.likePost(
        postId: widget.postId!,
        reactorName: AppSession.userName,
        reaction: reaction,
      );

      final parsedLikes =
          int.tryParse((response['likesCount'] ?? '0').toString()) ??
          _currentLikes;
      final updatedReaction = response['userReaction']?.toString() ?? reaction;

      if (!mounted) {
        return;
      }

      setState(() {
        _isLiked = true;
        _currentLikes = parsedLikes;
        _selectedReaction = updatedReaction;
        _topReactions = List<String>.from(
          (response['topReactions'] as List?)?.whereType<String>() ??
              const <String>[],
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLikeLoading = false);
      }
    }
  }

  Future<void> _openComments() async {
    if (widget.postId == null) {
      return;
    }

    await CommentsSheet.show(
      context,
      postId: widget.postId!,
      userName: widget.userName,
      onCommentCountChanged: (count) {
        if (mounted) {
          setState(() => _currentComments = count);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildContent(),
              _buildMediaSection(),
              _buildEngagementStats(),
              const Divider(
                height: 1,
                thickness: 0.5,
                indent: 16,
                endIndent: 16,
              ),
              _buildActionButtons(),
            ],
          ),
          if (_showReactions) _buildReactionOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isMyPost =
        widget.userName.trim().toLowerCase() ==
        AppSession.userName.trim().toLowerCase();
    final resolvedAvatar = isMyPost
        ? (AppSession.avatarUrlOrEmpty.trim().isNotEmpty
              ? AppSession.avatarUrlOrEmpty
              : widget.userAvatar)
        : widget.userAvatar;
    final proxiedAvatar = resolveMediaUrl(resolvedAvatar);
    final hasAvatar = _hasValidAvatarUrl(proxiedAvatar);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _openProfileFromPost,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE8F5E9),
              backgroundImage: hasAvatar ? NetworkImage(proxiedAvatar) : null,
              child: hasAvatar
                  ? null
                  : Text(
                      _ownerInitial(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _openProfileFromPost,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${widget.timeAgo} • ',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    Icon(Icons.public, size: 10, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        widget.postText,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    final hasLocalImages =
        widget.localImagePaths != null && widget.localImagePaths!.isNotEmpty;
    final hasNetworkImage = widget.postImageUrl != null;

    if (!hasLocalImages && !hasNetworkImage) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildMediaGrid(hasLocalImages),
      ),
    );
  }

  Widget _buildMediaGrid(bool isLocal) {
    if (isLocal) {
      final providers = widget.localImagePaths!
          .map(_providerForPath)
          .whereType<ImageProvider>()
          .toList();
      final count = providers.length;

      if (count == 0) {
        return const SizedBox.shrink();
      }

      if (count == 1) {
        return _buildLargeImage(providers[0]);
      }
      if (count == 2) {
        return Row(
          children: [
            Expanded(child: _buildSquareImage(providers[0])),
            const SizedBox(width: 2),
            Expanded(child: _buildSquareImage(providers[1])),
          ],
        );
      }
      if (count == 3) {
        return SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildImage(providers[0])),
              const SizedBox(width: 2),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(child: _buildImage(providers[1])),
                    const SizedBox(height: 2),
                    Expanded(child: _buildImage(providers[2])),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return SizedBox(
        height: 300,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(providers[0])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(providers[1])),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(providers[2])),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(providers[3]),
                        if (count > 4)
                          Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: Text(
                              '+${count - 3}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _buildLargeImage(
      NetworkImage(resolveMediaUrl(widget.postImageUrl!)),
    );
  }

  Widget _buildLargeImage(ImageProvider provider) {
    if (provider is NetworkImage) {
      return _buildReliableNetworkImage(
        provider.url,
        width: double.infinity,
        height: 300,
      );
    }

    return Image(
      image: provider,
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) {
        debugPrint('Post image load failed: $error');
        return _imageFallback(height: 220);
      },
    );
  }

  Widget _buildSquareImage(ImageProvider provider) {
    if (provider is NetworkImage) {
      return AspectRatio(
        aspectRatio: 1,
        child: _buildReliableNetworkImage(provider.url),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Image(
        image: provider,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) {
          debugPrint('Post image load failed: $error');
          return _imageFallback();
        },
      ),
    );
  }

  Widget _buildImage(ImageProvider provider) {
    if (provider is NetworkImage) {
      return _buildReliableNetworkImage(
        provider.url,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Image(
      image: provider,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) {
        debugPrint('Post image load failed: $error');
        return _imageFallback();
      },
    );
  }

  ImageProvider? _providerForPath(String rawPath) {
    final path = rawPath.trim();
    if (path.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(resolveMediaUrl(path));
    }

    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }

    return FileImage(file);
  }

  Widget _imageFallback({double? height}) {
    return Container(
      height: height,
      color: const Color(0xFFF1F3F5),
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined, color: Colors.grey[500]),
    );
  }

  Widget _buildReliableNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final future = _networkImageFutures[url] ??= _fetchImageBytesWithRetry(url);

    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF1F3F5),
          );
        }

        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return _imageFallback(height: height);
        }

        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, error, stackTrace) {
            debugPrint('Post image decode failed: $error');
            return _imageFallback(height: height);
          },
        );
      },
    );
  }

  Future<Uint8List?> _fetchImageBytesWithRetry(String url) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await http
            .get(
              Uri.parse(url),
              headers: const <String, String>{
                'Accept': 'image/*,*/*',
              },
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            response.bodyBytes.isNotEmpty) {
          return response.bodyBytes;
        }
      } catch (error) {
        debugPrint(
          'Post image fetch failed (attempt ${attempt + 1}/3): $error, url=$url',
        );
      }

      if (attempt < 2) {
        await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }

    return null;
  }

  Widget _buildEngagementStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_topReactions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _topReactions
                  .map(
                    (emoji) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Text(emoji, style: const TextStyle(fontSize: 16)),
                    ),
                  )
                  .toList(),
            )
          else
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.thumb_up, size: 10, color: Colors.white),
            ),
          const SizedBox(width: 6),
          Text(
            '$_currentLikes',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
          ),
          const Spacer(),
          Text(
            '$_currentComments comments',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onLongPress: () => setState(() => _showReactions = true),
              onTap: _toggleLike,
              child: _PostAction(
                icon: _selectedReaction.isEmpty
                    ? Icons.thumb_up_outlined
                    : null,
                label: _isLikeLoading
                    ? 'Saving...'
                    : (_isLiked ? _reactionLabel(_selectedReaction) : 'Like'),
                reaction: _selectedReaction,
                color: _isLiked ? AppColors.accentGreen : null,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _openComments,
              child: const _PostAction(
                icon: Icons.chat_bubble_outline,
                label: 'Comment',
              ),
            ),
          ),
          const Expanded(
            child: _PostAction(icon: Icons.share_outlined, label: 'Share'),
          ),
        ],
      ),
    );
  }

  void _openProfileFromPost() {
    final isOwner =
        widget.userName.trim().toLowerCase() ==
        AppSession.userName.trim().toLowerCase();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isOwner
            ? const ProfileScreen()
            : PublicProfileScreen(
                userName: widget.userName,
                userAvatar: widget.userAvatar,
              ),
      ),
    );
  }

  Widget _buildReactionOverlay() {
    return Positioned(
      bottom: 44,
      left: 0,
      right: 0,
      child: Center(
        child: _ReactionOverlay(
          reactions: _reactions,
          onSelected: _onReactionSelected,
          onDismiss: () => setState(() => _showReactions = false),
        ),
      ),
    );
  }
}

class _ReactionOverlay extends StatelessWidget {
  const _ReactionOverlay({
    required this.reactions,
    required this.onSelected,
    required this.onDismiss,
  });

  final List<String> reactions;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions
            .map(
              (emoji) =>
                  _ReactionButton(emoji: emoji, onTap: () => onSelected(emoji)),
            )
            .toList(),
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  const _ReactionButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (val) => setState(() => _isHovered = val),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedScale(
          scale: _isHovered ? 1.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(widget.emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({
    this.icon,
    required this.label,
    this.reaction = '',
    this.color,
  });

  final IconData? icon;
  final String label;
  final String reaction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (reaction.isNotEmpty)
            Text(reaction, style: const TextStyle(fontSize: 18))
          else if (icon != null)
            Icon(icon, size: 18, color: color ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color ?? Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
