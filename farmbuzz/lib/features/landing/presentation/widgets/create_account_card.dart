import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'common/action_button.dart';
import 'common/checkbox_tile.dart';
import 'common/custom_text_field.dart';
import 'common/mobile_input.dart';
import 'common/otp_input.dart';
import 'common/pin_dots.dart';
import 'common/numeric_keypad.dart';
import 'package:farmbuzz/features/home/presentation/home_screen.dart';

class CreateAccountCard extends StatefulWidget {
  const CreateAccountCard({
    super.key,
    required this.isCompact,
    required this.nameController,
    required this.mobileController,
    required this.referralController,
    required this.canSendCode,
    required this.onChanged,
    required this.onLogin,
  });

  final bool isCompact;
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController referralController;
  final bool canSendCode;
  final VoidCallback onChanged;
  final VoidCallback onLogin;

  @override
  State<CreateAccountCard> createState() => _CreateAccountCardState();
}

class _CreateAccountCardState extends State<CreateAccountCard> {
  int _currentStep = 0;
  bool _isEighteen = false;
  bool _isAgreed = false;

  String _pin = '';
  bool _isConfirmingPin = false;
  String _tempPin = '';

  bool get _canSignUp =>
      widget.nameController.text.trim().isNotEmpty && _isEighteen && _isAgreed;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      widget.onLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _StepsHeader(currentStep: _currentStep),
          const SizedBox(height: 18),
          if (_currentStep > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          if (_currentStep == 0) _buildInfoStep(),
          if (_currentStep == 1) _buildMobileStep(),
          if (_currentStep == 2) _buildVerifyStep(),
          if (_currentStep == 3) _buildPinStep(),
        ],
      ),
    );
  }

  Widget _buildInfoStep() {
    return Column(
      children: [
        Text(
          'Create a new account',
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSerif(
            fontSize: widget.isCompact ? 20 : 22,
            color: const Color(0xFFEAF7ED),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "It's quick and easy.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: widget.isCompact ? 12 : 13,
          ),
        ),
        SizedBox(height: widget.isCompact ? 18 : 22),
        CustomTextField(
          controller: widget.nameController,
          hintText: 'Full name',
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: widget.referralController,
          hintText: 'Referral code (optional)',
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: 20),
        CheckboxTile(
          value: _isEighteen,
          onChanged: (v) => setState(() {
            _isEighteen = v;
            widget.onChanged();
          }),
          label: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white70, fontSize: widget.isCompact ? 11 : 12),
              children: [
                const TextSpan(text: 'I confirm I am at least '),
                const TextSpan(
                  text: '18 years old.',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const TextSpan(text: ' FarmBuzz is an 18+ platform — see our '),
                const TextSpan(
                  text: 'Age Policy',
                  style: TextStyle(color: AppColors.accentGreen),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        CheckboxTile(
          value: _isAgreed,
          onChanged: (v) => setState(() {
            _isAgreed = v;
            widget.onChanged();
          }),
          label: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white70, fontSize: widget.isCompact ? 11 : 12),
              children: [
                const TextSpan(text: 'I agree to the '),
                const TextSpan(
                  text: 'Terms of Service, Privacy Policy, ',
                  style: TextStyle(color: AppColors.accentGreen),
                ),
                const TextSpan(text: 'and '),
                const TextSpan(
                  text: 'Community Guidelines.',
                  style: TextStyle(color: AppColors.accentGreen),
                ),
                const TextSpan(text: ' I understand I may receive SMS notifications.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: 'Sign Up',
          isEnabled: _canSignUp,
          onPressed: _nextStep,
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: widget.onLogin,
          child: const Text(
            'Already have an account?',
            style: TextStyle(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStep() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'Mobile number',
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSerif(
            fontSize: 22,
            color: const Color(0xFFEAF7ED),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "We'll send a verification code",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 24),
        MobileInput(
          controller: widget.mobileController,
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: 'Send Code',
          isEnabled: widget.canSendCode,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'Verify your number',
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSerif(
            fontSize: 22,
            color: const Color(0xFFEAF7ED),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Code sent to +63 971 **** 212",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 30),
        const OtpInput(),
        const SizedBox(height: 30),
        const Text(
          'Resend code (58s)',
          style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          "Didn't receive the code? Check your SMS inbox or tap Resend code when the timer expires.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 10),
        ActionButton(label: 'Verify', isEnabled: true, onPressed: _nextStep),
      ],
    );
  }

  Widget _buildPinStep() {
    final title = _isConfirmingPin ? 'Confirm your PIN' : 'Create your PIN';
    final subtitle = _isConfirmingPin ? 'Enter your PIN again to confirm' : 'Choose a 6-digit PIN for quick login';

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSerif(
            fontSize: 22,
            color: const Color(0xFFEAF7ED),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 30),
        PinDots(count: _pin.length),
        const SizedBox(height: 30),
        NumericKeypad(
          onTap: (val) {
            if (_pin.length < 6) {
              setState(() => _pin += val);
              if (_pin.length == 6) {
                if (!_isConfirmingPin) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    setState(() {
                      _tempPin = _pin;
                      _pin = '';
                      _isConfirmingPin = true;
                    });
                  });
                } else {
                  // Simulate registration success
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              }
            }
          },
          onDelete: () {
            if (_pin.isNotEmpty) {
              setState(() => _pin = _pin.substring(0, _pin.length - 1));
            }
          },
        ),
      ],
    );
  }
}

class _StepsHeader extends StatelessWidget {
  const _StepsHeader({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const steps = ['INFO', 'MOBILE', 'VERIFY', 'PIN'];

    return Column(
      children: [
        Row(
          children: List.generate(4, (index) {
            final isActive = index <= currentStep;
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accentGreen : Colors.white10,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final isActive = index == currentStep;
            return Text(
              steps[index],
              style: TextStyle(
                color: isActive ? AppColors.accentGreen : Colors.white24,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            );
          }),
        ),
      ],
    );
  }
}
