import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  bool get _canLogin => _mobileController.text.trim().length == 10;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final horizontalPadding = isCompact ? 14.0 : 20.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGreen,
              Color(0xFF0A281B),
              Color(0xFF452804),
              AppColors.darkBackground,
            ],
            stops: [0.0, 0.4, 0.85, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _GridLayer(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isCompact ? 12 : 20,
                          horizontalPadding,
                          20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _TopBar(isCompact: isCompact),
                                  SizedBox(height: isCompact ? 20 : 30),
                                  _HeroText(isCompact: isCompact),
                                  SizedBox(height: isCompact ? 20 : 30),
                                  _LoginCard(
                                    isCompact: isCompact,
                                    mobileController: _mobileController,
                                    canLogin: _canLogin,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                            const Column(
                              children: [
                                _FooterLinks(),
                                SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _Logo(),
        const Spacer(),
        _LanguageSelector(isCompact: isCompact),
        const SizedBox(width: 8),
        _ThemeToggle(isCompact: isCompact),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: 42,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image fails to load
        return const Text(
          'FB FarmBuzz',
          style: TextStyle(
            color: AppColors.accentGreen,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        );
      },
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withValues(alpha: 0.24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language_rounded, size: 14, color: Color(0xFFE8F6EA)),
          SizedBox(width: 6),
          Text(
            'English',
            style: TextStyle(
              color: Color(0xFFE8F6EA),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: Color(0xFFE8F6EA),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: const Icon(
        Icons.wb_sunny_outlined,
        size: 16,
        color: Color(0xFFE8F6EA),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final heroStyle = GoogleFonts.instrumentSerif(
      fontSize: isCompact ? 36 : 44,
      height: 1.02,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFEAF7ED),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Badge(isCompact: isCompact),
        SizedBox(height: isCompact ? 16 : 22),
        RichText(
          text: TextSpan(
            style: heroStyle,
            children: [
              const TextSpan(text: 'Build your farm.\n'),
              WidgetSpan(
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accentGreen, AppColors.golden],
                  ).createShader(bounds),
                  child: Text(
                    'Grow your flock.',
                    style: heroStyle.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const TextSpan(text: '\nOwn your community.'),
            ],
          ),
        ),
        SizedBox(height: isCompact ? 12 : 16),
        Text(
          'Connect with breeders, manage your farm, and grow your network on FarmBuzz.',
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: isCompact ? 13.5 : 14.5,
            height: 1.42,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.cardDarkGreen.withValues(alpha: 0.6),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.accentGreen),
          const SizedBox(width: 8),
          const Text(
            "The Breeder's Network",
            style: TextStyle(
              color: Color(0xFFE8F6EA),
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatefulWidget {
  const _LoginCard({
    super.key,
    required this.isCompact,
    required this.mobileController,
    required this.canLogin,
    required this.onChanged,
  });

  final bool isCompact;
  final TextEditingController mobileController;
  final bool canLogin;
  final ValueChanged<String> onChanged;

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showActive = _isFocused || widget.canLogin;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        widget.isCompact ? 12 : 16,
        widget.isCompact ? 14 : 18,
        widget.isCompact ? 12 : 16,
        widget.isCompact ? 16 : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.15)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardDarkGreen.withValues(alpha: 0.9),
            AppColors.cardDeepGreen.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
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
              fontSize: widget.isCompact ? 18 : 20,
              color: const Color(0xFFEAF7ED),
            ),
          ),
          SizedBox(height: widget.isCompact ? 10 : 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: widget.isCompact ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: showActive
                    ? AppColors.accentGreen.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.1),
                width: showActive ? 1.4 : 1.0,
              ),
              boxShadow: [
                if (showActive)
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Row(
              children: [
                _CountryPicker(isCompact: widget.isCompact),
                const SizedBox(width: 8),
                Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.mobileController,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '9XX XXXX XXX',
                      hintStyle: TextStyle(color: Color(0xFF61796A)),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (widget.canLogin)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.accentGreen,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: widget.isCompact ? 10 : 12),
          Container(
            decoration: widget.canLogin
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.45),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  )
                : null,
            child: ElevatedButton(
              onPressed: widget.canLogin ? () {} : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: widget.canLogin ? AppColors.accentGreen : const Color(0xFF2D2D2D),
                foregroundColor: widget.canLogin ? Colors.black : Colors.white.withValues(alpha: 0.5),
                disabledBackgroundColor: const Color(0xFF1A1A1A),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.2),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: widget.canLogin
                        ? AppColors.accentGreen.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: const Text(
                'Log In',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot PIN?',
              style: TextStyle(
                color: Color(0xFF54E07D),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 16),
          const Text(
            'New to FarmBuzz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.golden.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.golden,
                foregroundColor: const Color(0xFF2D2203),
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Create new account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryPicker extends StatelessWidget {
  const _CountryPicker({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            width: 20,
            height: 14,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: Container(color: const Color(0xFF0038A8))),
                    Expanded(child: Container(color: const Color(0xFFCE1126))),
                  ],
                ),
                Container(
                  width: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '+63',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    const links = [
      'Privacy',
      'Terms',
      'Community',
      'Disclaimer',
      'Ambassador',
      'Age 18+',
    ];

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final link in links)
            Text(
              link,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 11.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _GridLayer extends StatelessWidget {
  const _GridLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _GridPainter()));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;

    const step = 34.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
