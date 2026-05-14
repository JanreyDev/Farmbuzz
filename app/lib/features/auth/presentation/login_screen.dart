import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import 'widgets/action_button.dart';
import 'widgets/mobile_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLightMode = false;

  bool get _canLogin => _mobileController.text.trim().length == 10;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _showPlaceholderMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _BackgroundLayer(isLightMode: _isLightMode),
          Positioned.fill(child: _GridLayer(isLightMode: _isLightMode)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 700;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Logo(isCompact: isCompact, isLightMode: _isLightMode),
                            Row(
                              children: [
                                _LanguageSelector(isCompact: isCompact, isLightMode: _isLightMode),
                                const SizedBox(width: 12),
                                _ThemeToggle(
                                  isCompact: isCompact,
                                  isLightMode: _isLightMode,
                                  onTap: () => setState(() => _isLightMode = !_isLightMode),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: isCompact ? 30 : 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Badge(isCompact: isCompact, isLightMode: _isLightMode),
                              const SizedBox(height: 16),
                              _HeroText(isCompact: isCompact, isLightMode: _isLightMode),
                              const SizedBox(height: 20),
                              Text(
                                'Connect with breeders, manage your farm, and grow your network on FarmBuzz.',
                                style: TextStyle(
                                  color: _isLightMode
                                      ? const Color(0xFF5A6860)
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontSize: isCompact ? 14 : 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 420),
                                  child: _LoginCard(
                                    isCompact: isCompact,
                                    isLightMode: _isLightMode,
                                    mobileController: _mobileController,
                                    canLogin: _canLogin,
                                    onChanged: (_) => setState(() {}),
                                    onForgotPin: () => _showPlaceholderMessage('Forgot PIN flow is not connected yet.'),
                                    onCreateAccount: () => _showPlaceholderMessage('Create account flow is not connected yet.'),
                                    onLogin: () => _showPlaceholderMessage('Login action is frontend-only for now.'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            _FooterLinks(isLightMode: _isLightMode),
                            const SizedBox(height: 16),
                            _CopyrightText(isLightMode: _isLightMode),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({required this.isLightMode});

  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightMode
              ? const [Color(0xFFA4D4B1), Color(0xFFCFE2D9), Color(0xFFE2D7C2)]
              : const [Color(0xFF041C06), Color(0xFF1A1F04), Color(0xFF2D1B02)],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}

class _GridLayer extends StatelessWidget {
  const _GridLayer({required this.isLightMode});

  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _GridPainter(isLightMode: isLightMode)));
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.isLightMode});

  final bool isLightMode;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isLightMode
          ? const Color(0xFF3C5B49).withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0;

    const step = 34.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.isLightMode != isLightMode;
}

class _Logo extends StatelessWidget {
  const _Logo({required this.isCompact, required this.isLightMode});

  final bool isCompact;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: isCompact ? 32 : 40,
      errorBuilder: (context, error, stackTrace) => Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'FB',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isCompact ? 16 : 20,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Farm',
            style: TextStyle(
              color: isLightMode ? const Color(0xFF253329) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 18 : 22,
            ),
          ),
          Text(
            'Buzz',
            style: TextStyle(
              color: AppColors.golden,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 18 : 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.isCompact, required this.isLightMode});

  final bool isCompact;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLightMode
            ? const Color(0xFFFFFFFF).withValues(alpha: 0.45)
            : Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLightMode ? const Color(0xFFC7D0C4) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'English',
            style: TextStyle(
              color: isLightMode ? const Color(0xFF2A362E) : Colors.white,
              fontSize: isCompact ? 12 : 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            color: isLightMode ? const Color(0xFF5A655D) : Colors.white70,
            size: isCompact ? 16 : 18,
          ),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({
    required this.isCompact,
    required this.isLightMode,
    required this.onTap,
  });

  final bool isCompact;
  final bool isLightMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLightMode
                ? const Color(0xFFFFFFFF).withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: isLightMode ? const Color(0xFFC7D0C4) : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            isLightMode ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined,
            color: isLightMode ? const Color(0xFF3B4A3F) : Colors.white70,
            size: isCompact ? 16 : 20,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.isCompact, required this.isLightMode});

  final bool isCompact;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLightMode
            ? const Color(0xFFFFFFFF).withValues(alpha: 0.45)
            : Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accentGreen,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.accentGreen, blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'The Breeder\'s Network',
            style: TextStyle(
              color: isLightMode ? const Color(0xFF334236) : Colors.white.withValues(alpha: 0.9),
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.isCompact, required this.isLightMode});

  final bool isCompact;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    final primaryText = isLightMode ? const Color(0xFF0F1A14) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build your farm.',
          style: GoogleFonts.instrumentSerif(
            fontSize: isCompact ? 32 : 40,
            color: primaryText,
            height: 1.1,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2DBB57), Color(0xFFC88F1C)],
          ).createShader(bounds),
          child: Text(
            'Grow your flock.',
            style: GoogleFonts.instrumentSerif(
              fontSize: isCompact ? 32 : 40,
              color: Colors.white,
              height: 1.1,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Text(
          'Own your community.',
          style: GoogleFonts.instrumentSerif(
            fontSize: isCompact ? 32 : 40,
            color: primaryText,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.isCompact,
    required this.isLightMode,
    required this.mobileController,
    required this.canLogin,
    required this.onChanged,
    required this.onForgotPin,
    required this.onCreateAccount,
    required this.onLogin,
  });

  final bool isCompact;
  final bool isLightMode;
  final TextEditingController mobileController;
  final bool canLogin;
  final ValueChanged<String> onChanged;
  final VoidCallback onForgotPin;
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isCompact ? 16 : 24,
        isCompact ? 20 : 28,
        isCompact ? 16 : 24,
        isCompact ? 24 : 32,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isLightMode
              ? const Color(0xFFBFD1C2)
              : AppColors.accentGreen.withValues(alpha: 0.15),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightMode
              ? const [Color(0xFFF1F3EF), Color(0xFFE6E9E4)]
              : [
                  AppColors.cardDarkGreen.withValues(alpha: 0.9),
                  AppColors.cardDeepGreen.withValues(alpha: 0.95),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isLightMode
                ? const Color(0xFF758C79).withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log into FarmBuzz',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSerif(
              fontSize: isCompact ? 24 : 28,
              color: isLightMode ? const Color(0xFF19261E) : const Color(0xFFEAF7ED),
            ),
          ),
          SizedBox(height: isCompact ? 24 : 32),
          MobileInput(
            controller: mobileController,
            onChanged: onChanged,
            isValid: canLogin,
            isLightMode: isLightMode,
          ),
          const SizedBox(height: 20),
          ActionButton(
            label: 'Log In',
            isEnabled: canLogin,
            isLightMode: isLightMode,
            onPressed: onLogin,
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: onForgotPin,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentGreen,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: const Text(
                'Forgot PIN?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            color: isLightMode ? const Color(0xFFC8CFCA) : Colors.white.withValues(alpha: 0.08),
            height: 1,
          ),
          const SizedBox(height: 10),
          Text(
            'New to FarmBuzz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLightMode
                  ? const Color(0xFF6A766F)
                  : Colors.white.withValues(alpha: 0.38),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFCCB31), Color(0xFFF29A00)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF6AB00).withValues(alpha: isLightMode ? 0.35 : 0.45),
                    blurRadius: 22,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCreateAccount,
                  borderRadius: BorderRadius.circular(16),
                  child: const SizedBox(
                    width: 205,
                    height: 52,
                    child: Center(
                      child: Text(
                        'Create new account',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
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

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.isLightMode});

  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    const topRow = ['Privacy', 'Terms', 'Community'];
    const bottomRow = ['Disclaimer', 'Ambassador', 'Safety'];

    return Column(
      children: [
        Container(
          height: 1,
          width: 240,
          color: isLightMode ? const Color(0xFF9EB0A2).withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 12),
        _FooterRow(labels: topRow, isLightMode: isLightMode),
        const SizedBox(height: 8),
        _FooterRow(labels: bottomRow, isLightMode: isLightMode),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({required this.labels, required this.isLightMode});

  final List<String> labels;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final label in labels) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isLightMode
                  ? const Color(0xFFFFFFFF).withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isLightMode
                    ? const Color(0xFFBFC9C1)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isLightMode
                    ? const Color(0xFF516157)
                    : Colors.white.withValues(alpha: 0.68),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (label != labels.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _CopyrightText extends StatelessWidget {
  const _CopyrightText({required this.isLightMode});

  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Text(
      '© 2026 FarmBuzz. All rights reserved.',
      style: TextStyle(
        color: isLightMode
            ? const Color(0xFF67766D)
            : Colors.white.withValues(alpha: 0.4),
        fontSize: 11,
      ),
    );
  }
}
