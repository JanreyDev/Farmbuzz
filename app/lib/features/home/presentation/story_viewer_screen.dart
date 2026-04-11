import 'package:flutter/material.dart';

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
  late final AnimationController _progressController;
  late int _currentIndex;

  StoryItem get _currentStory => widget.stories[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _progressController = AnimationController(
      vsync: this,
      duration: widget.storyDuration,
    )..addStatusListener(_onStatusChanged);
    _startStory();
  }

  @override
  void dispose() {
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
        onVerticalDragUpdate: (details) {
          if ((details.primaryDelta ?? 0) > 12) {
            Navigator.of(context).maybePop();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _currentStory.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
            ),
            const _StoryTopGradient(),
            const _StoryBottomGradient(),
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Row(
                          children: List<Widget>.generate(
                            widget.stories.length,
                            (index) {
                              final value = index < _currentIndex
                                  ? 1.0
                                  : index > _currentIndex
                                  ? 0.0
                                  : _progressController.value;

                              return Expanded(
                                child: Container(
                                  height: 3,
                                  margin: EdgeInsets.only(
                                    right:
                                        index == widget.stories.length - 1 ? 0 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: value,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(_currentStory.avatarUrl),
                          backgroundColor: Colors.white24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentStory.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _currentStory.timestamp,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
    if (_currentIndex <= 0) {
      _startStory();
      return;
    }
    setState(() => _currentIndex -= 1);
    _startStory();
  }

  void _goToNextStory() {
    if (_currentIndex >= widget.stories.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _currentIndex += 1);
    _startStory();
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
            colors: [Color(0xA6000000), Colors.transparent],
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
            colors: [Colors.transparent, Color(0x66000000)],
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
