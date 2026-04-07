import 'dart:async';

import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _splashDuration = Duration(milliseconds: 2400);
  static const _entranceDuration = Duration(milliseconds: 1200);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _entranceDuration)
      ..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _navigationTimer = Timer(_splashDuration, _goToHome);
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _SplashBackdrop(),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 240,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: kGoldSoft, width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 28,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset(
                                'assets/images/splash.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'FarmBuzz',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Grow better decisions, together.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: kNeutralSubtle,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 170,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: const LinearProgressIndicator(minHeight: 5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, kSurfaceLight],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _GlowBlob(
              size: 230,
              color: kGoldAccent.withValues(alpha: 0.20),
            ),
          ),
          Positioned(
            left: -85,
            bottom: -65,
            child: _GlowBlob(
              size: 210,
              color: kGoldAccent.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            left: 26,
            top: 58,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: kGoldAccent.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            right: 44,
            bottom: 88,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: kGoldAccent.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 18)],
      ),
    );
  }
}
