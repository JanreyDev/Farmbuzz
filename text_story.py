import sys

code = '''
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class _TextStoryEditorSheet extends StatefulWidget {
  const _TextStoryEditorSheet();

  @override
  State<_TextStoryEditorSheet> createState() => _TextStoryEditorSheetState();
}

class _TextStoryEditorSheetState extends State<_TextStoryEditorSheet> {
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Color> _bgColors = const [
    Color(0xFF000000),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF795548),
  ];

  final List<Color> _textColors = const [
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFF44336),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFFEB3B),
  ];

  int _bgIndex = 3; // default blue
  int _textIndex = 0; // default white

  String _text = '';
  bool _isEditing = true;
  bool _isSharing = false;

  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _isEditing = false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_isEditing) return;
    _initialFocalPoint = details.focalPoint;
    _sessionOffset = _offset;
    _initialScale = _scale;
    _initialRotation = _rotation;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isEditing) return;
    setState(() {
      _offset = _sessionOffset + (details.focalPoint - _initialFocalPoint);
      _scale = (_initialScale * details.scale).clamp(0.2, 5.0);
      _rotation = _initialRotation + details.rotation;
    });
  }

  Future<void> _shareStory() async {
    if (_isSharing) return;
    if (_text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text to your story.')),
      );
      return;
    }

    setState(() => _isSharing = true);
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 300)); // wait for keyboard to close and layout to settle

    try {
      final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Unable to capture story.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/text_story_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      final prefs = await SharedPreferences.getInstance();
      final mobile = (prefs.getString('auth_mobile_number') ?? '').trim();
      if (mobile.isEmpty) throw Exception('Please login again before creating a story.');

      await _StoryStore.instance.create(
        mobileNumber: mobile,
        imagePath: file.path,
        textContent: _text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(); // pop this editor
        Navigator.of(context).pop(); // pop the create story options menu
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story shared')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // The Canvas that gets captured
            Positioned.fill(
              child: RepaintBoundary(
                key: _globalKey,
                child: GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onTap: () {
                    if (_isEditing) {
                      _focusNode.unfocus();
                    } else if (_text.isEmpty) {
                      _focusNode.requestFocus();
                      setState(() => _isEditing = true);
                    }
                  },
                  child: Container(
                    color: _bgColors[_bgIndex],
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_isEditing && _text.isNotEmpty)
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(_offset.dx, _offset.dy)
                              ..scale(_scale)
                              ..rotateZ(_rotation),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isEditing = true);
                                _focusNode.requestFocus();
                              },
                              child: Text(
                                _text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _textColors[_textIndex],
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top Controls (Color Pickers & Close)
            if (!_isEditing)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _textIndex = (_textIndex + 1) % _textColors.length),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.text_format, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _textColors[_textIndex],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _bgIndex = (_bgIndex + 1) % _bgColors.length),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.format_color_fill, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _bgColors[_bgIndex],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Text Editing Overlay
            if (_isEditing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLines: null,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textColors[_textIndex],
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type something...",
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 32,
                        ),
                      ),
                      onChanged: (val) => setState(() => _text = val),
                    ),
                  ),
                ),
              ),

            // Top Done Button (Only when editing)
            if (_isEditing)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => _focusNode.unfocus(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

            // Bottom Share Button
            if (!_isEditing)
              Positioned(
                bottom: 24,
                right: 24,
                child: GestureDetector(
                  onTap: _shareStory,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isSharing ? 'Sharing...' : 'Share to Story',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (!_isSharing) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
'''

with open('app/lib/features/home/presentation/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports if missing
if "import 'dart:ui' as ui;" not in content:
    idx = content.find('import')
    if idx != -1:
        content = content[:idx] + "import 'dart:ui' as ui;\nimport 'package:flutter/rendering.dart';\n" + content[idx:]

# Find where to replace the Text onTap logic in _CreateStoryOptionsSheet
target = """onTap: () => Navigator.of(context).pop(),
                        color: const Color(0xFF3A73E3),
                        icon: Icons.text_fields,
                        title: 'Text',"""

replacement = """onTap: () {
                          // Pop the bottom sheet first, then open the editor fullscreen
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const _TextStoryEditorSheet(),
                          ));
                        },
                        color: const Color(0xFF3A73E3),
                        icon: Icons.text_fields,
                        title: 'Text',"""

if target in content:
    content = content.replace(target, replacement)
    # Append the _TextStoryEditorSheet to the end
    content = content + '\n\n' + code
    with open('app/lib/features/home/presentation/home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print('Successfully applied text story feature')
else:
    print('Failed to find target in home_screen.dart')
