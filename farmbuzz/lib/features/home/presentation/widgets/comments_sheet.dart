import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

/// A premium, high-fidelity comments sheet for post interaction.
/// Supports threaded replies, filtering, and real-time posting simulation.
class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.userName});
  final String userName;

  /// Static utility to show the comments sheet.
  static void show(BuildContext context, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => CommentsSheet(userName: userName),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  late List<Map<String, dynamic>> _comments;

  @override
  void initState() {
    super.initState();
    _comments = _getRealisticComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Generates context-aware realistic comments based on the post author.
  List<Map<String, dynamic>> _getRealisticComments() {
    final name = widget.userName.toUpperCase();
    if (name.contains('TRIXIE')) {
      return [
        {
          'name': 'Farmer Joe',
          'text': 'How much for the whole batch? I\'m interested!',
          'time': '10m',
          'isLiked': true,
          'replies': [
            {
              'name': 'TRIXIE',
              'text': 'Sent you a DM, Joe! Check your inbox.',
              'time': '5m',
              'isLiked': false,
            }
          ],
        },
        {
          'name': 'Breeder Mike',
          'text': 'These look like high quality bloodlines. Great job!',
          'time': '2h',
          'isLiked': false,
          'replies': [],
        },
      ];
    } else if (name.contains('ALYSSA')) {
      return [
        {
          'name': 'Vet Sarah',
          'text': 'They look very healthy! Make sure to keep the temperature stable this week.',
          'time': '15m',
          'isLiked': true,
          'replies': [
            {
              'name': 'ALYSSA ROSE',
              'text': 'Thanks Doc! Already set the automated heater.',
              'time': '10m',
              'isLiked': false,
            }
          ],
        },
        {
          'name': 'Ken Farm',
          'text': 'Congrats on the new batch! Looking forward to seeing them grow.',
          'time': '1h',
          'isLiked': false,
          'replies': [],
        },
      ];
    } else {
      return [
        {
          'name': 'AgriExpert',
          'text': 'This is exactly what the industry needs right now. 👏',
          'time': '30m',
          'isLiked': true,
          'replies': [],
        },
        {
          'name': 'Local Farmer',
          'text': 'Very informative post! Thanks for sharing your process.',
          'time': '3h',
          'isLiked': false,
          'replies': [],
        },
      ];
    }
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _comments.insert(0, {
        'name': 'Janrey',
        'text': text,
        'time': 'now',
        'isLiked': false,
        'replies': [],
      });
      _commentController.clear();
    });
    
    FocusScope.of(context).unfocus();
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
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _CommentItem(
                    name: comment['name'],
                    text: comment['text'],
                    time: comment['time'],
                    initialIsLiked: comment['isLiked'],
                    replies: (comment['replies'] as List).map((r) => _CommentItem(
                      name: r['name'],
                      text: r['text'],
                      time: r['time'],
                      isReply: true,
                      initialIsLiked: r['isLiked'],
                    )).toList(),
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

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _FilterChip(label: 'Most Relevant', isActive: true),
                  SizedBox(width: 8),
                  _FilterChip(label: 'Newest'),
                  SizedBox(width: 8),
                  _FilterChip(label: 'All Comments'),
                ],
              ),
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
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janrey'),
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  _InputIcon(icon: Icons.sentiment_satisfied_alt_outlined),
                  const SizedBox(width: 10),
                  _InputIcon(icon: Icons.camera_alt_outlined),
                  const SizedBox(width: 10),
                  _InputIcon(icon: Icons.videocam_outlined),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _addComment,
                    child: const Icon(Icons.send_rounded, size: 20, color: AppColors.accentGreen),
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

class _InputIcon extends StatelessWidget {
  const _InputIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 20, color: Colors.grey[600]);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.isActive = false});
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.black : Colors.transparent),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          color: isActive ? Colors.black : Colors.grey[600],
        ),
      ),
    );
  }
}

class _CommentItem extends StatefulWidget {
  const _CommentItem({
    required this.name,
    required this.text,
    required this.time,
    this.isReply = false,
    this.initialIsLiked = false,
    this.replies = const [],
  });

  final String name;
  final String text;
  final String time;
  final bool isReply;
  final bool initialIsLiked;
  final List<_CommentItem> replies;

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _showReplies = true;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: widget.isReply ? 14 : 18,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${widget.name.toLowerCase().replaceAll(' ', '')}'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCommentBubble(),
              const SizedBox(height: 4),
              _buildActionRow(),
              if (widget.replies.isNotEmpty) _buildRepliesSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Text(
            widget.time,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => setState(() => _isLiked = !_isLiked),
            child: _ActionText(
              'Like', 
              color: _isLiked ? AppColors.accentGreen : null
            ),
          ),
          const SizedBox(width: 16),
          const _ActionText('Reply'),
          if (_isLiked) ...[
            const SizedBox(width: 12),
            const Icon(Icons.thumb_up, size: 12, color: AppColors.accentGreen),
          ],
        ],
      ),
    );
  }

  Widget _buildRepliesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _showReplies = !_showReplies),
          child: Text(
            _showReplies ? 'Hide replies' : 'Show replies',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accentGreen,
            ),
          ),
        ),
        if (_showReplies) ...[
          const SizedBox(height: 12),
          ...widget.replies.map((reply) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12, left: 4),
                  color: Colors.grey[200],
                ),
                Expanded(child: reply),
              ],
            ),
          )),
        ],
      ],
    );
  }
}

class _ActionText extends StatelessWidget {
  const _ActionText(this.label, {this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: color ?? Colors.grey[600],
      ),
    );
  }
}
