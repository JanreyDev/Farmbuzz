import 'package:flutter/material.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/home/data/post_api.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.postId,
    required this.userName,
    this.onCommentCountChanged,
  });

  final int postId;
  final String userName;
  final ValueChanged<int>? onCommentCountChanged;

  static Future<void> show(
    BuildContext context, {
    required int postId,
    required String userName,
    ValueChanged<int>? onCommentCountChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => CommentsSheet(
        postId: postId,
        userName: userName,
        onCommentCountChanged: onCommentCountChanged,
      ),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final PostApi _postApi = PostApi();

  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _postApi.getComments(widget.postId);
      if (!mounted) {
        return;
      }

      setState(() {
        _comments = comments;
        _isLoading = false;
      });

      widget.onCommentCountChanged?.call(_comments.length);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final result = await _postApi.addComment(
        postId: widget.postId,
        authorName: AppSession.userName,
        authorAvatar: AppSession.avatarUrl,
        content: text,
      );

      final comment = result['comment'];
      final commentsCount =
          int.tryParse((result['commentsCount'] ?? '0').toString()) ??
          _comments.length;

      if (!mounted) {
        return;
      }

      setState(() {
        if (comment is Map<String, dynamic>) {
          _comments.insert(0, {
            'id': comment['id'],
            'name': (comment['name'] ?? AppSession.userName).toString(),
            'avatar':
                (comment['avatar'] ?? AppSession.avatarUrl).toString(),
            'text': (comment['text'] ?? '').toString(),
            'time': (comment['time'] ?? 'now').toString(),
          });
        }
        _commentController.clear();
      });

      widget.onCommentCountChanged?.call(commentsCount);
      FocusScope.of(context).unfocus();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet. Be the first to comment.',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
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
                          avatar:
                              (comment['avatar'] ??
                                      'https://i.pravatar.cc/150?u=farmbuzz-comment')
                                  .toString(),
                        ),
                      );
                    },
                  ),
          ),
          _buildInputBar(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Text(
            "${widget.userName}'s Post",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.all(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(AppSession.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      onSubmitted: (_) => _addComment(),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSending ? null : _addComment,
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: AppColors.accentGreen,
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatar)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
