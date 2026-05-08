import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'common/mobile_input.dart';
import 'common/action_button.dart';

class ForgotPinCard extends StatelessWidget {
  const ForgotPinCard({
    super.key,
    required this.isCompact,
    required this.mobileController,
    required this.canReset,
    required this.onChanged,
    required this.onBack,
  });

  final bool isCompact;
  final TextEditingController mobileController;
  final bool canReset;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;

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
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Reset your PIN',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSerif(
              fontSize: isCompact ? 24 : 28,
              color: const Color(0xFFEAF7ED),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your phone number and we'll send you a recovery code.",
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
          const SizedBox(height: 32),
          ActionButton(
            label: 'Send Reset Code',
            isEnabled: canReset,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
