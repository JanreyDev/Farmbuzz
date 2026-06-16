import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

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
      final fetched = await _api.fetchPosts(clubId: widget.clubId, reactorName: reactor);
      if (mounted) setState(() { _posts = fetched.posts; _loading = false; });
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
                            itemBuilder: (context, i) {
                              final p = _posts[i];
                              return _ClubPostCard(
                                postId: p.id,
                                userName: p.userName,
                                userAvatar: p.userAvatar,
                                timeAgo: p.timeAgo,
                                postText: p.postText,
                                metaEmoji: p.metaEmoji,
                                metaFeeling: p.metaFeeling,
                                metaLocation: p.metaLocation,
                                userReaction: p.userReaction,
                                likesCount: p.likesCount,
                                commentsCount: p.commentsCount,
                                topReactions: p.topReactions,
                                imageUrls: p.imageUrls,
                              );
                            },
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
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8F5E9),
            backgroundImage: hasAvatar ? NetworkImage(userAvatar) : null,
            child: hasAvatar
                ? null
                : Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD0D3D6)),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What's happening ?",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
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
            child: const Icon(Icons.image, color: AppColors.accentGreen, size: 22),
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
  final TextEditingController _postController = TextEditingController();
  final List<String> _imagePaths = [];
  final List<FeedImageUpload> _imageUploads = [];
  final List<String> _videoPaths = [];
  String? _selectedFeeling;
  String? _selectedLocation;
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
    _postController.dispose();
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
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}${Platform.pathSeparator}fb_${DateTime.now().microsecondsSinceEpoch}$ext';
      await File(tempPath).writeAsBytes(bytes, flush: true);
      return tempPath;
    } catch (_) {
      return '__bytes_only__';
    }
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
        // Prioritize in-memory bytes (always available on Android via withData:true)
        final inMemoryBytes = pf.bytes;
        final hasBytes = inMemoryBytes != null && inMemoryBytes.isNotEmpty;

        final fileName = pf.name;
        final ext = _extensionFromName(fileName.isEmpty ? '.jpg' : fileName);
        if (!_isSupportedImagePath('file$ext')) continue;

        int size = 0;
        String? resolvedPath;

        if (hasBytes) {
          size = inMemoryBytes.length;
        } else {
          resolvedPath = await _resolveUsableImagePath(pf);
          if (resolvedPath == null || resolvedPath == '__bytes_only__') continue;
          if (!await File(resolvedPath).exists()) continue;
          size = await File(resolvedPath).length();
        }

        if (size <= 0 || size > _maxImageBytes) continue;
        if (runningTotal + size > _maxTotalImageBytes) continue;
        runningTotal += size;

        final previewPath = resolvedPath ??
            (hasBytes ? '__memory_${DateTime.now().microsecondsSinceEpoch}__' : null);
        if (previewPath == null) continue;
        valid.add(previewPath);
        validUploads.add(FeedImageUpload(
          path: resolvedPath,
          bytes: hasBytes ? inMemoryBytes : null,
          fileName: fileName.isNotEmpty
              ? fileName
              : 'image${DateTime.now().microsecondsSinceEpoch}$ext',
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

  Future<void> _pickVideo() async {
    try {
      FocusScope.of(context).unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (!mounted || result == null) return;
      final pickedPath = result.files.single.path;
      if (pickedPath == null) return;
      setState(() => _videoPaths.add(pickedPath));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open video picker: $e')),
      );
    }
  }

  Future<void> _openFeelingPicker() async {
    // We will just show a simple snackbar for now to keep it lightweight or you can integrate the full picker later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feeling picker coming soon...')),
    );
  }

  Future<void> _openLocationPicker() async {
    // We will just show a simple snackbar for now to keep it lightweight or you can integrate the full picker later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location picker coming soon...')),
    );
  }

  Future<void> _submitPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty && _imagePaths.isEmpty) return;
    setState(() => _isPosting = true);
    try {
      final post = await _api.createPost(
        authorName: widget.userName.trim().isEmpty ? 'FarmBuzz User' : widget.userName.trim(),
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
    final isEnabled = _postController.text.trim().isNotEmpty || _imagePaths.isNotEmpty || _videoPaths.isNotEmpty;
    final hasAttachments = _imagePaths.isNotEmpty || _videoPaths.isNotEmpty;
    final sheetHeight = MediaQuery.of(context).size.height * (hasAttachments ? 0.76 : 0.68);
    final hasAvatar = widget.userAvatar.trim().isNotEmpty;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(
          0,
          8,
          0,
          MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Create Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F3F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFE8F5E9),
                            backgroundImage: hasAvatar ? NetworkImage(widget.userAvatar) : null,
                            child: hasAvatar
                                ? null
                                : Text(
                                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 18),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: widget.userName.isNotEmpty ? widget.userName : 'You',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 64,
                        child: TextField(
                          controller: _postController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                          cursorColor: Colors.black87,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: "What's happening on your farm?",
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7C7C7C),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_imagePaths.isNotEmpty || _videoPaths.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${_imagePaths.length + _videoPaths.length} / 20 photos',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() {
                                _imagePaths.clear();
                                _imageUploads.clear();
                                _videoPaths.clear();
                              }),
                              child: const Text(
                                'Remove all',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_imagePaths.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildImagePreviewGrid(),
                      ],
                      if (_videoPaths.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        ..._videoPaths.map(
                          (videoPath) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFDDE3E8)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.videocam_outlined, color: Color(0xFF10A64A)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    videoPath.split('\\').last,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _videoPaths.remove(videoPath)),
                                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _MediaActionButton(
                          onTap: _pickImage,
                          icon: const Icon(Icons.image_outlined, color: Color(0xFF10A64A), size: 24),
                        ),
                        const SizedBox(width: 8),
                        _MediaActionButton(
                          onTap: _pickVideo,
                          icon: const Icon(Icons.videocam_outlined, color: Color(0xFF10A64A), size: 24),
                        ),
                        const SizedBox(width: 8),
                        _MediaActionButton(
                          onTap: _openFeelingPicker,
                          icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFFF6A623), size: 24),
                        ),
                        const SizedBox(width: 14),
                        _MediaActionButton(
                          onTap: _openLocationPicker,
                          icon: const Icon(Icons.location_on_outlined, color: Color(0xFFF6A623), size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: (!isEnabled || _isPosting) ? null : _submitPost,
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (isEnabled && !_isPosting) ? const Color(0xFF15A352) : const Color(0xFFE8EBEF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isPosting ? 'Posting...' : 'Post',
                          style: TextStyle(
                            color: (isEnabled && !_isPosting) ? Colors.white : const Color(0xFFB8BEC5),
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
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
      ),
    );
  }

  Widget _buildImagePreviewGrid() {
    final count = _imagePaths.length;
    if (count == 1) {
      return _buildImageTile(_imagePaths[0], height: 180, width: double.infinity);
    }
    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _buildImageTile(_imagePaths[0], height: 140)),
          const SizedBox(width: 8),
          Expanded(child: _buildImageTile(_imagePaths[1], height: 140)),
        ],
      );
    }
    if (count == 3) {
      return SizedBox(
        height: 180,
        child: Row(
          children: [
            Expanded(child: _buildImageTile(_imagePaths[0], height: 180)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildImageTile(_imagePaths[1], height: 86)),
                  const SizedBox(height: 8),
                  Expanded(child: _buildImageTile(_imagePaths[2], height: 86)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: count > 4 ? 4 : count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final path = _imagePaths[index];
        final extraCount = count - 4;
        return Stack(
          children: [
            _buildImageTile(path, height: double.infinity, width: double.infinity),
            if (index == 3 && extraCount > 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '+$extraCount',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImageTile(String path, {double? height, double? width}) {
    final index = _imagePaths.indexOf(path);
    final upload = (index >= 0 && index < _imageUploads.length)
        ? _imageUploads[index]
        : null;
    final isMemoryOnly = path.startsWith('__memory_');
    final previewBytes = upload?.bytes;

    Widget imageWidget;
    if (isMemoryOnly && previewBytes != null && previewBytes.isNotEmpty) {
      imageWidget = Image.memory(
        Uint8List.fromList(previewBytes),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFE9EDF1),
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      );
    } else {
      imageWidget = Image.file(
        File(path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFE9EDF1),
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageWidget,
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => setState(() {
                final idx = _imagePaths.indexOf(path);
                if (idx >= 0) {
                  _imagePaths.removeAt(idx);
                  if (idx < _imageUploads.length) _imageUploads.removeAt(idx);
                }
              }),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaActionButton extends StatelessWidget {
  const _MediaActionButton({required this.onTap, required this.icon});

  final VoidCallback onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 40, height: 40, child: Center(child: icon)),
      ),
    );
  }
}
// =================================================================================================
// Club Post Card


class _ClubPostCard extends StatefulWidget {
  const _ClubPostCard({
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
  State<_ClubPostCard> createState() => _ClubPostCardState();
}

class _ClubPostCardState extends State<_ClubPostCard> {
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
                      child: _PostAction(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        color: Colors.grey[700],
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
