import sys
import re

with open('app/lib/features/clubs/presentation/club_detail_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

replacement = '''class _ClubCreatePostSheet extends StatefulWidget {
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
                                    videoPath.split('\\\\').last,
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
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE9EDF1),
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => setState(() {
                final index = _imagePaths.indexOf(path);
                if (index >= 0) {
                  _imagePaths.removeAt(index);
                  if (index < _imageUploads.length) _imageUploads.removeAt(index);
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
'''

start_marker = "class _ClubCreatePostSheet extends StatefulWidget {"
end_marker = "class _ClubPostCard extends StatefulWidget {"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    new_content = content[:start_idx] + replacement + "\\n\\n" + content[end_idx:]
    with open('app/lib/features/clubs/presentation/club_detail_screen.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
else:
    print('Markers not found', start_idx, end_idx)
    sys.exit(1)
