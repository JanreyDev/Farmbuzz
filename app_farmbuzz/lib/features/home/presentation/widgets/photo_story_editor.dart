import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

/// A premium photo editor for creating stories.
/// Allows users to zoom, rotate, add text, music, and set privacy.
class PhotoStoryEditor extends StatefulWidget {
  const PhotoStoryEditor({super.key, required this.imageFile, this.onStoryCreated});

  final XFile imageFile;
  final void Function(String)? onStoryCreated;

  /// Utility method to show the editor as a bottom sheet.
  static void show(BuildContext context, XFile imageFile, {void Function(String)? onStoryCreated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => PhotoStoryEditor(imageFile: imageFile, onStoryCreated: onStoryCreated),
    );
  }

  @override
  State<PhotoStoryEditor> createState() => _PhotoStoryEditorState();
}

class _PhotoStoryEditorState extends State<PhotoStoryEditor> {
  // Transformation State
  double _zoom = 1.0;
  double _rotation = 0.0;
  
  // Text Editing State
  bool _showTextPanel = false;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  Color _selectedTextColor = const Color(0xFF0F172A);
  String _selectedTextStyle = 'Normal';

  // Privacy State
  bool _isPublic = true;

  // Constants
  static const List<Color> _textColors = [
    Colors.white,
    Color(0xFF0F172A), // Slate 900
    Color(0xFF22C55E), // Green 500
    Color(0xFF3B82F6), // Blue 500
    Color(0xFFEF4444), // Red 500
    Color(0xFFF59E0B), // Amber 500
    Color(0xFF8B5CF6), // Violet 500
    Color(0xFFEC4899), // Pink 500
  ];

  static const List<String> _textStyles = ['Normal', 'Bold', 'Elegant', 'Typewriter'];

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _toggleTextPanel() {
    setState(() {
      _showTextPanel = !_showTextPanel;
      if (_showTextPanel) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _textFocusNode.requestFocus();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: size.height * 0.9,
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
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
              child: Column(
                children: [
                  _buildImagePreview(size),
                  const SizedBox(height: 24),
                  _buildControlSliders(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  if (_showTextPanel) ...[
                    const SizedBox(height: 20),
                    _buildTextEditorPanel(),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Text(
            'Photo Story',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(Size size) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: size.height * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        clipBehavior: Clip.antiAlias,
        child: Transform.rotate(
          angle: _rotation * (3.14159 / 180),
          child: Transform.scale(
            scale: _zoom,
            child: Image.file(
              File(widget.imageFile.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlSliders() {
    return Column(
      children: [
        _SliderRow(
          label: 'Zoom ${( _zoom * 100).toInt()}%',
          icon: Icons.zoom_in,
          value: _zoom,
          min: 1.0,
          max: 3.0,
          onChanged: (val) => setState(() => _zoom = val),
        ),
        const SizedBox(height: 12),
        _SliderRow(
          label: 'Rotate ${_rotation.toInt()}°',
          icon: Icons.rotate_right,
          value: _rotation,
          min: 0,
          max: 360,
          onChanged: (val) => setState(() => _rotation = val),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _EditorActionButton(
            label: 'Add Text',
            icon: Icons.text_fields_rounded,
            isActive: _showTextPanel,
            onTap: _toggleTextPanel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _EditorActionButton(
            label: 'Add Music',
            icon: Icons.music_note_rounded,
            onTap: _showMusicDialog,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _EditorActionButton(
            label: _isPublic ? 'Public' : 'Private',
            icon: _isPublic ? Icons.public_rounded : Icons.lock_outline_rounded,
            onTap: _showPrivacyDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildTextEditorPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            focusNode: _textFocusNode,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Type your text...',
              hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildColorPicker(),
          const SizedBox(height: 16),
          _buildStylePicker(),
          const SizedBox(height: 20),
          _buildTextPanelActions(),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _textColors.map((color) {
          final isSelected = _selectedTextColor == color;
          return GestureDetector(
            onTap: () => setState(() => _selectedTextColor = color),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accentGreen : Colors.grey[200]!,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStylePicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _textStyles.map((style) {
          final isSelected = _selectedTextStyle == style;
          return GestureDetector(
            onTap: () => setState(() => _selectedTextStyle = style),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.accentGreen : Colors.grey[200]!,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                style,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.accentGreen : Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextPanelActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _showTextPanel = false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _showTextPanel = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[400],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onStoryCreated?.call(widget.imageFile.path);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Story shared successfully!'),
                    backgroundColor: AppColors.accentGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Share to Story',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMusicDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const _MusicSelectionDialog(),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => _PrivacyDialog(
        initialIsPublic: _isPublic,
        onSave: (val) => setState(() => _isPublic = val),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.accentGreen,
          inactiveColor: Colors.grey[200],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _EditorActionButton extends StatelessWidget {
  const _EditorActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0FDF4) : Colors.white,
          border: Border.all(color: isActive ? AppColors.accentGreen : Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isActive ? AppColors.accentGreen : Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.accentGreen : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicSelectionDialog extends StatelessWidget {
  const _MusicSelectionDialog();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxHeight: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildTabs(),
          const Divider(height: 24),
          const Expanded(child: _MusicList()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Add Music',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
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
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search songs or artists...',
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.accentGreen),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: const [
        Expanded(child: _TabButton(label: 'All', isActive: true)),
        SizedBox(width: 12),
        Expanded(child: _TabButton(label: 'Saved (0)', isActive: false)),
      ],
    );
  }
}

class _MusicList extends StatelessWidget {
  const _MusicList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _MusicItem(title: 'Good Vibes', subtitle: 'FarmBuzz Music • 0:30'),
        _MusicItem(title: 'Morning Farm', subtitle: 'Breeder Beats • 0:15'),
        _MusicItem(title: 'Champion Walk', subtitle: 'Game Sounds • 0:30'),
        _MusicItem(title: 'Sunrise', subtitle: 'Chill Mix • 0:15'),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.isActive});
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? AppColors.accentGreen : Colors.grey[100]!),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: isActive ? AppColors.accentGreen : Colors.grey[500],
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MusicItem extends StatelessWidget {
  const _MusicItem({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.play_arrow_outlined, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Use',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyDialog extends StatefulWidget {
  const _PrivacyDialog({required this.initialIsPublic, required this.onSave});
  final bool initialIsPublic;
  final ValueChanged<bool> onSave;

  @override
  State<_PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<_PrivacyDialog> {
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.initialIsPublic;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Story privacy',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Who can see your story? Your story will be visible for 24 hours on FarmBuzz.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500], height: 1.4),
            ),
            const SizedBox(height: 20),
            _PrivacyOption(
              title: 'Public',
              subtitle: 'Anyone on FarmBuzz can see this story',
              icon: Icons.public,
              isSelected: _isPublic,
              onTap: () => setState(() => _isPublic = true),
            ),
            const SizedBox(height: 12),
            _PrivacyOption(
              title: 'Private',
              subtitle: 'Only your followers can see this story',
              icon: Icons.lock_outline,
              isSelected: !_isPublic,
              onTap: () => setState(() => _isPublic = false),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[200]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_isPublic);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  const _PrivacyOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.accentGreen : Colors.grey[100]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: isSelected ? AppColors.accentGreen : Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 11)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
