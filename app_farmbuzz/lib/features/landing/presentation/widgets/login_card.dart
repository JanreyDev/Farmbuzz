import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'common/mobile_input.dart';
import 'common/action_button.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.isCompact,
    required this.mobileController,
    required this.canLogin,
    required this.onChanged,
    required this.onForgotPin,
    required this.onCreateAccount,
    required this.onLogin,
  });

  final bool isCompact;
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
            'Log in',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSerif(
              fontSize: isCompact ? 24 : 28,
              color: const Color(0xFFEAF7ED),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back to the farm.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: isCompact ? 13 : 14,
            ),
          ),
          SizedBox(height: isCompact ? 24 : 32),
          MobileInput(
            controller: mobileController,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onForgotPin,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentGreen,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: const Text(
                'Forgot your PIN?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ActionButton(
            label: 'Log In',
            isEnabled: canLogin,
            onPressed: onLogin,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCreateAccount,
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
        ],
      ),
    );
  }
}
