import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'landing_view.dart';
import 'widgets/login_card.dart';
import 'widgets/forgot_pin_card.dart';
import 'widgets/create_account_card.dart';
import 'widgets/pin_login_card.dart';
import 'widgets/common/footer_links.dart';
import 'widgets/common/grid_layer.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LandingView _currentView = LandingView.login;
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _forgotMobileController = TextEditingController();
  final TextEditingController _registerMobileController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _forgotMobileController.dispose();
    _registerMobileController.dispose();
    _nameController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  bool get _canLogin => _mobileController.text.trim().length == 10;
  bool get _canReset => _forgotMobileController.text.trim().length == 10;
  bool get _canSendCode => _registerMobileController.text.trim().length == 10;

  String _toE164(String number) => '+63$number';

  void _setView(LandingView view) {
    setState(() {
      _currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF041C06), // Deep Green
                    Color(0xFF1A1F04), // Dark Olive
                    Color(0xFF2D1B02), // Darker Orange/Brown
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: GridLayer()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 700;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Logo(isCompact: isCompact),
                            Row(
                              children: [
                                _LanguageSelector(isCompact: isCompact),
                                const SizedBox(width: 12),
                                _ThemeToggle(isCompact: isCompact),
                              ],
                            ),
                          ],
                        ),

                        // Main Content
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isCompact ? 30 : 40,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Badge(isCompact: isCompact),
                              const SizedBox(height: 16),
                              _HeroText(isCompact: isCompact),
                              const SizedBox(height: 20),
                              Text(
                                'Connect with farmers, manage your farm, and grow your network on FarmBuzz.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: isCompact ? 14 : 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Auth Card
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 420,
                                  ),
                                  child: _currentView == LandingView.login
                                      ? LoginCard(
                                          isCompact: isCompact,
                                          mobileController: _mobileController,
                                          canLogin: _canLogin,
                                          onChanged: (_) => setState(() {}),
                                          onForgotPin: () =>
                                              _setView(LandingView.forgotPin),
                                          onCreateAccount: () => _setView(
                                            LandingView.createAccount,
                                          ),
                                          onLogin: () =>
                                              _setView(LandingView.pinLogin),
                                        )
                                      : _currentView == LandingView.pinLogin
                                      ? PinLoginCard(
                                          isCompact: isCompact,
                                          phoneNumber:
                                              _mobileController.text.isEmpty
                                              ? '+63 961 **** 255'
                                              : '+63 ${_mobileController.text.substring(0, 3)} **** ${_mobileController.text.substring(7)}',
                                          mobileNumberE164: _toE164(
                                            _mobileController.text.trim(),
                                          ),
                                          onNotYou: () =>
                                              _setView(LandingView.login),
                                          onForgotPin: () =>
                                              _setView(LandingView.forgotPin),
                                        )
                                      : _currentView == LandingView.forgotPin
                                      ? ForgotPinCard(
                                          isCompact: isCompact,
                                          mobileController:
                                              _forgotMobileController,
                                          canReset: _canReset,
                                          onChanged: (_) => setState(() {}),
                                          onBack: () =>
                                              _setView(LandingView.login),
                                        )
                                      : CreateAccountCard(
                                          isCompact: isCompact,
                                          nameController: _nameController,
                                          mobileController:
                                              _registerMobileController,
                                          referralController:
                                              _referralController,
                                          canSendCode: _canSendCode,
                                          onChanged: () => setState(() {}),
                                          onLogin: () =>
                                              _setView(LandingView.login),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Footer
                        const Column(
                          children: [
                            FooterLinks(),
                            SizedBox(height: 16),
                            _CopyrightText(),
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

class _Logo extends StatelessWidget {
  const _Logo({required this.isCompact});
  final bool isCompact;

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
              color: Colors.white,
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
  const _LanguageSelector({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(
            'English',
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 12 : 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white70,
            size: isCompact ? 16 : 18,
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
        color: Colors.black.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(
        Icons.wb_sunny_outlined,
        color: Colors.white70,
        size: isCompact ? 16 : 20,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
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
              boxShadow: [
                BoxShadow(color: AppColors.accentGreen, blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'The Farmers\' Network',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
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
  const _HeroText({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build your farm.',
          style: GoogleFonts.instrumentSerif(
            fontSize: isCompact ? 32 : 40,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.accentGreen, AppColors.golden],
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
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _CopyrightText extends StatelessWidget {
  const _CopyrightText();

  @override
  Widget build(BuildContext context) {
    return Text(
      '© 2026 FarmBuzz. All rights reserved.',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 11,
      ),
    );
  }
}
