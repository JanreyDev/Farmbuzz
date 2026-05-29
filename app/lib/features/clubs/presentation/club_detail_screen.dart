import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../home/data/feed_api.dart';
import 'widgets/create_club_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Club Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class ClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  late Map<String, dynamic> _club;

  @override
  void initState() {
    super.initState();
    _club = widget.club;
  }

  bool get _isFounder => (_club['role'] as String? ?? '') == 'founder';
  String get _imageUrl => (_club['imageUrl'] as String?) ?? '';
  String get _clubTitle => (_club['title'] as String?) ?? 'Club';
  int get _memberCount => (_club['memberCount'] as num?)?.toInt() ?? 0;
  String get _region => (_club['region'] as String?) ?? '';
  String get _category => (_club['category'] as String?) ?? 'Community';
  bool get _isPublic => (_club['is_public'] as bool?) ?? true;
  String get _description => (_club['description'] as String?) ?? '';
  int get _clubId => (_club['id'] as num?)?.toInt() ?? 0;

  List<String> get _focusTags {
    final tags = _club['focus_tags'];
    if (tags is List) return tags.map((e) => e.toString()).toList();
    return [];
  }

  void _openEdit() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateClubModal(initialClub: _club),
    );
    if (updated == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverHeader(innerBoxIsScrolled),
        ],
        body: Column(
          children: [
            _buildClubInfoCard(),
            Expanded(
              child: _ClubFeed(clubId: _clubId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.accentGreen,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        if (_isFounder)
          GestureDetector(
            onTap: _openEdit,
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.edit2, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Edit',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_imageUrl.isNotEmpty)
              Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildGradientBg(),
              )
            else
              _buildGradientBg(),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a6b3a), Color(0xFF0a3d1f)],
        ),
      ),
    );
  }

  Widget _buildClubInfoCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _clubTitle.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildBadge(_category, AppColors.accentGreen),
                        _buildBadge(
                          _isPublic ? 'Public' : 'Private',
                          Colors.blue.shade600,
                          icon: _isPublic ? LucideIcons.globe : LucideIcons.lock,
                        ),
                        if (_isFounder)
                          _buildBadge('Founder', Colors.orange.shade700, icon: LucideIcons.crown)
                        else
                          _buildBadge('Member', Colors.grey.shade600, icon: LucideIcons.user),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.users, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '$_memberCount member${_memberCount == 1 ? '' : 's'}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        if (_region.isNotEmpty) ...[
                          Text('  ·  ', style: TextStyle(color: Colors.grey.shade400)),
                          Icon(LucideIcons.mapPin, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _region,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _description,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.45),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (_focusTags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _focusTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentGreen.withOpacity(0.25)),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Club Feed — displays posts + create composer for a specific club
// ─────────────────────────────────────────────────────────────────────────────

class _ClubFeed extends StatefulWidget {
  final int clubId;
  const _ClubFeed({required this.clubId});

  @override
  State<_ClubFeed> createState() => _ClubFeedState();
}

class _ClubFeedState extends State<_ClubFeed> {
  final FeedApi _api = FeedApi();
  List<FeedPost> _posts = [];
  bool _loading = true;
  String? _error;
  String _userName = '';
  String _userAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPosts();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = (prefs.getString('auth_user_name') ?? prefs.getString('auth_mobile_number') ?? '').trim();
    final avatar = _firstNonEmpty([
      prefs.getString('auth_user_avatar'),
      prefs.getString('auth_user_avatar_url'),
      prefs.getString('auth_avatar'),
      prefs.getString('user_avatar'),
    ]);
    if (mounted) setState(() { _userName = name; _userAvatar = avatar; });
  }

  String _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      final t = (v ?? '').trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }

  Future<void> _loadPosts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final reactor = prefs.getString('auth_user_name') ?? prefs.getString('auth_mobile_number') ?? '';
      final posts = await _api.fetchPosts(clubId: widget.clubId, reactorName: reactor);
      if (mounted) setState(() { _posts = posts; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onPostCreated(FeedPost post) {
    setState(() => _posts = [post, ..._posts]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status Composer
        _ClubStatusComposer(
          userName: _userName,
          userAvatar: _userAvatar,
          clubId: widget.clubId,
          onPostCreated: _onPostCreated,
        ),
        // Divider
        Container(height: 1, color: Colors.grey.shade200),
        // Posts list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
              : _error != null
                  ? _buildError()
                  : _posts.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _loadPosts,
                          color: AppColors.accentGreen,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _posts.length,
                            itemBuilder: (context, i) => _ClubPostCard(
                              post: _posts[i],
                              userName: _userName,
                              api: _api,
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.layoutList, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No posts yet',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Be the first to share something with this club!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertCircle, size: 40, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text('Failed to load posts', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadPosts,
            icon: const Icon(LucideIcons.refreshCw, size: 14),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentGreen),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Composer – bar that opens the create post sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ClubStatusComposer extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final int clubId;
  final void Function(FeedPost) onPostCreated;

  const _ClubStatusComposer({
    required this.userName,
    required this.userAvatar,
    required this.clubId,
    required this.onPostCreated,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = userAvatar.trim().isNotEmpty;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8F5E9),
            backgroundImage: hasAvatar ? NetworkImage(userAvatar) : null,
            child: hasAvatar
                ? null
                : Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final post = await showModalBottomSheet<FeedPost>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _ClubCreatePostSheet(
                    clubId: clubId,
                    userName: userName,
                    userAvatar: userAvatar,
                  ),
                );
                if (post != null) onPostCreated(post);
              },
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Share something with this club...",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final post = await showModalBottomSheet<FeedPost>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _ClubCreatePostSheet(
                  clubId: clubId,
                  userName: userName,
                  userAvatar: userAvatar,
                  openPhotoPicker: true,
                ),
              );
              if (post != null) onPostCreated(post);
            },
            child: const Icon(Icons.image, color: AppColors.accentGreen, size: 24),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create Post Sheet – bottom sheet for composing a club post
// ─────────────────────────────────────────────────────────────────────────────

class _ClubCreatePostSheet extends StatefulWidget {
  final int clubId;
  final String userName;
  final String userAvatar;
  final bool openPhotoPicker;

  const _ClubCreatePostSheet({
    required this.clubId,
    required this.userName,
    required this.userAvatar,
    this.openPhotoPicker = false,
  });

  @override
  State<_ClubCreatePostSheet> createState() => _ClubCreatePostSheetState();
}

class _ClubCreatePostSheetState extends State<_ClubCreatePostSheet> {
  static const int _maxImageBytes = 20 * 1024 * 1024;
  static const int _maxTotalImageBytes = 18 * 1024 * 1024;

  final FeedApi _api = FeedApi();
  final TextEditingController _controller = TextEditingController();
  final List<String> _imagePaths = [];
  final List<FeedImageUpload> _imageUploads = [];
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    if (widget.openPhotoPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickImage());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isSupportedImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.png') || lower.endsWith('.webp') ||
        lower.endsWith('.gif') || lower.endsWith('.bmp');
  }

  String _extensionFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '.jpg';
    return name.substring(dot).toLowerCase();
  }

  MediaType _mediaTypeForExt(String ext) {
    switch (ext) {
      case '.png': return MediaType('image', 'png');
      case '.webp': return MediaType('image', 'webp');
      case '.gif': return MediaType('image', 'gif');
      case '.bmp': return MediaType('image', 'bmp');
      default: return MediaType('image', 'jpeg');
    }
  }

  Future<String?> _resolveUsableImagePath(PlatformFile file) async {
    final path = file.path;
    if (path != null && path.isNotEmpty && await File(path).exists()) return path;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return null;
    final ext = _extensionFromName(file.name);
    final tempPath =
        '${Directory.systemTemp.path}${Platform.pathSeparator}fb_${DateTime.now().microsecondsSinceEpoch}$ext';
    await File(tempPath).writeAsBytes(bytes, flush: true);
    return tempPath;
  }

  Future<int> _currentTotalBytes() async {
    var total = 0;
    for (final upload in _imageUploads) {
      final b = upload.bytes;
      if (b != null && b.isNotEmpty) { total += b.length; continue; }
      final p = upload.path;
      if (p != null && p.isNotEmpty && await File(p).exists()) {
        total += await File(p).length();
      }
    }
    return total;
  }

  Future<void> _pickImage() async {
    try {
      FocusScope.of(context).unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (!mounted || result == null) return;
      final picked = result.files;
      if (picked.isEmpty) return;

      final valid = <String>[];
      final validUploads = <FeedImageUpload>[];
      var runningTotal = await _currentTotalBytes();

      for (final pf in picked) {
        final path = await _resolveUsableImagePath(pf);
        if (path == null || !_isSupportedImagePath(path)) continue;
        if (!await File(path).exists()) continue;
        final size = await File(path).length();
        if (size <= 0 || size > _maxImageBytes) continue;
        if (runningTotal + size > _maxTotalImageBytes) continue;
        runningTotal += size;
        valid.add(path);
        final ext = _extensionFromName(pf.name.isEmpty ? path : pf.name);
        validUploads.add(FeedImageUpload(
          path: path,
          bytes: (pf.bytes != null && pf.bytes!.isNotEmpty) ? pf.bytes : null,
          fileName: pf.name.isNotEmpty ? pf.name : path.split(Platform.pathSeparator).last,
          contentType: _mediaTypeForExt(ext),
        ));
      }

      if (valid.isNotEmpty && mounted) {
        setState(() {
          _imagePaths.addAll(valid);
          _imageUploads.addAll(validUploads);
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submitPost() async {
    final content = _controller.text.trim();
    if (content.isEmpty && _imagePaths.isEmpty) return;
    setState(() => _isPosting = true);
    try {
      final post = await _api.createPost(
        authorName: widget.userName,
        authorAvatar: widget.userAvatar,
        content: content,
        images: List.from(_imageUploads),
        clubId: widget.clubId,
      );
      if (mounted) Navigator.pop(context, post);
    } catch (e) {
      setState(() => _isPosting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final hasAvatar = widget.userAvatar.trim().isNotEmpty;
    final canPost = _controller.text.trim().isNotEmpty || _imagePaths.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE8F5E9),
                  backgroundImage: hasAvatar ? NetworkImage(widget.userAvatar) : null,
                  child: hasAvatar
                      ? null
                      : Text(
                          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName.isNotEmpty ? widget.userName : 'You',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      Text(
                        'Posting to club',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: (_isPosting || !canPost) ? null : _submitPost,
                  style: TextButton.styleFrom(
                    backgroundColor: canPost ? AppColors.accentGreen : Colors.grey.shade200,
                    foregroundColor: canPost ? Colors.white : Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Post', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Text Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 6,
              minLines: 3,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Image previews
          if (_imagePaths.isNotEmpty) ...[
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _imagePaths.length,
                itemBuilder: (_, i) => Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(File(_imagePaths[i])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4, right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _imagePaths.removeAt(i);
                          _imageUploads.removeAt(i);
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Action bar
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _ActionBtn(icon: Icons.image, label: 'Photo', onTap: _pickImage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accentGreen),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Club Post Card – lightweight card for displaying a single post
// ─────────────────────────────────────────────────────────────────────────────

class _ClubPostCard extends StatefulWidget {
  final FeedPost post;
  final String userName;
  final FeedApi api;

  const _ClubPostCard({required this.post, required this.userName, required this.api});

  @override
  State<_ClubPostCard> createState() => _ClubPostCardState();
}

class _ClubPostCardState extends State<_ClubPostCard> {
  late FeedPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _toggleLike() async {
    final isLiked = _post.userReaction.isNotEmpty;
    try {
      final result = isLiked
          ? await widget.api.unlikePost(postId: _post.id, reactorName: widget.userName)
          : await widget.api.likePost(
              postId: _post.id,
              reactorName: widget.userName,
              reaction: '👍',
            );
      if (mounted) {
        setState(() {
          _post = FeedPost(
            id: _post.id,
            userName: _post.userName,
            userAvatar: _post.userAvatar,
            timeAgo: _post.timeAgo,
            postText: _post.postText,
            metaEmoji: _post.metaEmoji,
            metaFeeling: _post.metaFeeling,
            metaLocation: _post.metaLocation,
            likesCount: result.likesCount,
            commentsCount: _post.commentsCount,
            topReactions: result.topReactions,
            userReaction: result.userReaction,
            imageUrls: _post.imageUrls,
          );
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = _post.userAvatar.trim().isNotEmpty;
    final isLiked = _post.userReaction.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE8F5E9),
                  backgroundImage: hasAvatar ? NetworkImage(_post.userAvatar) : null,
                  child: hasAvatar
                      ? null
                      : Text(
                          _post.userName.isNotEmpty ? _post.userName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _post.userName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87),
                      ),
                      Row(
                        children: [
                          Text(
                            _post.timeAgo,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                          if (_post.metaFeeling.isNotEmpty) ...[
                            Text(' · ', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                            Text(
                              '${_post.metaEmoji} feeling ${_post.metaFeeling}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                          if (_post.metaLocation.isNotEmpty) ...[
                            Text(' · ', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                            Icon(LucideIcons.mapPin, size: 10, color: Colors.grey.shade400),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                _post.metaLocation,
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Post text
          if (_post.postText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                _post.postText,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              ),
            ),
          // Images
          if (_post.imageUrls.isNotEmpty)
            SizedBox(
              height: _post.imageUrls.length == 1 ? 260 : 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _post.imageUrls.length,
                itemBuilder: (_, i) => Container(
                  margin: EdgeInsets.only(left: i == 0 ? 16 : 8),
                  width: _post.imageUrls.length == 1 ? double.infinity : 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(_post.imageUrls[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          if (_post.imageUrls.isNotEmpty) const SizedBox(height: 10),
          // Action row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 18,
                        color: isLiked ? AppColors.accentGreen : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _post.likesCount > 0 ? '${_post.likesCount}' : 'Like',
                        style: TextStyle(
                          color: isLiked ? AppColors.accentGreen : Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: isLiked ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    Icon(LucideIcons.messageCircle, size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 5),
                    Text(
                      _post.commentsCount > 0 ? '${_post.commentsCount} Comment${_post.commentsCount == 1 ? '' : 's'}' : 'Comment',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
        ],
      ),
    );
  }
}
