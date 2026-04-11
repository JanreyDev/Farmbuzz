import 'package:app/app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kLightGreen = Color(0xFF66BB6A);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), _goToOnboarding);
  }

  void _goToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDarkGreen,
      body: Stack(
        children: [
          const _BackdropGlow(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const _LogoHero(),
                  const SizedBox(height: 28),
                  const Text(
                    'FarmBuzz',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Built for farmers, breeders, and communities.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 148,
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            borderRadius: BorderRadius.all(Radius.circular(999)),
                            backgroundColor: Color(0x3D66BB6A),
                            valueColor: AlwaysStoppedAnimation<Color>(_kLightGreen),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading your farm world...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kDarkGreen, _kPrimaryGreen],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -40,
            child: _GlowOrb(size: 260, color: Color(0x2B66BB6A)),
          ),
          Positioned(
            top: 180,
            right: -80,
            child: _GlowOrb(size: 220, color: Color(0x2466BB6A)),
          ),
          Positioned(
            bottom: -110,
            left: -40,
            child: _GlowOrb(size: 280, color: Color(0x1F66BB6A)),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _LogoHero extends StatelessWidget {
  const _LogoHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 210,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.30),
            _kLightGreen.withValues(alpha: 0.28),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(24),
        child: Image.asset(
          'assets/images/Logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
