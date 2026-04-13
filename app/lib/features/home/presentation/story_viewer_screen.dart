import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/app/widgets/ai_chat_button.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.storyDuration = const Duration(seconds: 5),
  });

  final List<StoryItem> stories;
  final int initialIndex;
  final Duration storyDuration;

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  static const Color _kAccentGreen = Color(0xFF22C55E);
  late final AnimationController _progressController;
  late int _currentIndex;
  double _tapFlashOpacity = 0.0;
  double _verticalDrag = 0.0;
  bool _isPaused = false;

  StoryItem get _currentStory => widget.stories[_currentIndex];

  @override
  void initState() {
    super.initState();
    AiGlobalFab.isVisible.value = false;
    _currentIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _progressController = AnimationController(
      vsync: this,
      duration: widget.storyDuration,
    )..addStatusListener(_onStatusChanged);
    _startStory();
  }

  @override
  void dispose() {
    AiGlobalFab.isVisible.value = true;
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (_) => _pauseStory(),
        onLongPressEnd: (_) => _resumeStory(),
        onVerticalDragStart: (_) => _verticalDrag = 0,
        onVerticalDragUpdate: (details) {
          final drag = details.primaryDelta ?? 0;
          if (drag > 0) {
            _verticalDrag += drag;
          }
        },
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (_verticalDrag > 110 || velocity > 900) {
            _closeViewer();
          }
          _verticalDrag = 0;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: Image.network(
                _currentStory.imageUrl,
                key: ValueKey<int>(_currentIndex),
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => const ColoredBox(color: Colors.black),
              ),
            ),
            const _StoryTopGradient(),
            const _StoryBottomGradient(),
            const _StoryVignette(),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _tapFlashOpacity,
                duration: const Duration(milliseconds: 120),
                child: const ColoredBox(color: Colors.white),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _goToPreviousStory,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _goToNextStory,
                    ),
                  ),
                ],
              ),
            ),
            _StoryTopHud(
              storiesCount: widget.stories.length,
              currentIndex: _currentIndex,
              progress: _progressController,
              username: _currentStory.username,
              timestamp: _currentStory.timestamp,
              avatarUrl: _currentStory.avatarUrl,
              onClose: _closeViewer,
            ),
            _StoryReplyBar(
              username: _currentStory.username,
              onSend: () => HapticFeedback.lightImpact(),
            ),
          ],
        ),
      ),
    );
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goToNextStory();
    }
  }

  void _startStory() {
    _progressController
      ..stop()
      ..value = 0
      ..forward();
  }

  void _goToPreviousStory() {
    _triggerTapFlash();
    HapticFeedback.selectionClick();
    if (_currentIndex <= 0) {
      _startStory();
      return;
    }
    setState(() => _currentIndex -= 1);
    _startStory();
  }

  void _goToNextStory() {
    _triggerTapFlash();
    HapticFeedback.selectionClick();
    if (_currentIndex >= widget.stories.length - 1) {
      _closeViewer();
      return;
    }
    setState(() => _currentIndex += 1);
    _startStory();
  }

  void _pauseStory() {
    if (_isPaused) return;
    HapticFeedback.selectionClick();
    setState(() => _isPaused = true);
    _progressController.stop();
  }

  void _resumeStory() {
    if (!_isPaused) return;
    setState(() => _isPaused = false);
    _progressController.forward();
  }

  Future<void> _triggerTapFlash() async {
    if (!mounted) return;
    setState(() => _tapFlashOpacity = 0.06);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;
    setState(() => _tapFlashOpacity = 0.0);
  }

  void _closeViewer() {
    HapticFeedback.lightImpact();
    Navigator.of(context).maybePop();
  }
}

class _StoryTopHud extends StatelessWidget {
  const _StoryTopHud({
    required this.storiesCount,
    required this.currentIndex,
    required this.progress,
    required this.username,
    required this.timestamp,
    required this.avatarUrl,
    required this.onClose,
  });

  final int storiesCount;
  final int currentIndex;
  final Animation<double> progress;
  final String username;
  final String timestamp;
  final String avatarUrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: progress,
              builder: (context, child) {
                return Row(
                  children: List<Widget>.generate(storiesCount, (index) {
                    final value = index < currentIndex
                        ? 1.0
                        : index > currentIndex
                        ? 0.0
                        : progress.value;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index == storiesCount - 1 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x44000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(avatarUrl),
                    backgroundColor: Colors.white24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Color(0x70000000), blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                      Text(
                        timestamp,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.30),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    iconSize: 22,
                    splashRadius: 22,
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

class _StoryTopGradient extends StatelessWidget {
  const _StoryTopGradient();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0x99000000), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _StoryBottomGradient extends StatelessWidget {
  const _StoryBottomGradient();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xB3000000)],
          ),
        ),
      ),
    );
  }
}

class _StoryVignette extends StatelessWidget {
  const _StoryVignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.18,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.15),
              Colors.black.withValues(alpha: 0.30),
            ],
            stops: const [0.55, 0.82, 1.0],
          ),
        ),
      ),
    );
  }
}

class _StoryReplyBar extends StatelessWidget {
  const _StoryReplyBar({
    required this.username,
    required this.onSend,
  });

  final String username;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reply to $username...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: FilledButton(
                        onPressed: onSend,
                        style: FilledButton.styleFrom(
                          backgroundColor: _StoryViewerScreenState._kAccentGreen,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: const Icon(Icons.send_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoryItem {
  const StoryItem({
    required this.imageUrl,
    required this.username,
    required this.avatarUrl,
    required this.timestamp,
  });

  final String imageUrl;
  final String username;
  final String avatarUrl;
  final String timestamp;
}
