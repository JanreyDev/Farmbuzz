import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/feed_api.dart';
import '../profile_screen.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    required this.postId,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.postText,
    required this.metaEmoji,
    required this.metaFeeling,
    required this.metaLocation,
    required this.userReaction,
    required this.likesCount,
    required this.commentsCount,
    required this.topReactions,
    required this.imageUrls,
  });

  final int postId;
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String postText;
  final String metaEmoji;
  final String metaFeeling;
  final String metaLocation;
  final String userReaction;
  final int likesCount;
  final int commentsCount;
  final List<String> topReactions;
  final List<String> imageUrls;

  @override
  State<PostCard> createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  static const double _mediaTileGap = 2;
  final FeedApi _api = FeedApi();
  bool _showReactions = false;
  bool _isLikeBusy = false;
  String _selectedReaction = '';
  late int _currentLikes;
  late int _currentComments;
  late List<String> _topReactions;
  late List<Map<String, String>> _comments;
  bool _commentsLoaded = false;
  final List<String> _reactions = const [
    '\u{1F44D}',
    '\u{2764}\u{FE0F}',
    '\u{1F602}',
    '\u{1F62E}',
    '\u{1F622}',
    '\u{1F621}',
  ];

  @override
  void initState() {
    super.initState();
    _currentLikes = widget.likesCount;
    _currentComments = widget.commentsCount;
    _topReactions = List<String>.from(widget.topReactions);
    _selectedReaction = widget.userReaction;
    _comments = <Map<String, String>>[];
  }

  String _initial() {
    final trimmed = widget.userName.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  bool get _hasUserAvatar => widget.userAvatar.trim().isNotEmpty;

  bool get _hasMetaLine =>
      widget.metaFeeling.trim().isNotEmpty ||
      widget.metaLocation.trim().isNotEmpty;

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
        return 'Like';
    }
  }

  Future<void> _onReactionSelected(String reaction) async {
    setState(() => _showReactions = false);
    await _toggleReaction(reaction: reaction);
  }

  Future<String> _reactorName() async {
    final prefs = await SharedPreferences.getInstance();
    final name =
        prefs.getString('auth_user_name') ??
        prefs.getString('auth_mobile_number') ??
        'FarmBuzz User';
    return name.trim().isEmpty ? 'FarmBuzz User' : name.trim();
  }

  Future<void> _toggleReaction({String reaction = '\u{1F44D}'}) async {
    if (_isLikeBusy) return;
    setState(() => _isLikeBusy = true);
    try {
      final reactor = await _reactorName();
      final isSame = _selectedReaction == reaction;
      final result = isSame
          ? await _api.unlikePost(postId: widget.postId, reactorName: reactor)
          : await _api.likePost(
              postId: widget.postId,
              reactorName: reactor,
              reaction: reaction,
            );
      if (!mounted) return;
      setState(() {
        _selectedReaction = result.userReaction;
        _currentLikes = result.likesCount;
        _topReactions = result.topReactions;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update reaction. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLikeBusy = false);
      }
    }
  }

  Future<void> _ensureCommentsLoaded() async {
    if (_commentsLoaded) return;
    try {
      final items = await _api.fetchComments(postId: widget.postId);
      if (!mounted) return;
      setState(() {
        _comments = items.map((e) => e.toMap()).toList();
        _currentComments = items.length;
        _commentsLoaded = true;
      });
    } catch (_) {}
  }

  Future<void> _openComments() async {
    await _ensureCommentsLoaded();
    if (!mounted) return;
    await _CommentsSheet.show(
      context,
      postId: widget.postId,
      userName: widget.userName,
      comments: _comments,
      api: _api,
      likesCount: _currentLikes,
      topReactions: _displayReactions,
      onCommentCountChanged: (count, updatedComments) {
        if (!mounted) {
          return;
        }
        setState(() {
          _currentComments = count;
          _comments = updatedComments;
        });
      },
    );
  }

  Future<void> _openProfile() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final myName =
        (prefs.getString('auth_user_name') ?? '').trim().toLowerCase();
    final postAuthor = widget.userName.trim().toLowerCase();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          viewUserName: myName == postAuthor ? null : widget.userName,
          viewUserAvatar: widget.userAvatar,
        ),
      ),
    );
  }


  List<String> get _displayReactions {
    final ordered = <String>[];
    if (_selectedReaction.isNotEmpty) {
      ordered.add(_selectedReaction);
    }
    for (final reaction in _topReactions) {
      if (!ordered.contains(reaction)) {
        ordered.add(reaction);
      }
    }
    return ordered.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + Name wrapped in one tappable area
                    Expanded(
                      child: GestureDetector(
                        onTap: _openProfile,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFE8F5E9),
                              backgroundImage: _hasUserAvatar
                                  ? NetworkImage(widget.userAvatar)
                                  : null,
                              onBackgroundImageError: _hasUserAvatar ? (_, _) {} : null,
                              child: _hasUserAvatar
                                  ? null
                                  : Text(
                                      _initial(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  if (_hasMetaLine) ...[
                                    const SizedBox(height: 1),
                                    Text.rich(
                                      TextSpan(
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF374151),
                                          height: 1.15,
                                        ),
                                        children: [
                                          if (widget.metaFeeling.trim().isNotEmpty) ...[
                                            const TextSpan(text: 'is feeling '),
                                            TextSpan(text: '${widget.metaEmoji} '),
                                            TextSpan(text: widget.metaFeeling.trim()),
                                          ],
                                          if (widget.metaFeeling.trim().isNotEmpty &&
                                              widget.metaLocation.trim().isNotEmpty)
                                            const TextSpan(text: ' at '),
                                          if (widget.metaLocation
                                              .trim()
                                              .isNotEmpty) ...[
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 3,
                                                ),
                                                child: Icon(
                                                  Icons.location_on,
                                                  size: 13,
                                                  color: AppColors.accentGreen,
                                                ),
                                              ),
                                            ),
                                            TextSpan(
                                              text: widget.metaLocation.trim(),
                                              style: const TextStyle(
                                                color: AppColors.accentGreen,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Row(
                                    children: [
                                      Text(
                                        widget.timeAgo,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                      ),
                                      const Text(
                                        ' \u2022 ',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 11,
                                        ),
                                      ),
                                      Icon(
                                        Icons.public,
                                        size: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  widget.postText,
                  style: const TextStyle(
                    fontSize: 30 / 2,
                    height: 1.5,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _buildMediaSection(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _TopReactionsCluster(reactions: _displayReactions),
                    const SizedBox(width: 10),
                    Text(
                      '$_currentLikes',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '$_currentComments comments',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withValues(alpha: 0.22),
                indent: 0,
                endIndent: 0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () =>
                            setState(() => _showReactions = true),
                        onTap: () => _toggleReaction(),
                        child: _PostAction(
                          icon: _selectedReaction.isEmpty
                              ? Icons.thumb_up_outlined
                              : null,
                          label: _selectedReaction.isEmpty
                              ? 'Like'
                              : _reactionLabel(_selectedReaction),
                          reaction: _selectedReaction,
                          color: _selectedReaction.isEmpty
                              ? null
                              : AppColors.accentGreen,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _openComments,
                        child: _PostAction(
                          icon: Icons.chat_bubble_outline,
                          label: 'Comment',
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final shareText = widget.postText.trim().isNotEmpty
                              ? '${widget.userName} on FarmBuzz:\n"${widget.postText}"'
                              : '${widget.userName} shared a post on FarmBuzz.';
                          try {
                            await Share.share(shareText);
                            debugPrint('Share invoked with text: $shareText');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Share failed: $e')),
                            );
                          }
                        },
                        child: _PostAction(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showReactions) _buildReactionOverlay(),
        ],
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

  Widget _buildMediaSection() {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildMediaGrid(),
      ),
    );
  }

  Widget _buildMediaGrid() {
    final count = widget.imageUrls.length;

    if (count == 1) {
      return _networkImage(widget.imageUrls[0], height: 260);
    }

    if (count == 2) {
      return SizedBox(
        height: 220,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _networkImage(widget.imageUrls[0])),
            const SizedBox(width: _mediaTileGap),
            Expanded(child: _networkImage(widget.imageUrls[1])),
          ],
        ),
      );
    }

    if (count == 3) {
      return SizedBox(
        height: 260,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 2, child: _networkImage(widget.imageUrls[0])),
            const SizedBox(width: _mediaTileGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _networkImage(widget.imageUrls[1])),
                  const SizedBox(height: _mediaTileGap),
                  Expanded(child: _networkImage(widget.imageUrls[2])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _networkImage(widget.imageUrls[0])),
                const SizedBox(width: _mediaTileGap),
                Expanded(child: _networkImage(widget.imageUrls[1])),
              ],
            ),
          ),
          const SizedBox(height: _mediaTileGap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _networkImage(widget.imageUrls[2])),
                const SizedBox(width: _mediaTileGap),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _networkImage(widget.imageUrls[3]),
                      if (count > 4)
                        Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          alignment: Alignment.center,
                          child: Text(
                            '+${count - 4}',
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

  Widget _networkImage(String url, {double? height}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(color: const Color(0xFFE5E7EB));
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF1F3F5),
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: Colors.grey[500]),
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
    required this.color,
  });

  final IconData? icon;
  final String label;
  final String reaction;
  final Color? color;
  static const Color _defaultActionColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (reaction.isNotEmpty)
            _ReactionGlyph(reaction: reaction, size: 18)
          else if (icon != null)
            Icon(icon, size: 18, color: color ?? _defaultActionColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? _defaultActionColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.postId,
    required this.userName,
    required this.comments,
    required this.api,
    required this.likesCount,
    required this.topReactions,
    required this.onCommentCountChanged,
  });

  final int postId;
  final String userName;
  final List<Map<String, String>> comments;
  final FeedApi api;
  final int likesCount;
  final List<String> topReactions;
  final void Function(int count, List<Map<String, String>> comments)
  onCommentCountChanged;

  static Future<void> show(
    BuildContext context, {
    required int postId,
    required String userName,
    required List<Map<String, String>> comments,
    required FeedApi api,
    required int likesCount,
    required List<String> topReactions,
    required void Function(int count, List<Map<String, String>> comments)
    onCommentCountChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => _CommentsSheet(
        postId: postId,
        userName: userName,
        comments: comments,
        api: api,
        likesCount: likesCount,
        topReactions: topReactions,
        onCommentCountChanged: onCommentCountChanged,
      ),
    );
  }

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  late List<Map<String, String>> _comments;
  bool _isSendingComment = false;
  String _sortLabel = 'Most relevant';

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return '$value';
  }

  @override
  void initState() {
    super.initState();
    _comments = List<Map<String, String>>.from(widget.comments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSendingComment) return;
    setState(() => _isSendingComment = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final authorName =
          prefs.getString('auth_user_name') ??
          prefs.getString('auth_mobile_number') ??
          'FarmBuzz User';
      final result = await widget.api.addComment(
        postId: widget.postId,
        authorName: authorName.trim().isEmpty ? 'FarmBuzz User' : authorName,
        content: text,
      );
      if (!mounted) return;
      setState(() {
        _comments.insert(0, result.comment.toMap());
        _commentController.clear();
      });
      widget.onCommentCountChanged(result.commentsCount, _comments);
      FocusScope.of(context).unfocus();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add comment. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingComment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final reactionPreview = _formatCount(widget.likesCount);
    final headerReactions = widget.topReactions.isNotEmpty
        ? widget.topReactions
        : (widget.likesCount > 0 ? const ['\u{1F44D}'] : const <String>[]);

    return Container(
      height: size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFBFC5CA),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (headerReactions.isNotEmpty) ...[
                      _TopReactionsCluster(reactions: headerReactions),
                      const SizedBox(width: 6),
                      Text(
                        reactionPreview,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ] else
                      const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _sortLabel = _sortLabel == 'Most relevant'
                          ? 'Newest'
                          : 'Most relevant';
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  label: Text(
                    _sortLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet. Be the first to comment.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CommentItem(
                          name: (comment['name'] ?? '').toString(),
                          text: (comment['text'] ?? '').toString(),
                          time: (comment['time'] ?? 'now').toString(),
                          avatar: (comment['avatar'] ?? '').toString(),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=12',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      onSubmitted: (_) => _addComment(),
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                      cursorColor: Color(0xFF111827),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.name,
    required this.text,
    required this.time,
    required this.avatar,
  });

  final String name;
  final String text;
  final String time;
  final String avatar;

  String _initial() {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatar.trim().isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xFFE8F5E9),
          backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
          onBackgroundImageError: hasAvatar ? (_, _) {} : null,
          child: hasAvatar
              ? null
              : Text(
                  _initial(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                  ),
                ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.32,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
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
            color: Colors.black.withValues(alpha: 0.15),
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
            child: _ReactionGlyph(reaction: widget.emoji, size: 26),
          ),
        ),
      ),
    );
  }
}

class _TopReactionsCluster extends StatelessWidget {
  const _TopReactionsCluster({required this.reactions});

  final List<String> reactions;
  static const double _emojiSize = 16;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < reactions.length; i++) ...[
          _ReactionGlyph(reaction: reactions[i], size: _emojiSize),
          if (i != reactions.length - 1) const SizedBox(width: 2),
        ],
      ],
    );
  }
}

class _ReactionGlyph extends StatelessWidget {
  const _ReactionGlyph({required this.reaction, required this.size});

  final String reaction;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (reaction == '\u{2764}\u{FE0F}') {
      return Icon(Icons.favorite, color: const Color(0xFFE11D48), size: size);
    }

    return Text(
      reaction,
      style: TextStyle(fontSize: size),
      strutStyle: const StrutStyle(forceStrutHeight: true, height: 1),
    );
  }
}
