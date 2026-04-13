import 'package:flutter/material.dart';
import 'package:app/app/widgets/ai_chat_button.dart';

const Color _kPostBgLight = Color(0xFFF5F5F5);
const Color _kPostBgDark = Color(0xFF1F1F1F);
const Color _kPostCardDark = Color(0xFF242628);

const _kSampleGalleryImages = [
  'https://images.pexels.com/photos/18846336/pexels-photo-18846336.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'https://images.pexels.com/photos/15235677/pexels-photo-15235677.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'https://images.pexels.com/photos/13607889/pexels-photo-13607889.jpeg?auto=compress&cs=tinysrgb&w=1200',
];

const _kSampleCameraImages = [
  'https://images.pexels.com/photos/19198208/pexels-photo-19198208.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'https://images.pexels.com/photos/13293244/pexels-photo-13293244.jpeg?auto=compress&cs=tinysrgb&w=1200',
];

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocus = FocusNode();
  final List<String> _imageUrls = <String>[];
  String? _location;
  _PostVisibility _visibility = _PostVisibility.public;
  bool _isPosting = false;

  bool get _canPost =>
      _contentController.text.trim().isNotEmpty || _imageUrls.isNotEmpty;

  @override
  void initState() {
    super.initState();
    AiGlobalFab.isVisible.value = false;
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    AiGlobalFab.isVisible.value = true;
    _contentController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = isDark ? _kPostBgDark : _kPostBgLight;
    final contentBg = isDark ? _kPostBgDark : _kPostBgLight;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: const Text(
          'Create Post',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: (_canPost && !_isPosting) ? _submitPost : null,
            child: _isPosting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Text(
                    'Post',
                    style: TextStyle(
                      color: (_canPost && !_isPosting)
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.35),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ricardo Santos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Santos Gamefarm',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_PostVisibility>(
                    initialValue: _visibility,
                    onSelected: (value) => setState(() => _visibility = value),
                    itemBuilder: (context) => _PostVisibility.values
                        .map(
                          (v) => PopupMenuItem<_PostVisibility>(
                            value: v,
                            child: Text(v.label),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.30,
                              )
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.public,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _visibility.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: contentBg,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _contentController,
                        focusNode: _contentFocus,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 6,
                        maxLines: null,
                        style: theme.textTheme.titleMedium?.copyWith(height: 1.35),
                        decoration: InputDecoration(
                          hintText: 'What\'s happening on your farm?',
                          hintStyle: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (_imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _CreatePostImagePreview(
                          imageUrls: _imageUrls,
                          onRemove: (index) {
                            setState(() => _imageUrls.removeAt(index));
                          },
                        ),
                      ],
                      if (_location != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                          child: Text(
                            'Location: $_location',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                8 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? _kPostCardDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionButton(
                    icon: Icons.photo_camera_outlined,
                    label: 'Camera',
                    onTap: () => _pickImages(),
                  ),
                  _ActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Upload Images',
                    onTap: () => _pickImages(),
                  ),
                  _ActionButton(
                    icon: Icons.location_on_outlined,
                    label: 'Add location',
                    onTap: _addLocation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final options = <String>[
      ..._kSampleGalleryImages,
      ..._kSampleCameraImages,
    ];
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final picked = <String>{..._imageUrls};
        return StatefulBuilder(
          builder: (context, setModalState) {
            final remaining = 10 - picked.length;
            return SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Select up to 10 images',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$remaining left',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.48,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                        ),
                        itemBuilder: (_, index) {
                          final image = options[index];
                          final selected = picked.contains(image);
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                if (selected) {
                                  picked.remove(image);
                                  return;
                                }
                                if (picked.length >= 10) return;
                                if (_isValidImageFormat(image)) {
                                  picked.add(image);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(image, fit: BoxFit.cover),
                                  if (selected)
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(picked.toList()),
                        child: Text('Done (${picked.length})'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _imageUrls
        ..clear()
        ..addAll(selected.take(10));
    });
  }

  void _addLocation() {
    setState(() => _location = 'Arayat, Pampanga');
  }

  Future<void> _submitPost() async {
    if (!_canPost || _isPosting) {
      return;
    }
    setState(() => _isPosting = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop({
      'text': _contentController.text.trim(),
      'imageUrls': _imageUrls,
      'location': _location,
      'visibility': _visibility.label,
    });
  }

  bool _isValidImageFormat(String imageUrl) {
    final lower = imageUrl.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png');
  }
}

class _CreatePostImagePreview extends StatelessWidget {
  const _CreatePostImagePreview({
    required this.imageUrls,
    required this.onRemove,
  });

  final List<String> imageUrls;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final media = imageUrls.take(10).toList(growable: false);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: media.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(media[index], fit: BoxFit.cover),
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: () => onRemove(index),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 19, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PostVisibility {
  public('Public'),
  followers('Followers');

  const _PostVisibility(this.label);
  final String label;
}
