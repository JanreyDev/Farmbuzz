import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

/// A premium modal for creating new feed posts.
/// Features user info, privacy selection, multiple image picking with grid preview, and rich media attachment options.
class CreatePostModal extends StatefulWidget {
  const CreatePostModal({super.key, this.onPostCreated});

  final void Function(String text, List<String> imagePaths)? onPostCreated;

  /// Static utility to show the create post modal.
  static void show(BuildContext context, {void Function(String text, List<String> imagePaths)? onPostCreated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => CreatePostModal(onPostCreated: onPostCreated),
    );
  }

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _postController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _canPost = false;

  @override
  void initState() {
    super.initState();
    _postController.addListener(_updatePostState);
  }

  @override
  void dispose() {
    _postController.removeListener(_updatePostState);
    _postController.dispose();
    super.dispose();
  }

  void _updatePostState() {
    setState(() {
      _canPost = _postController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          _updatePostState();
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _updatePostState();
    });
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildUserInfo(),
                  const SizedBox(height: 20),
                  _buildTextInput(),
                  if (_selectedImages.isNotEmpty) _buildImageGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomArea(bottomPadding),
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
            'Create Post',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
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

  Widget _buildUserInfo() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janrey'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Janrey',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            _PrivacyPill(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _postController,
      autofocus: true,
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.inter(
        fontSize: 18,
        color: Colors.black87,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: "What's happening on your farm?",
        hintStyle: GoogleFonts.inter(
          fontSize: 18,
          color: Colors.grey[400],
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return _PreviewImageItem(
          path: _selectedImages[index].path,
          onRemove: () => _removeImage(index),
        );
      },
    );
  }

  Widget _buildBottomArea(double bottomPadding) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _AttachmentIcon(
                icon: Icons.image_rounded, 
                color: Colors.green,
                onTap: _pickImages,
              ),
              const SizedBox(width: 24),
              const _AttachmentIcon(icon: Icons.videocam_rounded, color: Colors.blue),
              const SizedBox(width: 24),
              const _AttachmentIcon(icon: Icons.sentiment_satisfied_alt_rounded, color: Colors.amber),
              const SizedBox(width: 24),
              const _AttachmentIcon(icon: Icons.location_on_rounded, color: Colors.red),
            ],
          ),
        ),
        _buildPostButton(bottomPadding),
      ],
    );
  }

  Widget _buildPostButton(double bottomPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _canPost ? _handlePost : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canPost ? AppColors.accentGreen : Colors.grey[100],
            foregroundColor: _canPost ? Colors.white : Colors.grey[400],
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Post',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  void _handlePost() {
    final text = _postController.text.trim();
    final paths = _selectedImages.map((e) => e.path).toList();
    
    widget.onPostCreated?.call(text, paths);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post shared successfully!'),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PrivacyPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.public, size: 12, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            'Public',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey[700]),
        ],
      ),
    );
  }
}

class _PreviewImageItem extends StatelessWidget {
  const _PreviewImageItem({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(File(path)),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentIcon extends StatelessWidget {
  const _AttachmentIcon({required this.icon, required this.color, this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 28),
    );
  }
}
