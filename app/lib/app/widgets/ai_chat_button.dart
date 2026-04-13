import 'package:app/app/widgets/ai_chat_sheet.dart';
import 'package:app/app/app.dart';
import 'package:app/app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class AiGlobalFab extends StatefulWidget {
  const AiGlobalFab({required this.child, super.key});
  final Widget child;

  static final ValueNotifier<bool> isVisible = ValueNotifier(true);

  @override
  State<AiGlobalFab> createState() => _AiGlobalFabState();
}

class _AiGlobalFabState extends State<AiGlobalFab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  static const Set<String> _hiddenRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.subscription,
    AppRoutes.messaging,
    AppRoutes.createStory,
    AppRoutes.addBird,
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100, 
      child: ValueListenableBuilder<String?>(
        valueListenable: AppRouteTracker.currentRoute,
        builder: (context, routeName, _) {
          final isBlockedRoute = _hiddenRoutes.contains(routeName);
          return ValueListenableBuilder<bool>(
            valueListenable: AiGlobalFab.isVisible,
            builder: (context, visible, _) {
              final shouldShow = visible && !isBlockedRoute;
              return AnimatedOpacity(
                opacity: shouldShow ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !shouldShow,
                  child: ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.08).animate(
                      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                    ),
                    child: const AiChatButton(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AiChatButton extends StatelessWidget {
  const AiChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showChat(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white24,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Hero(
            tag: 'buzz_mascot_fab',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/buzz_mascot.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stackTrace) => const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChat(BuildContext context) {
    final navContext = FarmBuzzApp.navigatorKey.currentContext;
    if (navContext != null) {
      AiGlobalFab.isVisible.value = false;
      showModalBottomSheet(
        context: navContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AiChatSheet(),
      ).then((_) {
        AiGlobalFab.isVisible.value = true;
      });
    }
  }
}
