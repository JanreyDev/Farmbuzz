import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_api.dart';
import 'widgets/action_button.dart';
import 'widgets/checkbox_tile.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/mobile_input.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/otp_input.dart';
import 'widgets/pin_dots.dart';

class CreateAccountCard extends StatefulWidget {
  const CreateAccountCard({
    super.key,
    required this.isCompact,
    required this.isLightMode,
    required this.nameController,
    required this.mobileController,
    required this.referralController,
    required this.onBackToLogin,
    required this.onComplete,
  });

  final bool isCompact;
  final bool isLightMode;
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController referralController;
  final VoidCallback onBackToLogin;
  final VoidCallback onComplete;

  @override
  State<CreateAccountCard> createState() => _CreateAccountCardState();
}

class _CreateAccountCardState extends State<CreateAccountCard> {
  final AuthApi _authApi = AuthApi();

  int _currentStep = 0;
  bool _isEighteen = false;
  bool _isAgreed = false;
  bool _isLoading = false;
  int? _registrationId;

  String _otp = '';
  String _pin = '';
  bool _isConfirmingPin = false;
  String _tempPin = '';

  bool get _canSignUp =>
      widget.nameController.text.trim().isNotEmpty && _isEighteen && _isAgreed;
  bool get _canSendCode => widget.mobileController.text.trim().length == 10;
  bool get _canVerifyOtp => _otp.length == 6;
  bool get _canEnterPin => _pin.length < 6;

  void _goNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    }
  }

  void _prevStep() {
    if (_isLoading) {
      return;
    }

    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      widget.onBackToLogin();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startRegistration() async {
    if (!_canSignUp || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final registrationId = await _authApi.startRegistration(
        name: widget.nameController.text.trim(),
        referralCode: widget.referralController.text.trim().isEmpty
            ? null
            : widget.referralController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _registrationId = registrationId;
        _isLoading = false;
      });
      _goNext();
    } on AuthApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage('Unable to start registration. Please try again.');
    }
  }

  Future<void> _sendOtp() async {
    final registrationId = _registrationId;
    if (!_canSendCode || _isLoading || registrationId == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authApi.sendOtp(
        registrationId: registrationId,
        mobileNumber: '+63${widget.mobileController.text.trim()}',
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _currentStep = 2;
      });
      _showMessage('Code sent successfully.');
    } on AuthApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage('Failed to send OTP. Please try again.');
    }
  }

  Future<void> _verifyOtp() async {
    final registrationId = _registrationId;
    if (!_canVerifyOtp || _isLoading || registrationId == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authApi.verifyOtp(registrationId: registrationId, otp: _otp);
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _currentStep = 3;
      });
    } on AuthApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage('OTP verification failed. Please try again.');
    }
  }

  Future<void> _submitPin() async {
    if (_pin.length != 6 || _isLoading) {
      return;
    }

    if (!_isConfirmingPin) {
      setState(() {
        _tempPin = _pin;
        _pin = '';
        _isConfirmingPin = true;
      });
      return;
    }

    if (_pin != _tempPin) {
      setState(() {
        _pin = '';
        _tempPin = '';
        _isConfirmingPin = false;
      });
      _showMessage('PIN does not match. Please try again.');
      return;
    }

    final registrationId = _registrationId;
    if (registrationId == null) {
      _showMessage('Registration session expired. Please start again.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authApi.setPin(registrationId: registrationId, pin: _pin);
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage('Account created successfully.');
      widget.onComplete();
    } on AuthApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      _showMessage('Failed to complete registration. Please try again.');
    }
  }

  String _maskedPhone() {
    final number = widget.mobileController.text.trim();
    if (number.length != 10) {
      return '+63 9XX XXX XXXX';
    }

    return '+63 ${number.substring(0, 3)} **** ${number.substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        widget.isCompact ? 14 : 20,
        widget.isCompact ? 16 : 22,
        widget.isCompact ? 14 : 20,
        widget.isCompact ? 18 : 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.isLightMode
              ? const Color(0xFFBFD1C2)
              : AppColors.accentGreen.withValues(alpha: 0.2),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isLightMode
              ? const [Color(0xFFF1F3EF), Color(0xFFE6E9E4)]
              : [
                  AppColors.cardDarkGreen.withValues(alpha: 0.9),
                  AppColors.cardDeepGreen.withValues(alpha: 0.95),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isLightMode
                ? const Color(0xFF758C79).withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.5),
            blurRadius: 44,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepsHeader(currentStep: _currentStep, isLightMode: widget.isLightMode),
          const SizedBox(height: 18),
          if (_currentStep > 1)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: _prevStep,
                icon: Icon(
                  Icons.arrow_back,
                  color: widget.isLightMode ? const Color(0xFF4A5A4F) : Colors.white70,
                  size: 20,
                ),
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
    final secondary = widget.isLightMode ? const Color(0xFF6A766F) : Colors.white70;

    return Column(
      children: [
        _StepIntro(
          title: 'Create a new account',
          subtitle: "It's quick and easy.",
          isCompact: widget.isCompact,
          isLightMode: widget.isLightMode,
        ),
        SizedBox(height: widget.isCompact ? 20 : 24),
        CustomTextField(
          controller: widget.nameController,
          hintText: 'Full name (required)',
          isLightMode: widget.isLightMode,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: widget.referralController,
          hintText: 'Referral code (optional)',
          isLightMode: widget.isLightMode,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        CheckboxTile(
          value: _isEighteen,
          isLightMode: widget.isLightMode,
          onChanged: (v) => setState(() => _isEighteen = v),
          label: RichText(
            text: TextSpan(
              style: TextStyle(color: secondary, fontSize: widget.isCompact ? 11 : 12),
              children: const [
                TextSpan(text: 'I confirm I am at least '),
                TextSpan(
                  text: '18 years old',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                ),
                TextSpan(text: '. FarmBuzz is an 18+ platform — see our '),
                TextSpan(
                  text: 'Age Policy.',
                  style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        CheckboxTile(
          value: _isAgreed,
          isLightMode: widget.isLightMode,
          onChanged: (v) => setState(() => _isAgreed = v),
          label: RichText(
            text: TextSpan(
              style: TextStyle(color: secondary, fontSize: widget.isCompact ? 11 : 12),
              children: const [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ', and '),
                TextSpan(
                  text: 'Community Guidelines',
                  style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: '. I understand I may receive SMS notifications.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: _isLoading ? 'Please wait...' : 'Sign Up',
          isEnabled: _canSignUp && !_isLoading,
          isLightMode: widget.isLightMode,
          onPressed: _startRegistration,
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: widget.onBackToLogin,
          child: const Text(
            'Already have an account?',
            style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStep() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.isLightMode
                    ? const Color(0xFFFFFFFF).withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isLightMode
                      ? const Color(0xFFCDD4CF)
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: IconButton(
                onPressed: _prevStep,
                icon: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: widget.isLightMode
                      ? const Color(0xFF4A5A4F)
                      : Colors.white70,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mobile number',
                    style: TextStyle(
                      fontSize: widget.isCompact ? 17 : 18,
                      fontWeight: FontWeight.w700,
                      color: widget.isLightMode
                          ? const Color(0xFF1E2821)
                          : const Color(0xFFEAF7ED),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "We'll send a verification code",
                    style: TextStyle(
                      color: widget.isLightMode
                          ? const Color(0xFF6F7A74)
                          : AppColors.textGrey,
                      fontSize: widget.isCompact ? 12 : 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        MobileInput(
          controller: widget.mobileController,
          onChanged: (_) => setState(() {}),
          isValid: _canSendCode,
          isLightMode: widget.isLightMode,
        ),
        const SizedBox(height: 22),
        ActionButton(
          label: _isLoading ? 'Sending...' : 'Send Code',
          isEnabled: _canSendCode && !_isLoading,
          isLightMode: widget.isLightMode,
          onPressed: _sendOtp,
        ),
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _StepIntro(
          title: 'Enter verification code',
          subtitle: 'Code sent to ${_maskedPhone()}',
          isCompact: widget.isCompact,
          isLightMode: widget.isLightMode,
        ),
        const SizedBox(height: 26),
        OtpInput(
          isLightMode: widget.isLightMode,
          onChanged: (value) => setState(() => _otp = value),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: _isLoading ? null : _sendOtp,
          child: const Text(
            'Resend code',
            style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        ActionButton(
          label: _isLoading ? 'Verifying...' : 'Verify',
          isEnabled: _canVerifyOtp && !_isLoading,
          isLightMode: widget.isLightMode,
          onPressed: _verifyOtp,
        ),
      ],
    );
  }

  Widget _buildPinStep() {
    final title = _isConfirmingPin ? 'Confirm your PIN' : 'Create your PIN';
    final subtitle = _isConfirmingPin
        ? 'Enter your PIN again to confirm'
        : 'Choose a 6-digit PIN for quick login';

    return Column(
      children: [
        const SizedBox(height: 8),
        _StepIntro(
          title: title,
          subtitle: subtitle,
          isCompact: widget.isCompact,
          isLightMode: widget.isLightMode,
        ),
        const SizedBox(height: 24),
        PinDots(count: _pin.length, isLightMode: widget.isLightMode),
        const SizedBox(height: 24),
        NumericKeypad(
          isLightMode: widget.isLightMode,
          onTap: (val) {
            if (!_canEnterPin || _isLoading) {
              return;
            }
            setState(() => _pin += val);
            if (_pin.length == 6) {
              Future<void>.delayed(const Duration(milliseconds: 120), _submitPin);
            }
          },
          onDelete: () {
            if (_pin.isNotEmpty && !_isLoading) {
              setState(() => _pin = _pin.substring(0, _pin.length - 1));
            }
          },
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

class _StepsHeader extends StatelessWidget {
  const _StepsHeader({required this.currentStep, required this.isLightMode});

  final int currentStep;
  final bool isLightMode;

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
                  color: isActive
                      ? AppColors.accentGreen
                      : (isLightMode ? const Color(0xFFC0C9C1) : Colors.white10),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final isActive = index == currentStep;
            return Expanded(
              child: Center(
                child: Text(
                  steps[index],
                  style: TextStyle(
                    color: isActive
                        ? AppColors.accentGreen
                        : (isLightMode ? const Color(0xFF8A9890) : Colors.white24),
                    fontSize: 9.5,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepIntro extends StatelessWidget {
  const _StepIntro({
    required this.title,
    required this.subtitle,
    required this.isCompact,
    required this.isLightMode,
  });

  final String title;
  final String subtitle;
  final bool isCompact;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSerif(
            fontSize: isCompact ? 20 : 24,
            color: isLightMode ? const Color(0xFF1E2821) : const Color(0xFFEAF7ED),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isLightMode ? const Color(0xFF6A766F) : AppColors.textGrey,
            fontSize: isCompact ? 12 : 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
