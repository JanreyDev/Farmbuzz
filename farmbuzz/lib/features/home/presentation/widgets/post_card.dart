import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'comments_sheet.dart';

/// A premium, high-density post card for the home feed.
/// Features interactive reactions (long-press), engagement stats, and supports sophisticated local/network media grids.
class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.postText,
    this.postImageUrl,
    this.localImagePaths,
    this.likesCount = '0',
    this.commentsCount = '0',
  });

  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String postText;
  final String? postImageUrl;
  final List<String>? localImagePaths;
  final String likesCount;
  final String commentsCount;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Reaction State
  bool _showReactions = false;
  String _selectedReaction = '';
  late int _currentLikes;
  bool _isLiked = false;

  final List<String> _reactions = const ['👍', '❤️', '😂', '😮', '😢', '😡'];

  @override
  void initState() {
    super.initState();
    _currentLikes = int.tryParse(widget.likesCount) ?? 0;
  }

  void _onReactionSelected(String reaction) {
    setState(() {
      if (!_isLiked) {
        _currentLikes++;
        _isLiked = true;
      }
      _selectedReaction = reaction;
      _showReactions = false;
    });
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _currentLikes--;
        _isLiked = false;
        _selectedReaction = '';
      } else {
        _currentLikes++;
        _isLiked = true;
        _selectedReaction = '👍';
      }
    });
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
              const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
              _buildActionButtons(),
            ],
          ),
          
          if (_showReactions) _buildReactionOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(widget.userAvatar),
          ),
          const SizedBox(width: 12),
          Column(
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
                    style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11),
                  ),
                  Icon(Icons.public, size: 10, color: Colors.grey[600]),
                ],
              ),
            ],
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
    final hasLocalImages = widget.localImagePaths != null && widget.localImagePaths!.isNotEmpty;
    final hasNetworkImage = widget.postImageUrl != null;

    if (!hasLocalImages && !hasNetworkImage) return const SizedBox.shrink();

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
      final paths = widget.localImagePaths!;
      final count = paths.length;

      if (count == 1) {
        return _buildLargeImage(FileImage(File(paths[0])));
      } else if (count == 2) {
        return Row(
          children: [
            Expanded(child: _buildSquareImage(FileImage(File(paths[0])))),
            const SizedBox(width: 2),
            Expanded(child: _buildSquareImage(FileImage(File(paths[1])))),
          ],
        );
      } else if (count == 3) {
        return SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildImage(FileImage(File(paths[0])))),
              const SizedBox(width: 2),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(child: _buildImage(FileImage(File(paths[1])))),
                    const SizedBox(height: 2),
                    Expanded(child: _buildImage(FileImage(File(paths[2])))),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        // 4 or more
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildImage(FileImage(File(paths[0])))),
                    const SizedBox(width: 2),
                    Expanded(child: _buildImage(FileImage(File(paths[1])))),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildImage(FileImage(File(paths[2])))),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImage(FileImage(File(paths[3]))),
                          if (count > 4)
                            Container(
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: Text(
                                '+${count - 3}',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
    } else {
      return _buildLargeImage(NetworkImage(widget.postImageUrl!));
    }
  }

  Widget _buildLargeImage(ImageProvider provider) {
    return Image(
      image: provider,
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
    );
  }

  Widget _buildSquareImage(ImageProvider provider) {
    return AspectRatio(
      aspectRatio: 1,
      child: Image(
        image: provider,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildImage(ImageProvider provider) {
    return Image(
      image: provider,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildEngagementStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_selectedReaction.isNotEmpty)
            Text(_selectedReaction, style: const TextStyle(fontSize: 16))
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
            '${widget.commentsCount} comments',
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
                icon: _selectedReaction.isEmpty ? Icons.thumb_up_outlined : null,
                label: _isLiked ? 'Liked' : 'Like',
                reaction: _selectedReaction,
                color: _isLiked ? AppColors.accentGreen : null,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => CommentsSheet.show(context, widget.userName),
              child: const _PostAction(icon: Icons.chat_bubble_outline, label: 'Comment'),
            ),
          ),
          const Expanded(child: _PostAction(icon: Icons.share_outlined, label: 'Share')),
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
        children: reactions.map((emoji) => _ReactionButton(
          emoji: emoji,
          onTap: () => onSelected(emoji),
        )).toList(),
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
            child: Text(
              widget.emoji,
              style: const TextStyle(fontSize: 26),
            ),
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
    this.color
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
