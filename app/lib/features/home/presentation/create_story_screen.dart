import 'package:flutter/material.dart';
import 'package:app/app/widgets/ai_chat_button.dart';

const Color _kStoryPrimary = Color(0xFF2E7D32);

const _kGallerySamples = [
  'https://images.pexels.com/photos/18846336/pexels-photo-18846336.jpeg?auto=compress&cs=tinysrgb&w=1400',
  'https://images.pexels.com/photos/15235677/pexels-photo-15235677.jpeg?auto=compress&cs=tinysrgb&w=1400',
  'https://images.pexels.com/photos/13607889/pexels-photo-13607889.jpeg?auto=compress&cs=tinysrgb&w=1400',
];

const _kCameraSamples = [
  'https://images.pexels.com/photos/19198208/pexels-photo-19198208.jpeg?auto=compress&cs=tinysrgb&w=1400',
  'https://images.pexels.com/photos/13293244/pexels-photo-13293244.jpeg?auto=compress&cs=tinysrgb&w=1400',
];

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _captionController = TextEditingController();
  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    AiGlobalFab.isVisible.value = false;
  }

  @override
  void dispose() {
    AiGlobalFab.isVisible.value = true;
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AiGlobalFab.isVisible.value) {
      AiGlobalFab.isVisible.value = false;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2230);
    final dockBg = isDark
        ? const Color(0xB3000000)
        : Colors.white.withValues(alpha: 0.96);
    final inputBg = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : const Color(0xFFF0F2F5);
    final inputHint = isDark ? Colors.white70 : const Color(0xFF8A9098);
    final bodyOverlayTop = isDark
        ? const Color(0x99000000)
        : const Color(0x80FFFFFF);
    final bodyOverlayBottom = isDark
        ? const Color(0xC2000000)
        : const Color(0x00FFFFFF);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _openGalleryPicker,
            child: _selectedImageUrl == null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.28),
                        radius: 1.05,
                        colors: isDark
                            ? const [Color(0xFF1B1B1B), Colors.black]
                            : const [Color(0xFFF8F9FB), Color(0xFFEFF1F5)],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  )
                : Image.network(_selectedImageUrl!, fit: BoxFit.cover),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bodyOverlayTop, Colors.transparent, bodyOverlayBottom],
                stops: const [0, 0.36, 1],
              ),
            ),
          ),
          if (_selectedImageUrl == null)
            Center(
              child: GestureDetector(
                onTap: _openGalleryPicker,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: isDark ? Colors.white : const Color(0xFF5D6672),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to add photo',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1F2230),
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Row(
                  children: [
                    _TopBarIcon(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                      color: titleColor,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Story',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    _TopBarIcon(
                      icon: Icons.settings_outlined,
                      onTap: () {},
                      color: titleColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(14, 12, 14, 14 + bottomInset),
              decoration: BoxDecoration(
                color: dockBg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white24 : const Color(0xFFE2E6EB),
                      ),
                    ),
                    child: TextField(
                      controller: _captionController,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1F2230),
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: isDark ? Colors.white : const Color(0xFF1F2230),
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: inputHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StoryIconAction(
                        icon: Icons.photo_camera_outlined,
                        onTap: _openCameraPicker,
                        darkMode: isDark,
                      ),
                      const SizedBox(width: 8),
                      _StoryIconAction(
                        icon: Icons.photo_library_outlined,
                        onTap: _openGalleryPicker,
                        darkMode: isDark,
                      ),
                      const SizedBox(width: 8),
                      _StoryIconAction(
                        icon: Icons.emoji_emotions_outlined,
                        onTap: _insertEmoji,
                        darkMode: isDark,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _postStory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kStoryPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            elevation: 5,
                            shadowColor: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Post Story', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGalleryPicker() async {
    final selected = await _showSamplePicker(title: 'Select from Gallery', images: _kGallerySamples);
    if (!mounted || selected == null) return;
    setState(() => _selectedImageUrl = selected);
  }

  Future<void> _openCameraPicker() async {
    final selected = await _showSamplePicker(title: 'Take Photo (Sample)', images: _kCameraSamples);
    if (!mounted || selected == null) return;
    setState(() => _selectedImageUrl = selected);
  }

  Future<String?> _showSamplePicker({required String title, required List<String> images}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 94,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, index) => InkWell(
                      onTap: () => Navigator.of(context).pop(images[index]),
                      borderRadius: BorderRadius.circular(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(images[index], width: 94, height: 94, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _insertEmoji() {
    final text = _captionController.text;
    _captionController.text = '$text :)';
    _captionController.selection = TextSelection.fromPosition(
      TextPosition(offset: _captionController.text.length),
    );
  }

  void _postStory() {
    if (_selectedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo first.')),
      );
      return;
    }
    Navigator.of(context).pop({'imageUrl': _selectedImageUrl!, 'caption': _captionController.text.trim()});
  }
}

class _TopBarIcon extends StatelessWidget {
  const _TopBarIcon({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 22),
      splashRadius: 22,
    );
  }
}

class _StoryIconAction extends StatelessWidget {
  const _StoryIconAction({
    required this.icon,
    required this.onTap,
    required this.darkMode,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: darkMode ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFF0F2F5),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: darkMode ? Colors.white : const Color(0xFF1F2230),
            size: 20,
          ),
        ),
      ),
    );
  }
}
