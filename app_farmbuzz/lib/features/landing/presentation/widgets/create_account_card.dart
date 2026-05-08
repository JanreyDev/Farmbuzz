import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/home/presentation/home_screen.dart';
import 'package:farmbuzz/features/landing/data/registration_api.dart';
import 'common/action_button.dart';
import 'common/checkbox_tile.dart';
import 'common/custom_text_field.dart';
import 'common/mobile_input.dart';
import 'common/otp_input.dart';
import 'common/pin_dots.dart';
import 'common/numeric_keypad.dart';

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
  final RegistrationApi _registrationApi = RegistrationApi();

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

  bool get _canVerifyOtp => _otp.length == 6;

  bool get _canEnterPin => _pin.length < 6;

  Future<void> _startRegistration() async {
    if (!_canSignUp || _isLoading) {
      return;
    }

    await _runBusy(() async {
      final id = await _registrationApi.startRegistration(
        name: widget.nameController.text.trim(),
        referralCode: widget.referralController.text.trim().isEmpty
            ? null
            : widget.referralController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _registrationId = id;
        _currentStep = 1;
      });
    });
  }

  Future<void> _sendOtp() async {
    if (_registrationId == null || !widget.canSendCode || _isLoading) {
      return;
    }

    await _runBusy(() async {
      await _registrationApi.sendOtp(
        registrationId: _registrationId!,
        mobileNumber: _toE164(widget.mobileController.text.trim()),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentStep = 2;
      });

      _showMessage('OTP sent. Use 123456 for now.');
    });
  }

  Future<void> _verifyOtp() async {
    if (_registrationId == null || !_canVerifyOtp || _isLoading) {
      return;
    }

    await _runBusy(() async {
      await _registrationApi.verifyOtp(
        registrationId: _registrationId!,
        otp: _otp,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentStep = 3;
      });
    });
  }

  Future<void> _submitPin() async {
    if (_registrationId == null || _pin.length != 6 || _isLoading) {
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

    await _runBusy(() async {
      await _registrationApi.setPin(
        registrationId: _registrationId!,
        pin: _pin,
      );

      if (!mounted) {
        return;
      }

      AppSession.setUser(
        userName: widget.nameController.text.trim(),
        mobileNumber: _toE164(widget.mobileController.text.trim()),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    setState(() => _isLoading = true);

    try {
      await action();
    } on RegistrationApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _prevStep() {
    if (_isLoading) {
      return;
    }

    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      widget.onLogin();
    }
  }

  String _toE164(String number) => '+63$number';

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
          color: AppColors.accentGreen.withValues(alpha: 0.2),
          width: 1.2,
        ),
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
            blurRadius: 44,
            offset: const Offset(0, 22),
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white70,
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
    return Column(
      children: [
        _StepIntro(
          title: 'Create your account',
          subtitle: 'Set up your FarmBuzz profile in a few quick steps.',
          isCompact: widget.isCompact,
        ),
        SizedBox(height: widget.isCompact ? 20 : 24),
        CustomTextField(
          controller: widget.nameController,
          hintText: 'Full name (required)',
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
              style: TextStyle(
                color: Colors.white70,
                fontSize: widget.isCompact ? 11 : 12,
              ),
              children: const [
                TextSpan(text: 'I confirm I meet the '),
                TextSpan(
                  text: 'minimum legal age',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(text: ' in my region.'),
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
              style: TextStyle(
                color: Colors.white70,
                fontSize: widget.isCompact ? 11 : 12,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                const TextSpan(
                  text: 'Terms and Privacy Policy.',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: _isLoading ? 'Please wait...' : 'Continue',
          isEnabled: _canSignUp && !_isLoading,
          onPressed: _startRegistration,
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: widget.onLogin,
          child: const Text(
            'I already have an account',
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
        const SizedBox(height: 8),
        _StepIntro(
          title: 'Verify your mobile number',
          subtitle: "We'll send a one-time code to secure your account.",
          isCompact: widget.isCompact,
        ),
        const SizedBox(height: 22),
        MobileInput(
          controller: widget.mobileController,
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: 22),
        ActionButton(
          label: _isLoading ? 'Sending...' : 'Send Code',
          isEnabled: widget.canSendCode && !_isLoading,
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
        ),
        const SizedBox(height: 26),
        OtpInput(onChanged: (value) => setState(() => _otp = value)),
        const SizedBox(height: 18),
        TextButton(
          onPressed: _isLoading ? null : _sendOtp,
          child: const Text(
            'Resend code',
            style: TextStyle(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ActionButton(
          label: _isLoading ? 'Verifying...' : 'Verify',
          isEnabled: _canVerifyOtp && !_isLoading,
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
        ),
        const SizedBox(height: 24),
        PinDots(count: _pin.length),
        const SizedBox(height: 24),
        NumericKeypad(
          onTap: (val) {
            if (!_canEnterPin || _isLoading) {
              return;
            }

            setState(() => _pin += val);
            if (_pin.length == 6) {
              Future.delayed(const Duration(milliseconds: 150), _submitPin);
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
  const _StepsHeader({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const steps = ['PROFILE', 'MOBILE', 'CODE', 'PIN'];

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
                fontSize: 9.5,
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

class _StepIntro extends StatelessWidget {
  const _StepIntro({
    required this.title,
    required this.subtitle,
    required this.isCompact,
  });

  final String title;
  final String subtitle;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSerif(
            fontSize: isCompact ? 20 : 24,
            color: const Color(0xFFEAF7ED),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: isCompact ? 12 : 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
